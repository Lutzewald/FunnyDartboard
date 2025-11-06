import 'package:flutter_test/flutter_test.dart';
import 'package:dartboard_flutter/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const DartBoardApp());

    // Verify that the main menu screen is displayed
    expect(find.text('DartBoard'), findsOneWidget);
  });
}

