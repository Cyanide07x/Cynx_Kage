
import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Search bar with a transparent inside and a moving gradient border.
/// Usage: AnimatedSearchBar(hint: 'Search jackets, cargos', onChanged: (v) {})
class AnimatedSearchBar extends StatefulWidget {
  final String hint;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextEditingController? controller;
  final double height;
  final double borderWidth;
  final Duration duration;

  const AnimatedSearchBar({
    super.key,
    this.hint = 'Search',
    this.onChanged,
    this.onSubmitted,
    this.controller,
    this.height = 52,
    this.borderWidth = 2,
    this.duration = const Duration(seconds: 4),
  });

  @override
  State<AnimatedSearchBar> createState() => _AnimatedSearchBarState();
}

class _AnimatedSearchBarState extends State<AnimatedSearchBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl =
      AnimationController(vsync: this, duration: widget.duration)..repeat();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return RepaintBoundary(
      child: CustomPaint(
        // The painter draws ONLY the ring, so the inside stays transparent.
        painter: _GradientRingPainter(
          animation: _ctrl,
          strokeWidth: widget.borderWidth,
          primaryColor: colors.primary,
          secondaryColor: colors.secondary,
          surfaceColor: colors.surface,
        ),
        child: SizedBox(
          height: widget.height,
          child: TextField(
            controller: widget.controller,
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
            textInputAction: TextInputAction.search,
            cursorColor: colors.primary,
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: TextStyle(
                color: colors.onSurfaceVariant,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: colors.onSurfaceVariant,
              ),
              // No fill, no borders: keeps the background transparent.
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                vertical: (widget.height - 24) / 2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}


class _GradientRingPainter extends CustomPainter {
  final Animation<double> animation;
  final double strokeWidth;
  final Color primaryColor;
  final Color secondaryColor;
  final Color surfaceColor;

  _GradientRingPainter({
    required this.animation,
    required this.strokeWidth,
    required this.primaryColor,
    required this.secondaryColor,
    required this.surfaceColor,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final radius = Radius.circular(size.height / 2);

    final rrect = RRect.fromRectAndRadius(
      rect.deflate(strokeWidth / 2),
      radius,
    );

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..shader = SweepGradient(
        transform: GradientRotation(animation.value * 2 * math.pi),
        colors: [
          primaryColor,
          secondaryColor,
          surfaceColor,
          secondaryColor,
          primaryColor,
        ],
      ).createShader(rect);

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _GradientRingPainter old) {
    return old.strokeWidth != strokeWidth ||
        old.primaryColor != primaryColor ||
        old.secondaryColor != secondaryColor ||
        old.surfaceColor != surfaceColor;
  }
}
