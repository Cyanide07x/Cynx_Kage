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
    const textColor = Color(0xFFF2F0E6);
    const hintColor = Color(0xFFA9BFAF);

    return RepaintBoundary(
      child: CustomPaint(
        // The painter draws ONLY the ring, so the inside stays transparent.
        painter: _GradientRingPainter(
          animation: _ctrl,
          strokeWidth: widget.borderWidth,
        ),
        child: SizedBox(
          height: widget.height,
          child: TextField(
            controller: widget.controller,
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
            textInputAction: TextInputAction.search,
            cursorColor: const Color(0xFFC5E37A),
            style: const TextStyle(color: textColor, fontSize: 15),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: const TextStyle(color: hintColor),
              prefixIcon: const Icon(Icons.search, color: hintColor),
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

  _GradientRingPainter({required this.animation, required this.strokeWidth})
      : super(repaint: animation); // repaints every frame without rebuilding widgets

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final radius = Radius.circular(size.height / 2);
    // Inset by half the stroke so the ring isn't clipped at the edges.
    final rrect = RRect.fromRectAndRadius(
      rect.deflate(strokeWidth / 2),
      radius,
    );

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..shader = SweepGradient(
        transform: GradientRotation(animation.value * 2 * math.pi),
        colors: const [
          Color(0xFFC5E37A), // lime
          Color(0xFF5E8E6E), // mid green
          Color(0xFF1E3A2F), // deep green
          Color(0xFF5E8E6E),
          Color(0xFFC5E37A), // same as first so the loop is seamless
        ],
      ).createShader(rect);

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _GradientRingPainter old) =>
      old.strokeWidth != strokeWidth;
}