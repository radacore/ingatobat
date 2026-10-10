import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Satu putaran loop animasi onboarding (nyaman & tenang).
const _kLoop = Duration(milliseconds: 3600);

enum OnboardingArtKind { alarm, family, offline, member }

/// Ilustrasi beranimasi untuk tiap slide onboarding. Digambar native via
/// [CustomPaint] (tanpa dependensi) memakai warna palet aplikasi, sejalan
/// dengan adegan splash (`splash_screen.dart`).
///
/// Menghormati *reduced motion*: bila animasi dimatikan OS, loop dibekukan
/// pada pose yang enak dilihat.
class OnboardingArt extends StatefulWidget {
  final OnboardingArtKind kind;
  final Color color;
  final Color accent;
  final Color container;
  final double size;

  const OnboardingArt({
    super.key,
    required this.kind,
    required this.color,
    required this.accent,
    required this.container,
    this.size = 176,
  });

  @override
  State<OnboardingArt> createState() => _OnboardingArtState();
}

class _OnboardingArtState extends State<OnboardingArt>
    with TickerProviderStateMixin {
  late final AnimationController _entrance;
  late final AnimationController _loop;

  @override
  void initState() {
    super.initState();
    _entrance =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 850))
          ..forward();
    _loop = AnimationController(vsync: this, duration: _kLoop);
    if (!WidgetsBinding.instance.disableAnimations) {
      _loop.repeat();
    } else {
      _loop.value = 0.62;
    }
  }

  @override
  void dispose() {
    _entrance.dispose();
    _loop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: Listenable.merge([_entrance, _loop]),
        builder: (context, _) => CustomPaint(
          painter: _ArtPainter(
            kind: widget.kind,
            t: _loop.value,
            e: Curves.easeOutCubic.transform(_entrance.value),
            color: widget.color,
            accent: widget.accent,
            container: widget.container,
          ),
        ),
      ),
    );
  }
}

class _ArtPainter extends CustomPainter {
  final OnboardingArtKind kind;

  /// 0..1 posisi dalam loop berulang.
  final double t;

  /// 0..1 progress entrance satu-kali (sudah di-ease).
  final double e;

  final Color color;
  final Color accent;
  final Color container;

  _ArtPainter({
    required this.kind,
    required this.t,
    required this.e,
    required this.color,
    required this.accent,
    required this.container,
  });

  static const _vb = 240.0;

  double _backOut(double x) {
    const c1 = 1.70158;
    const c3 = c1 + 1;
    final u = x - 1;
    return 1 + c3 * u * u * u + c1 * u * u;
  }

  /// Pop sekali saat entrance, dengan delay opsional (0..0.6).
  double _pop(double delay) {
    final x = ((e - delay) / (1 - delay)).clamp(0.0, 1.0);
    return _backOut(x).clamp(0.0, 1.25);
  }

  double _bob(double phase) => 3.0 * math.sin(2 * math.pi * (t + phase));

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / _vb;
    canvas.save();
    canvas.scale(s);

    // Piringan lembut di belakang ilustrasi.
    canvas.drawCircle(
      const Offset(120, 120),
      100,
      Paint()..color = container,
    );

    switch (kind) {
      case OnboardingArtKind.alarm:
        _alarm(canvas);
      case OnboardingArtKind.family:
        _family(canvas);
      case OnboardingArtKind.offline:
        _offline(canvas);
      case OnboardingArtKind.member:
        _member(canvas);
    }

    canvas.restore();
  }

  // ---- Slide 1: alarm keras & jelas ----
  void _alarm(Canvas canvas) {
    // Gelombang bunyi mengembang bergantian (mulai & berakhir transparan).
    for (var i = 0; i < 2; i++) {
      final phase = (t + i * 0.5) % 1.0;
      final grow = (phase / 0.5).clamp(0.0, 1.0);
      double a;
      if (phase < 0.12) {
        a = 0.5 * phase / 0.12;
      } else if (phase < 0.5) {
        a = 0.5 * (1 - (phase - 0.12) / 0.38);
      } else {
        a = 0;
      }
      if (a > 0.005) {
        canvas.drawCircle(
          const Offset(120, 116),
          62 * (0.6 + 0.7 * grow),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 5
            ..color = color.withValues(alpha: a * e),
        );
      }
    }

    // Lonceng: pop masuk + goyang lembut.
    final pop = _backOut(e.clamp(0.0, 1.0)).clamp(0.0, 1.2);
    final shake = 5 * math.sin(2 * math.pi * t);
    canvas.save();
    canvas.translate(120 + shake, 120);
    canvas.scale(pop);
    canvas.translate(-120, -120);

    canvas.drawCircle(const Offset(120, 72), 8, Paint()..color = color);
    canvas.drawPath(
      Path()
        ..moveTo(88, 152)
        ..cubicTo(88, 112, 102, 94, 120, 94)
        ..cubicTo(138, 94, 152, 112, 152, 152)
        ..close(),
      Paint()..color = color,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(82, 152, 76, 10), const Radius.circular(5)),
      Paint()..color = color,
    );
    canvas.drawCircle(const Offset(120, 170), 8, Paint()..color = accent);
    canvas.restore();
  }

  // ---- Slide 2: satu keluarga, satu jadwal ----
  void _family(Canvas canvas) {
    _avatar(canvas, const Offset(120, 110), 23, color, _pop(0.0),
        _bob(0.0));
    _avatar(canvas, const Offset(76, 150), 16, accent, _pop(0.20),
        _bob(0.33));
    _avatar(canvas, const Offset(164, 150), 16, accent, _pop(0.34),
        _bob(0.66));
  }

  void _avatar(Canvas canvas, Offset c, double r, Color col, double pop,
      double dy) {
    if (pop <= 0.01) return;
    canvas.save();
    canvas.translate(c.dx, c.dy + dy);
    canvas.scale(pop);
    // Kepala.
    canvas.drawCircle(Offset(0, -r * 0.5), r * 0.52, Paint()..color = col);
    // Bahu (setengah kapsul).
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromCenter(
            center: Offset(0, r * 0.72), width: r * 1.75, height: r * 1.1),
        topLeft: Radius.circular(r * 0.85),
        topRight: Radius.circular(r * 0.85),
        bottomLeft: const Radius.circular(3),
        bottomRight: const Radius.circular(3),
      ),
      Paint()..color = col,
    );
    canvas.restore();
  }

  // ---- Slide 3: tetap jalan tanpa internet ----
  void _offline(Canvas canvas) {
    // Denyut lembut di belakang perangkat.
    for (var i = 0; i < 2; i++) {
      final phase = (t + i * 0.5) % 1.0;
      final grow = (phase / 0.5).clamp(0.0, 1.0);
      double a;
      if (phase < 0.12) {
        a = 0.35 * phase / 0.12;
      } else if (phase < 0.5) {
        a = 0.35 * (1 - (phase - 0.12) / 0.38);
      } else {
        a = 0;
      }
      if (a > 0.005) {
        canvas.drawCircle(
          const Offset(120, 120),
          66 * (0.7 + 0.5 * grow),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 5
            ..color = accent.withValues(alpha: a * e),
        );
      }
    }

    final pop = _backOut(e.clamp(0.0, 1.0)).clamp(0.0, 1.2);
    final bob = _bob(0.15);
    canvas.save();
    canvas.translate(120, 120 + bob);
    canvas.scale(pop);
    canvas.translate(-120, -120);

    // Perangkat.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(92, 72, 56, 96), const Radius.circular(12)),
      Paint()..color = color,
    );
    // Layar.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(100, 84, 40, 64), const Radius.circular(6)),
      Paint()..color = container,
    );
    canvas.restore();

    // Centang menggambar sendiri di layar (loop bersih: gambar -> tahan -> hapus).
    double frac;
    if (t < 0.15) {
      frac = 0;
    } else if (t < 0.5) {
      frac = (t - 0.15) / 0.35;
    } else if (t < 0.85) {
      frac = 1;
    } else {
      frac = 1 - (t - 0.85) / 0.15;
    }
    frac *= e;
    if (frac > 0.01) {
      final path = Path()
        ..moveTo(109, 118 + bob)
        ..lineTo(118, 127 + bob)
        ..lineTo(133, 106 + bob);
      final metric = path.computeMetrics().first;
      canvas.drawPath(
        metric.extractPath(0, metric.length * frac),
        Paint()
          ..color = accent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }
  }

  // ---- Slide 4: siapa yang diingatkan ----
  void _member(Canvas canvas) {
    _avatar(canvas, const Offset(112, 118), 30, color, _pop(0.0), _bob(0.0));

    // Lencana "+" pop tiap loop.
    double b;
    if (t < 0.35) {
      b = 0;
    } else if (t < 0.40) {
      b = 1.2 * (t - 0.35) / 0.05;
    } else if (t < 0.45) {
      b = 1.2 - 0.2 * (t - 0.40) / 0.05;
    } else if (t < 0.80) {
      b = 1;
    } else if (t < 0.90) {
      b = 1 - (t - 0.80) / 0.10;
    } else {
      b = 0;
    }
    b *= e;
    if (b <= 0.01) return;
    const c = Offset(162, 74);
    canvas.drawCircle(c, 17 * b, Paint()..color = accent);
    final plus = Paint()
      ..color = container
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(c + const Offset(-8, 0), c + const Offset(8, 0), plus);
    canvas.drawLine(c + const Offset(0, -8), c + const Offset(0, 8), plus);
  }

  @override
  bool shouldRepaint(covariant _ArtPainter old) =>
      old.t != t ||
      old.e != e ||
      old.kind != kind ||
      old.color != color ||
      old.accent != accent ||
      old.container != container;
}
