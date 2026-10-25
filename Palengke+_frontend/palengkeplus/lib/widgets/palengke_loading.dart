// lib/widgets/palengke_loading.dart
//
// Native Flutter port of palengke_loading_animation-4.html
// No packages needed.
//
// Usage:
//   const PalengkeLoadingScreen()                              // full screen
//   const PalengkeLoading(withBackground: false, scale: .6)    // overlay / inline
import 'dart:math' as math;
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';

const _cream = Color(0xFFF3F4DF);
const _lime = Color(0xFFA8E66B);
const _forest = Color(0xFF244A29);

// All loops (1.4s, 1.1s, 0.65s, 1.2s) divide this evenly, so one controller
// drives everything without any visible jump at the wrap point.
const _cycle = 1201.2; // seconds

double _rad(double deg) => deg * math.pi / 180;

/// 0 -> 1 -> 0 with ease-in-out on each half (CSS `alternate`-style keyframes).
double _wave(double t, double period, [double delay = 0]) {
  if (t < delay) return 0;
  final p = ((t - delay) / period) % 1.0;
  return Curves.easeInOut.transform(p < .5 ? p * 2 : (1 - p) * 2);
}

double _lerp(double a, double b, double t) => a + (b - a) * t;

/// Full-screen loading page: green background + animated cart.
class PalengkeLoadingScreen extends StatelessWidget {
  const PalengkeLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: PalengkeLoading());
}

class PalengkeLoading extends StatefulWidget {
  const PalengkeLoading({
    super.key,
    this.withBackground = true,
    this.scale = 1.0,
  });

  /// true = green gradient background; false = transparent (for overlays).
  final bool withBackground;

  /// 1.0 = 300x245 logical pixels (same as the HTML).
  final double scale;

  @override
  State<PalengkeLoading> createState() => _PalengkeLoadingState();
}

class _PalengkeLoadingState extends State<PalengkeLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1201200),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = SizedBox(
      width: 300 * widget.scale,
      height: 245 * widget.scale,
      child: FittedBox(
        child: SizedBox(
          width: 300,
          height: 245,
          child: AnimatedBuilder(
            animation: _c,
            builder: (_, _) => _Cart(_c.value * _cycle),
          ),
        ),
      ),
    );

    if (!widget.withBackground) return Center(child: cart);

    return LayoutBuilder(
      builder: (context, box) => DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.16),
            radius: 1.0,
            colors: [Color(0xFF477D43), Color(0xFF315E32), Color(0xFF244A29)],
            stops: [0, .58, 1],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: box.maxHeight * .25,
              left: (box.maxWidth - 290) / 2,
              child: Container(
                width: 290,
                height: 290,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.fromRGBO(155, 229, 100, .09),
                ),
              ),
            ),
            Center(child: cart),
          ],
        ),
      ),
    );
  }
}

class _Cart extends StatelessWidget {
  const _Cart(this.t);
  final double t;

  static const _veg = [
    // emoji, left, top, fontSize, delay
    ('🥬', 72.0, 28.0, 39.0, 0.0),
    ('🥕', 104.0, 8.0, 43.0, 0.15),
    ('🍅', 137.0, 27.0, 37.0, 0.3),
    ('🍆', 48.0, 48.0, 32.0, 0.22),
    ('🥦', 159.0, 48.0, 32.0, 0.08),
  ];

  static const _streaks = [
    // left, top, width, delay
    (5.0, 119.0, 28.0, 0.0),
    (17.0, 140.0, 18.0, 0.35),
    (14.0, 98.0, 14.0, 0.6),
  ];

  @override
  Widget build(BuildContext context) {
    final bob = _wave(t, 1.4);
    final wheelAngle = 2 * math.pi * ((t / .65) % 1.0);

    return Transform.translate(
      offset: Offset(0, -8 * bob),
      child: Transform.rotate(
        angle: _rad(-1 + 2 * bob),
        child: SizedBox(
          width: 300,
          height: 245,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // ground shadow
              Positioned(
                left: 63,
                top: 223,
                width: 175,
                height: 17,
                child: Opacity(
                  opacity: _lerp(.65, .4, bob),
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.diagonal3Values(_lerp(1, .86, bob), 1, 1),
                    child: ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: const DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color.fromRGBO(15, 38, 18, .25),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // speed streaks
              for (final s in _streaks)
                Positioned(
                  left: s.$1,
                  top: s.$2,
                  width: s.$3,
                  height: 4,
                  child: Builder(builder: (_) {
                    final w = _wave(t, 1.2, s.$4);
                    return Transform.translate(
                      offset: Offset(-9 * w, 0),
                      child: Opacity(
                        opacity: _lerp(.35, 1, w),
                        child: const DecoratedBox(
                          decoration: BoxDecoration(
                            color: Color(0xFFB5ED83),
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                          ),
                        ),
                      ),
                    );
                  }),
                ),

              // the cart itself (skewed like the CSS)
              Positioned(
                left: 43,
                top: 75,
                width: 220,
                height: 140,
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.skewY(_rad(-3)),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // frame
                      Positioned(
                        left: 20,
                        top: 29,
                        width: 8,
                        height: 68,
                        child: Transform.rotate(
                          angle: _rad(-19),
                          child: const DecoratedBox(
                            decoration: BoxDecoration(
                              color: _cream,
                              borderRadius: BorderRadius.all(Radius.circular(8)),
                            ),
                          ),
                        ),
                      ),
                      // basket
                      Positioned(
                        left: 32,
                        top: 22,
                        width: 145,
                        height: 76,
                        child: Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.skewY(_rad(8)),
                          child: CustomPaint(painter: _BasketPainter()),
                        ),
                      ),
                      // base bar
                      Positioned(
                        left: 65,
                        top: 105,
                        width: 113,
                        height: 8,
                        child: Transform.rotate(
                          angle: _rad(-3),
                          child: const DecoratedBox(
                            decoration: BoxDecoration(
                              color: _cream,
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                            ),
                          ),
                        ),
                      ),
                      // wheels
                      for (final left in const [67.0, 164.0])
                        Positioned(
                          left: left,
                          top: 118,
                          width: 31,
                          height: 31,
                          child: Transform.rotate(
                            angle: wheelAngle,
                            child: CustomPaint(painter: _WheelPainter()),
                          ),
                        ),
                      // "+" badge
                      Positioned(
                        left: 143,
                        top: 15,
                        width: 34,
                        height: 34,
                        child: Transform.scale(
                          scale: 1 + .09 * bob,
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _lime,
                              border: Border.all(color: _cream, width: 3),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color.fromRGBO(0, 0, 0, .2),
                                  blurRadius: 10,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Text(
                              '+',
                              style: TextStyle(
                                color: _forest,
                                fontSize: 27,
                                fontWeight: FontWeight.w800,
                                height: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // vegetables (on top of the cart)
              for (final v in _veg)
                Positioned(
                  left: v.$2,
                  top: v.$3,
                  child: Builder(builder: (_) {
                    final w = _wave(t, 1.1, v.$5);
                    return Transform.translate(
                      offset: Offset(0, -5 * w),
                      child: Transform.rotate(
                        angle: _rad(_lerp(-2, 3, w)),
                        alignment: Alignment.bottomCenter,
                        child: Text(v.$1, style: TextStyle(fontSize: v.$4)),
                      ),
                    );
                  }),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BasketPainter extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    final w = s.width, h = s.height;
    final cream = Paint()..color = _cream;

    final outer = RRect.fromRectAndCorners(
      Rect.fromLTWH(0, 0, w, h),
      topLeft: const Radius.circular(5),
      topRight: const Radius.circular(8),
      bottomRight: const Radius.circular(25),
      bottomLeft: const Radius.circular(18),
    );
    // border: 7px left/right/bottom, 5px top
    final inner = RRect.fromLTRBAndCorners(
      7,
      5,
      w - 7,
      h - 7,
      topLeft: Radius.zero,
      topRight: const Radius.elliptical(1, 3),
      bottomRight: const Radius.circular(18),
      bottomLeft: const Radius.circular(11),
    );
    c.drawDRRect(outer, inner, cream);

    // weave stripes + green inset shadow, clipped to the inside
    c.save();
    c.clipRRect(inner);
    final stripe = Paint()..color = const Color.fromRGBO(243, 244, 223, .8);
    for (var x = 7 + 25.5; x < w - 7; x += 31) {
      c.drawRect(Rect.fromLTWH(x, 5, 5.5, h - 12), stripe);
    }
    c.drawRect(
      Rect.fromLTRB(7, h - 14, w - 7, h - 7),
      Paint()..color = const Color.fromRGBO(155, 229, 100, .3),
    );
    c.restore();

    // handle (::before)
    c.save();
    c.translate(-7, -4);
    c.rotate(_rad(15));
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: 34, height: 8),
        const Radius.circular(8),
      ),
      cream,
    );
    c.restore();

    // bottom rail (::after)
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(15, h, w - 15, h + 7),
        const Radius.circular(8),
      ),
      cream,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _WheelPainter extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    const center = Offset(15.5, 15.5);

    // soft outer ring
    c.drawCircle(
      center,
      17,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = const Color.fromRGBO(22, 55, 28, .15),
    );

    // 6px tyre: top+left green, right+bottom cream
    final rect = Rect.fromCircle(center: center, radius: 12.5);
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    p.color = _lime;
    c.drawArc(rect, 3 * math.pi / 4, math.pi, false, p);
    p.color = _cream;
    c.drawArc(rect, -math.pi / 4, math.pi, false, p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
