<<<<<<< HEAD
import 'package:flutter/material.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key, required this.onAddActivity});

  final VoidCallback onAddActivity;
=======
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../models/activity.dart';
import '../models/saved_route.dart';
import '../services/local_storage.dart';
import '../widgets/save_activity_dialog.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key, required this.onActivityRecorded});

  final VoidCallback onActivityRecorded;
>>>>>>> 55e8c4b70038aaa6754a400e0274880266a10e3c

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
<<<<<<< HEAD
  String _selectedFilter = 'Rute';
  bool _is3D = false;
  bool _isCentered = false;
  bool _isSaved = false;
  bool _showRoads = true;
  bool _showRoute = true;
=======
  final _mapController = MapController();
  final _draftPoints = <LatLng>[];
  final _recordedPoints = <LatLng>[];
  final _distance = const Distance();

  LatLng _mapCenter = const LatLng(-6.2, 106.816666);
  Position? _currentPosition;
  List<SavedRoute> _savedRoutes = [];
  SavedRoute? _selectedRoute;
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
    _loadRoutes();
    _loadCurrentLocation();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _timer?.cancel();
    super.dispose();
  }

  List<LatLng> get _visiblePoints {
    if (_isRecording) return _recordedPoints;
    if (_isCreatingRoute) return _draftPoints;
    return _selectedRoute?.points ?? [];
  }

  Future<void> _loadRoutes() async {
    final routes = await LocalStorage.loadRoutes();
    if (!mounted) return;
    setState(() {
      _savedRoutes = routes;
      _selectedRoute = routes.isEmpty ? null : routes.first;
    });
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
    setState(() => _selectedRoute = route);
    _mapController.fitCamera(
      CameraFit.coordinates(
        coordinates: route.points,
        padding: const EdgeInsets.fromLTRB(32, 112, 32, 200),
        maxZoom: 16,
      ),
    );
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
>>>>>>> 55e8c4b70038aaa6754a400e0274880266a10e3c

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
<<<<<<< HEAD
            child: CustomPaint(
              painter: _CityMapPainter(
                is3D: _is3D,
                isCentered: _isCentered,
                showRoads: _showRoads,
                showRoute: _showRoute,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _topBar(),
                const SizedBox(height: 12),
                _filters(),
                const Spacer(),
                _mapActions(),
                _routeCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _topBar() => Container(
    margin: const EdgeInsets.symmetric(horizontal: 14),
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(17),
      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 14)],
    ),
    child: Row(
      children: [
        IconButton(
          onPressed: _showSearch,
          icon: const Icon(
            Icons.directions_run,
            color: Color(0xFFE84B16),
            size: 30,
          ),
        ),
        const Expanded(
          child: Text(
            'Cari',
            style: TextStyle(fontSize: 23, fontWeight: FontWeight.w700),
          ),
        ),
        IconButton(
          onPressed: _toggleSaved,
          icon: Icon(
            _isSaved ? Icons.bookmark : Icons.bookmark_border,
            size: 29,
          ),
        ),
        TextButton(
          onPressed: _toggleSaved,
          child: Text(
            _isSaved ? 'Tersimpan' : 'Simpan',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _filters() => SizedBox(
    height: 52,
    child: ListView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      children: [
        for (final filter in [
          'Rute',
          'Panjang',
          'Kesulitan',
          'Elevasi',
          'Permukaan',
        ])
          GestureDetector(
            onTap: () => setState(() => _selectedFilter = filter),
            child: _MapChip(filter, selected: _selectedFilter == filter),
          ),
      ],
    ),
  );

  Widget _mapActions() => Align(
    alignment: Alignment.centerRight,
    child: Padding(
      padding: const EdgeInsets.only(right: 16, bottom: 10),
      child: Column(
        children: [
          GestureDetector(
            onTap: _showLayers,
            child: _roundAction(Icons.layers_outlined, badge: '2'),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => setState(() => _is3D = !_is3D),
            child: _roundAction(
              Icons.threed_rotation,
              label: _is3D ? '2D' : '3D',
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: _centerMap,
            child: _roundAction(Icons.my_location),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'create-route',
            onPressed: _showCreateRoute,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            icon: const Icon(Icons.edit_location_alt_outlined),
            label: const Text(
              'Buat Rute',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _roundAction(IconData icon, {String? label, String? badge}) => Stack(
    clipBehavior: Clip.none,
    children: [
      Container(
        width: 64,
        height: 64,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: label == null
              ? Icon(icon, size: 32)
              : Text(
                  label,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      ),
      if (badge != null)
        Positioned(
          right: -2,
          top: -5,
          child: Container(
            padding: const EdgeInsets.all(7),
            decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
            child: Text(
              badge,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
    ],
  );

  Widget _routeCard() => GestureDetector(
    onTap: _showRouteDetails,
    child: Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 10),
      height: 142,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 12)],
      ),
      child: Row(
        children: [
          Container(
            width: 136,
            decoration: const BoxDecoration(
              color: Color(0xFF55735F),
              borderRadius: BorderRadius.horizontal(left: Radius.circular(22)),
            ),
            child: const Icon(
              Icons.park_outlined,
              color: Colors.white,
              size: 54,
            ),
          ),
          const Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(14, 15, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Jalan Tanjung Gedong-J...',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: 11),
                  Row(
                    children: [
                      Icon(
                        Icons.directions_run,
                        size: 22,
                        color: Colors.black54,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Mudah',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF4D9427),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(width: 7),
                      Text(
                        '7 km · 24,3 m · 0j 56m',
                        style: TextStyle(fontSize: 15, color: Colors.black54),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        Icons.explore_outlined,
                        size: 22,
                        color: Color(0xFFE84B16),
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Dibuat untuk Anda',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFFE84B16),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
=======
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
                if (_visiblePoints.length > 1)
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
>>>>>>> 55e8c4b70038aaa6754a400e0274880266a10e3c
                ],
              ),
            ),
          ),
<<<<<<< HEAD
          Padding(
            padding: EdgeInsets.only(right: 14),
            child: Icon(Icons.bookmark_border, size: 28),
          ),
        ],
      ),
    ),
  );

  void _toggleSaved() {
    setState(() => _isSaved = !_isSaved);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isSaved ? 'Rute disimpan' : 'Rute dihapus dari simpanan',
        ),
      ),
    );
  }

  void _centerMap() {
    setState(() => _isCentered = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Peta dipusatkan ke lokasi Anda')),
    );
  }

  Future<void> _showSearch() async {
    final controller = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cari lokasi'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Contoh: Taman Kota',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              if (controller.text.trim().isNotEmpty) {
                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(
                    content: Text('Mencari "${controller.text.trim()}"'),
                  ),
                );
              }
            },
            child: const Text('Cari'),
          ),
        ],
      ),
    );
    controller.dispose();
  }

  Future<void> _showLayers() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(
                title: Text(
                  'Tampilan peta',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              SwitchListTile(
                title: const Text('Jalan utama'),
                value: _showRoads,
                onChanged: (value) {
                  setState(() => _showRoads = value);
                  setSheetState(() {});
                },
              ),
              SwitchListTile(
                title: const Text('Rute rekomendasi'),
                value: _showRoute,
                onChanged: (value) {
                  setState(() => _showRoute = value);
                  setSheetState(() {});
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showCreateRoute() async {
    final nameController = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buat rute'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Nama rute',
            hintText: 'Lari sore di sekitar kota',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(this.context).showSnackBar(
                SnackBar(
                  content: Text(
                    nameController.text.trim().isEmpty
                        ? 'Rute baru dibuat'
                        : 'Rute "${nameController.text.trim()}" dibuat',
                  ),
                ),
              );
            },
            child: const Text('Buat'),
          ),
        ],
      ),
    );
    nameController.dispose();
  }

  void _showRouteDetails() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Jalan Tanjung Gedong-J...',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              const Text('Rute mudah sejauh 7 km dengan elevasi 24,3 m.'),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  widget.onAddActivity();
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('Mulai aktivitas'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapChip extends StatelessWidget {
  const _MapChip(this.label, {this.selected = false});
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(right: 10),
    padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 11),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(28),
      border: Border.all(
        color: selected ? const Color(0xFFE84B16) : Colors.black12,
        width: selected ? 2 : 1,
      ),
    ),
    child: Text(
      label,
      style: TextStyle(
        fontSize: 16,
        color: selected ? const Color(0xFFE84B16) : Colors.black,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
      ),
    ),
  );
}

class _CityMapPainter extends CustomPainter {
  const _CityMapPainter({
    this.is3D = false,
    this.isCentered = false,
    this.showRoads = true,
    this.showRoute = true,
  });

  final bool is3D;
  final bool isCentered;
  final bool showRoads;
  final bool showRoute;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFE7E5DE),
    );
    final road = Paint()
      ..color = const Color(0xFFCAD4D7)
      ..strokeWidth = 2;
    final major = Paint()
      ..color = const Color(0xFFF3A98B)
      ..strokeWidth = 4;
    final route = Paint()
      ..color = const Color(0xFFE84B16)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    if (showRoads) {
      for (var x = -size.height; x < size.width + size.height; x += 34) {
        canvas.drawLine(
          Offset(x, 0),
          Offset(x + size.height * .7, size.height),
          road,
        );
      }
      for (var y = 20.0; y < size.height; y += 43) {
        canvas.drawLine(Offset(0, y), Offset(size.width, y - 35), road);
      }
      for (var i = 0; i < 6; i++) {
        canvas.drawLine(
          Offset(size.width * .1, size.height * (.18 + i * .14)),
          Offset(size.width * .85, size.height * (.08 + i * .15)),
          major,
        );
      }
    }
    final path = Path()
      ..moveTo(size.width * .48, size.height * .55)
      ..lineTo(size.width * .57, size.height * .61)
      ..lineTo(size.width * .66, size.height * .57)
      ..lineTo(size.width * .74, size.height * .68)
      ..lineTo(size.width * .66, size.height * .79)
      ..lineTo(size.width * .52, size.height * .72)
      ..lineTo(size.width * .45, size.height * .61)
      ..close();
    if (showRoute) canvas.drawPath(path, route);
    final marker = isCentered
        ? Offset(size.width * .5, size.height * .48)
        : Offset(size.width * .48, size.height * .55);
    canvas.drawCircle(marker, 14, Paint()..color = Colors.white);
    canvas.drawCircle(marker, 9, Paint()..color = const Color(0xFF1475C9));
  }

  @override
  bool shouldRepaint(covariant _CityMapPainter oldDelegate) =>
      oldDelegate.is3D != is3D ||
      oldDelegate.isCentered != isCentered ||
      oldDelegate.showRoads != showRoads ||
      oldDelegate.showRoute != showRoute;
=======
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
    final routes = [..._savedRoutes, route];
    await LocalStorage.saveRoutes(routes);
    if (!mounted) return;
    setState(() {
      _savedRoutes = routes;
      _selectedRoute = route;
      _isCreatingRoute = false;
      _draftPoints.clear();
    });
    _showMessage('Rute "${route.name}" disimpan.');
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
    _mapController.move(start, 16);
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
>>>>>>> 55e8c4b70038aaa6754a400e0274880266a10e3c
}
