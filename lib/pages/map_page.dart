import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key, required this.onAddActivity});

  final VoidCallback onAddActivity;

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  String _selectedFilter = 'Rute';
  bool _isSaved = false;
  bool _showRoute = true;

  final MapController _mapController = MapController();
  Position? _currentPosition;
  
  // Posisi default (misal Jakarta)
  LatLng _currentCenter = const LatLng(-6.200000, 106.816666);

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = position;
      _currentCenter = LatLng(position.latitude, position.longitude);
    });

    _centerMap();
  }

  void _centerMap() {
    if (_currentPosition != null) {
      _mapController.move(
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        16.0,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Peta dipusatkan ke lokasi Anda')),
      );
    }
  }

  List<LatLng> _getRoutePoints() {
    if (!_showRoute || _currentPosition == null) return [];
    return [
      LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
      LatLng(_currentPosition!.latitude + 0.005, _currentPosition!.longitude + 0.005),
      LatLng(_currentPosition!.latitude + 0.002, _currentPosition!.longitude + 0.010),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Peta Interaktif (OpenStreetMap - Gratis & Tanpa API Key)
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentCenter,
                initialZoom: 15.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                ),
                // Gambar rute lari
                PolylineLayer(
                  polylines: [
                    if (_getRoutePoints().isNotEmpty)
                      Polyline(
                        points: _getRoutePoints(),
                        strokeWidth: 6.0,
                        color: const Color(0xFFE84B16), // Orange Strava
                      ),
                  ],
                ),
                // Gambar titik biru lokasi kita
                if (_currentPosition != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                        width: 24,
                        height: 24,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF1475C9),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
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
          icon: const Icon(Icons.directions_run, color: Color(0xFFE84B16), size: 30),
        ),
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _showSearch,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text('Cari', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w700)),
            ),
          ),
        ),
        IconButton(
          onPressed: _toggleSaved,
          icon: Icon(_isSaved ? Icons.bookmark : Icons.bookmark_border, size: 29),
        ),
        TextButton(
          onPressed: _toggleSaved,
          child: Text(
            _isSaved ? 'Tersimpan' : 'Simpan',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black),
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
        for (final filter in ['Rute', 'Panjang', 'Kesulitan', 'Elevasi', 'Permukaan'])
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
          GestureDetector(onTap: _showLayers, child: _roundAction(Icons.layers_outlined, badge: '2')),
          const SizedBox(height: 10),
          GestureDetector(onTap: _centerMap, child: _roundAction(Icons.my_location)),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'create-route',
            onPressed: _showCreateRoute,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            icon: const Icon(Icons.edit_location_alt_outlined),
            label: const Text('Buat Rute', style: TextStyle(fontWeight: FontWeight.w700)),
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
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
        ),
        child: Center(
          child: label == null
              ? Icon(icon, size: 32)
              : Text(label, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
        ),
      ),
      if (badge != null)
        Positioned(
          right: -2,
          top: -5,
          child: Container(
            padding: const EdgeInsets.all(7),
            decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
            child: Text(badge, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
            child: const Icon(Icons.park_outlined, color: Colors.white, size: 54),
          ),
          const Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(14, 15, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Jalan Tanjung Gedong-J...', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  SizedBox(height: 11),
                  Row(
                    children: [
                      Icon(Icons.directions_run, size: 22, color: Colors.black54),
                      SizedBox(width: 6),
                      Text('Mudah', style: TextStyle(fontSize: 16, color: Color(0xFF4D9427), fontWeight: FontWeight.w800)),
                      SizedBox(width: 7),
                      Expanded(child: Text('7 km · 24,3 m · 0j 56m', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 15, color: Colors.black54))),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.explore_outlined, size: 22, color: Color(0xFFE84B16)),
                      SizedBox(width: 6),
                      Flexible(child: Text('Dibuat untuk Anda', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 16, color: Color(0xFFE84B16), fontWeight: FontWeight.w700))),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const Padding(padding: EdgeInsets.only(right: 14), child: Icon(Icons.bookmark_border, size: 28)),
        ],
      ),
    ),
  );

  void _toggleSaved() {
    setState(() => _isSaved = !_isSaved);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_isSaved ? 'Rute disimpan' : 'Rute dihapus dari simpanan')));
  }

  Future<void> _showSearch() async {
    final query = await showDialog<String>(
      context: context,
      builder: (context) => const _TextInputDialog(title: 'Cari lokasi', hintText: 'Contoh: Taman Kota', prefixIcon: Icons.search, confirmLabel: 'Cari', autofocus: true),
    );
    if (!mounted || query == null || query.isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Mencari "$query"')));
  }

  Future<void> _showLayers() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(title: Text('Tampilan peta', style: TextStyle(fontWeight: FontWeight.w700))),
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
    final name = await showDialog<String>(
      context: context,
      builder: (context) => const _TextInputDialog(title: 'Buat rute', labelText: 'Nama rute', hintText: 'Lari sore di sekitar kota', confirmLabel: 'Buat'),
    );
    if (!mounted || name == null) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(name.isEmpty ? 'Rute baru dibuat' : 'Rute "$name" dibuat')));
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
              const Text('Jalan Tanjung Gedong-J...', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
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

class _TextInputDialog extends StatefulWidget {
  const _TextInputDialog({required this.title, required this.confirmLabel, this.labelText, this.hintText, this.prefixIcon, this.autofocus = false});
  final String title;
  final String confirmLabel;
  final String? labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final bool autofocus;
  @override State<_TextInputDialog> createState() => _TextInputDialogState();
}

class _TextInputDialogState extends State<_TextInputDialog> {
  final _controller = TextEditingController();
  @override void dispose() { _controller.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(controller: _controller, autofocus: widget.autofocus, decoration: InputDecoration(labelText: widget.labelText, hintText: widget.hintText, prefixIcon: widget.prefixIcon == null ? null : Icon(widget.prefixIcon))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
        FilledButton(onPressed: () => Navigator.pop(context, _controller.text.trim()), child: Text(widget.confirmLabel)),
      ],
    );
  }
}

class _MapChip extends StatelessWidget {
  const _MapChip(this.label, {this.selected = false});
  final String label;
  final bool selected;
  @override Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(right: 10),
    padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 11),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(28),
      border: Border.all(color: selected ? const Color(0xFFE84B16) : Colors.black12, width: selected ? 2 : 1),
    ),
    child: Text(label, style: TextStyle(fontSize: 16, color: selected ? const Color(0xFFE84B16) : Colors.black, fontWeight: selected ? FontWeight.w600 : FontWeight.w400)),
  );
}