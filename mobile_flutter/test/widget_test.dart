// Widget Test — PrimaPulih
// Test smoke dasar untuk memastikan app dapat di-render

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:prima_pulih/main.dart';

void main() {
  testWidgets('PrimaPulih app smoke test', (WidgetTester tester) async {
    // Build aplikasi dan trigger frame pertama
    await tester.pumpWidget(const PrimaPulihApp());
    // Verifikasi bahwa app dapat dirender tanpa crash
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
