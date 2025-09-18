import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pirr_app/login_screen.dart';

void main() {
  testWidgets('Shows validation errors for bad email and short password', (
    tester,
  ) async {
    await tester.pumpWidget(MaterialApp(home: LoginScreen(onLogin: () {})));

    await tester.enterText(find.byType(TextField).at(0), 'invalid');
    await tester.enterText(find.byType(TextField).at(1), '123');
    await tester.tap(find.byKey(const Key('auth_button')));
    await tester.pump();

    expect(find.text('Please enter a valid email address'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(0), 'a@b.com');
    await tester.tap(find.byKey(const Key('auth_button')));
    await tester.pump();

    expect(find.text('Password must be at least 6 characters'), findsOneWidget);
  });
}
