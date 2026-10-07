import 'package:flutter/foundation.dart';

import '../models/saved_route.dart';
import 'local_storage.dart';

/// Tempat tunggal untuk rute buatan. Tab Peta dan tab Rute sama-sama baca dan
/// tulis lewat sini, jadi keduanya selalu sinkron tanpa saling kenal.
class RouteStore extends ChangeNotifier {
  RouteStore._();

  static final RouteStore instance = RouteStore._();

  final List<SavedRoute> _routes = [];
  SavedRoute? _selected;
  Future<void>? _loading;
  int _createRequests = 0;
  int _showRequests = 0;

  /// Semua rute buatan, sesuai urutan disimpan (yang terlama di depan).
  List<SavedRoute> get routes => List.unmodifiable(_routes);

  /// Rute yang lagi dipilih dan ditampilkan di tab Peta.
  SavedRoute? get selected => _selected;

  /// Naik tiap ada permintaan "buat rute baru" dari tab lain.
  int get createRequests => _createRequests;

  /// Naik tiap ada permintaan "buka rute ini di peta" dari tab lain.
  int get showRequests => _showRequests;

  /// Memuat rute dari penyimpanan. Aman dipanggil berkali-kali, cuma jalan sekali.
  Future<void> load() => _loading ??= _load();

  Future<void> _load() async {
    List<SavedRoute> saved;
    try {
      saved = await LocalStorage.loadRoutes();
    } catch (_) {
      // Data rusak dianggap kosong, biar tab Peta dan Rute tetap bisa dibuka.
      saved = [];
    }
    _routes
      ..clear()
      ..addAll(saved);
    _selected = _routes.isEmpty ? null : _routes.first;
    notifyListeners();
  }

  Future<void> add(SavedRoute route) async {
    await load();
    _routes.add(route);
    _selected = route;
    await LocalStorage.saveRoutes(_routes);
    notifyListeners();
  }

  Future<void> remove(SavedRoute route) async {
    await load();
    _routes.remove(route);
    if (identical(_selected, route)) {
      _selected = _routes.isEmpty ? null : _routes.first;
    }
    await LocalStorage.saveRoutes(_routes);
    notifyListeners();
  }

  /// Mengganti nama rute. Mengembalikan false kalau nama kosong atau rute
  /// tidak ditemukan.
  Future<bool> rename(SavedRoute route, String newName) async {
    await load();
    final name = newName.trim();
    final index = _routes.indexOf(route);
    if (name.isEmpty || index == -1) return false;

    final renamed = SavedRoute(name: name, points: route.points);
    _routes[index] = renamed;
    if (identical(_selected, route)) _selected = renamed;
    await LocalStorage.saveRoutes(_routes);
    notifyListeners();
    return true;
  }

  /// Pilih rute biasa (misalnya dari dropdown di tab Peta).
  void select(SavedRoute route) {
    _selected = route;
    notifyListeners();
  }

  /// Minta tab Peta menampilkan rute ini dan menggeser kameranya ke sana.
  void openInMap(SavedRoute route) {
    _selected = route;
    _showRequests++;
    notifyListeners();
  }

  /// Minta tab Peta mulai membuat rute baru.
  void requestCreate() {
    _createRequests++;
    notifyListeners();
  }

  /// Khusus tes: kosongkan isi memori, seolah app baru dibuka.
  @visibleForTesting
  void resetForTest() {
    _routes.clear();
    _selected = null;
    _loading = null;
    _createRequests = 0;
    _showRequests = 0;
  }
}