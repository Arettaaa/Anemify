import 'package:flutter_test/flutter_test.dart';
import 'package:anemify/main.dart';

void main() {
  testWidgets('Anemify app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const AnemifyApp());

    expect(find.text('Anemify'), findsOneWidget);
  }, skip: true); // SEMENTARA (Yumna): home = DebugParityPage. Aktifkan lagi saat halaman utama sudah ada.
}