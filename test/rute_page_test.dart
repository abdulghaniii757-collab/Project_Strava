import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_strava/pages/stats_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _bukaTabRute(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
  await tester.pumpWidget(const MaterialApp(home: StatsPage()));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('tab Rute menampilkan rute saya dan rute populer', (
    WidgetTester tester,
  ) async {
    await _bukaTabRute(tester);

    expect(find.text('Rute Saya'), findsOneWidget);
    expect(find.text('Rute Populer'), findsOneWidget);
    expect(find.textContaining('Belum ada rute'), findsOneWidget);
    expect(find.text('Rute Monas Loop'), findsOneWidget);
  });

  testWidgets('filter Sepeda cuma menampilkan rute sepeda', (
    WidgetTester tester,
  ) async {
    await _bukaTabRute(tester);

    await tester.tap(find.text('Sepeda'));
    await tester.pumpAndSettle();

    expect(find.text('Gowes PIK 2 Coast'), findsOneWidget);
    expect(find.text('Rute Monas Loop'), findsNothing);
  });

  testWidgets('pencarian menyaring rute berdasarkan nama', (
    WidgetTester tester,
  ) async {
    await _bukaTabRute(tester);

    await tester.enterText(find.byType(TextField), 'monas');
    await tester.pumpAndSettle();

    expect(find.text('Rute Monas Loop'), findsOneWidget);
    expect(find.text('GBK Senayan Loop'), findsNothing);

    await tester.enterText(find.byType(TextField), 'tidak-ada-rute-ini');
    await tester.pumpAndSettle();

    expect(find.text('Tidak ada rute populer yang cocok.'), findsOneWidget);
  });
}