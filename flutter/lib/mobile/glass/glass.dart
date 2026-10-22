import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// PortalDesk "glass" design system: black and white only, no accent hues
/// (owner decision, see docs/design-glass.md). Pure Flutter, no app
/// dependencies, so it can be previewed on its own.
class Glass {
  static const Color base = Color(0xFF050507);
  static const Color text = Color(0xFFF2F2F2);
  static const Color soft = Color(0xFFC9C9C9);
  static const Color muted = Color(0xFF8C8C8C);
  static const Color ok = Color(0xFF34D399);
  static const Color warn = Color(0xFFFBBF24);
  static const Color bad = Color(0xFFF87171);

  static Color fill([double a = 0.08]) => Colors.white.withOpacity(a);
  static Color edge([double a = 0.16]) => Colors.white.withOpacity(a);

  static const double rCard = 28;
  static const double rPill = 99;
}

/// Full-screen background. Put it under everything.
class AuroraBackground extends StatelessWidget {
  final Widget child;
  const AuroraBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      const Positioned.fill(
          child: IgnorePointer(child: ColoredBox(color: Glass.base))),
      Positioned.fill(child: child),
    ]);
  }
}

/// A frosted panel.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final double blur;
  final double strength;
  final VoidCallback? onTap;
  /// Opt-in "liquid glass" depth: inset highlight, drop shadow, top-left
  /// specular glare. Off by default so existing (phone) call sites are
  /// unchanged; desktop passes true.
  final bool liquid;
  /// Opt-in entrance animation (fade + slide-up). Off by default so existing
  /// call sites, including the ones GlassNavBar/GlassDock rebuild per frame,
  /// are unaffected.
  final bool animate;
  final Duration animateDelay;
  const GlassCard(
      {super.key,
      required this.child,
      this.padding = const EdgeInsets.all(16),
      this.margin,
      this.radius = Glass.rCard,
      this.blur = 22,
      this.strength = 1,
      this.onTap,
      this.liquid = false,
      this.animate = false,
      this.animateDelay = Duration.zero});

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(radius);
    Widget inner = Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: r,
        color: liquid ? Colors.black.withOpacity(0.35 * strength) : null,
        gradient: liquid
            ? null
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Glass.fill(0.14 * strength), Glass.fill(0.05 * strength)],
              ),
        border: Border.all(
            color: Glass.edge((liquid ? 0.09 : 0.18) * strength), width: 1),
        boxShadow: liquid
            ? [
                BoxShadow(
                    color: Colors.white.withOpacity(0.22 * strength),
                    blurRadius: 0,
                    spreadRadius: 0,
                    offset: const Offset(0, 1)),
              ]
            : null,
      ),
      child: child,
    );
    if (liquid) {
      inner = Stack(children: [
        inner,
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: r,
                gradient: RadialGradient(
                  center: const Alignment(-0.7, -1.2),
                  radius: 1.1,
                  colors: [
                    Colors.white.withOpacity(0.14 * strength),
                    Colors.white.withOpacity(0),
                  ],
                ),
              ),
            ),
          ),
        ),
      ]);
    }
    Widget body = ClipRRect(
      borderRadius: r,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: inner,
      ),
    );
    if (liquid) {
      body = Container(
        decoration: BoxDecoration(borderRadius: r, boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.65),
              blurRadius: 50,
              spreadRadius: -8,
              offset: const Offset(0, 24)),
          BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 3)),
        ]),
        child: body,
      );
    }
    if (onTap != null) {
      body = Material(
        type: MaterialType.transparency,
        child: InkWell(
            borderRadius: r, onTap: onTap, child: body),
      );
    }
    Widget result = margin == null ? body : Padding(padding: margin!, child: body);
    if (animate) {
      result = result
          .animate(delay: animateDelay)
          .fadeIn(duration: 300.ms)
          .slideY(begin: 0.08, end: 0, duration: 300.ms, curve: Curves.easeOut);
    }
    return result;
  }
}

/// The one loud button: white, soft violet glow.
class GlassButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool filled;
  final bool dense;
  /// Opt-in scale-down press feedback. Off by default so existing call
  /// sites are unaffected.
  final bool animate;
  const GlassButton(
      {super.key,
      required this.label,
      this.icon,
      this.onPressed,
      this.filled = true,
      this.dense = false,
      this.animate = false});

  @override
  Widget build(BuildContext context) {
    final button = _buildButton(context);
    return animate ? _PressScale(child: button) : button;
  }

  Widget _buildButton(BuildContext context) {
    final fg = filled ? Colors.black : Glass.text;
    final shape = const StadiumBorder();
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Glass.rPill),
        boxShadow: filled
            ? [
                BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 20,
                    offset: const Offset(0, 10)),
                BoxShadow(
                    color: Colors.black.withOpacity(0.35),
                    blurRadius: 6,
                    offset: const Offset(0, 2)),
              ]
            : null,
      ),
      child: Stack(children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Glass.rPill),
              color: filled ? Colors.white : null,
              gradient: filled
                  ? null
                  : LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Glass.fill(0.16), Glass.fill(0.04)],
                    ),
              border: filled ? null : Border.all(color: Glass.edge()),
              boxShadow: [
                BoxShadow(
                    color: Colors.white.withOpacity(filled ? 1 : 0.2),
                    blurRadius: 0,
                    offset: const Offset(0, 1)),
              ],
            ),
          ),
        ),
        Material(
          color: Colors.transparent,
          shape: shape,
          child: InkWell(
            customBorder: shape,
            onTap: onPressed,
            child: Padding(
              padding: EdgeInsets.symmetric(
                  vertical: dense ? 9 : 15, horizontal: dense ? 14 : 22),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: dense ? 15 : 20, color: fg),
                    SizedBox(width: dense ? 5 : 8)
                  ],
                  Flexible(
                    child: Text(label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: fg,
                            fontWeight: FontWeight.w700,
                            fontSize: dense ? 13 : 16)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

/// Scale-down-on-press wrapper, used by [GlassButton] when `animate: true`.
class _PressScale extends StatefulWidget {
  final Widget child;
  const _PressScale({required this.child});

  @override
  State<_PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<_PressScale> {
  bool _pressed = false;

  void _setPressed(bool v) {
    if (_pressed != v) setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _setPressed(true),
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? 0.94 : 1,
        duration: 120.ms,
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// Glowing status dot.
class StatusDot extends StatelessWidget {
  final Color color;
  final bool glow;
  const StatusDot({super.key, this.color = Glass.ok, this.glow = true});

  @override
  Widget build(BuildContext context) => Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow:
              glow ? [BoxShadow(color: color.withOpacity(0.8), blurRadius: 10)] : null,
        ),
      );
}

class GlassNavItem {
  final String label;
  final IconData icon;
  const GlassNavItem(this.label, this.icon);
}

/// Floating pill navigation.
class GlassNavBar extends StatelessWidget {
  final List<GlassNavItem> items;
  final int index;
  final ValueChanged<int> onChanged;
  const GlassNavBar(
      {super.key,
      required this.items,
      required this.index,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Align(
          alignment: Alignment.bottomCenter,
          heightFactor: 1,
          child: ConstrainedBox(
            // never wider than the screen, whatever the phone or font size
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width - 24),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: GlassCard(
                radius: Glass.rPill,
                padding: const EdgeInsets.all(6),
                strength: 1.15,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i = 0; i < items.length; i++)
                      _NavChip(
                          item: items[i],
                          selected: i == index,
                          onTap: () => onChanged(i)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavChip extends StatelessWidget {
  final GlassNavItem item;
  final bool selected;
  final VoidCallback onTap;
  const _NavChip(
      {required this.item, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        // icon 22 + 13*2 padding = 48dp tall, 14*2 + 22 = 50dp wide:
        // the Material minimum without letting the chip expand.
        padding: EdgeInsets.symmetric(
            horizontal: selected ? 18 : 14, vertical: 13),
        decoration: BoxDecoration(
          color: selected ? Colors.white.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(Glass.rPill),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(item.icon,
              size: 22, color: selected ? Colors.white : Glass.soft),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            child: selected
                ? Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(item.label,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14)),
                  )
                : const SizedBox.shrink(),
          ),
        ]),
      ),
      ),
    );
  }
}

/// Two or three way switch, for "Касание / Трекпад" and similar.
class GlassSegmented extends StatelessWidget {
  final List<String> labels;
  final int index;
  final ValueChanged<int> onChanged;
  const GlassSegmented(
      {super.key,
      required this.labels,
      required this.index,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: Glass.rPill,
      padding: const EdgeInsets.all(4),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        for (var i = 0; i < labels.length; i++)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onChanged(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
              decoration: BoxDecoration(
                color: i == index
                    ? Colors.white.withOpacity(0.22)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(Glass.rPill),
              ),
              child: Text(labels[i],
                  style: TextStyle(
                      color: i == index ? Colors.white : Glass.soft,
                      fontWeight: FontWeight.w700,
                      fontSize: 13)),
            ),
          ),
      ]),
    );
  }
}

class GlassDockItem {
  final IconData icon;
  final String tip;
  final VoidCallback? onTap;
  final bool primary;
  const GlassDockItem(this.icon, this.tip, {this.onTap, this.primary = false});
}

/// Floating tool dock for the remote session.
class GlassDock extends StatelessWidget {
  final List<GlassDockItem> items;
  const GlassDock({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 16),
      child: FittedBox(fit: BoxFit.scaleDown, child: _dock()),
    );
  }

  Widget _dock() {
    return GlassCard(
      radius: Glass.rPill,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      strength: 1.2,
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        for (final it in items)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Tooltip(
              message: it.tip,
              child: GestureDetector(
                onTap: it.onTap,
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: it.primary
                        ? Colors.white
                        : Colors.white.withOpacity(0.12),
                    boxShadow: it.primary
                        ? [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 16)
                          ]
                        : null,
                  ),
                  child: Icon(it.icon,
                      size: 21,
                      color: it.primary ? Colors.black : Colors.white),
                ),
              ),
            ),
          ),
      ]),
    );
  }
}
