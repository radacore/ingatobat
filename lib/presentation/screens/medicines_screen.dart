import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../data/database/app_database.dart';
import '../providers/providers.dart';
import '../widgets/common.dart';
import 'medicine_detail_screen.dart';
import 'medicine_form_screen.dart';
import 'member_detail_screen.dart';
import 'member_form_screen.dart';

class MedicinesScreen extends ConsumerWidget {
  const MedicinesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medsAsync = ref.watch(allMedicinesProvider);
    final members = ref.watch(membersProvider).value ?? const [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Obat & Stok'),
        actions: [
          IconButton(
            tooltip: 'Anggota keluarga',
            icon: const Icon(Icons.people_outline),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MemberListScreen()),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (members.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Tambahkan anggota keluarga terlebih dahulu.')),
            );
            return;
          }
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const MedicineFormScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah Obat'),
      ),
      body: medsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Gagal memuat: $e')),
        data: (meds) {
          if (meds.isEmpty) {
            return const EmptyState(
              icon: Icons.medication_outlined,
              title: 'Belum ada obat',
              subtitle:
                  'Tambahkan obat beserta foto dan takarannya, lalu atur jadwal minumnya.',
            );
          }
          final grouped = <String, List<Medicine>>{};
          for (final m in meds) {
            grouped.putIfAbsent(m.memberId, () => []).add(m);
          }
          final memberById = {for (final m in members) m.id: m};

          return ListView(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.xs, AppSpacing.md, 100),
            children: [
              for (final entry in grouped.entries) ...[
                SectionHeader(memberById[entry.key]?.name ?? 'Anggota'),
                ...entry.value.map((m) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                      child: _MedicineTile(medicine: m),
                    )),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _MedicineTile extends StatelessWidget {
  final Medicine medicine;
  const _MedicineTile({required this.medicine});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final low = medicine.stockQty <= medicine.lowStockThreshold;
    final stockColor = low ? p.warning : p.textSecondary;
    return Card(
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => MedicineDetailScreen(medicineId: medicine.id),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Row(
            children: [
              MedicineAvatar(
                thumbB64: medicine.photoThumbB64,
                filePath: medicine.photoPath,
                size: 58,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medicine.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: p.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${medicine.dosage} • ${formatQty(medicine.doseQty)} ${medicine.unit}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13.5, color: p.textSecondary),
                    ),
                    const SizedBox(height: 6),
                    _StockBadge(
                      low: low,
                      label: 'Stok: ${formatQty(medicine.stockQty)} ${medicine.unit}',
                      color: stockColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Icon(Icons.chevron_right, color: p.textHint),
            ],
          ),
        ),
      ),
    );
  }
}

class _StockBadge extends StatelessWidget {
  final bool low;
  final String label;
  final Color color;
  const _StockBadge({required this.low, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: p.highContrast ? Colors.transparent : color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: p.highContrast ? Border.all(color: color) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            low ? Icons.warning_amber_rounded : Icons.inventory_2_outlined,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              color: color,
              fontWeight: low ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class MemberListScreen extends ConsumerWidget {
  const MemberListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final membersAsync = ref.watch(membersProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Anggota Keluarga')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const MemberFormScreen()),
        ),
        icon: const Icon(Icons.person_add),
        label: const Text('Tambah'),
      ),
      body: membersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Gagal memuat: $e')),
        data: (members) {
          if (members.isEmpty) {
            return const EmptyState(
              icon: Icons.people_outline,
              title: 'Belum ada anggota',
              subtitle:
                  'Tambahkan anggota keluarga untuk mulai membuat jadwal obat.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.xs, AppSpacing.md, 100),
            itemCount: members.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.xs),
            itemBuilder: (_, i) {
              final m = members[i];
              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm, vertical: 6),
                  leading: MemberAvatar(
                    name: m.name,
                    avatarPath: m.avatarPath,
                    thumbB64: m.avatarThumbB64,
                    size: 50,
                  ),
                  title: Text(m.name,
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: p.textPrimary)),
                  subtitle: Text(m.notes ?? 'Tanpa catatan'),
                  trailing: Icon(Icons.chevron_right, color: p.textHint),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => MemberDetailScreen(memberId: m.id),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
