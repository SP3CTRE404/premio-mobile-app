import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subtrack/main.dart';

void main() {
  testWidgets('SubTrack initialization test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: SubTrackApp(),
      ),
    );
    // Since Appbar has 'SubTrack' title
    expect(find.text('SubTrack'), findsOneWidget);
  });
}
