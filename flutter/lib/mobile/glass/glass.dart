import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// PortalDesk design system: flat graphite surfaces, hairline borders, one
/// off-white primary action. Depth comes from surface steps, never from glow,
/// blur or gradient. Pure Flutter, no app dependencies, so it can be previewed
/// on its own. Class names are kept from the earlier "glass" system so call
/// sites do not change.
class Glass {
  // Surfaces, darkest to lightest.
  static const Color base = Color(0xFF141415);
  static const Color surface = Color(0xFF19191B);
  static const Color raised = Color(0xFF232325);

  // Text roles.
  static const Color text = Color(0xFFEDEDED);
  static const Color soft = Color(0xFFA1A1A6);
  static const Color muted = Color(0xFF85858B);

  // One accent, for focus and the single thing that matters on a screen.
  static const Color accent = Color(0xFF5B9DFF);

  // Semantic colors, toned to sit on the graphite ramp.
  static const Color ok = Color(0xFF4CC38A);
  static const Color warn = Color(0xFFE0A43B);
  static const Color bad = Color(0xFFE5484D);

  /// Surface step: the text color at low opacity over the page.
  static Color fill([double a = 0.05]) => text.withOpacity(a);

  /// Hairline: the text color at 8%.
  static Color edge([double a = 0.08]) => text.withOpacity(a);

  // Radii: row/input/button 10, card 16, pill for the floating bars only.
  static const double rCtl = 10;
  static const double rCard = 16;
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

/// A raised surface with a hairline border.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final double strength;
  final VoidCallback? onTap;
  final bool animate;
  final Duration animateDelay;

  /// Kept so older call sites compile. Flat surfaces ignore it.
  final double blur;
  final bool liquid;
  const GlassCard(
      {super.key,
      required this.child,
      this.padding = const EdgeInsets.all(16),
      this.margin,
      this.radius = Glass.rCard,
      this.blur = 0,
      this.strength = 1,
      this.onTap,
      this.liquid = false,
      this.animate = false,
      this.animateDelay = Duration.zero});

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(radius);
    Widget body = Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: r,
        color: Glass.surface,
        border: Border.all(color: Glass.edge(0.08 * strength.clamp(1, 1.5))),
      ),
      child: child,
    );
    if (onTap != null) {
      body = Material(
        type: MaterialType.transparency,
        child: InkWell(borderRadius: r, onTap: onTap, child: body),
      );
    }
    Widget result =
        margin == null ? body : Padding(padding: margin!, child: body);
    if (animate) {
      result = result
          .animate(delay: animateDelay)
          .fadeIn(duration: 300.ms, curve: _ease)
          .slideY(begin: 0.04, end: 0, duration: 300.ms, curve: _ease);
    }
    return result;
  }
}

const Curve _ease = Cubic(0.22, 1, 0.36, 1);

/// The one loud button: off-white with dark text. The quiet variant is a
/// raised surface with a hairline.
class GlassButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool filled;
  final bool dense;
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
    final enabled = onPressed != null;
    final fg = filled ? Glass.base : Glass.text;
    final shape = RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Glass.rCtl + 2));
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Material(
        color: filled ? Glass.text : Glass.raised,
        shape: shape.copyWith(
            side: filled ? BorderSide.none : BorderSide(color: Glass.edge())),
        child: InkWell(
          customBorder: shape,
          onTap: onPressed,
          child: Padding(
            padding: EdgeInsets.symmetric(
                vertical: dense ? 8 : 14, horizontal: dense ? 12 : 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: dense ? 16 : 18, color: fg),
                  SizedBox(width: dense ? 6 : 8)
                ],
                Flexible(
                  child: Text(label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: fg,
                          fontWeight: FontWeight.w500,
                          fontSize: dense ? 13 : 15)),
                ),
              ],
            ),
          ),
        ),
      ),
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
        scale: _pressed ? 0.97 : 1,
        duration: 120.ms,
        curve: _ease,
        child: widget.child,
      ),
    );
  }
}

/// Status dot. Flat: the color alone says the state.
class StatusDot extends StatelessWidget {
  final Color color;
  final bool glow;
  const StatusDot({super.key, this.color = Glass.ok, this.glow = false});

  @override
  Widget build(BuildContext context) => Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
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
                padding: const EdgeInsets.all(4),
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
          duration: const Duration(milliseconds: 180),
          curve: _ease,
          // icon 22 + 13*2 padding = 48dp tall, the Material minimum.
          padding: EdgeInsets.symmetric(
              horizontal: selected ? 18 : 14, vertical: 13),
          decoration: BoxDecoration(
            color: selected ? Glass.raised : Colors.transparent,
            borderRadius: BorderRadius.circular(Glass.rPill),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(item.icon,
                size: 22, color: selected ? Glass.text : Glass.soft),
            AnimatedSize(
              duration: const Duration(milliseconds: 180),
              curve: _ease,
              child: selected
                  ? Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(item.label,
                          style: const TextStyle(
                              color: Glass.text,
                              fontWeight: FontWeight.w500,
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
      radius: Glass.rCtl + 2,
      padding: const EdgeInsets.all(4),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        for (var i = 0; i < labels.length; i++)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onChanged(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              curve: _ease,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: i == index ? Glass.raised : Colors.transparent,
                borderRadius: BorderRadius.circular(Glass.rCtl),
              ),
              child: Text(labels[i],
                  style: TextStyle(
                      color: i == index ? Glass.text : Glass.soft,
                      fontWeight: FontWeight.w500,
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
                    color: it.primary ? Glass.text : Glass.raised,
                  ),
                  child: Icon(it.icon,
                      size: 20,
                      color: it.primary ? Glass.base : Glass.text),
                ),
              ),
            ),
          ),
      ]),
    );
  }
}
