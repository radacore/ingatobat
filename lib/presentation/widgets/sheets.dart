import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/dates.dart';

/// Judul konsisten untuk semua bottom sheet.
class _SheetTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  const _SheetTitle(this.title, {this.subtitle});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
            color: p.textPrimary,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(
            subtitle!,
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color: p.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

EdgeInsets _sheetPadding(BuildContext ctx) => EdgeInsets.only(
      left: 20,
      right: 20,
      top: 4,
      bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
    );

Future<double?> showRestockSheet(BuildContext context, String medicineName) {
  final controller = TextEditingController();
  return showModalBottomSheet<double>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => Padding(
      padding: _sheetPadding(ctx),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SheetTitle('Tambah Stok', subtitle: medicineName),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: controller,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Jumlah tambahan',
              hintText: 'mis. 10',
              prefixIcon: Icon(Icons.add_circle_outline),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton(
            onPressed: () {
              final v = double.tryParse(controller.text.replaceAll(',', '.'));
              if (v != null && v > 0) Navigator.pop(ctx, v);
            },
            child: const Text('Simpan Stok'),
          ),
        ],
      ),
    ),
  );
}

Future<String?> showSkipReasonSheet(BuildContext context) {
  final controller = TextEditingController();
  String? selected;
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => Padding(
        padding: _sheetPadding(ctx),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _SheetTitle('Alasan Lewati Obat',
                subtitle: 'Pilih alasan agar catatan tetap akurat.'),
            const SizedBox(height: AppSpacing.xs),
            RadioGroup<String>(
              groupValue: selected,
              onChanged: (v) => setState(() => selected = v),
              child: Column(
                children: SkipReasons.reasons
                    .map((r) => RadioListTile<String>(
                          value: r,
                          title: Text(r),
                          contentPadding: EdgeInsets.zero,
                        ))
                    .toList(),
              ),
            ),
            if (selected == 'Lainnya') ...[
              const SizedBox(height: AppSpacing.xs),
              TextField(
                controller: controller,
                decoration: const InputDecoration(labelText: 'Alasan lainnya'),
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            FilledButton(
              onPressed: () {
                final reason = selected == 'Lainnya'
                    ? (controller.text.trim().isEmpty
                        ? 'Lainnya'
                        : controller.text.trim())
                    : selected;
                Navigator.pop(ctx, reason ?? 'Dilewati');
              },
              child: const Text('Lewati Dosis'),
            ),
          ],
        ),
      ),
    ),
  );
}

Future<String?> showCorrectStatusSheet(
  BuildContext context,
  String currentStatus,
) {
  const options = ['taken', 'skipped', 'missed', 'pending'];
  return showModalBottomSheet<String>(
    context: context,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: _SheetTitle('Koreksi Status Riwayat'),
          ),
          RadioGroup<String>(
            groupValue: currentStatus,
            onChanged: (v) => Navigator.pop(ctx, v),
            child: Column(
              children: options
                  .map((s) => RadioListTile<String>(
                        value: s,
                        title: Text(doseStatusLabel(s)),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}

Future<String?> showInviteEmailSheet(BuildContext context) {
  final controller = TextEditingController();
  final formKey = GlobalKey<FormState>();
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => Padding(
      padding: _sheetPadding(ctx),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _SheetTitle(
              'Undang Anggota Keluarga',
              subtitle:
                  'Masukkan email Google anggota keluarga. Setelah login, data keluarga akan tersinkron otomatis.',
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: controller,
              keyboardType: TextInputType.emailAddress,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Email Google',
                prefixIcon: Icon(Icons.alternate_email),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Email wajib diisi';
                if (!v.contains('@')) return 'Format email tidak valid';
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.pop(ctx, controller.text.trim());
                }
              },
              child: const Text('Kirim Undangan'),
            ),
          ],
        ),
      ),
    ),
  );
}

/// BS-05: pilih rentang tanggal laporan/PDF.
Future<({DateTime from, DateTime to})?> showDateRangeSheet(
  BuildContext context, {
  DateTime? initialFrom,
  DateTime? initialTo,
}) async {
  final now = DateTime.now();
  final presets = <String, ({DateTime from, DateTime to})>{
    '7 hari terakhir': (from: now.subtract(const Duration(days: 7)), to: now),
    '30 hari terakhir': (from: now.subtract(const Duration(days: 30)), to: now),
    'Bulan ini': (from: Dates.startOfMonth(now), to: now),
  };

  return showModalBottomSheet<({DateTime from, DateTime to})>(
    context: context,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: _SheetTitle('Rentang Tanggal'),
          ),
          ...presets.entries.map((e) => ListTile(
                leading: const Icon(Icons.date_range_outlined),
                title: Text(e.key),
                subtitle: Text(
                    '${Dates.dateShort(e.value.from)} - ${Dates.dateShort(e.value.to)}'),
                onTap: () => Navigator.pop(ctx, e.value),
              )),
          ListTile(
            leading: const Icon(Icons.tune),
            title: const Text('Pilih tanggal khusus'),
            onTap: () async {
              final picked = await showDateRangePicker(
                context: ctx,
                firstDate: DateTime(2020),
                lastDate: now.add(const Duration(days: 365)),
                initialDateRange: DateTimeRange(
                  start: initialFrom ?? now.subtract(const Duration(days: 30)),
                  end: initialTo ?? now,
                ),
              );
              if (picked != null && ctx.mounted) {
                Navigator.pop(ctx, (from: picked.start, to: picked.end));
              }
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}
