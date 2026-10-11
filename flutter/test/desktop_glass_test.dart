import 'package:flutter/material.dart';
import 'package:flutter_hbb/mobile/glass/glass.dart';
import 'package:flutter_test/flutter_test.dart';

/// Desktop home-window measurements: the left pane is 268px wide, the ID card
/// has 14px margins and 16/10px padding. A nine-digit ID must fit on one line.
void main() {
  const pane = 268.0;
  const inner = pane - 14 * 2 - 16 - 10;

  // flutter_test renders with the Ahem font (one em per glyph), so measuring
  // text there is meaningless. Use the real digit advance of Roboto/Segoe UI
  // (about 0.62em for bold digits) plus the letter spacing.
  double estimate(String t, double fontSize, double letterSpacing) =>
      t.length * (0.62 * fontSize + letterSpacing);

  test('ID at 24sp w800 fits the 268px left pane', () {
    expect(estimate('494 079 736', 24, 0.8), lessThanOrEqualTo(inner));
    expect(estimate('1 101 633 775', 24, 0.8), lessThanOrEqualTo(inner),
        reason: 'ten digits plus separators is the worst case');
  });

  test('the old 26sp ID did not fit the old 200px pane', () {
    const oldInner = 200.0 - 14 * 2 - 16 - 10;
    expect(estimate('494 079 736', 26, 0.8), greaterThan(oldInner));
  });

  testWidgets('version row stacks the label above the link', (tester) async {
    await tester.binding.setSurfaceSize(const Size(pane, 400));
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: pane,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 6, 16, 10),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
              Text('Версия 1.5.31', style: TextStyle(fontSize: 12)),
              SizedBox(height: 4),
              Text('Проверить обновления', style: TextStyle(fontSize: 12)),
            ]),
          ),
        ),
      ),
    ));
    final a = tester.getRect(find.text('Версия 1.5.31'));
    final b = tester.getRect(find.text('Проверить обновления'));
    expect(a.overlaps(b), isFalse);
    expect(b.right, lessThanOrEqualTo(pane));
    expect(tester.takeException(), isNull);
  });

  testWidgets('glass device tile keeps its text inside at 220x160',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 400));
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 220,
            height: 160,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Column(children: [
                Expanded(
                    child: Container(
                        color: Glass.fill(0.07),
                        child: const Center(
                            child: Text('BROADCAST 2025@home-pc',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: Glass.soft, fontSize: 12))))),
                Container(
                    color: Glass.fill(0.13),
                    padding: const EdgeInsets.all(12),
                    child: const Text('29 530 695')),
              ]),
            ),
          ),
        ),
      ),
    ));
    expect(tester.takeException(), isNull);
    final t = tester.getRect(find.text('BROADCAST 2025@home-pc'));
    expect(t.width, lessThanOrEqualTo(220));
  });
}
