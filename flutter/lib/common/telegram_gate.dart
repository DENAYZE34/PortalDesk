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

String genTelegramLinkCode() {
  final code = 100000 + Random.secure().nextInt(900000);
  return code.toString();
}

String telegramDeepLink(String code) =>
    'https://t.me/$_kBotUsername?start=$code';

// Telegram's own "Start" button (when the chat was opened without our
// ?start=<code> deep link, or on an older client that strips the payload)
// sends a bare "/start" with no code. Without this, the owner taps Start
// and nothing visibly happens — remembered across polls so the same bare
// /start isn't replied to every 3s tick (we never advance the Telegram
// update offset, so the same update keeps coming back until something
// else acks it).
final Set<String> _repliedToBareStart = {};

/// Polls Telegram once for a message in the gate's chat. Does not advance
/// the update offset (so it never consumes an update another device's poll
/// still needs — every device just ignores messages whose code doesn't
/// match its own). Three outcomes:
/// - `/start <code>` matching [code]: links, sends a confirmation, returns
///   true.
/// - bare `/start` (Telegram's own button with no deep-link payload):
///   replies once with the current code as copyable text, keeps waiting.
/// - anything else: ignored.
Future<bool> pollTelegramLink(String code) async {
  if (_kBotToken.isEmpty) return false;
  final url =
      Uri.parse('https://api.telegram.org/bot$_kBotToken/getUpdates');
  final resp = await http.get(url).timeout(const Duration(seconds: 10));
  if (resp.statusCode != 200) return false;
  final body = jsonDecode(resp.body) as Map<String, dynamic>;
  if (body['ok'] != true) return false;
  final results = body['result'] as List<dynamic>? ?? [];
  final expected = '/start $code';

  for (final u in results) {
    final msg = u['message'] as Map<String, dynamic>?;
    final text = (msg?['text'] as String?)?.trim();
    final chatId = msg?['chat']?['id'];
    if (msg == null || text == null || chatId == null) continue;

    if (text == expected || text == code) {
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
            '🔒 Код входа в PortalDesk\n\n$code\n\n'
            'Нажмите на цифры, чтобы скопировать, и отправьте их '
            'отдельным сообщением сюда же. Код действует 1 минуту.');
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
