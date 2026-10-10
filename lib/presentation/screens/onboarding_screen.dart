import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../providers/providers.dart';
import '../widgets/onboarding_art.dart';
import 'home_shell.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _page = 0;

  final _nameController = TextEditingController();
  bool _saving = false;

  static const _slides = [
    (
      kind: OnboardingArtKind.alarm,
      title: 'Alarm Keras & Jelas',
      body:
          'Alarm berbunyi seperti alarm panggilan, disertai nama obat dan foto agar tidak pernah keliru.',
    ),
    (
      kind: OnboardingArtKind.family,
      title: 'Satu Keluarga, Satu Jadwal',
      body:
          'Semua anggota keluarga bisa melihat dan mengonfirmasi obat yang sudah diminum.',
    ),
    (
      kind: OnboardingArtKind.offline,
      title: 'Tetap Jalan Tanpa Internet',
      body:
          'Semua fitur inti bekerja offline. Gratis sepenuhnya, tanpa biaya bulanan.',
    ),
  ];

  int get _total => _slides.length + 1;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _finish({bool createMember = false}) async {
    setState(() => _saving = true);
    if (createMember && _nameController.text.trim().isNotEmpty) {
      await ref.read(repositoryProvider).createMember(
            name: _nameController.text.trim(),
          );
    }
    await ref.read(appSettingsProvider.notifier).setOnboardingDone(true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scaffold(
      backgroundColor: p.canvas,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  ..._slides.map((s) => _Slide(
                        kind: s.kind,
                        title: s.title,
                        body: s.body,
                      )),
                  _memberStep(),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < _total; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _page ? 22 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _page ? p.primary : p.border,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  if (_page < _slides.length)
                    TextButton(
                      onPressed: () => _finish(),
                      child: const Text('Lewati'),
                    ),
                  const Spacer(),
                  if (_page < _slides.length)
                    FilledButton(
                      onPressed: () => _pageController.nextPage(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                      ),
                      child: const Text('Lanjut'),
                    )
                  else
                    FilledButton(
                      onPressed:
                          _saving ? null : () => _finish(createMember: true),
                      child: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Mulai Gunakan'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _memberStep() {
    final p = context.palette;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          Center(
            child: OnboardingArt(
              kind: OnboardingArtKind.member,
              color: p.primary,
              accent: p.accent,
              container: p.primaryContainer,
              size: 148,
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'Siapa yang akan diingatkan?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
              color: p.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tambahkan satu anggota keluarga dulu. Kamu bisa menambah lainnya kapan saja.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: p.textSecondary,
              fontSize: 15,
              height: 1.45,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          TextField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Nama anggota (mis. Ibu)',
              prefixIcon: Icon(Icons.badge_outlined),
            ),
          ),
        ],
      ),
    );
  }
}

class _Slide extends StatelessWidget {
  final OnboardingArtKind kind;
  final String title;
  final String body;
  const _Slide({required this.kind, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          OnboardingArt(
            kind: kind,
            color: p.primary,
            accent: p.accent,
            container: p.primaryContainer,
          ),
          const SizedBox(height: 36),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
              color: p.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            body,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: p.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
