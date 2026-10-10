// Uji asap: memastikan tema dan konstanta aplikasi dapat dimuat tanpa error.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ingatobat/core/constants.dart';
import 'package:ingatobat/core/theme/app_theme.dart';

void main() {
  testWidgets('Tema aplikasi dapat dibangun', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(),
        home: const Scaffold(body: Center(child: Text(AppInfo.appName))),
      ),
    );

    expect(find.text(AppInfo.appName), findsOneWidget);
  });
}
