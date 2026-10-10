import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/dates.dart';
import '../../data/database/app_database.dart';
import '../providers/providers.dart';
import '../widgets/common.dart';

/// Form jadwal minum (FR-03): harian, mingguan, atau interval.
class ScheduleFormScreen extends ConsumerStatefulWidget {
  final String memberId;
  final String? medicineId;
  final Schedule? schedule;

  const ScheduleFormScreen({
    super.key,
    required this.memberId,
    this.medicineId,
    this.schedule,
  });

  @override
  ConsumerState<ScheduleFormScreen> createState() => _ScheduleFormScreenState();
}

class _ScheduleFormScreenState extends ConsumerState<ScheduleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _interval = TextEditingController(text: '8');
  final _doseQty = TextEditingController();

  String? _medicineId;
  String _recurrence = 'daily';
  final List<String> _times = ['08:00'];
  final Set<int> _days = {1, 2, 3, 4, 5, 6, 7};
  String _mealRelation = 'none';
  bool _ttsEnabled = true;
  bool _isActive = true;
  late DateTime _startDate;
  DateTime? _endDate;
  bool _saving = false;

  bool get _isEdit => widget.schedule != null;

  @override
  void initState() {
    super.initState();
    _medicineId = widget.medicineId ?? widget.schedule?.medicineId;
    final s = widget.schedule;
    _startDate = DateTime.now();
    if (s != null) {
      _recurrence = s.recurrenceType;
      _times
        ..clear()
        ..addAll(_decodeList(s.timesJson));
      if (_times.isEmpty) _times.add('08:00');
      _days
        ..clear()
        ..addAll(_decodeIntList(s.daysOfWeek));
      if (_days.isEmpty) _days.addAll({1, 2, 3, 4, 5, 6, 7});
      _interval.text = (s.intervalHours ?? 8).toString();
      _doseQty.text = s.doseQty == null ? '' : formatQty(s.doseQty!);
      _mealRelation = s.mealRelation ?? 'none';
      _ttsEnabled = s.ttsEnabled;
      _isActive = s.isActive;
      _startDate = DateTime.fromMillisecondsSinceEpoch(s.startDate);
      _endDate = s.endDate == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(s.endDate!);
    }
  }

  @override
  void dispose() {
    _interval.dispose();
    _doseQty.dispose();
    super.dispose();
  }

  List<String> _decodeList(String json) {
    try {
      return json
          .replaceAll('[', '')
          .replaceAll(']', '')
          .split(',')
          .map((e) => e.replaceAll('"', '').trim())
          .where((e) => e.isNotEmpty)
          .toList();
    } catch (_) {
      return [];
    }
  }

  List<int> _decodeIntList(String? json) {
    if (json == null) return [];
    return json
        .replaceAll('[', '')
        .replaceAll(']', '')
        .split(',')
        .map((e) => int.tryParse(e.trim()) ?? 0)
        .where((e) => e > 0)
        .toList();
  }

  Future<void> _addTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 8, minute: 0),
    );
    if (picked == null) return;
    final text = '${picked.hour.toString().padLeft(2, '0')}:'
        '${picked.minute.toString().padLeft(2, '0')}';
    if (!_times.contains(text)) setState(() => _times.add(text));
  }

  Future<void> _pickDate({required bool isEnd}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isEnd ? (_endDate ?? _startDate) : _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked == null) return;
    setState(() {
      if (isEnd) {
        _endDate = picked;
      } else {
        _startDate = picked;
      }
    });
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_medicineId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih obat terlebih dahulu.')),
      );
      return;
    }
    if (_times.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tambahkan minimal satu waktu minum.')),
      );
      return;
    }
    if (_recurrence == 'weekly' && _days.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih minimal satu hari.')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final repo = ref.read(repositoryProvider);
      final session = ref.read(familySessionProvider);
      final sorted = [..._times]..sort();
      final doseQty = _doseQty.text.trim().isEmpty
          ? null
          : double.tryParse(_doseQty.text.replaceAll(',', '.'));

      if (_isEdit) {
        await repo.updateSchedule(
          widget.schedule!.id,
          recurrenceType: _recurrence,
          times: sorted,
          intervalHours: _recurrence == 'interval'
              ? int.tryParse(_interval.text) ?? 8
              : null,
          daysOfWeek: _recurrence == 'weekly' ? (_days.toList()..sort()) : null,
          doseQty: doseQty,
          mealRelation: _mealRelation == 'none' ? null : _mealRelation,
          ttsEnabled: _ttsEnabled,
          startDate: _startDate,
          endDate: _endDate,
          isActive: _isActive,
        );
      } else {
        await repo.createSchedule(
          memberId: widget.memberId,
          medicineId: _medicineId!,
          recurrenceType: _recurrence,
          times: sorted,
          intervalHours: _recurrence == 'interval'
              ? int.tryParse(_interval.text) ?? 8
              : null,
          daysOfWeek: _recurrence == 'weekly' ? (_days.toList()..sort()) : null,
          doseQty: doseQty,
          mealRelation: _mealRelation == 'none' ? null : _mealRelation,
          ttsEnabled: _ttsEnabled,
          startDate: _startDate,
          endDate: _endDate,
          familyId: session.familyId,
        );
      }

      await ref.read(doseServiceProvider).ensureDoseLogsForRange(
            DateTime.now(),
            DateTime.now().add(const Duration(days: 3)),
          );
      await ref.read(alarmCoordinatorProvider).rescheduleAll();

      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan jadwal: $e')),
      );
    }
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Jadwal?'),
        content: const Text(
            'Jadwal ini akan dihapus dan alarm terkait dibatalkan. Riwayat minum sebelumnya tetap tersimpan.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: ctx.palette.error,
              foregroundColor: ctx.palette.onPrimary,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(repositoryProvider).deleteSchedule(widget.schedule!.id);
    await ref.read(alarmCoordinatorProvider).rescheduleAll();
    if (mounted) Navigator.of(context).pop();
  }

  Widget _label(BuildContext context, String text) => Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 15,
          color: context.palette.textPrimary,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final meds =
        ref.watch(medicinesProvider(widget.memberId)).value ?? const [];
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Ubah Jadwal' : 'Buat Jadwal'),
        actions: [
          if (_isEdit)
            IconButton(
              tooltip: 'Hapus jadwal',
              icon: Icon(Icons.delete_outline, color: p.error),
              onPressed: _delete,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xxl),
          children: [
            if (!_isEdit) ...[
              DropdownButtonFormField<String>(
                initialValue: _medicineId,
                decoration: const InputDecoration(
                  labelText: 'Obat *',
                  prefixIcon: Icon(Icons.medication_outlined),
                ),
                items: meds
                    .map((m) => DropdownMenuItem(value: m.id, child: Text(m.name)))
                    .toList(),
                onChanged: (v) => setState(() => _medicineId = v),
                validator: (v) => v == null ? 'Pilih obat' : null,
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
            _label(context, 'Jenis Pengulangan'),
            const SizedBox(height: AppSpacing.xs),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'daily', label: Text('Harian')),
                  ButtonSegment(value: 'weekly', label: Text('Mingguan')),
                  ButtonSegment(value: 'interval', label: Text('Interval')),
                ],
                selected: {_recurrence},
                showSelectedIcon: false,
                onSelectionChanged: (v) => setState(() => _recurrence = v.first),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (_recurrence == 'weekly') ...[
              _label(context, 'Hari'),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  for (var i = 1; i <= 7; i++)
                    FilterChip(
                      label: Text(
                          const ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'][i - 1]),
                      selected: _days.contains(i),
                      onSelected: (on) => setState(() {
                        if (on) {
                          _days.add(i);
                        } else {
                          _days.remove(i);
                        }
                      }),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
            if (_recurrence == 'interval') ...[
              TextFormField(
                controller: _interval,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Setiap berapa jam *',
                  hintText: 'mis. 8',
                  prefixIcon: Icon(Icons.timelapse_rounded),
                ),
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  if (n == null || n <= 0 || n > 24) return '1 - 24 jam';
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Dosis dibangkitkan tiap N jam mulai dari waktu pertama di hari itu.',
                style: TextStyle(color: p.textSecondary, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
            Row(
              children: [
                Expanded(child: _label(context, 'Waktu Minum')),
                TextButton.icon(
                  onPressed: _addTime,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Tambah'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            if (_times.isEmpty)
              Text('Belum ada waktu.',
                  style: TextStyle(color: p.textSecondary))
            else
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  for (final t in _times)
                    Chip(
                      label: Text(t,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                      avatar: Icon(Icons.access_time_rounded,
                          size: 18, color: p.primary),
                      onDeleted: _times.length <= 1
                          ? null
                          : () => setState(() => _times.remove(t)),
                    ),
                ],
              ),
            const SizedBox(height: AppSpacing.lg),
            TextFormField(
              controller: _doseQty,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Takaran khusus (opsional)',
                hintText: 'Kosongkan untuk pakai takaran obat',
                prefixIcon: Icon(Icons.straighten_rounded),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<String>(
              initialValue: _mealRelation,
              decoration: const InputDecoration(
                labelText: 'Relasi makan',
                prefixIcon: Icon(Icons.restaurant_outlined),
              ),
              items: MedicineCatalog.mealRelations.entries
                  .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                  .toList(),
              onChanged: (v) => setState(() => _mealRelation = v!),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickDate(isEnd: false),
                    icon: const Icon(Icons.event_available_rounded, size: 20),
                    label: Text('Mulai: ${Dates.dateShort(_startDate)}'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickDate(isEnd: true),
                    icon: const Icon(Icons.event_busy_rounded, size: 20),
                    label: Text(_endDate == null
                        ? 'Tanpa akhir'
                        : 'Akhir: ${Dates.dateShort(_endDate!)}'),
                  ),
                ),
              ],
            ),
            if (_endDate != null)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => setState(() => _endDate = null),
                  icon: const Icon(Icons.close_rounded, size: 18),
                  label: const Text('Hapus tanggal akhir'),
                ),
              ),
            const SizedBox(height: AppSpacing.xs),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    value: _ttsEnabled,
                    onChanged: (v) => setState(() => _ttsEnabled = v),
                    title: const Text('Suara pengingat'),
                    subtitle:
                        const Text('Sebutkan nama obat saat alarm berbunyi'),
                    secondary: SoftIcon(
                        icon: Icons.record_voice_over_rounded,
                        color: p.primary),
                  ),
                  if (_isEdit) ...[
                    Divider(height: 1, color: p.divider),
                    SwitchListTile(
                      value: _isActive,
                      onChanged: (v) => setState(() => _isActive = v),
                      title: const Text('Jadwal aktif'),
                      subtitle:
                          const Text('Nonaktifkan untuk menghentikan alarm'),
                      secondary: SoftIcon(
                          icon: Icons.power_settings_new_rounded,
                          color: p.primary),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.alarm_add_rounded),
              label: Text(_isEdit ? 'Simpan Jadwal' : 'Buat Jadwal & Alarm'),
            ),
          ],
        ),
      ),
    );
  }
}
