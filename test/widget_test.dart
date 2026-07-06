import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_ecommerce/main.dart';

void main() {
  testWidgets('ShopApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ShopApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
