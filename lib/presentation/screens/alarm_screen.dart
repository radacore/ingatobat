import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/dates.dart';
import '../../data/database/app_database.dart';
import '../../domain/services/alarm_service.dart';
import '../providers/providers.dart';
import '../widgets/common.dart';
import '../widgets/dose_card.dart';
import '../widgets/sheets.dart';

/// Layar alarm layar-penuh saat waktu minum tiba (FR-05).
class AlarmScreen extends ConsumerStatefulWidget {
  final List<String> doseLogIds;
  const AlarmScreen({super.key, required this.doseLogIds});

  @override
  ConsumerState<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends ConsumerState<AlarmScreen>
    with SingleTickerProviderStateMixin {
  bool _loading = true;
  bool _busy = false;
  List<DoseLog> _logs = const [];
  Map<String, Medicine> _meds = const {};
  Map<String, Member> _members = const {};

  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat(reverse: true);

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final db = ref.read(databaseProvider);
    final logs = await db.getDoseLogsByIds(widget.doseLogIds);
    final meds = <String, Medicine>{};
    final members = <String, Member>{};
    for (final l in logs) {
      if (!meds.containsKey(l.medicineId)) {
        final m = await db.getMedicine(l.medicineId);
        if (m != null) meds[m.id] = m;
      }
      if (!members.containsKey(l.memberId)) {
        final m = await db.getMember(l.memberId);
        if (m != null) members[m.id] = m;
      }
    }
    if (!mounted) return;
    setState(() {
      _logs = logs;
      _meds = meds;
      _members = members;
      _loading = false;
    });
  }

  Future<void> _finish() async {
    try {
      await AlarmService.stopAlarm();
    } catch (_) {}
    if (mounted) Navigator.of(context).maybePop();
  }

  Future<void> _taken() async {
    setState(() => _busy = true);
    final actions = DoseActions(ref);
    for (final l in _logs) {
      await actions.taken(l);
    }
    await _finish();
  }

  Future<void> _snooze() async {
    final minutes = await showSnoozeSheet(context);
    if (minutes == null) return;
    setState(() => _busy = true);
    final actions = DoseActions(ref);
    for (final l in _logs) {
      await actions.snooze(l, minutes);
    }
    await _finish();
  }

  Future<void> _skip() async {
    final reason = await showSkipReasonSheet(context);
    if (reason == null) return;
    setState(() => _busy = true);
    final actions = DoseActions(ref);
    for (final l in _logs) {
      await actions.skip(l, reason);
    }
    await _finish();
  }

  @override
  Widget build(BuildContext context) {
    final first = _logs.isNotEmpty ? _logs.first : null;
    final med = first == null ? null : _meds[first.medicineId];
    final member = first == null ? null : _members[first.memberId];
    final time = Dates.time(DateTime.fromMillisecondsSinceEpoch(
        first?.effectiveScheduledAt ?? DateTime.now().millisecondsSinceEpoch));
    final others = _logs.length > 1 ? _logs.sublist(1) : const <DoseLog>[];

    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primaryDark, Color(0xFF06304F)],
          ),
        ),
        child: SafeArea(
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white))
              : Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
                  child: Column(
                    children: [
                      _PulseHalo(pulse: _pulse),
                      const SizedBox(height: 14),
                      const Text(
                        'Waktunya Minum Obat',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        time,
                        style: const TextStyle(
                          color: AppColors.hcYellow,
                          fontSize: 42,
                          fontWeight: FontWeight.w800,
                          height: 1.05,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (first == null)
                        const Expanded(
                          child: Center(
                            child: Text(
                              'Data dosis tidak ditemukan.',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        )
                      else
                        Expanded(
                          child: ListView(
                            children: [
                              Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(AppSpacing.md),
                                  child: Row(
                                    children: [
                                      MedicineAvatar(
                                        thumbB64: med?.photoThumbB64,
                                        filePath: med?.photoPath,
                                        size: 76,
                                      ),
                                      const SizedBox(width: AppSpacing.md),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              med?.name ?? 'Obat',
                                              style: const TextStyle(
                                                fontSize: 21,
                                                fontWeight: FontWeight.w700,
                                                height: 1.15,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              '${formatQty(med?.doseQty ?? 1)} ${med?.unit ?? ''} • ${med?.dosage ?? ''}'
                                                  .trim(),
                                              style: const TextStyle(
                                                  color: AppColors.textMedium,
                                                  fontSize: 14),
                                            ),
                                            if (member != null) ...[
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  const Icon(
                                                      Icons.person_outline_rounded,
                                                      size: 16,
                                                      color: AppColors.accent),
                                                  const SizedBox(width: 5),
                                                  Text(
                                                    'Untuk ${member.name}',
                                                    style: const TextStyle(
                                                      color: AppColors.accent,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (others.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                const Text(
                                  'Juga pada waktu ini:',
                                  style: TextStyle(
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 8),
                                ...others.map((l) {
                                  final om = _meds[l.medicineId];
                                  final omem = _members[l.memberId];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.medication_rounded,
                                            color: Colors.white70, size: 18),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            '${om?.name ?? 'Obat'} — ${omem?.name ?? ''}',
                                            style: const TextStyle(
                                                color: Colors.white70),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ],
                          ),
                        ),
                      const SizedBox(height: 16),
                      if (_busy)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child:
                              CircularProgressIndicator(color: Colors.white),
                        ),
                      FilledButton.icon(
                        onPressed: _busy ? null : _taken,
                        icon: const Icon(Icons.check_rounded, size: 26),
                        label: const Text('Sudah Minum'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                          textStyle: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w700),
                          minimumSize: const Size.fromHeight(62),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _busy ? null : _snooze,
                              icon: const Icon(Icons.snooze_rounded),
                              label: const Text('Tunda'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Colors.white54),
                                minimumSize: const Size(0, 56),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _busy ? null : _skip,
                              icon: const Icon(Icons.remove_circle_outline),
                              label: const Text('Lewati'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.hcYellow,
                                side:
                                    const BorderSide(color: AppColors.hcYellow),
                                minimumSize: const Size(0, 56),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

/// Ikon alarm dengan cincin yang berdenyut halus agar menarik perhatian.
class _PulseHalo extends StatelessWidget {
  final Animation<double> pulse;
  const _PulseHalo({required this.pulse});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 124,
      height: 124,
      child: AnimatedBuilder(
        animation: pulse,
        builder: (_, _) {
          final t = Curves.easeInOut.transform(pulse.value);
          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 96 + 26 * t,
                height: 96 + 26 * t,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.10 * (1 - t) + 0.03),
                ),
              ),
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.14),
                ),
                child: const Icon(Icons.alarm_on_rounded,
                    color: Colors.white, size: 46),
              ),
            ],
          );
        },
      ),
    );
  }
}
