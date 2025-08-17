import 'package:flutter_test/flutter_test.dart';
import 'package:moneyquest/app/app.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('App renders MaterialApp', (tester) async {
    await tester.pumpWidget(const MoneyQuestApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
