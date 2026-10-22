import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

export 'portal_icons.dart';
import 'portal_icons.dart';

import '../../mobile/glass/glass.dart';

/// PortalDesk desktop design system.
///
/// One 8 px grid, one type scale, one radius set, one control height. Every page
/// is built from these pieces so spacing and proportions never drift.

/// Layout and type tokens.
class P {
  // spacing: multiples of 8 (4 for hairline gaps)
  static const double s4 = 4, s8 = 8, s12 = 12, s16 = 16, s20 = 20, s24 = 24, s32 = 32, s48 = 48;
  // page
  static const double pageGutter = 24;
  static const double contentMax = 1120;
  static const double settingsMax = 840;
  // radii
  static const double rCtl = 10, rTile = 16, rCard = 24;
  static const double rPill = 99;
  // controls
  static const double hCtl = 36, hBtn = 40, hInput = 44, hIcon = 40, hIconSm = 32;

  // type: size / line height / weight
  static const TextStyle display = TextStyle(
      color: Glass.text, fontSize: 32, height: 40 / 32, fontWeight: FontWeight.w800, letterSpacing: -0.4);
  static const TextStyle headline = TextStyle(
      color: Glass.text, fontSize: 24, height: 32 / 24, fontWeight: FontWeight.w800, letterSpacing: -0.2);
  static const TextStyle title = TextStyle(
      color: Glass.text, fontSize: 16, height: 22 / 16, fontWeight: FontWeight.w700);
  static const TextStyle body = TextStyle(
      color: Glass.text, fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w400);
  static const TextStyle bodyStrong = TextStyle(
      color: Glass.text, fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w600);
  static const TextStyle caption = TextStyle(
      color: Glass.soft, fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w400);
  static const TextStyle overline = TextStyle(
      color: Glass.muted, fontSize: 11, height: 16 / 11, fontWeight: FontWeight.w600, letterSpacing: 1.2);

  /// The ID: tabular figures so digits do not jitter.
  static const TextStyle id = TextStyle(
      color: Glass.text,
      fontSize: 28,
      height: 36 / 28,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.6,
      fontFeatures: [FontFeature.tabularFigures()]);
}

/// The real PortalDesk logo (the neon P app icon).
class PortalLogo extends StatelessWidget {
  final double size;
  const PortalLogo({super.key, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.26),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.45),
              blurRadius: size * 0.45,
              spreadRadius: -size * 0.12),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.26),
        child: Image.asset('assets/portal_logo.png',
            width: size, height: size, fit: BoxFit.cover, filterQuality: FilterQuality.high),
      ),
    );
  }
}

/// Status line: dot + text.
class PortalStatus extends StatelessWidget {
  final String text;
  final Color color;
  const PortalStatus({super.key, required this.text, this.color = Glass.ok});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      StatusDot(color: color),
      const SizedBox(width: P.s8),
      Text(text, style: P.caption),
    ]);
  }
}

/// 40 px round icon button with a tooltip.
class PortalIconButton extends StatelessWidget {
  final Object icon;
  final String tip;
  final VoidCallback? onTap;
  final Color? color;
  final bool primary;
  final double size;
  const PortalIconButton(
      {super.key,
      required this.icon,
      required this.tip,
      this.onTap,
      this.color,
      this.primary = false,
      this.size = P.hIcon});

  @override
  Widget build(BuildContext context) {
    final glyph = PortalGlyph(icon,
        size: size * 0.5, color: primary ? Colors.black : (color ?? Glass.soft));
    final deco = primary
        ? BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 14, offset: const Offset(0, 6)),
            ],
          )
        : BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white.withOpacity(0.14), Colors.white.withOpacity(0.03)],
            ),
            border: Border.all(color: Glass.edge(0.14)),
            boxShadow: [
              BoxShadow(color: Colors.white.withOpacity(0.2), blurRadius: 0, offset: const Offset(0, 1)),
              BoxShadow(color: Colors.black.withOpacity(0.45), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          );
    return Tooltip(
      message: tip,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Container(
            width: size,
            height: size,
            decoration: deco,
            alignment: Alignment.center,
            child: glyph,
          ),
        ),
      ),
    );
  }
}

/// A square 3D bevel tile for a glyph (app-icon style), light or dark variant.
class PortalTile3D extends StatelessWidget {
  final Object icon;
  final double size;
  final double radius;
  final bool dark;
  const PortalTile3D(this.icon,
      {super.key, this.size = P.hIcon, this.radius = P.rCtl, this.dark = true});

  @override
  Widget build(BuildContext context) {
    final gradient = dark
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF3A3A3E), Color(0xFF0A0A0B)],
          )
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFCFCFD), Color(0xFFB7B7BD)],
          );
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: gradient,
        boxShadow: [
          BoxShadow(
              color: dark ? Colors.black.withOpacity(0.08) : Colors.white.withOpacity(0.9),
              blurRadius: 0,
              offset: const Offset(0, 1)),
          BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 16, offset: const Offset(0, 8)),
        ],
      ),
      child: PortalGlyph(icon, size: size * 0.42, color: dark ? Colors.white.withOpacity(0.92) : Colors.black.withOpacity(0.78)),
    );
  }
}

/// A titled glass panel that groups related settings.
class PortalSection extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Object? icon;
  final List<Widget> children;
  final List<Widget>? trailing;
  const PortalSection(
      {super.key,
      required this.title,
      required this.children,
      this.subtitle,
      this.icon,
      this.trailing});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: P.rCard,
      strength: 1.1,
      liquid: true,
      padding: const EdgeInsets.fromLTRB(P.s20, P.s16, P.s20, P.s4),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          if (icon != null) ...[
            PortalTile3D(icon!, size: 34, radius: P.rCtl, dark: true),
            const SizedBox(width: P.s16),
          ],
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: P.title),
              if (subtitle != null) Text(subtitle!, style: P.caption.copyWith(color: Glass.muted)),
            ]),
          ),
          ...?trailing,
        ]),
        const SizedBox(height: P.s16),
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) Divider(height: 1, thickness: 1, color: Colors.white.withOpacity(0.07)),
          children[i],
        ],
      ]),
    );
  }
}

/// One setting row: label (and hint) left, control right. 56 px minimum.
class PortalRow extends StatelessWidget {
  final String label;
  final String? hint;
  final Widget trailing;
  final VoidCallback? onTap;
  final bool enabled;
  const PortalRow(
      {super.key,
      required this.label,
      required this.trailing,
      this.hint,
      this.onTap,
      this.enabled = true});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(P.rCtl),
      onTap: enabled ? onTap : null,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: P.s8),
          child: Row(children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(label, style: P.body.copyWith(color: enabled ? Glass.text : Glass.muted)),
                    if (hint != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(hint!, style: P.caption.copyWith(color: Glass.muted)),
                      ),
                  ]),
            ),
            const SizedBox(width: P.s16),
            trailing,
          ]),
        ),
      ),
    );
  }
}

class PortalSwitchRow extends StatelessWidget {
  final String label;
  final String? hint;
  final bool value;
  final ValueChanged<bool>? onChanged;
  const PortalSwitchRow(
      {super.key, required this.label, required this.value, this.onChanged, this.hint});

  @override
  Widget build(BuildContext context) {
    return PortalRow(
      label: label,
      hint: hint,
      enabled: onChanged != null,
      onTap: onChanged == null ? null : () => onChanged!(!value),
      trailing: PortalSwitch(value: value, enabled: onChanged != null),
    );
  }
}

/// 44 x 24 switch.
class PortalSwitch extends StatelessWidget {
  final bool value;
  final bool enabled;
  const PortalSwitch({super.key, required this.value, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      width: 44,
      height: 24,
      padding: const EdgeInsets.all(3),
      alignment: value ? Alignment.centerRight : Alignment.centerLeft,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(P.rPill),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: value
              ? [
                  Colors.white.withOpacity(enabled ? 1 : 0.45),
                  Colors.white.withOpacity(enabled ? 0.78 : 0.35),
                ]
              : [
                  Colors.white.withOpacity(enabled ? 0.22 : 0.09),
                  Colors.white.withOpacity(enabled ? 0.08 : 0.04),
                ],
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.45),
              blurRadius: 6,
              offset: const Offset(0, -1)),
          if (value)
            BoxShadow(
                color: Colors.white.withOpacity(0.18),
                blurRadius: 0,
                offset: const Offset(0, 1)),
        ],
      ),
      child: Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: value
                ? [
                    Colors.black.withOpacity(enabled ? 0.92 : 0.5),
                    Colors.black.withOpacity(enabled ? 1 : 0.6),
                  ]
                : [
                    Colors.white.withOpacity(enabled ? 1 : 0.6),
                    Color.lerp(Colors.white, Colors.black, 0.12)!
                        .withOpacity(enabled ? 1 : 0.6),
                  ],
          ),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 4,
                offset: const Offset(0, 2)),
          ],
        ),
      ),
    );
  }
}

/// Mutually exclusive options as pills (segmented control).
class PortalChoiceRow<T> extends StatelessWidget {
  final String? label;
  final List<(T, String)> options;
  final T value;
  final ValueChanged<T>? onChanged;
  const PortalChoiceRow(
      {super.key, required this.options, required this.value, this.onChanged, this.label});

  @override
  Widget build(BuildContext context) {
    final pills = Wrap(spacing: P.s8, runSpacing: P.s8, children: [
      for (final o in options)
        _Pill(
            text: o.$2,
            selected: o.$1 == value,
            onTap: onChanged == null ? null : () => onChanged!(o.$1)),
    ]);
    if (label == null) {
      return Padding(padding: const EdgeInsets.symmetric(vertical: P.s12), child: pills);
    }
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 48),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: P.s8),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Expanded(child: Text(label!, style: P.body)),
          const SizedBox(width: P.s16),
          Flexible(child: Align(alignment: Alignment.centerRight, child: pills)),
        ]),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback? onTap;
  const _Pill({required this.text, required this.selected, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: P.s16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(P.rPill),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: selected
                ? [Colors.white, const Color(0xFFDFDFE3)]
                : [Colors.white.withOpacity(0.12), Colors.white.withOpacity(0.03)],
          ),
          border: Border.all(color: selected ? Colors.white : Glass.edge(0.14)),
          boxShadow: selected
              ? [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.45),
                      blurRadius: 14,
                      offset: const Offset(0, 6)),
                ]
              : [
                  BoxShadow(
                      color: Colors.white.withOpacity(0.2),
                      blurRadius: 0,
                      offset: const Offset(0, 1)),
                  BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3)),
                ],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(text,
              style: P.caption.copyWith(
                  fontSize: 13,
                  color: selected ? Colors.black : Glass.soft,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500)),
        ]),
      ),
    );
  }
}

/// Buttons: primary (white pill), secondary (glass pill). Height 40 or 48.
class PortalButton extends StatelessWidget {
  final String label;
  final Object? icon;
  final VoidCallback? onPressed;
  final bool primary;
  final bool large;
  final bool destructive;
  const PortalButton(
      {super.key,
      required this.label,
      this.icon,
      this.onPressed,
      this.primary = false,
      this.large = false,
      this.destructive = false});

  @override
  Widget build(BuildContext context) {
    final h = large ? P.hBtn : P.hCtl;
    final enabled = onPressed != null;
    final fg = primary ? Colors.black : (enabled ? Glass.text : Glass.muted);
    final shape = const StadiumBorder();

    Widget fill;
    List<BoxShadow>? outerShadow;
    if (!enabled) {
      fill = DecoratedBox(
        decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(P.rPill),
            color: Colors.white.withOpacity(0.04)),
      );
    } else if (primary) {
      fill = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(P.rPill),
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.white, blurRadius: 0, offset: const Offset(0, 1)),
          ],
        ),
      );
      outerShadow = [
        BoxShadow(color: Colors.black.withOpacity(0.55), blurRadius: 20, offset: const Offset(0, 10)),
        BoxShadow(color: Colors.black.withOpacity(0.35), blurRadius: 6, offset: const Offset(0, 2)),
      ];
    } else {
      final tint = destructive ? Glass.bad : Colors.white;
      fill = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(P.rPill),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [tint.withOpacity(destructive ? 0.22 : 0.14), tint.withOpacity(destructive ? 0.08 : 0.04)],
          ),
          border: Border.all(color: tint.withOpacity(destructive ? 0.4 : 0.16)),
          boxShadow: [
            BoxShadow(color: Colors.white.withOpacity(0.22), blurRadius: 0, offset: const Offset(0, 1)),
          ],
        ),
      );
      outerShadow = [
        BoxShadow(
            color: (destructive ? Glass.bad : Colors.black).withOpacity(destructive ? 0.35 : 0.5),
            blurRadius: 18,
            offset: const Offset(0, 8)),
      ];
    }

    Widget btn = DecoratedBox(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(P.rPill), boxShadow: outerShadow),
      child: Stack(children: [
        Positioned.fill(child: fill),
        Material(
          color: Colors.transparent,
          shape: shape,
          child: InkWell(
            customBorder: shape,
            onTap: onPressed,
            child: SizedBox(
              height: h,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: large ? P.s24 : P.s16),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  if (icon != null) ...[
                    PortalGlyph(icon, size: 18, color: fg),
                    const SizedBox(width: P.s8)
                  ],
                  Text(label,
                      style: P.bodyStrong.copyWith(color: fg, fontSize: large ? 15 : 14)),
                ]),
              ),
            ),
          ),
        ),
      ]),
    );
    return btn;
  }
}

/// 48 px glass text field.
class PortalInput extends StatelessWidget {
  final TextEditingController? controller;
  final String? hint;
  final Object? icon;
  final bool obscure;
  final TextStyle? style;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final List<TextInputFormatter>? formatters;
  final double height;
  const PortalInput(
      {super.key,
      this.controller,
      this.hint,
      this.icon,
      this.obscure = false,
      this.style,
      this.onChanged,
      this.onSubmitted,
      this.formatters,
      this.height = P.hInput});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: P.s16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(P.rPill),
        border: Border.all(color: Glass.edge(0.16)),
      ),
      child: Row(children: [
        if (icon != null) ...[PortalGlyph(icon, size: 20, color: Glass.soft), const SizedBox(width: P.s12)],
        Expanded(
          child: TextField(
            controller: controller,
            obscureText: obscure,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            inputFormatters: formatters,
            cursorColor: Colors.white,
            style: style ?? P.body.copyWith(fontSize: 15),
            decoration: InputDecoration(
              isCollapsed: true,
              border: InputBorder.none,
              hintText: hint,
              hintStyle: P.body.copyWith(fontSize: 15, color: Glass.muted),
            ),
          ),
        ),
      ]),
    );
  }
}

/// Label left, value right (About page, read-only facts).
class PortalInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool selectable;
  const PortalInfoRow({super.key, required this.label, required this.value, this.selectable = true});

  @override
  Widget build(BuildContext context) {
    final v = Text(value,
        textAlign: TextAlign.right,
        style: P.body.copyWith(color: Glass.soft, fontFeatures: const [FontFeature.tabularFigures()]));
    return PortalRow(label: label, trailing: Flexible(child: selectable ? SelectionArea(child: v) : v));
  }
}

class PortalNavItem {
  final String label;
  final Object icon;
  const PortalNavItem(this.label, this.icon);
}

/// Pill navigation for the settings window.
class PortalTopNav extends StatelessWidget {
  final List<PortalNavItem> items;
  final int index;
  final ValueChanged<int> onChanged;
  const PortalTopNav({super.key, required this.items, required this.index, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: GlassCard(
        radius: P.rPill,
        padding: const EdgeInsets.all(P.s4),
        strength: 1.15,
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          for (var i = 0; i < items.length; i++)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onChanged(i),
              child: Tooltip(message: items[i].label, child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                height: 36,
                padding: EdgeInsets.symmetric(horizontal: items.length <= 4 || i == index ? P.s16 : P.s12),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(P.rPill),
                    color: i == index ? Colors.white.withOpacity(0.2) : Colors.transparent),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  PortalGlyph(items[i].icon, size: 18, color: i == index ? Colors.white : Glass.soft),
                  if (items.length <= 4 || i == index) const SizedBox(width: P.s8),
                  if (items.length <= 4 || i == index)
                  Text(items[i].label,
                      style: P.bodyStrong.copyWith(
                          fontSize: 13,
                          color: i == index ? Colors.white : Glass.soft,
                          fontWeight: i == index ? FontWeight.w700 : FontWeight.w500)),
                ]),
              )),
            ),
        ]),
      ),
    );
  }
}

/// Vertical sidebar navigation for the settings window (macOS System
/// Settings / VS Code style): icon + label rows, stacked, instead of a row
/// of icon pills. One item per row, 44px tall, full-width highlight on the
/// selected row.
class PortalSideNav extends StatelessWidget {
  final List<PortalNavItem> items;
  final int index;
  final ValueChanged<int> onChanged;
  final double width;
  const PortalSideNav(
      {super.key,
      required this.items,
      required this.index,
      required this.onChanged,
      this.width = 208});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: GlassCard(
        radius: P.rCard,
        liquid: true,
        padding: const EdgeInsets.all(P.s8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          for (var i = 0; i < items.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(P.rCtl),
                  onTap: () => onChanged(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: P.s12),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(P.rCtl),
                        color: i == index ? Colors.white : Colors.transparent),
                    child: Row(children: [
                      PortalGlyph(items[i].icon,
                          size: 18, color: i == index ? Colors.black : Glass.soft),
                      const SizedBox(width: P.s12),
                      Expanded(
                        child: Text(items[i].label,
                            overflow: TextOverflow.ellipsis,
                            style: P.bodyStrong.copyWith(
                                fontSize: 14,
                                color: i == index ? Colors.black : Glass.soft,
                                fontWeight:
                                    i == index ? FontWeight.w700 : FontWeight.w500)),
                      ),
                    ]),
                  ),
                ),
              ),
            ),
        ]),
      ),
    );
  }
}

/// A device tile (recent connections).
class PortalDeviceTile extends StatelessWidget {
  final String name;
  final String id;
  final String platform;
  final bool online;
  final VoidCallback? onTap;
  final Widget? trailing;
  const PortalDeviceTile(
      {super.key,
      required this.name,
      required this.id,
      required this.platform,
      required this.online,
      this.onTap,
      this.trailing});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: P.rTile,
      onTap: onTap,
      liquid: true,
      padding: const EdgeInsets.all(P.s16),
      child: SizedBox(
        width: 232,
        child: Row(children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(P.rCtl + 2), color: Colors.white.withOpacity(0.1)),
            child: const PortalGlyph('monitor', color: Colors.white, size: 24),
          ),
          const SizedBox(width: P.s16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: P.bodyStrong),
              Text(id, style: P.caption.copyWith(fontFeatures: const [FontFeature.tabularFigures()])),
              const SizedBox(height: P.s4),
              PortalStatus(text: online ? '$platform · в сети' : '$platform · не в сети', color: online ? Glass.ok : Glass.muted),
            ]),
          ),
          if (trailing != null) trailing!,
        ]),
      ),
    );
  }
}

/// Desktop-only near-black "liquid glass" background: a near-black base with
/// two faint accent glows (not the phone's strong violet aurora wash — a
/// mouse-driven, denser desktop UI reads better with the background staying
/// out of the way). Does not touch the shared mobile `AuroraBackground`.
class DesktopAuroraBackground extends StatelessWidget {
  final Widget child;
  const DesktopAuroraBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      // Opaque base FIRST, as its own layer: a BoxDecoration with both
      // `color` and `gradient` set silently drops `color` and uses only the
      // gradient, which fades to fully transparent at the edges — on a
      // transparent native window (`backgroundColor: Colors.transparent` in
      // main.dart's WindowOptions) that let the real desktop show through.
      const Positioned.fill(
        child: IgnorePointer(
          child: ColoredBox(color: Color(0xFF050507)),
        ),
      ),
      Positioned.fill(child: child),
    ]);
  }
}

/// Brand mark used in headers and cards.
class PortalRing extends StatelessWidget {
  final double size;
  const PortalRing({super.key, this.size = 40});

  @override
  Widget build(BuildContext context) => PortalLogo(size: size);
}
