import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subtrack/features/auth/screens/onboarding_screen.dart';

void main() {
  testWidgets('Onboarding Screen renders slides and navigates', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: OnboardingScreen(),
        ),
      ),
    );

    // Verify slide 1 is displayed
    expect(find.text('TRACK EVERYTHING'), findsOneWidget);
    expect(find.text('SMART RENEWAL ALERTS'), findsNothing);

    // Find the Next button by its arrow icon
    final nextBtn = find.byIcon(Icons.arrow_forward_rounded);
    expect(nextBtn, findsOneWidget);

    // Tap Next
    await tester.tap(nextBtn);
    await tester.pumpAndSettle();

    // Verify slide 2 is displayed
    expect(find.text('TRACK EVERYTHING'), findsNothing);
    expect(find.text('SMART RENEWAL ALERTS'), findsOneWidget);
  });
}
