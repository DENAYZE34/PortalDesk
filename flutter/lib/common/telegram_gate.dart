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

/// Polls Telegram once for a `/start <code>` message matching [code]. Does not
/// advance the update offset (so it never consumes an update another device's
/// poll still needs — every device just ignores messages whose code doesn't
/// match its own). Returns true once linked.
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
  final matched = results.any((u) =>
      (u['message']?['text'] as String?)?.trim() == expected);
  if (matched) {
    await _setLinked();
  }
  return matched;
}
