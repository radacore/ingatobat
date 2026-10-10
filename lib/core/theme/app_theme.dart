import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_palette.dart';

export 'app_palette.dart';

/// Skala jarak berbasis unit 8dp (DESIGN_SYSTEM.md).
class AppSpacing {
  static const xxs = 4.0;
  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 20.0;
  static const xl = 24.0;
  static const xxl = 32.0;

  /// Padding tepi layar standar.
  static const screen = EdgeInsets.symmetric(horizontal: md);
}

/// Radius sudut konsisten (DESIGN_SYSTEM.md: sudut membulat besar).
class AppRadius {
  static const sm = 10.0;
  static const md = 14.0;
  static const lg = 18.0;
  static const xl = 24.0;
  static const pill = 999.0;
}

/// Pilihan aksesibilitas (FR-13).
enum FontScale { s, m, l, xl }

extension FontScaleX on FontScale {
  String get label {
    switch (this) {
      case FontScale.s:
        return 'S';
      case FontScale.m:
        return 'M';
      case FontScale.l:
        return 'L';
      case FontScale.xl:
        return 'XL';
    }
  }

  double get multiplier {
    switch (this) {
      case FontScale.s:
        return 0.875;
      case FontScale.m:
        return 1.0;
      case FontScale.l:
        return 1.25;
      case FontScale.xl:
        return 1.5;
    }
  }
}

class AppTheme {
  static ThemeData build({
    bool largeButtons = false,
    bool highContrast = false,
  }) {
    final p = highContrast ? AppPalette.hc : AppPalette.light;

    final scheme = ColorScheme.fromSeed(
      seedColor: p.primary,
      brightness: highContrast ? Brightness.dark : Brightness.light,
    ).copyWith(
      primary: p.primary,
      onPrimary: p.onPrimary,
      secondary: p.accent,
      onSecondary: p.onAccent,
      error: p.error,
      surface: p.surface,
      onSurface: p.textPrimary,
      outline: p.border,
      outlineVariant: p.divider,
      surfaceContainerLowest: p.surface,
      surfaceContainerLow: p.surfaceMuted,
    );

    final buttonHeight = largeButtons ? 64.0 : 56.0;
    final textTheme = _textTheme(p);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      extensions: [p],
      scaffoldBackgroundColor: p.canvas,
      textTheme: textTheme,
      fontFamily: 'Roboto',
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: p.surface,
        foregroundColor: p.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 20,
        shape: Border(bottom: BorderSide(color: p.border)),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: p.textPrimary,
        ),
        iconTheme: IconThemeData(color: p.textPrimary),
        actionsIconTheme: IconThemeData(color: p.textPrimary),
        systemOverlayStyle: highContrast
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: p.surface,
        surfaceTintColor: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(
            color: p.border,
            width: highContrast ? 2 : 1,
          ),
        ),
        margin: EdgeInsets.zero,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: Size(0, buttonHeight),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: Size(0, buttonHeight),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          side: BorderSide(
            color: highContrast ? p.border : p.border,
            width: highContrast ? 2 : 1.5,
          ),
          foregroundColor: p.textPrimary,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: highContrast ? p.primary : p.primary,
          minimumSize: const Size(0, 44),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: p.textPrimary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.surface,
        isDense: true,
        border: _inputBorder(p, p.border, 1),
        enabledBorder: _inputBorder(p, p.border, 1),
        focusedBorder: _inputBorder(p, p.primary, 2),
        errorBorder: _inputBorder(p, p.error, 1),
        focusedErrorBorder: _inputBorder(p, p.error, 2),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: TextStyle(color: p.textSecondary),
        floatingLabelStyle: TextStyle(color: p.primary),
        hintStyle: TextStyle(color: p.textHint),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: p.surfaceMuted,
        selectedColor: p.primaryContainer,
        side: BorderSide(color: p.border),
        labelStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: p.textPrimary,
        ),
        secondaryLabelStyle: TextStyle(color: p.textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
      listTileTheme: ListTileThemeData(
        minVerticalPadding: 12,
        iconColor: p.textSecondary,
        titleTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: p.textPrimary,
        ),
        subtitleTextStyle: TextStyle(
          fontSize: 14,
          color: p.textSecondary,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: p.divider,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: p.textPrimary,
        contentTextStyle: TextStyle(color: p.canvas, fontSize: 14.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        insetPadding: const EdgeInsets.all(16),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: p.textPrimary,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: p.border,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
        ),
        modalBackgroundColor: p.surface,
        modalBarrierColor: Colors.black54,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: p.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        textStyle: TextStyle(color: p.textPrimary, fontSize: 15),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: p.primary,
        foregroundColor: p.onPrimary,
        elevation: 2,
        highlightElevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        extendedTextStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: p.primaryContainer,
        elevation: 0,
        height: 72,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
            color: states.contains(WidgetState.selected)
                ? p.primary
                : p.textSecondary,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 24,
            color: states.contains(WidgetState.selected)
                ? p.primary
                : p.textSecondary,
          ),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: p.primary,
        inactiveTrackColor: p.surfaceMuted,
        thumbColor: p.primary,
        overlayColor: p.primary.withValues(alpha: 0.12),
        valueIndicatorColor: p.primaryDark,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? p.onPrimary : p.surface,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? p.primary : p.border,
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? p.primary : p.border,
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          textStyle: const WidgetStatePropertyAll(
            TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          backgroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected)
                ? p.primary
                : p.surface,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected)
                ? p.onPrimary
                : p.textPrimary,
          ),
          side: WidgetStatePropertyAll(BorderSide(color: p.border)),
        ),
      ),
      badgeTheme: BadgeThemeData(
        backgroundColor: p.error,
        textColor: Colors.white,
        textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: p.primary,
        linearTrackColor: p.surfaceMuted,
        circularTrackColor: p.surfaceMuted,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: p.textPrimary,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        textStyle: TextStyle(color: p.canvas, fontSize: 13),
      ),
    );
  }

  static OutlineInputBorder _inputBorder(AppPalette p, Color color, double w) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide(color: color, width: w),
    );
  }

  static TextTheme _textTheme(AppPalette p) {
    TextStyle s(
      double size,
      FontWeight weight,
      Color color, {
      double? height,
      double? letterSpacing,
    }) =>
        TextStyle(
          fontSize: size,
          fontWeight: weight,
          color: color,
          height: height,
          letterSpacing: letterSpacing,
        );

    return TextTheme(
      displayLarge: s(34, FontWeight.w700, p.textPrimary, height: 1.15, letterSpacing: -0.5),
      displayMedium: s(30, FontWeight.w700, p.textPrimary, height: 1.18, letterSpacing: -0.4),
      displaySmall: s(26, FontWeight.w700, p.textPrimary, height: 1.2),
      headlineLarge: s(24, FontWeight.w700, p.textPrimary, height: 1.25),
      headlineMedium: s(22, FontWeight.w700, p.textPrimary, height: 1.25),
      headlineSmall: s(20, FontWeight.w700, p.textPrimary, height: 1.3),
      titleLarge: s(19, FontWeight.w700, p.textPrimary, height: 1.3),
      titleMedium: s(16.5, FontWeight.w600, p.textPrimary, height: 1.3),
      titleSmall: s(15, FontWeight.w600, p.textPrimary, height: 1.3),
      bodyLarge: s(16, FontWeight.w400, p.textPrimary, height: 1.45),
      bodyMedium: s(14.5, FontWeight.w400, p.textPrimary, height: 1.45),
      bodySmall: s(13, FontWeight.w400, p.textSecondary, height: 1.4),
      labelLarge: s(15.5, FontWeight.w600, p.textPrimary, height: 1.2),
      labelMedium: s(13, FontWeight.w600, p.textSecondary, height: 1.2),
      labelSmall: s(11.5, FontWeight.w600, p.textSecondary, height: 1.2, letterSpacing: 0.2),
    );
  }
}
