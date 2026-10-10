import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/constants.dart';
import '../../core/theme/app_theme.dart';
import '../../data/database/app_database.dart';
import '../../domain/services/image_service.dart';
import '../providers/providers.dart';
import '../widgets/common.dart';
import 'schedule_form_screen.dart';

class MedicineFormScreen extends ConsumerStatefulWidget {
  final String? memberId;
  final Medicine? medicine;
  const MedicineFormScreen({super.key, this.memberId, this.medicine});

  @override
  ConsumerState<MedicineFormScreen> createState() => _MedicineFormScreenState();
}

class _MedicineFormScreenState extends ConsumerState<MedicineFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _dosage;
  late final TextEditingController _doseQty;
  late final TextEditingController _stock;
  late final TextEditingController _threshold;
  late final TextEditingController _notes;

  String? _memberId;
  String _unit = 'tablet';
  String _mealRelation = 'none';
  String? _photoPath;
  String? _thumbB64;
  bool _saving = false;

  bool get _isEdit => widget.medicine != null;

  @override
  void initState() {
    super.initState();
    final m = widget.medicine;
    _name = TextEditingController(text: m?.name ?? '');
    _dosage = TextEditingController(text: m?.dosage ?? '');
    _doseQty = TextEditingController(text: m == null ? '1' : formatQty(m.doseQty));
    _stock = TextEditingController(text: m == null ? '0' : formatQty(m.stockQty));
    _threshold = TextEditingController(
        text: m == null ? '3' : formatQty(m.lowStockThreshold));
    _notes = TextEditingController(text: m?.notes ?? '');
    _unit = m?.unit ?? 'tablet';
    _mealRelation = m?.mealRelation ?? 'none';
    _photoPath = m?.photoPath;
    _thumbB64 = m?.photoThumbB64;
    _memberId = widget.memberId ?? m?.memberId;
  }

  @override
  void dispose() {
    _name.dispose();
    _dosage.dispose();
    _doseQty.dispose();
    _stock.dispose();
    _threshold.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 90,
    );
    if (picked == null) return;
    final path = await ImageService.compressAndSave(picked.path);
    final thumb = await ImageService.makeThumbB64(path);
    if (!mounted) return;
    setState(() {
      _photoPath = path;
      _thumbB64 = thumb;
    });
  }

  double _parse(TextEditingController c, double fallback) =>
      double.tryParse(c.text.replaceAll(',', '.')) ?? fallback;

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_memberId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih anggota pemilik obat.')),
      );
      return;
    }
    setState(() => _saving = true);
    final repo = ref.read(repositoryProvider);
    final session = ref.read(familySessionProvider);

    if (_isEdit) {
      await repo.updateMedicine(
        widget.medicine!.id,
        name: _name.text.trim(),
        dosage: _dosage.text.trim(),
        unit: _unit,
        doseQty: _parse(_doseQty, 1),
        mealRelation: _mealRelation,
        lowStockThreshold: _parse(_threshold, 3),
        photoPath: _photoPath,
        photoThumbB64: _thumbB64,
        notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(context).pop();
    } else {
      final id = await repo.createMedicine(
        memberId: _memberId!,
        name: _name.text.trim(),
        dosage: _dosage.text.trim(),
        unit: _unit,
        doseQty: _parse(_doseQty, 1),
        mealRelation: _mealRelation,
        photoPath: _photoPath,
        photoThumbB64: _thumbB64,
        stockQty: _parse(_stock, 0),
        lowStockThreshold: _parse(_threshold, 3),
        notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
        familyId: session.familyId,
      );
      if (!mounted) return;
      // Tawarkan langsung membuat jadwal.
      final createSchedule = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Buat Jadwal Sekarang?'),
          content: const Text(
              'Obat tersimpan. Atur jadwal minum agar alarm otomatis dibuat.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Nanti')),
            FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Atur Jadwal')),
          ],
        ),
      );
      if (!mounted) return;
      if (createSchedule == true) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => ScheduleFormScreen(
              memberId: _memberId!,
              medicineId: id,
            ),
          ),
        );
      } else {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final members = ref.watch(membersProvider).value ?? const [];
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Ubah Obat' : 'Tambah Obat')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xxl),
          children: [
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      MedicineAvatar(
                        thumbB64: _thumbB64,
                        filePath: _photoPath,
                        size: 120,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Material(
                          color: p.primary,
                          shape: const CircleBorder(),
                          elevation: 2,
                          child: IconButton(
                            tooltip: 'Pilih foto',
                            icon: Icon(Icons.camera_alt_rounded,
                                color: p.onPrimary),
                            onPressed: _pickImage,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text('Foto obat membantu lansia mengenali obat',
                      style: TextStyle(color: p.textSecondary, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const SectionHeader('Data Obat'),
            if (!_isEdit)
              DropdownButtonFormField<String>(
                initialValue: _memberId,
                decoration: const InputDecoration(
                  labelText: 'Untuk anggota *',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
                items: members
                    .map((m) => DropdownMenuItem(value: m.id, child: Text(m.name)))
                    .toList(),
                onChanged: (v) => setState(() => _memberId = v),
                validator: (v) => v == null ? 'Pilih anggota' : null,
              ),
            if (!_isEdit) const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Nama obat *',
                hintText: 'mis. Amlodipine',
                prefixIcon: Icon(Icons.medication_outlined),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Nama obat wajib diisi' : null,
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _dosage,
              decoration: const InputDecoration(
                labelText: 'Kekuatan dosis *',
                hintText: 'mis. 500mg, 5ml',
                prefixIcon: Icon(Icons.straighten_rounded),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Dosis wajib diisi' : null,
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _doseQty,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Takaran sekali minum *',
                      hintText: 'mis. 1 atau 0.5',
                    ),
                    validator: (v) {
                      final d = double.tryParse((v ?? '').replaceAll(',', '.'));
                      if (d == null || d <= 0) return 'Angka > 0';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _unit,
                    decoration: const InputDecoration(labelText: 'Satuan'),
                    items: MedicineCatalog.units
                        .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                        .toList(),
                    onChanged: (v) => setState(() => _unit = v!),
                  ),
                ),
              ],
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
            const SizedBox(height: AppSpacing.lg),
            const SectionHeader('Stok & Catatan'),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _stock,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Stok awal',
                      hintText: 'mis. 30',
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: TextFormField(
                    controller: _threshold,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Batas menipis',
                      hintText: 'mis. 3',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _notes,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Catatan (opsional)',
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
              label: Text(_isEdit ? 'Simpan Perubahan' : 'Simpan Obat'),
            ),
          ],
        ),
      ),
    );
  }
}
