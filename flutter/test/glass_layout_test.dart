import 'package:flutter/material.dart';
import 'package:flutter_hbb/mobile/glass/glass.dart';
import 'package:flutter_test/flutter_test.dart';

/// Layout guards for the glass design system. They exist because a nav chip
/// once turned the floating pill into a full-screen slab: every shape the
/// design relies on must stay inside its box at phone widths and at the
/// largest supported system font.
const _items = [
  GlassNavItem('Устройства', Icons.devices_rounded),
  GlassNavItem('Телефон', Icons.screen_share_rounded),
  GlassNavItem('Настройки', Icons.tune_rounded),
];

Widget _host(Widget child, {double width = 360, double height = 780, double scale = 1.0}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MediaQuery(
      data: MediaQueryData(
          size: Size(width, height), textScaler: TextScaler.linear(scale)),
      child: Scaffold(
        body: SizedBox(
          width: width,
          height: height,
          child: AuroraBackground(
            child: Align(alignment: Alignment.bottomCenter, child: child),
          ),
        ),
      ),
    ),
  );
}

void main() {
  for (final w in [320.0, 360.0, 412.0]) {
    for (final scale in [1.0, 1.3]) {
      testWidgets('nav pill stays a pill at ${w.toInt()}dp, font x$scale',
          (tester) async {
        await tester.binding.setSurfaceSize(Size(w, 780));
        await tester.pumpWidget(_host(
            GlassNavBar(items: _items, index: 0, onChanged: (_) {}),
            width: w,
            scale: scale));
        await tester.pump(const Duration(milliseconds: 400));
        final size = tester.getSize(find.byType(GlassNavBar));
        expect(size.height, lessThan(110),
            reason: 'the pill must not grow into a slab');
        expect(size.width, lessThanOrEqualTo(w));
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('every nav chip is a 48dp touch target', (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 780));
    await tester.pumpWidget(_host(
        GlassNavBar(items: _items, index: 1, onChanged: (_) {})));
    await tester.pump(const Duration(milliseconds: 400));
    for (final icon in [
      Icons.devices_rounded,
      Icons.screen_share_rounded,
      Icons.tune_rounded
    ]) {
      final chip = find.ancestor(
          of: find.byIcon(icon), matching: find.byType(AnimatedContainer));
      final s = tester.getSize(chip.first);
      expect(s.height, greaterThanOrEqualTo(48), reason: '$icon height');
      expect(s.width, greaterThanOrEqualTo(48), reason: '$icon width');
    }
  });

  testWidgets('nav reports taps for each chip', (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 780));
    final taps = <int>[];
    await tester.pumpWidget(_host(
        GlassNavBar(items: _items, index: 0, onChanged: taps.add)));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.byIcon(Icons.screen_share_rounded));
    await tester.tap(find.byIcon(Icons.tune_rounded));
    expect(taps, [1, 2]);
  });

  testWidgets('dock with six tools fits a 320dp phone', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 780));
    await tester.pumpWidget(_host(
        GlassDock(items: [
          for (final i in [
            Icons.keyboard_rounded,
            Icons.mic_rounded,
            Icons.touch_app_rounded,
            Icons.zoom_in_rounded,
            Icons.crop_rounded,
            Icons.close_rounded,
          ])
            GlassDockItem(i, 'tool')
        ]),
        width: 320));
    await tester.pump();
    expect(tester.getSize(find.byType(GlassDock)).width, lessThanOrEqualTo(320));
    expect(tester.takeException(), isNull);
  });

  testWidgets('long Russian permission text wraps without overflow',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 780));
    await tester.pumpWidget(_host(
        GlassCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
            Text('Управление с другого устройства',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            Text('Специальные возможности → PortalDesk → включить'),
          ]),
        ),
        width: 320,
        scale: 1.3));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('a 95-character fingerprint wraps under its title, not beside it',
      (tester) async {
    const fp =
        'fb9b 8f70 1f48 055a ab3a 8dc3 5bf4 f3f2 a64b 8f10 77b0 6e72 d3ff 2e5c 9a41 03aa';
    await tester.binding.setSurfaceSize(const Size(360, 780));
    await tester.pumpWidget(_host(
        GlassCard(
          child: Row(children: [
            const Icon(Icons.fingerprint),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text('Отпечаток'),
                    Text(fp, style: TextStyle(fontSize: 12.5)),
                  ]),
            ),
          ]),
        ),
        scale: 1.3));
    await tester.pump();
    expect(tester.takeException(), isNull);
    final title = tester.getSize(find.text('Отпечаток'));
    expect(title.height, lessThan(40), reason: 'title must stay on one line');
    final value = tester.getSize(find.text(fp));
    expect(value.width, lessThanOrEqualTo(360));
  });

  testWidgets('primary button text is dark on white (readable)',
      (tester) async {
    await tester.pumpWidget(_host(
        GlassButton(label: 'Подключиться', onPressed: () {})));
    final text = tester.widget<Text>(find.text('Подключиться'));
    final c = text.style!.color!;
    expect(c.computeLuminance(), lessThan(0.05));
  });

  test('glass palette keeps text readable on the base colour', () {
    double ratio(Color a, Color b) {
      final la = a.computeLuminance(), lb = b.computeLuminance();
      final hi = la > lb ? la : lb, lo = la > lb ? lb : la;
      return (hi + 0.05) / (lo + 0.05);
    }

    expect(ratio(Glass.text, Glass.base), greaterThan(12));
    expect(ratio(Glass.soft, Glass.base), greaterThan(7));
    expect(ratio(Glass.muted, Glass.base), greaterThan(4.5));
  });
}
