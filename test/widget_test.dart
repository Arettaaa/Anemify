import 'package:flutter_test/flutter_test.dart';
import 'package:anemify/main.dart';

void main() {
  testWidgets('Anemify app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const AnemifyApp());

    expect(find.text('Anemify'), findsOneWidget);
  });
}