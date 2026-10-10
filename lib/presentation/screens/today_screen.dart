import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/dates.dart';
import '../../data/database/app_database.dart';
import '../../domain/services/widget_service.dart';
import '../providers/providers.dart';
import '../widgets/common.dart';
import '../widgets/dose_card.dart';
import 'member_form_screen.dart';
import 'settings_screen.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    final now = DateTime.now();
    await ref
        .read(doseServiceProvider)
        .ensureDoseLogsForRange(now, now.add(const Duration(days: 3)));
    await ref.read(doseServiceProvider).reconcileMissed();
    await ref.read(alarmCoordinatorProvider).rescheduleAll();
    await WidgetService.refresh(ref.read(databaseProvider));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final logsAsync = ref.watch(todayDoseLogsProvider);
    final meds = ref.watch(allMedicinesProvider).value ?? const [];
    final members = ref.watch(membersProvider).value ?? const [];
    final settings = ref.watch(appSettingsProvider);
    final modes = ref.watch(alarmModesProvider).value ?? const {};

    // FR-19: banner bila belum ada anggota yang di-set "Alarm keras" di HP ini.
    final activeIds = members.map((m) => m.id).toSet();
    final hasFullAlarm = modes.entries
        .any((e) => e.value == 'full_alarm' && activeIds.contains(e.key));

    final medById = {for (final m in meds) m.id: m};
    final memberById = {for (final m in members) m.id: m};

    final logs = logsAsync.value ?? const <DoseLog>[];
    final pending = logs
        .where((l) => l.status == 'pending' || l.status == 'snoozed')
        .toList();
    final done = logs.where((l) => l.status == 'taken').toList();
    final missed = logs.where((l) => l.status == 'missed').toList();
    final skipped = logs.where((l) => l.status == 'skipped').toList();

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => _refresh(ref),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: 150,
              backgroundColor: p.primary,
              foregroundColor: p.onPrimary,
              elevation: 0,
              scrolledUnderElevation: 0,
              shape: const Border(),
              systemOverlayStyle:
                  p.highContrast ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light,
              titleTextStyle: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: p.onPrimary,
              ),
              title: const Text('Hari Ini'),
              flexibleSpace: FlexibleSpaceBar(
                background: _HeroHeader(
                  dayName: Dates.dayName(DateTime.now()),
                  dateFull: Dates.dateFull(DateTime.now()),
                  greeting: _greeting(),
                  trailing: settings.highContrast
                      ? Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: Icon(Icons.contrast, color: p.onPrimary),
                        )
                      : null,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
                child: _summaryCard(
                    context, pending.length, done.length, missed.length),
              ),
            ),
            if (members.isNotEmpty && !hasFullAlarm)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
                  child: _alarmBanner(context),
                ),
              ),
            if (members.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  icon: Icons.person_add_alt_1,
                  title: 'Belum ada anggota keluarga',
                  subtitle:
                      'Tambahkan anggota terlebih dahulu, lalu buat jadwal minum obatnya.',
                  action: FilledButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const MemberFormScreen()),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah Anggota'),
                  ),
                ),
              )
            else ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: SectionHeader(
                    'Perlu Dikonfirmasi (${pending.length})',
                  ),
                ),
              ),
              if (pending.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: _allDoneCard(context),
                  ),
                )
              else
                SliverList.builder(
                  itemCount: pending.length,
                  itemBuilder: (_, i) {
                    final l = pending[i];
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(
                          AppSpacing.md, 0, AppSpacing.md, AppSpacing.sm),
                      child: DoseCard(
                        log: l,
                        medicine: medById[l.medicineId],
                        member: memberById[l.memberId],
                      ),
                    );
                  },
                ),
              if (missed.isNotEmpty || skipped.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: SectionHeader(
                        'Terlewat / Dilewati (${missed.length + skipped.length})'),
                  ),
                ),
                SliverList.builder(
                  itemCount: missed.length + skipped.length,
                  itemBuilder: (_, i) {
                    final l = i < missed.length
                        ? missed[i]
                        : skipped[i - missed.length];
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(
                          AppSpacing.md, 0, AppSpacing.md, AppSpacing.sm),
                      child: DoseCard(
                        log: l,
                        medicine: medById[l.medicineId],
                        member: memberById[l.memberId],
                        compact: true,
                      ),
                    );
                  },
                ),
              ],
              if (done.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: SectionHeader('Sudah Minum (${done.length})'),
                  ),
                ),
                SliverList.builder(
                  itemCount: done.length,
                  itemBuilder: (_, i) {
                    final l = done[i];
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(
                          AppSpacing.md, 0, AppSpacing.md, AppSpacing.sm),
                      child: DoseCard(
                        log: l,
                        medicine: medById[l.medicineId],
                        member: memberById[l.memberId],
                        compact: true,
                      ),
                    );
                  },
                ),
              ],
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
            ],
          ],
        ),
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 11) return 'Selamat pagi';
    if (h < 15) return 'Selamat siang';
    if (h < 19) return 'Selamat sore';
    return 'Selamat malam';
  }

  Widget _summaryCard(BuildContext context, int pending, int taken, int missed) {
    final p = context.palette;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: 4),
        child: Row(
          children: [
            _stat(context, Icons.schedule_rounded, 'Menunggu', pending, p.primary),
            _vdivider(context),
            _stat(context, Icons.check_circle_rounded, 'Sudah', taken, p.success),
            _vdivider(context),
            _stat(context, Icons.error_rounded, 'Terlewat', missed, p.error),
          ],
        ),
      ),
    );
  }

  Widget _vdivider(BuildContext context) => Container(
        width: 1,
        height: 42,
        color: context.palette.divider,
      );

  Widget _stat(BuildContext context, IconData icon, String label, int value,
      Color color) {
    final p = context.palette;
    return Expanded(
      child: Column(
        children: [
          Text(
            '$value',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              height: 1.1,
              color: color,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 13, color: p.textSecondary),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: p.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _alarmBanner(BuildContext context) {
    final p = context.palette;
    return Container(
      decoration: BoxDecoration(
        color: p.highContrast ? Colors.transparent : p.primaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: p.highContrast ? p.border : p.primaryContainer),
      ),
      padding: const EdgeInsets.fromLTRB(14, 14, 8, 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: p.highContrast
                  ? Colors.transparent
                  : p.primary.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.notifications_active_rounded,
                color: p.primary, size: 21),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Aktifkan Alarm Keras',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: p.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Pilih di HP ini anggota mana yang perlu membunyikan weker keras.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.35,
                    color: p.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
            child: const Text('Atur'),
          ),
        ],
      ),
    );
  }

  Widget _allDoneCard(BuildContext context) {
    final p = context.palette;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: p.highContrast
                    ? Colors.transparent
                    : p.success.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: p.highContrast ? Border.all(color: p.success) : null,
              ),
              child: Icon(Icons.check_circle_rounded, color: p.success, size: 22),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'Semua obat hari ini sudah dikonfirmasi. Kerja bagus!',
                style: TextStyle(fontSize: 14.5, color: p.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Latar header beranda: gradasi merek + ornamen lingkaran halus.
class _HeroHeader extends StatelessWidget {
  final String dayName;
  final String dateFull;
  final String greeting;
  final Widget? trailing;

  const _HeroHeader({
    required this.dayName,
    required this.dateFull,
    required this.greeting,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [p.primary, p.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -40,
            top: -30,
            child: _orb(140, p.onPrimary.withValues(alpha: 0.07)),
          ),
          Positioned(
            right: 60,
            top: 40,
            child: _orb(64, p.onPrimary.withValues(alpha: 0.06)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, 18),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: TextStyle(
                    color: p.onPrimary.withValues(alpha: 0.8),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  dateFull,
                  style: TextStyle(
                    color: p.onPrimary,
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  dayName,
                  style: TextStyle(
                    color: p.onPrimary.withValues(alpha: 0.8),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null)
            Positioned(top: 8, right: 0, child: trailing!),
        ],
      ),
    );
  }

  Widget _orb(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}
