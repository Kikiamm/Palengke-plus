// lib/screens/palengke_splash.dart
//
// Native Flutter port of Palengke_Logo_Animation.html (the 6-step logo build).
// Needs:  flutter pub add google_fonts
//
// Usage:
//   PalengkeSplash(onFinished: () => Navigator.of(context).pushReplacement(...))
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


const _bg = Color(0xFFFDF9EA);
const _total = 7.7; // seconds (matches the HTML timeline)

// CSS cubic-bezier curves from the HTML
const _cPop = Cubic(.2, 1.35, .4, 1);
const _cDrop = Cubic(.25, 1.5, .4, 1);
const _cRise = Cubic(.2, 1.4, .4, 1);
const _cGrow = Cubic(.3, 1.3, .5, 1);
const _cSweep = Cubic(.45, .05, .2, 1);
const _cSwim = Cubic(.2, 1.2, .4, 1);
const _cSpark = Cubic(0, 0, .58, 1);

double _rad(double deg) => deg * math.pi / 180;

/// CSS-style keyframes: the curve is applied between each pair of stops.
double _kf(double p, List<double> stops, List<double> vals, Curve curve) {
  for (var i = 0; i < stops.length - 1; i++) {
    if (p <= stops[i + 1]) {
      final local =
          ((p - stops[i]) / (stops[i + 1] - stops[i])).clamp(0.0, 1.0).toDouble();
      return vals[i] + (vals[i + 1] - vals[i]) * curve.transform(local);
    }
  }
  return vals.last;
}

// ───────────────────────── SPLASH WIDGET ─────────────────────────

class PalengkeSplash extends StatefulWidget {
  const PalengkeSplash({
    super.key,
    required this.onFinished,
    this.hold = const Duration(milliseconds: 500),
  });

  /// Called once, after the animation ends (+ [hold]) or when the user taps to skip.
  final VoidCallback onFinished;
  final Duration hold;

  @override
  State<PalengkeSplash> createState() => _PalengkeSplashState();
}

class _PalengkeSplashState extends State<PalengkeSplash>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: (_total * 1000).round()),
  );
  bool _done = false;

  void _finish() {
    if (_done || !mounted) return;
    _done = true;
    widget.onFinished();
  }

  @override
  void initState() {
    super.initState();
    _c.forward();
    _c.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        Future.delayed(widget.hold, _finish);
      }
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _finish, // tap to skip
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  width: 1000,
                  height: 470,
                  child: AnimatedBuilder(
                    animation: _c,
                    builder: (_, _) => _Stage(_c.value * _total),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ───────────────────────── STAGE (1000 x 470) ─────────────────────────

class _Stage extends StatelessWidget {
  const _Stage(this.t);
  final double t;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: CustomPaint(painter: _LayerPainter(_back, t)),
        ),
        _word(t),
        Positioned.fill(
          child: CustomPaint(painter: _LayerPainter(_front, t)),
        ),
      ],
    );
  }
}

// ───────────────────────── LETTERING ─────────────────────────

const _green = [Color(0xFF2B9140), Color(0xFF1B7A32), Color(0xFF0E4A20)];
const _greenStops = [0.0, .45, 1.0];
const _yellow = [Color(0xFFF7CF4A), Color(0xFFF2B81D), Color(0xFFE8920F)];
const _yellowStops = [0.0, .55, 1.0];

Widget _gradText(
  String ch,
  double size,
  List<Color> colors,
  List<double> stops,
  Color shadow,
  double shadowDy, {
  double spacing = 0,
}) {
  final style = GoogleFonts.baloo2(
    fontSize: size,
    fontWeight: FontWeight.w800,
    height: 1,
    letterSpacing: spacing,
    color: Colors.white,
  );
  return Stack(
    children: [
      Transform.translate(
        offset: Offset(0, shadowDy),
        child: Text(ch, style: style.copyWith(color: shadow)),
      ),
      ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (r) => LinearGradient(
          begin: const Alignment(-.12, -1),
          end: const Alignment(.12, 1),
          colors: colors,
          stops: stops,
        ).createShader(r),
        child: Text(ch, style: style),
      ),
    ],
  );
}

/// One animated letter. [pop] = the P and the "+", otherwise the "rise" letters.
Widget _letter(
  double t,
  String ch,
  double size,
  double r,
  double delay, {
  bool pop = false,
  bool plus = false,
  double spacing = 0,
}) {
  double s, rot, ty = 0, op;
  if (pop) {
    final p = ((t - delay) / .75).clamp(0.0, 1.0).toDouble();
    s = _kf(p, [0, .6, 1], [.2, 1.14, 1], _cPop);
    rot = _kf(p, [0, .6, 1], [r - 12, r, r], _cPop);
    op = _kf(p, [0, .6, 1], [0, 1, 1], _cPop);
  } else {
    final p = ((t - delay) / .7).clamp(0.0, 1.0).toDouble();
    s = _kf(p, [0, 1], [.6, 1], _cRise);
    rot = _kf(p, [0, 1], [r + 10, r], _cRise);
    ty = _kf(p, [0, 1], [.35 * size, 0], _cRise);
    op = _kf(p, [0, 1], [0, 1], _cRise);
  }
  final origin = Alignment(0, pop ? .6 : .7);

  final text = plus
      ? _gradText(ch, size, _yellow, _yellowStops,
          const Color.fromRGBO(14, 74, 32, .55), size * .04)
      : _gradText(ch, size, _green, _greenStops,
          const Color.fromRGBO(8, 50, 20, .35), size * .02,
          spacing: spacing);

  return Opacity(
    opacity: op.clamp(0.0, 1.0).toDouble(),
    child: Transform.translate(
      offset: Offset(0, ty),
      child: Transform.rotate(
        angle: _rad(rot),
        alignment: origin,
        child: Transform.scale(scale: s, alignment: origin, child: text),
      ),
    ),
  );
}

Widget _word(double t) {
  const fs = 160.0; // 16cqw of a 1000px stage
  const pSize = fs * 1.22;
  const plusSize = fs * .66;
  const pad = fs * .015;

  Widget cell(Widget w) =>
      Padding(padding: const EdgeInsets.symmetric(horizontal: pad), child: w);

  const rest = [
    ('A', -2.0, 2.3),
    ('L', 2.0, 2.45),
    ('E', -2.0, 2.6),
    ('N', 2.0, 2.75),
    ('G', -2.0, 2.9),
    ('K', 2.0, 3.05),
    ('E', -3.0, 3.2),
  ];

  return Positioned(
    left: 100,
    top: 145.7,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            // P: bigger, tucked closer to the next letter (-.03em margin)
            cell(_letter(t, 'P', pSize, -3, .2,
                pop: true, spacing: -(.02 + .03) * pSize)),
            for (final l in rest)
              cell(_letter(t, l.$1, fs, l.$2, l.$3, spacing: -.02 * fs)),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(
              left: .02 * plusSize, top: .06 * plusSize),
          child: _letter(t, '+', plusSize, 0, 3.4, pop: true, plus: true),
        ),
      ],
    ),
  );
}

// ───────────────────────── SHAPE ENGINE ─────────────────────────

class _S {
  _S(this.path, this.paint);
  final Path path;
  final Paint paint;
}

enum _K { pop, drop, grow, sweep, swim, spark }

class _G {
  _G(this.kind, this.delay, this.shapes, {this.base});
  final _K kind;
  final double delay;
  final List<_S> shapes;
  final Matrix4? base; // parent transform (like the SVG `transform` attribute)

  late final Rect bounds = shapes
      .map((s) => s.path.getBounds())
      .reduce((a, b) => a.expandToInclude(b));

  static const _layer = Rect.fromLTWH(-600, -600, 2400, 1800);

  void draw(Canvas c, double t) {
    if (t <= delay) return; // every animation starts invisible
    final b = bounds;
    Offset at(double fx, double fy) =>
        Offset(b.left + b.width * fx, b.top + b.height * fy);

    var dx = 0.0, dy = 0.0, sx = 1.0, sy = 1.0, rot = 0.0, op = 1.0;
    var o = Offset.zero;

    switch (kind) {
      case _K.pop:
        final p = ((t - delay) / .75).clamp(0.0, 1.0).toDouble();
        sx = sy = _kf(p, [0, .6, 1], [.2, 1.14, 1], _cPop);
        rot = _kf(p, [0, .6, 1], [-12, 0, 0], _cPop);
        op = _kf(p, [0, .6, 1], [0, 1, 1], _cPop);
        o = at(.5, .8);
      case _K.drop:
        final p = ((t - delay) / .9).clamp(0.0, 1.0).toDouble();
        dy = _kf(p, [0, .55, .75, 1], [-170, 12, -5, 0], _cDrop);
        op = _kf(p, [0, .55, 1], [0, 1, 1], _cDrop);
      case _K.grow:
        final p = ((t - delay) / .8).clamp(0.0, 1.0).toDouble();
        sx = sy = _kf(p, [0, 1], [0, 1], _cGrow);
        op = _kf(p, [0, 1], [0, 1], _cGrow);
        o = at(0, 1);
      case _K.sweep:
        final p = ((t - delay) / 1.0).clamp(0.0, 1.0).toDouble();
        sx = _kf(p, [0, 1], [0, 1], _cSweep);
        op = _kf(p, [0, .15, 1], [0, 1, 1], _cSweep);
        o = at(0, .5);
      case _K.swim:
        final p = ((t - delay) / .9).clamp(0.0, 1.0).toDouble();
        dx = _kf(p, [0, 1], [-46, 0], _cSwim);
        rot = _kf(p, [0, 1], [-14, 0], _cSwim);
        sx = sy = _kf(p, [0, 1], [.6, 1], _cSwim);
        op = _kf(p, [0, 1], [0, 1], _cSwim);
        o = at(.5, .5);
      case _K.spark:
        final p = ((t - delay) / .5).clamp(0.0, 1.0).toDouble();
        sx = sy = _kf(p, [0, .6, 1], [.2, 1.2, 1], _cSpark);
        op = _kf(p, [0, .6, 1], [0, 1, 1], _cSpark);
        o = at(.5, .5);
    }

    op = op.clamp(0.0, 1.0).toDouble();
    c.save();
    if (base != null) c.transform(base!.storage);
    final fade = op < 1;
    if (fade) c.saveLayer(_layer, Paint()..color = Color.fromRGBO(0, 0, 0, op));
    c.translate(dx, dy);
    c.translate(o.dx, o.dy);
    c.rotate(_rad(rot));
    c.scale(sx, sy);
    c.translate(-o.dx, -o.dy);
    for (final s in shapes) {
      c.drawPath(s.path, s.paint);
    }
    if (fade) c.restore();
    c.restore();
  }
}

class _LayerPainter extends CustomPainter {
  _LayerPainter(this.groups, this.t);
  final List<_G> groups;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    for (final g in groups) {
      g.draw(canvas, t);
    }
  }

  @override
  bool shouldRepaint(covariant _LayerPainter old) => old.t != t;
}

class _Squash extends GradientTransform {
  const _Squash(this.sy);
  final double sy;
  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    final c = bounds.center;
    return Matrix4.translationValues(c.dx, c.dy, 0) *
        Matrix4.diagonal3Values(1, sy, 1) *
        Matrix4.translationValues(-c.dx, -c.dy, 0);
  }
}

// ───────────────────────── SHAPE HELPERS ─────────────────────────

Paint _fill(Color c) => Paint()..color = c;

Paint _stroke(Color c, double w) => Paint()
  ..color = c
  ..style = PaintingStyle.stroke
  ..strokeWidth = w
  ..strokeCap = StrokeCap.round;

Path _poly(List<double> pts) => Path()
  ..addPolygon([
    for (var i = 0; i < pts.length; i += 2) Offset(pts[i], pts[i + 1]),
  ], true);

Path _circle(double x, double y, double r) =>
    Path()..addOval(Rect.fromCircle(center: Offset(x, y), radius: r));

Path _ell(double cx, double cy, double rx, double ry, [double deg = 0]) {
  final p = Path()
    ..addOval(Rect.fromCenter(
        center: Offset(cx, cy), width: rx * 2, height: ry * 2));
  if (deg == 0) return p;
  final m = Matrix4.translationValues(cx, cy, 0) *
      Matrix4.rotationZ(_rad(deg)) *
      Matrix4.translationValues(-cx, -cy, 0);
  return p.transform(m.storage);
}

Path _line(double x1, double y1, double x2, double y2) =>
    Path()..moveTo(x1, y1)..lineTo(x2, y2);

Path _calyx(double x, double y) => Path()
  ..moveTo(x, y)
  ..relativeLineTo(8, 6)
  ..relativeLineTo(8, -6)
  ..relativeLineTo(-4, 8)
  ..relativeLineTo(-8, 0)
  ..close();

Path _leafP() => Path()
  ..moveTo(0, 0)
  ..cubicTo(18, -44, 64, -62, 104, -54)
  ..cubicTo(98, -10, 54, 26, 0, 0)
  ..close();

Path _leafT() => Path()
  ..moveTo(0, 0)
  ..cubicTo(20, -46, 66, -64, 106, -58)
  ..cubicTo(100, -12, 54, 26, 0, 0)
  ..close();

Path _veinP() => Path()
  ..moveTo(6, -2)
  ..cubicTo(36, -18, 66, -34, 96, -50);

Path _veinT() => Path()
  ..moveTo(8, -2)
  ..cubicTo(40, -20, 70, -38, 98, -54);

Matrix4 _at(double x, double y, double deg, [double scale = 1]) =>
    Matrix4.translationValues(x, y, 0) *
    Matrix4.rotationZ(_rad(deg)) *
    Matrix4.diagonal3Values(scale, scale, 1);

_G _hGrad(_K k, double d, Path p, Color a, Color b) => _G(k, d, [
      _S(p, Paint()..shader = LinearGradient(colors: [a, b]).createShader(p.getBounds())),
    ]);

// ───────────────────────── LAYERS ─────────────────────────

final List<_G> _back = [
  // awning posts
  _G(_K.drop, 1.2, [
    _S(_poly([196, 124, 212, 124, 224, 238, 208, 238]), _fill(const Color(0xFF8A5A2B))),
    _S(_poly([196, 124, 203, 124, 215, 238, 208, 238]), _fill(const Color(0xFFA8723A))),
    _S(_poly([372, 118, 388, 118, 400, 240, 384, 240]), _fill(const Color(0xFF8A5A2B))),
    _S(_poly([372, 118, 379, 118, 391, 240, 384, 240]), _fill(const Color(0xFFA8723A))),
  ]),
];

final List<_G> _front = _buildFront();

List<_G> _buildFront() {
  // ground shadow
  final shadowShader = const RadialGradient(
    radius: .5,
    colors: [Color.fromRGBO(233, 180, 90, .45), Color.fromRGBO(233, 180, 90, 0)],
    transform: _Squash(18 / 240),
  ).createShader(Rect.fromCircle(center: const Offset(470, 418), radius: 240));

  final swooshYellow = Path()
    ..moveTo(540, 402)
    ..cubicTo(660, 406, 740, 362, 820, 338)
    ..cubicTo(880, 320, 935, 330, 952, 362)
    ..cubicTo(902, 346, 860, 356, 820, 374)
    ..cubicTo(740, 406, 650, 430, 540, 402)
    ..close();
  final swooshGreen = Path()
    ..moveTo(246, 334)
    ..cubicTo(330, 330, 450, 372, 604, 398)
    ..cubicTo(470, 414, 330, 404, 246, 334)
    ..close();
  final swooshLine = Path()
    ..moveTo(290, 342)
    ..cubicTo(380, 350, 470, 376, 560, 392);

  // awning
  final top = [190, 221.7, 253.3, 285, 316.7, 348.3, 380];
  final bot = [85, 137.5, 190, 242.5, 295, 347.5, 400];
  const cols = [
    Color(0xFF17672C), Color(0xFF2C9143), Color(0xFFF5F0D6),
    Color(0xFF2C9143), Color(0xFFF7E7A1), Color(0xFFF2B81D),
  ];
  final awning = <_S>[];
  for (var i = 0; i < 6; i++) {
    awning.add(_S(
      _poly([
        top[i].toDouble(), 45, top[i + 1].toDouble(), 45,
        bot[i + 1].toDouble(), 128, bot[i].toDouble(), 128,
      ]),
      _fill(cols[i]),
    ));
    final mid = (bot[i] + bot[i + 1]) / 2;
    awning.add(_S(
      Path()
        ..moveTo(bot[i].toDouble(), 127)
        ..quadraticBezierTo(mid, 160, bot[i + 1].toDouble(), 127)
        ..close(),
      _fill(cols[i]),
    ));
  }
  awning.add(_S(_line(190, 45, 380, 45), _stroke(const Color(0xFF0F4D22), 5)));
  awning.add(_S(
    Path()
      ..moveTo(92, 132)
      ..quadraticBezierTo(250, 118, 394, 130),
    _stroke(const Color.fromRGBO(255, 255, 255, .25), 3),
  ));

  // fish body gradient (vertical, over the unrotated ellipse box)
  final fishShader = const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF4AA7DD), Color(0xFF7CC8EE)],
  ).createShader(Rect.fromCenter(center: const Offset(650, 322), width: 116, height: 54));

  return [
    _G(_K.grow, 5.2, [_S(_ell(470, 418, 240, 18), Paint()..shader = shadowShader)]),

    _hGrad(_K.sweep, 5.55, swooshYellow, const Color(0xFFF7CF4A), const Color(0xFFF0A818)),
    _hGrad(_K.sweep, 5.3, swooshGreen, const Color(0xFF1B7A32), const Color(0xFF6CBF3E)),
    _G(_K.sweep, 5.5, [_S(swooshLine, _stroke(const Color.fromRGBO(167, 220, 120, .7), 3))]),

    // crate
    _G(_K.pop, 3.9, [
      _S(_poly([395, 330, 520, 332, 512, 374, 405, 372]), _fill(const Color(0xFFC98A4B))),
      _S(_poly([395, 330, 520, 332, 519, 342, 396, 340]), _fill(const Color(0xFFE0A566))),
      _S(_line(399, 352, 516, 353), _stroke(const Color(0xFF9A6430), 3)),
      _S(_line(402, 364, 513, 364), _stroke(const Color(0xFF9A6430), 3)),
    ]),
    // greens
    _G(_K.pop, 4.05, [
      _S(_circle(414, 318, 22), _fill(const Color(0xFF4A9A3A))),
      _S(_circle(436, 306, 22), _fill(const Color(0xFF6DBB4A))),
      _S(_circle(498, 304, 20), _fill(const Color(0xFF5AAB3F))),
      _S(_circle(478, 296, 17), _fill(const Color(0xFF7CC957))),
    ]),
    // tomato 1
    _G(_K.pop, 4.2, [
      _S(_circle(440, 324, 19), _fill(const Color(0xFFE0302B))),
      _S(_ell(434, 316, 6, 4), _fill(const Color.fromRGBO(255, 255, 255, .35))),
      _S(_calyx(432, 306), _fill(const Color(0xFF2F8A3A))),
    ]),
    // tomato 2
    _G(_K.pop, 4.3, [
      _S(_circle(482, 326, 17), _fill(const Color(0xFFE8403A))),
      _S(_ell(477, 319, 5, 3.5), _fill(const Color.fromRGBO(255, 255, 255, .35))),
      _S(_calyx(474, 310), _fill(const Color(0xFF2F8A3A))),
    ]),
    // carrot
    _G(_K.pop, 4.45, [
      _S(
        Path()
          ..moveTo(562, 276)
          ..relativeQuadraticBezierTo(8, -18, 20, -14)
          ..relativeQuadraticBezierTo(-2, 14, -14, 22)
          ..close(),
        _fill(const Color(0xFF4FAA3A)),
      ),
      _S(
        Path()
          ..moveTo(572, 282)
          ..relativeQuadraticBezierTo(16, -12, 26, -2)
          ..relativeQuadraticBezierTo(-10, 10, -24, 10)
          ..close(),
        _fill(const Color(0xFF6CC24A)),
      ),
      _S(_ell(556, 324, 15, 44, 22), _fill(const Color(0xFFF08A1C))),
      _S(
        Path()
          ..moveTo(546, 300)..relativeQuadraticBezierTo(8, -6, 16, -2)
          ..moveTo(540, 322)..relativeQuadraticBezierTo(8, -4, 14, 0)
          ..moveTo(538, 342)..relativeQuadraticBezierTo(8, -4, 12, 0),
        _stroke(const Color(0xFFC96A0E), 2.5),
      ),
    ]),
    // fish
    _G(_K.swim, 4.65, [
      _S(_poly([598, 322, 572, 298, 574, 346]), _fill(const Color(0xFF2F86C0))),
      _S(_ell(650, 322, 58, 27, -10), Paint()..shader = fishShader),
      _S(
        Path()
          ..moveTo(612, 332)
          ..relativeQuadraticBezierTo(36, 18, 84, -4)
          ..relativeQuadraticBezierTo(-30, 20, -84, 4)
          ..close(),
        _fill(const Color.fromRGBO(217, 240, 251, .8)),
      ),
      _S(
        Path()
          ..moveTo(640, 296)
          ..relativeQuadraticBezierTo(10, -16, 28, -12)
          ..relativeQuadraticBezierTo(-6, 10, -6, 18)
          ..close(),
        _fill(const Color(0xFF2F86C0)),
      ),
      _S(_circle(690, 310, 6), _fill(Colors.white)),
      _S(_circle(692, 310, 3), _fill(const Color(0xFF10202C))),
      _S(
        Path()
          ..moveTo(672, 330)
          ..relativeQuadraticBezierTo(8, 2, 14, -2),
        _stroke(const Color(0xFF2A7AAE), 2.5),
      ),
    ]),

    // leaf tucked into the P
    _G(_K.grow, 5.85, [_S(_leafP(), _fill(const Color(0xFF6CBF45)))], base: _at(212, 276, -38, .9)),
    _G(_K.grow, 5.95, [_S(_veinP(), _stroke(const Color(0xFF2F8A3A), 3))], base: _at(212, 276, -38, .9)),

    // leaves, top right
    _G(_K.grow, 5.7, [_S(_leafT(), _fill(const Color(0xFF2F9A46)))], base: _at(748, 152, -8)),
    _G(_K.grow, 5.8, [_S(_veinT(), _stroke(const Color(0xFFBFE6A2), 3))], base: _at(748, 152, -8)),
    _G(_K.grow, 5.95, [_S(_leafT(), _fill(const Color(0xFF14602A)))], base: _at(812, 160, -6, .75)),
    _G(_K.grow, 6.05, [_S(_veinT(), _stroke(const Color(0xFF7BC25A), 3.5))], base: _at(812, 160, -6, .75)),

    // sparks around the P
    _G(_K.spark, .55, [_S(_line(66, 214, 110, 228), _stroke(const Color(0xFF4FAE3C), 9))]),
    _G(_K.spark, .65, [_S(_line(80, 264, 118, 246), _stroke(const Color(0xFF4FAE3C), 9))]),
    _G(_K.spark, .75, [_S(_line(236, 196, 250, 172), _stroke(const Color(0xFF4FAE3C), 9))]),
    // sparks around the awning
    _G(_K.spark, 5.4, [_S(_line(430, 112, 462, 70), _stroke(const Color(0xFF6CC24A), 9))]),
    _G(_K.spark, 5.5, [_S(_line(448, 142, 494, 124), _stroke(const Color(0xFF6CC24A), 9))]),

    // awning (drops in on top)
    _G(_K.drop, 1.2, awning),
  ];
}
