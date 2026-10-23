// Mandatory gate shown before [child] (the real home page) until the device is
// linked via telegram_gate.dart. Same screen on desktop/Android/iOS — plain
// black/white styling, not gated behind kNeon, since this runs before the rest
// of the app's theme decisions matter.
import 'dart:async';

import 'package:flutter/material.dart';
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
  late final String _code = genTelegramLinkCode();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (!_linked) {
      _timer = Timer.periodic(const Duration(seconds: 3), (_) => _poll());
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _poll() async {
    final ok = await pollTelegramLink(_code).catchError((_) => false);
    if (ok && mounted) {
      _timer?.cancel();
      setState(() => _linked = true);
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 28),
                    decoration: BoxDecoration(
                      color: card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: border),
                    ),
                    child: Column(children: [
                      _step('1',
                          'Откройте Telegram и начните чат с ботом @PortalDeskVerify_bot'),
                      const SizedBox(height: 14),
                      _step('2', 'Отправьте боту этот код:'),
                      const SizedBox(height: 18),
                      SelectableText(
                        '${_code.substring(0, 3)} ${_code.substring(3)}',
                        style: const TextStyle(
                            color: fg,
                            fontSize: 40,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 4,
                            fontFeatures: [FontFeature.tabularFigures()]),
                      ),
                      const SizedBox(height: 4),
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
                          onPressed: () => launchUrl(
                              Uri.parse(telegramDeepLink(_code)),
                              mode: LaunchMode.externalApplication),
                          child: const Text('Открыть Telegram',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 15)),
                        ),
                      ),
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

  Widget _step(String n, String text) {
    const fg = Color(0xFFF2F2F2);
    const bg = Color(0xFF050507);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: const BoxDecoration(shape: BoxShape.circle, color: fg),
          child: Text(n,
              style: const TextStyle(
                  color: bg, fontSize: 12, fontWeight: FontWeight.w800)),
        ),
        const SizedBox(width: 12),
        Expanded(
            child: Text(text,
                textAlign: TextAlign.left,
                style: const TextStyle(color: fg, fontSize: 14, height: 1.5))),
      ],
    );
  }
}
