import 'package:flutter/material.dart';

/// Token warna mentah (brand) sesuai DESIGN_SYSTEM.md.
///
/// Nilai di sini tidak bergantung tema. Untuk pemakaian di UI, pakai
/// [AppPalette] lewat `context.palette` agar mode kontras tinggi ikut bekerja.
class AppColors {
  // Brand (DESIGN_SYSTEM.md)
  static const primary = Color(0xFF1565C0);
  static const primaryDark = Color(0xFF0D47A1);
  static const accent = Color(0xFF00897B);
  static const secondaryLight = Color(0xFFE3F2FD);
  static const success = Color(0xFF2E7D32);
  static const warning = Color(0xFFB45309);
  static const warningFill = Color(0xFFF59E0B);
  static const error = Color(0xFFD32F2F);

  // Kontras tinggi
  static const hcBg = Color(0xFF000000);
  static const hcText = Color(0xFFFFFFFF);
  static const hcYellow = Color(0xFFFFEB3B);

  // Netral (diperhalus, sedikit kebiruan agar terasa crafted)
  static const textDark = Color(0xFF16202E);
  static const textMedium = Color(0xFF5C6B7E);
  static const textHint = Color(0xFF93A1B2);
  static const border = Color(0xFFDFE6EF);
  static const divider = Color(0xFFEBF0F6);
  static const surface = Color(0xFFFFFFFF);
  static const canvas = Color(0xFFF3F6FB);
  static const surfaceMuted = Color(0xFFEFF3F9);

  static const white = Colors.white;
}

/// Palet semantik yang sudah memperhitungkan tema (normal vs kontras tinggi).
///
/// Selalu ambil warna lewat `context.palette.<nama>` supaya teks tetap
/// terbaca di mode kontras tinggi.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.primary,
    required this.primaryDark,
    required this.onPrimary,
    required this.accent,
    required this.onAccent,
    required this.primaryContainer,
    required this.accentContainer,
    required this.success,
    required this.successContainer,
    required this.warning,
    required this.warningContainer,
    required this.warningFill,
    required this.error,
    required this.errorContainer,
    required this.textPrimary,
    required this.textSecondary,
    required this.textHint,
    required this.surface,
    required this.surfaceMuted,
    required this.canvas,
    required this.border,
    required this.divider,
    required this.highContrast,
  });

  final Color primary;
  final Color primaryDark;
  final Color onPrimary;
  final Color accent;
  final Color onAccent;
  final Color primaryContainer;
  final Color accentContainer;
  final Color success;
  final Color successContainer;
  final Color warning;
  final Color warningContainer;
  final Color warningFill;
  final Color error;
  final Color errorContainer;
  final Color textPrimary;
  final Color textSecondary;
  final Color textHint;
  final Color surface;
  final Color surfaceMuted;
  final Color canvas;
  final Color border;
  final Color divider;
  final bool highContrast;

  /// Tema normal.
  static const light = AppPalette(
    primary: AppColors.primary,
    primaryDark: AppColors.primaryDark,
    onPrimary: Color(0xFFFFFFFF),
    accent: AppColors.accent,
    onAccent: Color(0xFFFFFFFF),
    primaryContainer: AppColors.secondaryLight,
    accentContainer: Color(0xFFDFF3F1),
    success: AppColors.success,
    successContainer: Color(0xFFE8F5E9),
    warning: AppColors.warning,
    warningContainer: Color(0xFFFFF4E0),
    warningFill: AppColors.warningFill,
    error: AppColors.error,
    errorContainer: Color(0xFFFCEAE9),
    textPrimary: AppColors.textDark,
    textSecondary: AppColors.textMedium,
    textHint: AppColors.textHint,
    surface: AppColors.surface,
    surfaceMuted: AppColors.surfaceMuted,
    canvas: AppColors.canvas,
    border: AppColors.border,
    divider: AppColors.divider,
    highContrast: false,
  );

  /// Tema kontras tinggi (FR-13): latar hitam, teks putih, aksen kuning.
  static const hc = AppPalette(
    primary: AppColors.hcYellow,
    primaryDark: AppColors.hcYellow,
    onPrimary: Color(0xFF000000),
    accent: AppColors.hcYellow,
    onAccent: Color(0xFF000000),
    primaryContainer: Color(0xFF000000),
    accentContainer: Color(0xFF000000),
    success: Color(0xFF69F0AE),
    successContainer: Color(0xFF000000),
    warning: Color(0xFFFFD54F),
    warningContainer: Color(0xFF000000),
    warningFill: Color(0xFFFFD54F),
    error: Color(0xFFFF5252),
    errorContainer: Color(0xFF000000),
    textPrimary: AppColors.hcText,
    textSecondary: Color(0xFFE6E6E6),
    textHint: Color(0xFFBDBDBD),
    surface: Color(0xFF000000),
    surfaceMuted: Color(0xFF0A0A0A),
    canvas: Color(0xFF000000),
    border: AppColors.hcYellow,
    divider: AppColors.hcYellow,
    highContrast: true,
  );

  @override
  AppPalette copyWith({
    Color? primary,
    Color? primaryDark,
    Color? onPrimary,
    Color? accent,
    Color? onAccent,
    Color? primaryContainer,
    Color? accentContainer,
    Color? success,
    Color? successContainer,
    Color? warning,
    Color? warningContainer,
    Color? warningFill,
    Color? error,
    Color? errorContainer,
    Color? textPrimary,
    Color? textSecondary,
    Color? textHint,
    Color? surface,
    Color? surfaceMuted,
    Color? canvas,
    Color? border,
    Color? divider,
    bool? highContrast,
  }) {
    return AppPalette(
      primary: primary ?? this.primary,
      primaryDark: primaryDark ?? this.primaryDark,
      onPrimary: onPrimary ?? this.onPrimary,
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      primaryContainer: primaryContainer ?? this.primaryContainer,
      accentContainer: accentContainer ?? this.accentContainer,
      success: success ?? this.success,
      successContainer: successContainer ?? this.successContainer,
      warning: warning ?? this.warning,
      warningContainer: warningContainer ?? this.warningContainer,
      warningFill: warningFill ?? this.warningFill,
      error: error ?? this.error,
      errorContainer: errorContainer ?? this.errorContainer,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textHint: textHint ?? this.textHint,
      surface: surface ?? this.surface,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      canvas: canvas ?? this.canvas,
      border: border ?? this.border,
      divider: divider ?? this.divider,
      highContrast: highContrast ?? this.highContrast,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    // Mode kontras tinggi berganti seketika, tanpa animasi warna.
    if (other.highContrast != highContrast) {
      return t < 0.5 ? this : other;
    }
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppPalette(
      primary: c(primary, other.primary),
      primaryDark: c(primaryDark, other.primaryDark),
      onPrimary: c(onPrimary, other.onPrimary),
      accent: c(accent, other.accent),
      onAccent: c(onAccent, other.onAccent),
      primaryContainer: c(primaryContainer, other.primaryContainer),
      accentContainer: c(accentContainer, other.accentContainer),
      success: c(success, other.success),
      successContainer: c(successContainer, other.successContainer),
      warning: c(warning, other.warning),
      warningContainer: c(warningContainer, other.warningContainer),
      warningFill: c(warningFill, other.warningFill),
      error: c(error, other.error),
      errorContainer: c(errorContainer, other.errorContainer),
      textPrimary: c(textPrimary, other.textPrimary),
      textSecondary: c(textSecondary, other.textSecondary),
      textHint: c(textHint, other.textHint),
      surface: c(surface, other.surface),
      surfaceMuted: c(surfaceMuted, other.surfaceMuted),
      canvas: c(canvas, other.canvas),
      border: c(border, other.border),
      divider: c(divider, other.divider),
      highContrast: highContrast,
    );
  }
}

/// Akses cepat palet dari `BuildContext`.
extension AppPaletteX on BuildContext {
  AppPalette get palette =>
      Theme.of(this).extension<AppPalette>() ?? AppPalette.light;
}
