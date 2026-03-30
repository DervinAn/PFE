import 'package:flutter_test/flutter_test.dart';

import 'package:untitled/main.dart';

void main() {
  testWidgets('VacciTrack app boots to splash', (WidgetTester tester) async {
    await tester.pumpWidget(const VacciTrackApp());

    expect(find.text('VacciTrack'), findsOneWidget);
  });
}
