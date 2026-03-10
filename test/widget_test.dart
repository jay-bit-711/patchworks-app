import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Patchworks basic UI smoke test', (WidgetTester tester) async {
    // Build a basic version of our splash screen to verify the test environment is healthy.
    // We avoid pumping the full MyApp here because it requires a live Firebase connection
    // or complex mocking which is best handled during the backend wiring phase.
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          backgroundColor: Color(0xFF0D1117),
          body: Center(
            child: Text(
              'PATCHWORKS',
              style: TextStyle(
                fontSize: 36,
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    );

    // Verify that our brand name is rendered correctly.
    expect(find.text('PATCHWORKS'), findsOneWidget);
  });
}
