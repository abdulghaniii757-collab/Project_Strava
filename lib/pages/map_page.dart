import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../models/activity.dart';
import '../models/saved_route.dart';
import '../services/local_storage.dart';
import '../services/route_store.dart';
import '../widgets/route_name_dialog.dart';
import '../widgets/save_activity_dialog.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key, required this.onActivityRecorded});

  final VoidCallback onActivityRecorded;

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final _mapController = MapController();
  final _draftPoints = <LatLng>[];
  final _recordedPoints = <LatLng>[];
  final _distance = const Distance();

  LatLng _mapCenter = const LatLng(-6.2, 106.816666);
  Position? _currentPosition;
  int _seenCreateRequests = 0;
  int _seenShowRequests = 0;
  String _routeName = '';
  bool _isCreatingRoute = false;
  bool _isRecording = false;
  String _activityType = 'Jalan Kaki';
  DateTime? _recordingStartedAt;
  Duration _elapsed = Duration.zero;
  double _distanceMeters = 0;
  StreamSubscription<Position>? _positionSubscription;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    final store = RouteStore.instance;
    _seenCreateRequests = store.createRequests;
    _seenShowRequests = store.showRequests;
    store.addListener(_onRouteStoreChanged);
    _loadRoutes();
    _loadCurrentLocation();
  }

  @override
  void dispose() {
    RouteStore.instance.removeListener(_onRouteStoreChanged);
    _positionSubscription?.cancel();
    _timer?.cancel();
    super.dispose();
  }

  // Daftar dan pilihan rute disimpan di RouteStore, biar tab Rute dan Peta sinkron.
  List<SavedRoute> get _savedRoutes => RouteStore.instance.routes;
  SavedRoute? get _selectedRoute => RouteStore.instance.selected;

  List<LatLng> get _visiblePoints {
    if (_isRecording) return _recordedPoints;
    if (_isCreatingRoute) return _draftPoints;
    return _selectedRoute?.points ?? [];
  }

  Future<void> _loadRoutes() async {
    await RouteStore.instance.load();
    if (!mounted) return;
    setState(() {});
  }

  /// Dipanggil tiap isi RouteStore berubah, termasuk permintaan dari tab Rute
  /// untuk membuat rute baru atau membuka rute tertentu di peta ini.
  void _onRouteStoreChanged() {
    if (!mounted) return;
    final store = RouteStore.instance;
    final wantsCreate = store.createRequests != _seenCreateRequests;
    final wantsShow = store.showRequests != _seenShowRequests;
    _seenCreateRequests = store.createRequests;
    _seenShowRequests = store.showRequests;

    setState(() {});

    if (!wantsCreate && !wantsShow) return;
    if (_isRecording || _isCreatingRoute) {
      _showMessage('Selesaikan dulu rekaman atau rute yang sedang dibuat.');
      return;
    }
    if (wantsCreate) {
      _createRoute();
    } else {
      final route = store.selected;
      if (route != null) _fitToRoute(route);
    }
  }

  Future<bool> _requestLocationPermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      _showMessage('Aktifkan layanan lokasi terlebih dahulu.');
      return false;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      _showMessage('Izin lokasi diperlukan untuk menggunakan GPS.');
      return false;
    }
    return true;
  }

  Future<void> _loadCurrentLocation() async {
    if (!await _requestLocationPermission()) return;
    final position = await Geolocator.getCurrentPosition();
    if (!mounted) return;
    setState(() {
      _currentPosition = position;
      _mapCenter = LatLng(position.latitude, position.longitude);
    });
    _mapController.move(_mapCenter, 15);
  }

  void _centerMap() {
    final position = _currentPosition;
    if (position == null) {
      _loadCurrentLocation();
      return;
    }
    _mapController.move(LatLng(position.latitude, position.longitude), 16);
  }

  void _selectRoute(SavedRoute route) {
    RouteStore.instance.select(route);
    _fitToRoute(route);
  }

  void _fitToRoute(SavedRoute route) {
    if (route.points.length < 2) return;
    try {
      _mapController.fitCamera(
        CameraFit.coordinates(
          coordinates: route.points,
          padding: const EdgeInsets.fromLTRB(32, 112, 32, 200),
          maxZoom: 16,
        ),
      );
    } catch (_) {
      // Peta belum siap digerakkan; rutenya tetap tergambar di layar.
    }
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    if (_isCreatingRoute) setState(() => _draftPoints.add(point));
  }

  double _routeDistanceKm(List<LatLng> points) {
    var meters = 0.0;
    for (var i = 1; i < points.length; i++) {
      meters += _distance.as(LengthUnit.Meter, points[i - 1], points[i]);
    }
    return meters / 1000;
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }
    return '${duration.inMinutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _mapCenter,
                initialZoom: 15,
                onTap: _onMapTap,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.project_strava',
                ),
                SimpleAttributionWidget(
                  source: const Text('© OpenStreetMap contributors'),
                ),
                if (_isRecording && (_selectedRoute?.points.length ?? 0) > 1)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _selectedRoute!.points,
                        strokeWidth: 5,
                        color: Colors.blue,
                      ),
                    ],
                  ),
                if (_isRecording && _recordedPoints.length > 1)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _recordedPoints,
                        strokeWidth: 5,
                        color: Colors.deepOrange,
                      ),
                    ],
                  )
                else if (!_isRecording && _visiblePoints.length > 1)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _visiblePoints,
                        strokeWidth: 5,
                        color: Colors.deepOrange,
                      ),
                    ],
                  ),
                if (_currentPosition != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(
                          _currentPosition!.latitude,
                          _currentPosition!.longitude,
                        ),
                        width: 28,
                        height: 28,
                        child: const Icon(
                          Icons.my_location,
                          color: Colors.blue,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              child: Column(
                children: [
                  _header(),
                  const Spacer(),
                  if (_isRecording)
                    _recordingControls()
                  else if (_isCreatingRoute)
                    _routeControls()
                  else
                    _mapControls(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() => Card(
    child: ListTile(
      title: const Text('Peta', style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(
        _selectedRoute == null
            ? 'Buat rute atau mulai jalan'
            : '${_selectedRoute!.name} · '
                  '${_routeDistanceKm(_selectedRoute!.points).toStringAsFixed(2)} km',
      ),
      trailing: _selectedRoute == null || _isRecording || _isCreatingRoute
          ? null
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Ubah nama rute',
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: _renameRoute,
                ),
                IconButton(
                  tooltip: 'Hapus rute',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: _deleteRoute,
                ),
              ],
            ),
    ),
  );

  Widget _mapControls() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (_savedRoutes.isNotEmpty) ...[
        DropdownButtonFormField<SavedRoute>(
          value: _selectedRoute,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Pilih rute',
            filled: true,
          ),
          items: [
            for (final route in _savedRoutes)
              DropdownMenuItem(
                value: route,
                child: Text(
                  '${route.name} · ${_routeDistanceKm(route.points).toStringAsFixed(2)} km',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
          onChanged: (route) {
            if (route != null) _selectRoute(route);
          },
        ),
        const SizedBox(height: 12),
      ],
      Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              onPressed: _createRoute,
              icon: const Icon(Icons.edit_road),
              label: const Text('Buat rute'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _chooseTypeAndStart,
              icon: const Icon(Icons.fiber_manual_record),
              label: const Text('Mulai rekam'),
            ),
          ),
        ],
      ),
      Align(
        alignment: Alignment.centerRight,
        child: IconButton.filledTonal(
          tooltip: 'Lokasi saya',
          onPressed: _centerMap,
          icon: const Icon(Icons.my_location),
        ),
      ),
    ],
  );

  Widget _routeControls() => _bottomCard(
    children: [
      Text(
        'Ketuk peta untuk menambahkan titik (${_draftPoints.length})',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      Text('Jarak: ${_routeDistanceKm(_draftPoints).toStringAsFixed(2)} km'),
      Row(
        children: [
          TextButton(
            onPressed: () => setState(() {
              _isCreatingRoute = false;
              _draftPoints.clear();
            }),
            child: const Text('Batal'),
          ),
          const Spacer(),
          FilledButton(onPressed: _saveRoute, child: const Text('Simpan rute')),
        ],
      ),
    ],
  );

  Widget _recordingControls() => _bottomCard(
    children: [
      Row(
        children: [
          Icon(activityIcon(_activityType), size: 18, color: Colors.deepOrange),
          const SizedBox(width: 6),
          Text(
            '${activityVerb(_activityType)} sedang direkam',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
      if ((_selectedRoute?.points.length ?? 0) > 1)
        const Padding(
          padding: EdgeInsets.only(top: 8),
          child: Row(
            children: [
              Icon(Icons.circle, size: 10, color: Colors.blue),
              SizedBox(width: 5),
              Text('Rute tersimpan'),
              SizedBox(width: 12),
              Icon(Icons.circle, size: 10, color: Colors.deepOrange),
              SizedBox(width: 5),
              Text('Jejak rekaman'),
            ],
          ),
        ),
      Row(
        children: [
          Expanded(
            child: Text(
              '${_formatDuration(_elapsed)}  ·  '
              '${(_distanceMeters / 1000).toStringAsFixed(2)} km',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          FilledButton.icon(
            onPressed: _finishWalk,
            icon: const Icon(Icons.stop),
            label: const Text('Selesai'),
          ),
        ],
      ),
    ],
  );

  Widget _bottomCard({required List<Widget> children}) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    ),
  );

  Future<void> _createRoute() async {
    // Controller nama rute diurus sama _RouteNameDialog sendiri. Kalau di-dispose
    // di sini, TextField-nya masih kepakai selama animasi dialog nutup -> error.
    final name = await showDialog<String>(
      context: context,
      builder: (context) => const _RouteNameDialog(),
    );
    if (!mounted || name == null) return;
    if (name.isEmpty) {
      _showMessage('Nama rute tidak boleh kosong.');
      return;
    }
    setState(() {
      _routeName = name;
      _draftPoints.clear();
      _isCreatingRoute = true;
    });
  }

  Future<void> _saveRoute() async {
    if (_draftPoints.length < 2) {
      _showMessage('Tambahkan minimal 2 titik pada peta.');
      return;
    }

    final route = SavedRoute(
      name: _routeName,
      points: List<LatLng>.unmodifiable(_draftPoints),
    );
    await RouteStore.instance.add(route);
    if (!mounted) return;
    setState(() {
      _isCreatingRoute = false;
      _draftPoints.clear();
    });
    _showMessage('Rute "${route.name}" disimpan.');
  }

  Future<void> _renameRoute() async {
    final route = _selectedRoute;
    if (route == null) return;

    final name = await showRouteNameDialog(context, initialName: route.name);
    if (name == null || !mounted) return;
    if (name.isEmpty) {
      _showMessage('Nama rute tidak boleh kosong.');
      return;
    }
    if (name == route.name) return;

    await RouteStore.instance.rename(route, name);
    if (!mounted) return;
    _showMessage('Rute diubah menjadi "$name".');
  }

  Future<void> _deleteRoute() async {
    final route = _selectedRoute;
    if (route == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus rute?'),
        content: Text('Rute "${route.name}" akan dihapus permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    await RouteStore.instance.remove(route);
    if (!mounted) return;
    _showMessage('Rute "${route.name}" dihapus.');
  }

  Future<void> _chooseTypeAndStart() async {
    final type = await showActivityTypePicker(context);
    if (!mounted || type == null) return;
    setState(() => _activityType = type);
    await _startWalk();
  }

  Future<void> _startWalk() async {
    if (!await _requestLocationPermission() || !mounted) return;
    final position = await Geolocator.getCurrentPosition();
    if (!mounted) return;
    final start = LatLng(position.latitude, position.longitude);
    setState(() {
      _currentPosition = position;
      _recordedPoints
        ..clear()
        ..add(start);
      _distanceMeters = 0;
      _elapsed = Duration.zero;
      _recordingStartedAt = DateTime.now();
      _isRecording = true;
    });
    final routePoints = _selectedRoute?.points;
    if (routePoints != null && routePoints.length > 1) {
      _mapController.fitCamera(
        CameraFit.coordinates(
          coordinates: [...routePoints, start],
          padding: const EdgeInsets.fromLTRB(32, 112, 32, 200),
          maxZoom: 16,
        ),
      );
    } else {
      _mapController.move(start, 16);
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final startedAt = _recordingStartedAt;
      if (!mounted || startedAt == null) return;
      setState(() => _elapsed = DateTime.now().difference(startedAt));
    });
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 3,
      ),
    ).listen(_onPosition, onError: _onLocationError);
  }

  void _onPosition(Position position) {
    if (!mounted || !_isRecording || _recordedPoints.isEmpty) return;
    final point = LatLng(position.latitude, position.longitude);
    final addedDistance = _distance.as(
      LengthUnit.Meter,
      _recordedPoints.last,
      point,
    );
    if (addedDistance < 1) return;
    setState(() {
      _recordedPoints.add(point);
      _distanceMeters += addedDistance;
      _currentPosition = position;
    });
  }

  void _onLocationError(Object error) {
    _stopRecording();
    if (!mounted) return;
    setState(() => _isRecording = false);
    _showMessage('Gagal membaca lokasi: $error');
  }

  Future<void> _finishWalk() async {
    _stopRecording();
    final startedAt = _recordingStartedAt;
    final duration = _elapsed;
    final distanceKm = _distanceMeters / 1000;
    setState(() => _isRecording = false);

    if (startedAt == null || distanceKm <= 0 || duration.inSeconds <= 0) {
      _showMessage('Belum ada jarak yang tercatat. Coba jalan sebentar lagi.');
      return;
    }

    final summary =
        '${distanceKm.toStringAsFixed(2)} km · ${_formatDuration(duration)}';
    final info = await showSaveActivityDialog(
      context,
      summary: summary,
      initialType: _activityType,
    );
    if (!mounted) return;
    if (info == null) {
      _showMessage('Rekaman dibuang.');
      return;
    }

    final activity = Activity(
      name: info.name,
      type: info.type,
      distanceKm: distanceKm,
      duration: _formatActivityDuration(duration),
      date: startedAt,
      routePoints: List.unmodifiable(_recordedPoints),
    );
    dummyActivities.insert(0, activity);
    await LocalStorage.saveActivities(dummyActivities);
    if (!mounted) return;
    widget.onActivityRecorded();
    _showMessage('${info.name} tersimpan: $summary');
  }

  void _stopRecording() {
    _timer?.cancel();
    _timer = null;
    _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  String _formatActivityDuration(Duration duration) {
    return '${duration.inMinutes.toString().padLeft(2, '0')}:'
        '${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}';
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

class _RouteNameDialog extends StatefulWidget {
  const _RouteNameDialog();

  @override
  State<_RouteNameDialog> createState() => _RouteNameDialogState();
}

class _RouteNameDialogState extends State<_RouteNameDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Buat rute'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(
          labelText: 'Nama rute',
          hintText: 'Contoh: Keliling',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text.trim()),
          child: const Text('Lanjut'),
        ),
      ],
    );
  }
}