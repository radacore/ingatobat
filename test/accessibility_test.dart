// Uji regresi FR-13 (aksesibilitas):
// - tema tidak boleh crash untuk kombinasi aksesibilitas apa pun
// - skala huruf harus benar-benar mengubah ukuran teks yang dirender

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ingatobat/core/theme/app_theme.dart';

Widget _wrap(Widget child, {double textScale = 1.0}) {
  return MaterialApp(
    theme: AppTheme.build(),
    builder: (context, appChild) => MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(textScale),
      ),
      child: appChild ?? const SizedBox.shrink(),
    ),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  testWidgets('Tema dapat dibangun untuk semua kombinasi aksesibilitas', (
    tester,
  ) async {
    for (final large in [false, true]) {
      for (final hc in [false, true]) {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.build(largeButtons: large, highContrast: hc),
            home: const Scaffold(body: Center(child: Text('Tes'))),
          ),
        );
        expect(tester.takeException(), isNull);
      }
    }
  });

  testWidgets('textScaler memperbesar ukuran teks', (tester) async {
    await tester.pumpWidget(
      _wrap(const Text('Tes', style: TextStyle(fontSize: 20))),
    );
    final base = tester.getSize(find.text('Tes'));

    await tester.pumpWidget(
      _wrap(const Text('Tes', style: TextStyle(fontSize: 20)), textScale: 1.5),
    );
    final scaled = tester.getSize(find.text('Tes'));

    expect(scaled.width, greaterThan(base.width));
    expect(scaled.height, greaterThan(base.height));
  });
}
