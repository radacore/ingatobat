import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/services/alarm_service.dart';
import '../../domain/services/widget_service.dart';
import '../providers/providers.dart';
import 'home_shell.dart';
import 'onboarding_screen.dart';

/// Satu putaran loop adegan splash (sinkron dengan `splash_care.svg`).
const _kLoop = Duration(milliseconds: 4000);

/// Durasi entrance satu-kali saat splash pertama tampil.
const _kEntrance = Duration(milliseconds: 900);

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entrance;
  late final AnimationController _loop;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(vsync: this, duration: _kEntrance)
      ..forward();
    _loop = AnimationController(vsync: this, duration: _kLoop);
    if (!WidgetsBinding.instance.disableAnimations) {
      _loop.repeat();
    } else {
      // Gerak yang dikurangi: bekukan di pose badge terlihat.
      _loop.value = 0.62;
    }
    _boot();
  }

  @override
  void dispose() {
    _entrance.dispose();
    _loop.dispose();
    super.dispose();
  }

  Future<void> _boot() async {
    final db = ref.read(databaseProvider);
    final settings = ref.read(appSettingsProvider);
    // Tahan splash min. 3,5 dtk agar animasi (loop 4 dtk) sempat dimainkan.
    final startedAt = DateTime.now();

    try {
      // Sinkronkan alarm yang mungkin hilang (reboot/pembaruan jadwal).
      await ref.read(doseServiceProvider).ensureDoseLogsForRange(
            DateTime.now(),
            DateTime.now().add(const Duration(days: 3)),
          );
      await ref.read(doseServiceProvider).reconcileMissed();
      await ref.read(alarmCoordinatorProvider).rescheduleAll();
      await WidgetService.refresh(db);

      final tts = await AlarmService.isTtsAvailable();
      await ref.read(appSettingsProvider.notifier).setTtsAvailable(tts);
    } catch (_) {
      // Tetap lanjut ke aplikasi walau inisialisasi alarm gagal.
    }

    if (!mounted) return;
    final elapsed = DateTime.now().difference(startedAt);
    const minSplash = Duration(milliseconds: 3500);
    if (elapsed < minSplash) {
      await Future.delayed(minSplash - elapsed);
    }
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => settings.onboardingDone
            ? const HomeShell()
            : const OnboardingScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primaryDark],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: Listenable.merge([_entrance, _loop]),
            builder: (context, _) {
              final e = Curves.easeOutCubic.transform(_entrance.value);
              final t = _loop.value;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 208,
                    height: 208,
                    child: CustomPaint(
                      painter: _SplashScenePainter(entrance: e, loop: t),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Opacity(
                    opacity: e,
                    child: Transform.translate(
                      offset: Offset(0, 18 * (1 - e)),
                      child: const Text(
                        'IngatObat',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.6,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Opacity(
                    opacity: e * 0.75,
                    child: const Text(
                      'Pengingat obat keluarga',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 36),
                  const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Adegan splash: jam alarm bergetar + gelombang bunyi + kapsul & tablet
/// mengambang + badge "sudah minum" yang pop-in dengan centang draw-on.
///
/// Geometri (viewBox 240x240) dan timeline (loop 4 dtk) mencerminkan
/// `assets/animations/splash_care.svg` — file SVG adalah sumber storyboard.
class _SplashScenePainter extends CustomPainter {
  /// 0..1, progress entrance satu-kali (sudah di-ease).
  final double entrance;

  /// 0..1, posisi dalam loop berulang.
  final double loop;

  _SplashScenePainter({required this.entrance, required this.loop});

  static const _blue = Color(0xFF1565C0);
  static const _darkBlue = Color(0xFF0D47A1);
  static const _teal = Color(0xFF00897B);
  static const _white = Colors.white;

  double _backOut(double x) {
    const c1 = 1.70158;
    const c3 = c1 + 1;
    final u = x - 1;
    return 1 + c3 * u * u * u + c1 * u * u;
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Petakan viewBox 240 ke ukuran aktual.
    final s = size.width / 240;
    canvas.save();
    canvas.scale(s);
    final e = entrance;
    final t = loop;

    // Halo lembut.
    canvas.drawCircle(
      const Offset(120, 120),
      72,
      Paint()..color = _white.withValues(alpha: 0.18 * e),
    );

    // Gelombang bunyi: dua cincin mengembang bergantian.
    for (var i = 0; i < 2; i++) {
      final phase = (t + i * 0.5) % 1.0;
      final grow = (phase / 0.5).clamp(0.0, 1.0);
      double alpha;
      if (phase < 0.12) {
        alpha = 0.5 * phase / 0.12;
      } else if (phase < 0.5) {
        alpha = 0.5 * (1 - (phase - 0.12) / 0.38);
      } else {
        alpha = 0;
      }
      if (alpha > 0.005) {
        canvas.drawCircle(
          const Offset(120, 120),
          58 * (0.62 + 0.68 * grow),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 5
            ..color = _white.withValues(alpha: alpha * e),
        );
      }
    }

    // Kapsul kiri: meluncur masuk + mengambang.
    _drawCapsule(canvas, e, t);

    // Tablet kanan: meluncur masuk + mengambang berlawanan fase.
    _drawTablet(canvas, e, t);

    // Jam alarm: pop entrance + napas + lonceng bergetar.
    _drawClock(canvas, e, t);

    // Badge "sudah minum": pop + centang draw-on.
    _drawBadge(canvas, e, t);

    // Kilau berkelip.
    _drawSparkles(canvas, e, t);

    canvas.restore();
  }

  void _drawClock(Canvas canvas, double e, double t) {
    final pop = _backOut(e.clamp(0.0, 1.0)).clamp(0.0, 1.25);
    final breath = 1 + 0.025 * (1 - math.cos(2 * math.pi * t));
    final rock = 0.03 * math.sin(2 * math.pi * t);

    canvas.save();
    canvas.translate(120, 120);
    canvas.rotate(rock);
    canvas.scale(pop * breath);
    canvas.translate(-120, -120);

    // Kaki.
    final legPaint = Paint()
      ..color = _darkBlue
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(96, 158), const Offset(88, 172), legPaint);
    canvas.drawLine(const Offset(144, 158), const Offset(152, 172), legPaint);

    // Tombol atas.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(112, 70, 16, 9), const Radius.circular(4.5)),
      Paint()..color = _darkBlue,
    );

    // Badan + muka.
    canvas.drawCircle(const Offset(120, 120), 44, Paint()..color = _blue);
    canvas.drawCircle(const Offset(120, 120), 34, Paint()..color = _white);

    // Jarum 10:10.
    final handPaint = Paint()
      ..color = _blue
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(120, 120), const Offset(120, 98), handPaint);
    canvas.drawLine(const Offset(120, 120), const Offset(136, 129), handPaint);
    canvas.drawCircle(const Offset(120, 120), 5, Paint()..color = _teal);
    canvas.restore();

    // Lonceng bergetar berlawanan fase (di luar transform badan).
    final shake = 6 * math.sin(2 * math.pi * t);
    final bellPaint = Paint()..color = _darkBlue.withValues(alpha: e);
    canvas.drawCircle(Offset(80 - shake, 64), 13 * pop, bellPaint);
    canvas.drawCircle(Offset(160 + shake, 64), 13 * pop, bellPaint);
  }

  void _drawCapsule(Canvas canvas, double e, double t) {
    final slide = -46 * (1 - e);
    final bob = -3.5 + 3.5 * math.cos(4 * math.pi * t);
    canvas.save();
    canvas.translate(53 + slide, 152 + bob);
    canvas.rotate(-20 * math.pi / 180);
    final alpha = e;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: 58, height: 26),
          const Radius.circular(13)),
      Paint()..color = _blue.withValues(alpha: alpha),
    );
    canvas.drawPath(
      Path()
        ..moveTo(0, -13)
        ..lineTo(16, -13)
        ..arcToPoint(const Offset(16, 13),
            radius: const Radius.circular(13))
        ..lineTo(0, 13)
        ..close(),
      Paint()..color = _teal.withValues(alpha: alpha),
    );
    canvas.drawLine(
      const Offset(0, -13),
      const Offset(0, 13),
      Paint()
        ..color = _white.withValues(alpha: alpha)
        ..strokeWidth = 3,
    );
    canvas.restore();
  }

  void _drawTablet(Canvas canvas, double e, double t) {
    final slide = 46 * (1 - e);
    final bob = 3.5 - 3.5 * math.cos(4 * math.pi * t);
    final c = Offset(188 + slide, 152 + bob);
    canvas.drawCircle(c, 15, Paint()..color = _teal.withValues(alpha: e));
    canvas.drawLine(
      c + const Offset(-12, 0),
      c + const Offset(12, 0),
      Paint()
        ..color = _white.withValues(alpha: e)
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawBadge(Canvas canvas, double e, double t) {
    // Pop-in tiap loop: 0.35 muncul, 0.45 penuh, 0.8-0.9 keluar.
    double s;
    if (t < 0.35) {
      s = 0;
    } else if (t < 0.40) {
      s = 1.2 * (t - 0.35) / 0.05;
    } else if (t < 0.45) {
      s = 1.2 - 0.2 * (t - 0.40) / 0.05;
    } else if (t < 0.80) {
      s = 1;
    } else if (t < 0.90) {
      s = 1 - (t - 0.80) / 0.10;
    } else {
      s = 0;
    }
    s *= e;
    if (s <= 0.01) return;

    const c = Offset(172, 64);
    canvas.drawCircle(c, 17 * s, Paint()..color = _teal);

    // Centang draw-on 0.40 -> 0.48.
    final frac = ((t - 0.40) / 0.08).clamp(0.0, 1.0);
    if (frac <= 0) return;
    final path = Path()
      ..moveTo(164, 64)
      ..lineTo(170, 70)
      ..lineTo(181, 58);
    final metric = path.computeMetrics().first;
    final drawn = metric.extractPath(0, metric.length * frac);
    canvas.save();
    canvas.translate(c.dx * (1 - s), c.dy * (1 - s));
    canvas.scale(s);
    canvas.drawPath(
      drawn,
      Paint()
        ..color = _white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.restore();
  }

  void _drawSparkles(Canvas canvas, double e, double t) {
    Path sparkle(double r) => Path()
      ..moveTo(0, -r)
      ..cubicTo(r * 0.12, -r * 0.25, r * 0.25, -r * 0.12, r, 0)
      ..cubicTo(r * 0.25, r * 0.12, r * 0.12, r * 0.25, 0, r)
      ..cubicTo(-r * 0.12, r * 0.25, -r * 0.25, r * 0.12, -r, 0)
      ..cubicTo(-r * 0.25, -r * 0.12, -r * 0.12, -r * 0.25, 0, -r)
      ..close();

    double pulse(double start, double end) {
      if (t < start || t > end) return 0;
      return math.sin(math.pi * (t - start) / (end - start));
    }

    final a1 = pulse(0, 0.30);
    if (a1 > 0.01) {
      canvas.save();
      canvas.translate(44, 76);
      canvas.scale(0.6 + 0.5 * a1);
      canvas.drawPath(
          sparkle(10), Paint()..color = _white.withValues(alpha: a1 * e));
      canvas.restore();
    }
    final a2 = pulse(0.50, 0.85);
    if (a2 > 0.01) {
      canvas.save();
      canvas.translate(202, 104);
      canvas.scale(0.6 + 0.5 * a2);
      canvas.drawPath(
          sparkle(8), Paint()..color = _white.withValues(alpha: a2 * e));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _SplashScenePainter old) =>
      old.entrance != entrance || old.loop != loop;
}
