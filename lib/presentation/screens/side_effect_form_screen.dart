import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/dates.dart';
import '../../data/database/app_database.dart';
import '../providers/providers.dart';
import '../widgets/common.dart';

/// Form catat efek samping (FR-15).
class SideEffectFormScreen extends ConsumerStatefulWidget {
  final Medicine medicine;
  final SideEffect? existing;

  const SideEffectFormScreen({super.key, required this.medicine, this.existing});

  @override
  ConsumerState<SideEffectFormScreen> createState() =>
      _SideEffectFormScreenState();
}

class _SideEffectFormScreenState extends ConsumerState<SideEffectFormScreen> {
  final _custom = TextEditingController();
  final _note = TextEditingController();

  String _kind = 'mual';
  String _severity = 'ringan';
  late DateTime _occurredAt;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _occurredAt = DateTime.now();
    final e = widget.existing;
    if (e != null) {
      _kind = e.kind;
      _custom.text = e.customKind ?? '';
      _severity = e.severity;
      _note.text = e.note ?? '';
      _occurredAt = DateTime.fromMillisecondsSinceEpoch(e.occurredAt);
    }
  }

  @override
  void dispose() {
    _custom.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _occurredAt,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_occurredAt),
    );
    if (time == null) return;
    setState(() {
      _occurredAt =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final session = ref.read(familySessionProvider);
    await ref.read(repositoryProvider).createSideEffect(
          memberId: widget.medicine.memberId,
          medicineId: widget.medicine.id,
          occurredAt: _occurredAt,
          kind: _kind,
          customKind:
              _kind == 'kustom' ? (_custom.text.trim().isEmpty ? 'Lainnya' : _custom.text.trim()) : null,
          severity: _severity,
          note: _note.text.trim().isEmpty ? null : _note.text.trim(),
          familyId: session.familyId,
        );
    if (!mounted) return;
    Navigator.of(context).pop();
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
    return Scaffold(
      appBar: AppBar(title: const Text('Catat Efek Samping')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xxl),
        children: [
          Card(
            child: ListTile(
              leading: MedicineAvatar(
                thumbB64: widget.medicine.photoThumbB64,
                filePath: widget.medicine.photoPath,
              ),
              title: Text(widget.medicine.name,
                  style: TextStyle(
                      fontWeight: FontWeight.w600, color: p.textPrimary)),
              subtitle: Text(widget.medicine.dosage,
                  style: TextStyle(color: p.textSecondary)),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _label(context, 'Jenis Efek Samping'),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: SideEffectCatalog.kinds.entries
                .map((e) => ChoiceChip(
                      label: Text(e.value),
                      selected: _kind == e.key,
                      onSelected: (_) => setState(() => _kind = e.key),
                    ))
                .toList(),
          ),
          if (_kind == 'kustom') ...[
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _custom,
              decoration: const InputDecoration(
                labelText: 'Sebutkan efek samping',
                prefixIcon: Icon(Icons.edit_note_rounded),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          _label(context, 'Tingkat Keparahan'),
          const SizedBox(height: AppSpacing.xs),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<String>(
              segments: SideEffectCatalog.severities.entries
                  .map((e) => ButtonSegment(value: e.key, label: Text(e.value)))
                  .toList(),
              selected: {_severity},
              showSelectedIcon: false,
              onSelectionChanged: (v) => setState(() => _severity = v.first),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          OutlinedButton.icon(
            onPressed: _pickDateTime,
            icon: const Icon(Icons.schedule_rounded, size: 20),
            label: Text('Terjadi: ${Dates.dateTimeFull(_occurredAt)}'),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _note,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Catatan (opsional)',
              hintText: 'mis. muncul 30 menit setelah minum',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_rounded),
            label: const Text('Simpan Catatan'),
          ),
        ],
      ),
    );
  }
}
