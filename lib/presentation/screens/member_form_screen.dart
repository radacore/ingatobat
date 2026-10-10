import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_theme.dart';
import '../../data/database/app_database.dart';
import '../../domain/services/image_service.dart';
import '../providers/providers.dart';
import '../widgets/common.dart';

class MemberFormScreen extends ConsumerStatefulWidget {
  final Member? member;
  const MemberFormScreen({super.key, this.member});

  @override
  ConsumerState<MemberFormScreen> createState() => _MemberFormScreenState();
}

class _MemberFormScreenState extends ConsumerState<MemberFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _notes;

  String? _photoPath;
  String? _thumbB64;
  bool _saving = false;

  bool get _isEdit => widget.member != null;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.member?.name ?? '');
    _notes = TextEditingController(text: widget.member?.notes ?? '');
    _photoPath = widget.member?.avatarPath;
    _thumbB64 = widget.member?.avatarThumbB64;
  }

  @override
  void dispose() {
    _name.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
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

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    final repo = ref.read(repositoryProvider);
    final session = ref.read(familySessionProvider);

    if (_isEdit) {
      await repo.updateMember(
        widget.member!.id,
        name: _name.text.trim(),
        notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
        avatarPath: _photoPath,
        avatarThumbB64: _thumbB64,
      );
    } else {
      await repo.createMember(
        name: _name.text.trim(),
        notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
        avatarPath: _photoPath,
        avatarThumbB64: _thumbB64,
        familyId: session.familyId,
      );
    }
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Ubah Anggota' : 'Tambah Anggota')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      MemberAvatar(
                        name: _name.text.isEmpty ? '?' : _name.text,
                        avatarPath: _photoPath,
                        thumbB64: _thumbB64,
                        size: 112,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Material(
                          color: p.primary,
                          shape: const CircleBorder(),
                          child: IconButton(
                            icon: Icon(Icons.camera_alt_rounded,
                                color: p.onPrimary),
                            onPressed: _pickImage,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Foto opsional',
                      style: TextStyle(color: p.textSecondary, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Nama anggota *',
                hintText: 'mis. Ibu, Ayah, Kakek',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
              onChanged: (_) => setState(() {}),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _notes,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Catatan (opsional)',
                hintText: 'mis. alergi, kondisi khusus',
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
              label: Text(_isEdit ? 'Simpan Perubahan' : 'Simpan Anggota'),
            ),
          ],
        ),
      ),
    );
  }
}
