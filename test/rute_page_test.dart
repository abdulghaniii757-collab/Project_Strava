import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:project_strava/models/saved_route.dart';
import 'package:project_strava/pages/stats_page.dart';
import 'package:project_strava/services/local_storage.dart';
import 'package:project_strava/services/route_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _bukaTabRute(
  WidgetTester tester, {
  VoidCallback? onCreate,
  void Function(SavedRoute route)? onOpen,
}) async {
  SharedPreferences.setMockInitialValues({});
  RouteStore.instance.resetForTest();
  await tester.pumpWidget(
    MaterialApp(
      home: StatsPage(onCreateRoute: onCreate, onOpenRoute: onOpen),
    ),
  );
  await tester.pumpAndSettle();
}

/// Mengisi penyimpanan dengan rute, lalu membuka tab Rute.
Future<void> _bukaDenganRute(
  WidgetTester tester,
  List<SavedRoute> rute, {
  void Function(SavedRoute route)? onOpen,
}) async {
  SharedPreferences.setMockInitialValues({});
  RouteStore.instance.resetForTest();
  await LocalStorage.saveRoutes(rute);
  await tester.pumpWidget(MaterialApp(home: StatsPage(onOpenRoute: onOpen)));
  await tester.pumpAndSettle();
}

SavedRoute _rute(String name, double lat) => SavedRoute(
  name: name,
  points: [LatLng(lat, 106.8), LatLng(lat + 0.001, 106.801)],
);

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
    await _bukaDenganRute(tester, [
      _rute('Rute 1', -6.2),
      _rute('Rute 2', -6.3),
    ]);

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

  testWidgets('tombol Buat rute baru memanggil callback', (
    WidgetTester tester,
  ) async {
    var dipanggil = false;
    await _bukaTabRute(tester, onCreate: () => dipanggil = true);

    await tester.tap(find.text('Buat rute baru'));

    expect(dipanggil, isTrue);
  });

  testWidgets('mengetuk rute buatan membukanya di Peta', (
    WidgetTester tester,
  ) async {
    SavedRoute? dibuka;
    await _bukaDenganRute(tester, [
      _rute('Rute 1', -6.2),
    ], onOpen: (route) => dibuka = route);

    await tester.tap(find.text('Rute 1'));

    expect(dibuka?.name, 'Rute 1');
  });

  testWidgets('menghapus rute lewat menu opsi', (WidgetTester tester) async {
    await _bukaDenganRute(tester, [_rute('Rute 1', -6.2)]);

    await tester.tap(find.byTooltip('Opsi rute'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hapus'));
    await tester.pumpAndSettle();

    expect(find.text('Hapus rute?'), findsOneWidget);

    await tester.tap(find.text('Hapus'));
    await tester.pumpAndSettle();

    expect(find.text('Rute 1'), findsNothing);
    expect(RouteStore.instance.routes, isEmpty);
  });
}