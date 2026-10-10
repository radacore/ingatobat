import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/dates.dart';

/// Avatar/foto obat: coba thumbnail Base64 → file lokal → ikon.
class MedicineAvatar extends StatelessWidget {
  final String? thumbB64;
  final String? filePath;
  final double size;
  final String? heroTag;

  const MedicineAvatar({
    super.key,
    this.thumbB64,
    this.filePath,
    this.size = 56,
    this.heroTag,
  });

  Widget _image(BuildContext context) {
    if (thumbB64 != null && thumbB64!.isNotEmpty) {
      try {
        return Image.memory(
          base64Decode(thumbB64!),
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _fileOrIcon(context),
        );
      } catch (_) {
        return _fileOrIcon(context);
      }
    }
    return _fileOrIcon(context);
  }

  Widget _fileOrIcon(BuildContext context) {
    if (filePath != null && File(filePath!).existsSync()) {
      return Image.file(
        File(filePath!),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _icon(context),
      );
    }
    return _icon(context);
  }

  Widget _icon(BuildContext context) {
    final p = context.palette;
    return Container(
      width: size,
      height: size,
      color: p.primaryContainer,
      alignment: Alignment.center,
      child: Icon(Icons.medication_rounded, size: size * 0.5, color: p.primary),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final clip = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: p.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(width: size, height: size, child: _image(context)),
    );
    if (heroTag == null) return clip;
    return Hero(tag: heroTag!, child: clip);
  }
}

/// Avatar anggota (foto atau inisial).
class MemberAvatar extends StatelessWidget {
  final String name;
  final String? avatarPath;
  final String? thumbB64;
  final double size;

  const MemberAvatar({
    super.key,
    required this.name,
    this.avatarPath,
    this.thumbB64,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (thumbB64 != null && thumbB64!.isNotEmpty) {
      try {
        child = Image.memory(base64Decode(thumbB64!),
            width: size, height: size, fit: BoxFit.cover);
      } catch (_) {
        child = _initial(context);
      }
    } else if (avatarPath != null && File(avatarPath!).existsSync()) {
      child = Image.file(File(avatarPath!),
          width: size, height: size, fit: BoxFit.cover);
    } else {
      child = _initial(context);
    }
    return ClipOval(
      child: SizedBox(width: size, height: size, child: child),
    );
  }

  Widget _initial(BuildContext context) {
    final p = context.palette;
    return Container(
      width: size,
      height: size,
      color: p.primary,
      alignment: Alignment.center,
      child: Text(
        name.isNotEmpty ? name.characters.first.toUpperCase() : '?',
        style: TextStyle(
          color: p.onPrimary,
          fontSize: size * 0.42,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Chip status dosis (Menunggu / Sudah / Terlewat / Ditunda).
class StatusChip extends StatelessWidget {
  final String status;
  const StatusChip(this.status, {super.key});

  Color _color(BuildContext context) {
    final p = context.palette;
    switch (status) {
      case 'taken':
        return p.success;
      case 'skipped':
      case 'missed':
        return p.error;
      case 'snoozed':
        return p.warning;
      default:
        return p.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color(context);
    final hc = context.palette.highContrast;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: hc ? Colors.transparent : color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: color, width: hc ? 1.5 : 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(doseStatusIcon(status), size: 15, color: color),
          const SizedBox(width: 5),
          Text(
            doseStatusLabel(status),
            style: TextStyle(
              color: color,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Judul bagian dengan garis aksen kecil di kiri.
class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const SectionHeader(this.title, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 20, 2, 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16.5,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
                color: p.textPrimary,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Tampilan kosong yang ramah: ikon dalam lingkaran lembut + aksi opsional.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: p.primaryContainer,
                shape: BoxShape.circle,
                border: p.highContrast
                    ? Border.all(color: p.border, width: 2)
                    : null,
              ),
              child: Icon(icon, size: 44, color: p.primary),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: p.textPrimary,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.5,
                  height: 1.45,
                  color: p.textSecondary,
                ),
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: AppSpacing.xl),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Ikon dalam kotak lembut untuk leading ListTile.
class SoftIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  const SoftIcon({super.key, required this.icon, required this.color, this.size = 44});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: p.highContrast ? Colors.transparent : color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: p.highContrast ? Border.all(color: color) : null,
      ),
      child: Icon(icon, color: color, size: size * 0.5),
    );
  }
}

/// Baris info dengan ikon dalam kotak lembut + judul/subjudul.
class InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? color;

  const InfoTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final tint = color ?? p.primary;
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: p.highContrast ? Colors.transparent : tint.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: p.highContrast ? Border.all(color: tint) : null,
        ),
        child: Icon(icon, color: tint, size: 22),
      ),
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing:
          trailing ?? (onTap == null ? null : Icon(Icons.chevron_right, color: p.textHint)),
    );
  }
}

String formatQty(double qty) =>
    qty == qty.roundToDouble() ? qty.toInt().toString() : qty.toString();

String doseSummary(String medicineName, double qty, String unit) =>
    '$medicineName • ${formatQty(qty)} $unit';

String timeLabel(int epochMs) => Dates.time(DateTime.fromMillisecondsSinceEpoch(epochMs));
