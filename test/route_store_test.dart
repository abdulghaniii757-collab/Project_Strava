import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:project_strava/models/saved_route.dart';
import 'package:project_strava/services/route_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

SavedRoute _rute(String name) => SavedRoute(
  name: name,
  points: const [LatLng(-6.2, 106.8), LatLng(-6.21, 106.81)],
);

void main() {
  final store = RouteStore.instance;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    store.resetForTest();
  });

  test('awalnya belum ada rute', () async {
    await store.load();
    expect(store.routes, isEmpty);
    expect(store.selected, isNull);
  });

  test('bisa menyimpan banyak rute sesuai urutan simpan', () async {
    await store.add(_rute('Rute A'));
    await store.add(_rute('Rute B'));

    expect(store.routes.map((r) => r.name), ['Rute A', 'Rute B']);
    expect(store.selected?.name, 'Rute B');
  });

  test('rute tetap ada setelah app dibuka ulang', () async {
    await store.add(_rute('Rute A'));
    await store.add(_rute('Rute B'));

    store.resetForTest(); // seolah app baru dibuka, isi memori kosong
    await store.load();

    expect(store.routes.map((r) => r.name), ['Rute A', 'Rute B']);
  });

  test('menghapus satu rute tidak menghapus rute lain', () async {
    await store.add(_rute('Rute A'));
    await store.add(_rute('Rute B'));

    await store.remove(store.routes.last); // hapus Rute B (yang terpilih)

    expect(store.routes.map((r) => r.name), ['Rute A']);
    expect(store.selected?.name, 'Rute A');

    store.resetForTest();
    await store.load();
    expect(store.routes.map((r) => r.name), ['Rute A']);
  });

  test('menghapus rute terakhir mengosongkan pilihan', () async {
    await store.add(_rute('Rute A'));
    await store.remove(store.routes.first);

    expect(store.routes, isEmpty);
    expect(store.selected, isNull);
  });

  test('mengubah nama rute tersimpan dan pilihan ikut berganti', () async {
    await store.add(_rute('Rute A'));

    final berhasil = await store.rename(store.routes.first, '  Rute Baru  ');

    expect(berhasil, isTrue);
    expect(store.routes.single.name, 'Rute Baru');
    expect(store.selected?.name, 'Rute Baru');

    store.resetForTest();
    await store.load();
    expect(store.routes.single.name, 'Rute Baru');
  });

  test('nama kosong ditolak saat mengubah nama', () async {
    await store.add(_rute('Rute A'));

    expect(await store.rename(store.routes.first, '   '), isFalse);
    expect(store.routes.single.name, 'Rute A');
  });

  test('permintaan dari tab lain menaikkan penghitung', () async {
    await store.add(_rute('Rute A'));
    var dipanggil = 0;
    store.addListener(() => dipanggil++);

    store.requestCreate();
    store.openInMap(store.routes.first);
    store.openInMap(store.routes.first); // rute yang sama tetap dihitung
    store.select(store.routes.first); // pilih biasa bukan permintaan

    expect(store.createRequests, 1);
    expect(store.showRequests, 2);
    expect(dipanggil, 4);
  });
}