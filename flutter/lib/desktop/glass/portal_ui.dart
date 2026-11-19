import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

export 'portal_icons.dart';
import 'portal_icons.dart';

import '../../mobile/glass/glass.dart';

/// PortalDesk desktop design system.
///
/// One 4 px grid, one type scale, one radius set, one control height. Every
/// page is built from these pieces so spacing and proportions never drift.
/// Surfaces are flat graphite with hairline borders; there is no glow, blur or
/// gradient anywhere in this file.

/// Layout and type tokens.
class P {
  // spacing: multiples of 4
  static const double s4 = 4, s8 = 8, s12 = 12, s16 = 16, s20 = 20, s24 = 24, s32 = 32, s48 = 48;
  // page
  static const double pageGutter = 24;
  static const double contentMax = 1120;
  static const double settingsMax = 840;
  // radii: control 10, tile 12, card 16
  static const double rCtl = 10, rTile = 12, rCard = 16;
  static const double rPill = 99;
  // controls
  static const double hCtl = 36, hBtn = 40, hInput = 44, hIcon = 40, hIconSm = 32;

  // type: size / line height / weight (400 and 500 only)
  static const TextStyle display = TextStyle(
      color: Glass.text, fontSize: 32, height: 40 / 32, fontWeight: FontWeight.w500, letterSpacing: -0.4);
  static const TextStyle headline = TextStyle(
      color: Glass.text, fontSize: 24, height: 32 / 24, fontWeight: FontWeight.w500, letterSpacing: -0.2);
  static const TextStyle title = TextStyle(
      color: Glass.text, fontSize: 16, height: 22 / 16, fontWeight: FontWeight.w500);
  static const TextStyle body = TextStyle(
      color: Glass.text, fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w400);
  static const TextStyle bodyStrong = TextStyle(
      color: Glass.text, fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w500);
  static const TextStyle caption = TextStyle(
      color: Glass.soft, fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w400);
  static const TextStyle overline = TextStyle(
      color: Glass.muted, fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w500);

  /// The ID: tabular figures so digits do not jitter.
  static const TextStyle id = TextStyle(
      color: Glass.text,
      fontSize: 28,
      height: 36 / 28,
      fontWeight: FontWeight.w500,
      fontFeatures: [FontFeature.tabularFigures()]);
}

/// The PortalDesk logo.
class PortalLogo extends StatelessWidget {
  final double size;
  const PortalLogo({super.key, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.26),
      child: Image.asset('assets/portal_logo.png',
          width: size, height: size, fit: BoxFit.cover, filterQuality: FilterQuality.high),
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

/// Round icon button with a tooltip.
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
        size: size * 0.5, color: primary ? Glass.base : (color ?? Glass.soft));
    return Tooltip(
      message: tip,
      child: Material(
        color: primary ? Glass.text : Glass.raised,
        shape: CircleBorder(side: primary ? BorderSide.none : BorderSide(color: Glass.edge())),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(width: size, height: size, child: Center(child: glyph)),
        ),
      ),
    );
  }
}

/// A square tile for a glyph, light or dark variant.
class PortalTile3D extends StatelessWidget {
  final Object icon;
  final double size;
  final double radius;
  final bool dark;
  const PortalTile3D(this.icon,
      {super.key, this.size = P.hIcon, this.radius = P.rCtl, this.dark = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        color: dark ? Glass.raised : Glass.text,
        border: dark ? Border.all(color: Glass.edge()) : null,
      ),
      child: PortalGlyph(icon, size: size * 0.42, color: dark ? Glass.text : Glass.base),
    );
  }
}

/// A titled panel that groups related settings.
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
      padding: const EdgeInsets.fromLTRB(P.s20, P.s16, P.s20, P.s4),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          if (icon != null) ...[
            PortalTile3D(icon!, size: 32, radius: P.rCtl, dark: true),
            const SizedBox(width: P.s12),
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
          if (i > 0) Divider(height: 1, thickness: 1, color: Glass.edge()),
          children[i],
        ],
      ]),
    );
  }
}

/// One setting row: label (and hint) left, control right. 48 px minimum.
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
      duration: const Duration(milliseconds: 160),
      curve: Cubic(0.22, 1, 0.36, 1),
      width: 44,
      height: 24,
      padding: const EdgeInsets.all(3),
      alignment: value ? Alignment.centerRight : Alignment.centerLeft,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(P.rPill),
        color: value ? Glass.text.withOpacity(enabled ? 1 : 0.4) : Glass.raised,
        border: value ? null : Border.all(color: Glass.edge(0.14)),
      ),
      child: Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: value ? Glass.base : Glass.soft.withOpacity(enabled ? 1 : 0.5),
        ),
      ),
    );
  }
}

/// Mutually exclusive options as a row of chips.
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
        duration: const Duration(milliseconds: 140),
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: P.s16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(P.rCtl),
          color: selected ? Glass.text : Colors.transparent,
          border: Border.all(color: selected ? Glass.text : Glass.edge(0.14)),
        ),
        child: Text(text,
            style: P.caption.copyWith(
                fontSize: 13,
                color: selected ? Glass.base : Glass.soft,
                fontWeight: FontWeight.w500)),
      ),
    );
  }
}

/// Buttons: primary (off-white), secondary (raised surface with a hairline).
/// Height 36 or 40.
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
    final fg = primary
        ? Glass.base
        : (!enabled ? Glass.muted : (destructive ? Glass.bad : Glass.text));
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(P.rCtl + 2),
      side: primary
          ? BorderSide.none
          : BorderSide(color: destructive && enabled ? Glass.bad.withOpacity(0.4) : Glass.edge()),
    );
    return Material(
      color: !enabled ? Glass.fill(0.04) : (primary ? Glass.text : Glass.raised),
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
              Text(label, style: P.bodyStrong.copyWith(color: fg, fontSize: large ? 15 : 14)),
            ]),
          ),
        ),
      ),
    );
  }
}

/// 44 px text field.
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
        color: Glass.raised,
        borderRadius: BorderRadius.circular(P.rCtl + 2),
        border: Border.all(color: Glass.edge(0.12)),
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
            cursorColor: Glass.accent,
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
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          for (var i = 0; i < items.length; i++)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onChanged(i),
              child: Tooltip(message: items[i].label, child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                curve: Cubic(0.22, 1, 0.36, 1),
                height: 36,
                padding: EdgeInsets.symmetric(horizontal: items.length <= 4 || i == index ? P.s16 : P.s12),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(P.rPill),
                    color: i == index ? Glass.raised : Colors.transparent),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  PortalGlyph(items[i].icon, size: 18, color: i == index ? Glass.text : Glass.soft),
                  if (items.length <= 4 || i == index) const SizedBox(width: P.s8),
                  if (items.length <= 4 || i == index)
                  Text(items[i].label,
                      style: P.bodyStrong.copyWith(
                          fontSize: 13,
                          color: i == index ? Glass.text : Glass.soft)),
                ]),
              )),
            ),
        ]),
      ),
    );
  }
}

/// Vertical sidebar navigation for the settings window: icon + label rows,
/// one per line, 40 px tall, with a raised surface on the selected row.
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
                    duration: const Duration(milliseconds: 140),
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: P.s12),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(P.rCtl),
                        color: i == index ? Glass.raised : Colors.transparent),
                    child: Row(children: [
                      PortalGlyph(items[i].icon,
                          size: 18, color: i == index ? Glass.text : Glass.soft),
                      const SizedBox(width: P.s12),
                      Expanded(
                        child: Text(items[i].label,
                            overflow: TextOverflow.ellipsis,
                            style: P.bodyStrong.copyWith(
                                fontSize: 14,
                                color: i == index ? Glass.text : Glass.soft)),
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
      padding: const EdgeInsets.all(P.s16),
      child: SizedBox(
        width: 232,
        child: Row(children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(P.rCtl), color: Glass.raised),
            child: const PortalGlyph('monitor', color: Glass.text, size: 22),
          ),
          const SizedBox(width: P.s12),
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

/// Desktop page background: one flat graphite layer. It is opaque on purpose:
/// the native window is transparent (`backgroundColor: Colors.transparent` in
/// main.dart's WindowOptions), so anything translucent would let the real
/// desktop show through.
class DesktopAuroraBackground extends StatelessWidget {
  final Widget child;
  const DesktopAuroraBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      const Positioned.fill(
        child: IgnorePointer(child: ColoredBox(color: Glass.base)),
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
