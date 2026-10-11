import 'package:flutter/material.dart';

import '../../mobile/glass/glass.dart';

/// PortalDesk desktop components. Pure Flutter, no app dependencies, so they can
/// be previewed on their own. They replace the checkbox lists, grey cards and
/// side tab lists of the original code with one look of our own.

/// The ring from the app icon: violet-to-cyan outline, white dot in the middle.
class PortalRing extends StatelessWidget {
  final double size;
  const PortalRing({super.key, this.size = 46});

  @override
  Widget build(BuildContext context) {
    final stroke = size * 0.13;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const SweepGradient(
            colors: [Glass.violet, Glass.cyan, Glass.violet]),
        boxShadow: [
          BoxShadow(
              color: Glass.cyan.withOpacity(0.35),
              blurRadius: size * 0.5,
              spreadRadius: -size * 0.1)
        ],
      ),
      child: Center(
        child: Container(
          width: size - stroke * 2,
          height: size - stroke * 2,
          decoration:
              const BoxDecoration(shape: BoxShape.circle, color: Glass.base),
          child: Center(
            child: Container(
              width: size * 0.16,
              height: size * 0.16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Glass.cyan.withOpacity(0.9), blurRadius: 8)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A titled glass panel that groups related settings.
class PortalSection extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
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
      radius: 24,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          if (icon != null) ...[
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(11),
                  gradient: LinearGradient(colors: [
                    Glass.violet.withOpacity(0.55),
                    Glass.cyan.withOpacity(0.35)
                  ])),
              child: Icon(icon, size: 19, color: Colors.white),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Glass.text,
                          fontSize: 17,
                          fontWeight: FontWeight.w800)),
                  if (subtitle != null)
                    Text(subtitle!,
                        style: const TextStyle(
                            color: Glass.muted, fontSize: 12, height: 1.3)),
                ]),
          ),
          ...?trailing,
        ]),
        const SizedBox(height: 8),
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0)
            Divider(height: 1, thickness: 1, color: Colors.white.withOpacity(0.06)),
          children[i],
        ],
      ]),
    );
  }
}

/// One setting: label (and optional hint) on the left, a switch on the right.
class PortalSwitchRow extends StatelessWidget {
  final String label;
  final String? hint;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final IconData? icon;
  const PortalSwitchRow(
      {super.key,
      required this.label,
      required this.value,
      this.onChanged,
      this.hint,
      this.icon});

  @override
  Widget build(BuildContext context) {
    final enabled = onChanged != null;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: enabled ? () => onChanged!(!value) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 2),
        child: Row(children: [
          if (icon != null) ...[
            Icon(icon, size: 19, color: enabled ? Glass.soft : Glass.muted),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          color: enabled ? Glass.text : Glass.muted,
                          fontSize: 14,
                          height: 1.25)),
                  if (hint != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(hint!,
                          style: const TextStyle(
                              color: Glass.muted, fontSize: 12, height: 1.3)),
                    ),
                ]),
          ),
          const SizedBox(width: 12),
          _PortalSwitch(value: value, enabled: enabled),
        ]),
      ),
    );
  }
}

class _PortalSwitch extends StatelessWidget {
  final bool value;
  final bool enabled;
  const _PortalSwitch({required this.value, required this.enabled});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      width: 42,
      height: 24,
      padding: const EdgeInsets.all(3),
      alignment: value ? Alignment.centerRight : Alignment.centerLeft,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(99),
        gradient: value
            ? LinearGradient(colors: [
                Glass.violet.withOpacity(enabled ? 1 : 0.45),
                Glass.cyan.withOpacity(enabled ? 0.9 : 0.4)
              ])
            : null,
        color: value ? null : Colors.white.withOpacity(enabled ? 0.14 : 0.07),
      ),
      child: Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(enabled ? 1 : 0.6),
        ),
      ),
    );
  }
}

/// Mutually exclusive options shown as pills instead of radio dots.
class PortalChoiceRow<T> extends StatelessWidget {
  final String? label;
  final List<(T, String)> options;
  final T value;
  final ValueChanged<T>? onChanged;
  const PortalChoiceRow(
      {super.key,
      required this.options,
      required this.value,
      this.onChanged,
      this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(label!,
                style: const TextStyle(color: Glass.text, fontSize: 14)),
          ),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final o in options)
            _Pill(
                text: o.$2,
                selected: o.$1 == value,
                onTap: onChanged == null ? null : () => onChanged!(o.$1)),
        ]),
      ]),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(99),
          gradient: selected
              ? LinearGradient(colors: [
                  Glass.violet.withOpacity(0.75),
                  Glass.cyan.withOpacity(0.5)
                ])
              : null,
          color: selected ? null : Colors.white.withOpacity(0.07),
          border: Border.all(
              color: selected ? Colors.white.withOpacity(0.35) : Glass.edge()),
        ),
        child: Text(text,
            style: TextStyle(
                color: selected ? Colors.white : Glass.soft,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13)),
      ),
    );
  }
}

/// Secondary action: glass pill.
class PortalButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool primary;
  const PortalButton(
      {super.key,
      required this.label,
      this.icon,
      this.onPressed,
      this.primary = false});

  @override
  Widget build(BuildContext context) {
    if (primary) {
      return GlassButton(label: label, icon: icon, onPressed: onPressed);
    }
    final enabled = onPressed != null;
    return Material(
      color: Colors.white.withOpacity(enabled ? 0.09 : 0.04),
      shape: StadiumBorder(side: BorderSide(color: Glass.edge())),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (icon != null) ...[
              Icon(icon, size: 17, color: enabled ? Glass.text : Glass.muted),
              const SizedBox(width: 8)
            ],
            Text(label,
                style: TextStyle(
                    color: enabled ? Glass.text : Glass.muted,
                    fontWeight: FontWeight.w600,
                    fontSize: 13)),
          ]),
        ),
      ),
    );
  }
}

class PortalNavItem {
  final String label;
  final IconData icon;
  const PortalNavItem(this.label, this.icon);
}

/// Horizontal pill navigation for the settings window (replaces the side list).
class PortalTopNav extends StatelessWidget {
  final List<PortalNavItem> items;
  final int index;
  final ValueChanged<int> onChanged;
  const PortalTopNav(
      {super.key,
      required this.items,
      required this.index,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: GlassCard(
        radius: 99,
        padding: const EdgeInsets.all(5),
        strength: 1.15,
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          for (var i = 0; i < items.length; i++)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(99),
                    color: i == index
                        ? Colors.white.withOpacity(0.2)
                        : Colors.transparent),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(items[i].icon,
                      size: 18,
                      color: i == index ? Colors.white : Glass.soft),
                  const SizedBox(width: 8),
                  Text(items[i].label,
                      style: TextStyle(
                          color: i == index ? Colors.white : Glass.soft,
                          fontSize: 13,
                          fontWeight:
                              i == index ? FontWeight.w700 : FontWeight.w500)),
                ]),
              ),
            ),
        ]),
      ),
    );
  }
}
