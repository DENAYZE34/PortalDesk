// Mandatory gate shown before [child] (the real home page) until the device is
// linked via telegram_gate.dart. Same screen on desktop/Android/iOS — plain
// black/white styling, not gated behind kNeon, since this runs before the rest
// of the app's theme decisions matter.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'telegram_gate.dart';

class TelegramGateScreen extends StatefulWidget {
  final Widget child;
  const TelegramGateScreen({super.key, required this.child});

  @override
  State<TelegramGateScreen> createState() => _TelegramGateScreenState();
}

class _TelegramGateScreenState extends State<TelegramGateScreen> {
  bool _linked = telegramGateLinked;
  bool _opening = false;
  String _token = genTelegramLinkToken();
  Timer? _pollTimer;
  Timer? _rotateTimer;

  @override
  void initState() {
    super.initState();
    if (!_linked) {
      _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) => _poll());
      // Each token is single-use (consumed the instant it links), but
      // rotating it even while unused keeps a QR code photographed off the
      // screen, or a deep link left open in Telegram, from staying valid
      // indefinitely.
      _rotateTimer =
          Timer.periodic(const Duration(seconds: 60), (_) => _rotate());
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _rotateTimer?.cancel();
    super.dispose();
  }

  void _rotate() {
    if (!mounted || _linked) return;
    setState(() => _token = genTelegramLinkToken());
  }

  Future<void> _poll() async {
    final ok = await pollTelegramLink(_token).catchError((_) => false);
    if (ok && mounted) {
      _pollTimer?.cancel();
      _rotateTimer?.cancel();
      setState(() => _linked = true);
    }
  }

  Future<void> _openTelegram() async {
    if (_opening) return;
    setState(() => _opening = true);
    try {
      final appLink = Uri.parse(telegramAppDeepLink(_token));
      var opened = await launchUrl(appLink,
          mode: LaunchMode.externalApplication);
      if (!opened) {
        final webLink = Uri.parse(telegramWebDeepLink(_token));
        opened =
            await launchUrl(webLink, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      final webLink = Uri.parse(telegramWebDeepLink(_token));
      await launchUrl(webLink, mode: LaunchMode.externalApplication)
          .catchError((_) => false);
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_linked) return widget.child;

    const bg = Color(0xFF050507);
    const fg = Color(0xFFF2F2F2);
    const muted = Color(0xFF9A9A9A);
    const card = Color(0xFF121214);
    const border = Color(0x1AFFFFFF);
    const ok = Color(0xFF34D399);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Подтвердите, что это вы',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: fg, fontSize: 22, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  const Text(
                      'Чтобы защитить PortalDesk от мошенников, один раз '
                      'подтвердите аккаунт через Telegram',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: muted, fontSize: 14, height: 1.4)),
                  const SizedBox(height: 32),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 28),
                    decoration: BoxDecoration(
                      color: card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: border),
                    ),
                    child: Column(children: [
                      Container(
                        width: 56,
                        height: 56,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF229ED9)),
                        child: const Icon(Icons.send_rounded,
                            color: Colors.white, size: 26),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: fg,
                            foregroundColor: bg,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: _opening ? null : _openTelegram,
                          child: Text(
                              _opening ? 'Открываем…' : 'Войти через Telegram',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 15)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                          'Откроется Telegram — нажмите «Запустить», и вход '
                          'в приложение произойдёт сам.',
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(color: muted, fontSize: 12.5, height: 1.4)),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          Expanded(child: Divider(color: border)),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10),
                            child: Text('или отсканируйте',
                                style:
                                    TextStyle(color: muted, fontSize: 12)),
                          ),
                          Expanded(child: Divider(color: border)),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: QrImageView(
                          data: telegramWebDeepLink(_token),
                          version: QrVersions.auto,
                          size: 148,
                          gapless: false,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                          'Наведите камеру телефона на код — он действует 60 секунд.',
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(color: muted, fontSize: 12.5, height: 1.4)),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                              width: 8,
                              height: 8,
                              child: DecoratedBox(
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle, color: ok))),
                          const SizedBox(width: 8),
                          const Text('Ждём подтверждения…',
                              style: TextStyle(color: muted, fontSize: 13)),
                        ],
                      ),
                    ]),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
