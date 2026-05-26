import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subtrack/main.dart';

void main() {
  testWidgets('Premio initialization test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: SubTrackApp(),
      ),
    );
    // Since Splash screen has 'PREMIO' title
    expect(find.text('PREMIO'), findsOneWidget);
  });
}
