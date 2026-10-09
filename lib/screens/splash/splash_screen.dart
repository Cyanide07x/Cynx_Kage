import 'package:flutter/material.dart';

class KageColors {
  static const background = Color(0xFF0B0B0B);
  static const surface = Color(0xFF171717);
  static const border = Color(0xFF333333);
  static const accent = Color(0xFFF2F2F2);
  static const text = Color(0xFFFAFAFA);
  static const dim = Color(0xFFA3A3A3);
}

class SplashScreen extends StatefulWidget {
  final VoidCallback? onFinished;

  const SplashScreen({super.key, this.onFinished});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const _total = Duration(milliseconds: 3000);
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: _total);
    _play();
  }

  Future<void> _play() async {
    await _c.forward(from: 0);
    if (!mounted) return;
    widget.onFinished?.call();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Animation<double> _window(
    double startSec,
    double endSec, [
    Curve curve = Curves.easeOut,
  ]) {
    final total = _total.inMilliseconds / 1000;
    return CurvedAnimation(
      parent: _c,
      curve: Interval(
        startSec / total,
        (endSec / total).clamp(0.0, 1.0),
        curve: curve,
      ),
    );
  }

  Widget _rise(Animation<double> a, Widget child) {
    return FadeTransition(
      opacity: a,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(0, 0.12),
          end: Offset.zero,
        ).animate(a),
        child: child,
      ),
    );
  }

  Widget _ring(double startSec, double endSec) {
    final a = _window(startSec, endSec);

    return AnimatedBuilder(
      animation: a,
      builder: (_, _) => Opacity(
        opacity: 0.45 * (1 - a.value),
        child: Transform.scale(
          scale: 0.4 + 1.3 * a.value,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: KageColors.border,
                width: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _stalk(
    int i,
    double heightFactor,
    Color color,
    double maxHeight, {
    bool outlined = false,
  }) {
    final start = 0.2 + 0.15 * i;
    final a = _window(
      start,
      start + 1.3,
      const Cubic(0.2, 0.8, 0.2, 1),
    );

    return AnimatedBuilder(
      animation: a,
      builder: (_, child) => Transform(
        alignment: Alignment.bottomCenter,
        transform: Matrix4.diagonal3Values(1, a.value, 1),
        child: child,
      ),
      child: Container(
        width: 24,
        height: maxHeight * heightFactor,
        decoration: BoxDecoration(
          color: color,
          border: outlined
              ? Border.all(color: KageColors.border, width: 2)
              : null,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(12),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mark = _window(0.3, 1.3);
    final name = _window(0.9, 1.9);
    final tagline = _window(1.4, 2.4);

    return Scaffold(
      backgroundColor: KageColors.background,
      body: SizedBox.expand(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Expanding monochrome rings
            _ring(0.2, 2.6),
            _ring(0.6, 3.0),

            // Mark, name, and tagline
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _rise(
                  mark,
                  const Text(
                    'CK',
                    style: TextStyle(
                      fontSize: 96,
                      height: 1,
                      fontWeight: FontWeight.w800,
                      color: KageColors.accent,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _rise(
                  name,
                  const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Text(
                      'CYNX KAGE',
                      style: TextStyle(
                        fontSize: 26,
                        letterSpacing: 8,
                        fontWeight: FontWeight.w800,
                        color: KageColors.text,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                _rise(
                  tagline,
                  const Text(
                    'Gear for the quiet trade',
                    style: TextStyle(
                      fontSize: 16,
                      color: KageColors.dim,
                    ),
                  ),
                ),
              ],
            ),

            // Monochrome decorative stalks
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Builder(
                builder: (context) {
                  final maxH =
                      MediaQuery.of(context).size.height * 0.24;

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _stalk(
                        0, 0.55, KageColors.surface, maxH,
                        outlined: true,
                      ),
                      const SizedBox(width: 12),
                      _stalk(1, 0.90, KageColors.border, maxH),
                      const SizedBox(width: 12),
                      _stalk(2, 0.70, KageColors.surface, maxH),
                      const SizedBox(width: 12),
                      _stalk(3, 1.00, KageColors.accent, maxH),
                      const SizedBox(width: 12),
                      _stalk(4, 0.62, KageColors.border, maxH),
                    ],
                  );
                },
              ),
            ),

            // Replay button when auto-navigation is disabled
            if (widget.onFinished == null)
              SafeArea(
                child: Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: OutlinedButton(
                      onPressed: _play,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: KageColors.accent,
                        side: const BorderSide(
                          color: KageColors.border,
                          width: 1.5,
                        ),
                        minimumSize: const Size(0, 44),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                        ),
                        shape: const StadiumBorder(),
                      ),
                      child: const Text(
                        'Replay',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}