import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:project_strava/models/saved_route.dart';
import 'package:project_strava/pages/stats_page.dart';
import 'package:project_strava/services/local_storage.dart';
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

  testWidgets('tab Rute menampilkan semua rute buatan yang tersimpan', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorage.saveRoutes([
      const SavedRoute(
        name: 'Rute 1',
        points: [LatLng(-6.2, 106.8), LatLng(-6.201, 106.801)],
      ),
      const SavedRoute(
        name: 'Rute 2',
        points: [LatLng(-6.3, 106.9), LatLng(-6.301, 106.901)],
      ),
    ]);

    await tester.pumpWidget(const MaterialApp(home: StatsPage()));
    await tester.pumpAndSettle();

    expect(find.text('Rute 1'), findsOneWidget);
    expect(find.text('Rute 2'), findsOneWidget);
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
