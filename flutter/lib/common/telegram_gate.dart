// Mandatory Telegram identity-verification gate, shown once on first run before
// the normal home/connection screen. Pure Dart (no Rust/FFI changes): uses the
// app's own shipped bot (@PortalDeskVerify_bot, token baked in at build time via
// --dart-define=PORTAL_VERIFY_BOT_TOKEN=..., same pattern as PORTAL_DG_SECRET in
// update_check.dart) to confirm a human with Telegram access completed the link.
// Storage reuses the existing mainGetLocalOption/mainSetLocalOption bridge calls
// (common.dart:1716/1720) — no new config key registration needed, same as how
// auth_2fa.rs's "2fa"/"bot" options work on the Rust side.
import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

import '../models/platform_model.dart';

const String _kBotToken = String.fromEnvironment('PORTAL_VERIFY_BOT_TOKEN');
const String _kBotUsername = 'PortalDeskVerify_bot';
const String _kLocalOptionKey = 'telegram-gate-linked';

bool get telegramGateLinked => bind.mainGetLocalOption(key: _kLocalOptionKey) == 'Y';

Future<void> _setLinked() async {
  await bind.mainSetLocalOption(key: _kLocalOptionKey, value: 'Y');
}

Future<void> telegramGateUnlink() async {
  await bind.mainSetLocalOption(key: _kLocalOptionKey, value: '');
}

/// A per-session secret token, never shown to the user. It rides as the
/// `start` payload of the deep link so the one tap that opens Telegram and
/// the one tap on Telegram's own "START" button are the entire login flow —
/// there is nothing to type or copy.
String genTelegramLinkToken() {
  final rand = Random.secure();
  return List.generate(24, (_) => rand.nextInt(16).toRadixString(16)).join();
}

/// `tg://` resolves straight to the Telegram app and, unlike `https://t.me`,
/// isn't a web link another installed app can register itself as a handler
/// for (observed in testing: a third-party app intercepted the `t.me` link
/// before Telegram did). Tried first; [telegramWebDeepLink] is the fallback
/// for platforms without a registered `tg://` handler (e.g. some desktops).
String telegramAppDeepLink(String token) =>
    'tg://resolve?domain=$_kBotUsername&start=$token';

String telegramWebDeepLink(String token) =>
    'https://t.me/$_kBotUsername?start=$token';

// Telegram's own "Start" button only appears when the chat was opened via
// our ?start=<token> deep link, so a bare "/start" here means the user
// opened the bot chat some other way (search, old history). There is no
// token to correlate it to a waiting app, so it can't auto-link — just
// point them back to the app. Remembered across polls so the same bare
// /start isn't replied to every 3s tick (we never advance the Telegram
// update offset, so the same update keeps coming back until something else
// acks it).
final Set<String> _repliedToBareStart = {};

/// Polls Telegram once for a message in the gate's chat. Does not advance
/// the update offset (so it never consumes an update another device's poll
/// still needs — every device just ignores messages whose token doesn't
/// match its own). Two outcomes:
/// - `/start <token>` matching [token]: links, sends a confirmation, returns
///   true.
/// - bare `/start`: replies once pointing back to the app, keeps waiting.
Future<bool> pollTelegramLink(String token) async {
  if (_kBotToken.isEmpty) return false;
  final url =
      Uri.parse('https://api.telegram.org/bot$_kBotToken/getUpdates');
  final resp = await http.get(url).timeout(const Duration(seconds: 10));
  if (resp.statusCode != 200) return false;
  final body = jsonDecode(resp.body) as Map<String, dynamic>;
  if (body['ok'] != true) return false;
  final results = body['result'] as List<dynamic>? ?? [];
  final expected = '/start $token';

  for (final u in results) {
    final msg = u['message'] as Map<String, dynamic>?;
    final text = (msg?['text'] as String?)?.trim();
    final chatId = msg?['chat']?['id'];
    if (msg == null || text == null || chatId == null) continue;

    if (text == expected) {
      await _setLinked();
      await _sendMessage(chatId.toString(),
          '✅ Подтверждено. Можно возвращаться в приложение PortalDesk.');
      return true;
    }

    if (text == '/start') {
      final updateId = u['update_id']?.toString();
      if (updateId != null && _repliedToBareStart.add(updateId)) {
        await _sendMessage(
            chatId.toString(),
            '🔒 Это вход в PortalDesk.\n\n'
            'Откройте приложение PortalDesk на устройстве и нажмите '
            '«Войти через Telegram» — подтверждение пройдёт автоматически.');
      }
    }
  }
  return false;
}

Future<void> _sendMessage(String chatId, String text) async {
  final url =
      Uri.parse('https://api.telegram.org/bot$_kBotToken/sendMessage');
  try {
    await http.post(url, body: {'chat_id': chatId, 'text': text}).timeout(
        const Duration(seconds: 10));
  } catch (_) {
    // Best-effort: a failed reply never blocks the gate itself.
  }
}
