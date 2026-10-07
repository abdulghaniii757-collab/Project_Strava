import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../models/activity.dart';
import '../models/saved_route.dart';
import '../services/route_store.dart';
import '../widgets/activity_route_map.dart';
import '../widgets/route_name_dialog.dart';
import 'activity_detail_page.dart';
import 'route_map.dart';

/// Tab "Rute": pusat semua rute. Di sini pengguna bisa membuat rute baru,
/// membuka rute di Peta, mengubah nama atau menghapusnya, dan mencari rute
/// lewat nama atau jenis olahraga. Petanya sendiri tetap ada di tab Peta.
class StatsPage extends StatefulWidget {
  const StatsPage({super.key, this.onOpenRoute, this.onCreateRoute});

  /// Dipanggil saat rute buatan diketuk, untuk membukanya di tab Peta.
  final void Function(SavedRoute route)? onOpenRoute;

  /// Dipanggil saat tombol "Buat rute baru" ditekan, untuk pindah ke tab Peta
  /// dan mulai membuat rute.
  final VoidCallback? onCreateRoute;

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _PopularRoute {
  const _PopularRoute(
    this.title,
    this.type,
    this.distanceKm,
    this.elevation,
    this.seed,
  );

  final String title;
  final String type;
  final double distanceKm;
  final String elevation;
  final int seed;
}

enum _RouteAction { rename, delete }

// Data contoh. Jenisnya sama dengan jenis aktivitas di seluruh app.
const _popularRoutes = [
  _PopularRoute('Rute Monas Loop', 'Lari', 5.2, '12 m', 11),
  _PopularRoute('GBK Senayan Loop', 'Lari', 4.8, '8 m', 12),
  _PopularRoute('Gowes PIK 2 Coast', 'Sepeda', 18.5, '25 m', 21),
  _PopularRoute('Ancol Waterfront Ride', 'Sepeda', 12.4, '6 m', 22),
  _PopularRoute('Pluit Park Jogging Route', 'Jalan Kaki', 3.1, '5 m', 31),
  _PopularRoute('Taman Suropati Walk', 'Jalan Kaki', 2.4, '3 m', 32),
];

IconData _iconFor(String type) {
  switch (type) {
    case 'Sepeda':
      return Icons.directions_bike;
    case 'Jalan Kaki':
      return Icons.directions_walk;
    default:
      return Icons.directions_run;
  }
}

String _formatDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

class _StatsPageState extends State<StatsPage> {
  static const _filters = ['Semua', 'Lari', 'Sepeda', 'Jalan Kaki'];
  static const _card = Color(0xFF1C1C1E);

  final _store = RouteStore.instance;
  final _searchController = TextEditingController();
  final _distance = const Distance();

  String _selectedFilter = 'Semua';
  String _query = '';

  @override
  void initState() {
    super.initState();
    _store.addListener(_onStoreChanged);
    _store.load();
  }

  @override
  void dispose() {
    _store.removeListener(_onStoreChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onStoreChanged() {
    if (mounted) setState(() {});
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  bool get _isFiltering => _query.isNotEmpty || _selectedFilter != 'Semua';

  bool _matchesQuery(String name) =>
      _query.isEmpty || name.toLowerCase().contains(_query);

  bool _matchesType(String type) =>
      _selectedFilter == 'Semua' || type == _selectedFilter;

  /// Rute buatan belum punya jenis olahraga, jadi cuma tampil di filter Semua.
  /// Yang terbaru ditaruh di atas.
  List<SavedRoute> get _savedRoutes {
    if (_selectedFilter != 'Semua') return const [];
    return _store.routes.reversed
        .where((r) => r.points.length >= 2 && _matchesQuery(r.name))
        .toList();
  }

  /// Aktivitas yang direkam lewat Peta (punya jejak GPS), terbaru di atas.
  List<Activity> get _myActivities {
    final list = dummyActivities
        .where(
          (a) => a.hasRoute && _matchesType(a.type) && _matchesQuery(a.name),
        )
        .toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  List<_PopularRoute> get _visiblePopular => _popularRoutes
      .where((r) => _matchesType(r.type) && _matchesQuery(r.title))
      .toList();

  double _routeKm(List<LatLng> points) {
    var meters = 0.0;
    for (var i = 1; i < points.length; i++) {
      meters += _distance.as(LengthUnit.Meter, points[i - 1], points[i]);
    }
    return meters / 1000;
  }

  Future<void> _openActivity(Activity activity) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ActivityDetailPage(activity: activity),
      ),
    );
    if (mounted) setState(() {});
  }

  Future<void> _renameRoute(SavedRoute route) async {
    final name = await showRouteNameDialog(context, initialName: route.name);
    if (name == null || !mounted) return;
    if (name.isEmpty) {
      _showMessage('Nama rute tidak boleh kosong.');
      return;
    }
    if (name == route.name) return;

    await _store.rename(route, name);
    if (!mounted) return;
    _showMessage('Rute diubah menjadi "$name".');
  }

  Future<void> _confirmDelete(SavedRoute route) async {
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

    await _store.remove(route);
    if (!mounted) return;
    _showMessage('Rute "${route.name}" dihapus.');
  }

  void _showPopularDetail(_PopularRoute route) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: _card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: RouteMap(seed: route.seed, height: 170),
              ),
              const SizedBox(height: 16),
              Text(
                route.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${route.type} • Elevasi ${route.elevation}',
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 12),
              Text(
                '${route.distanceKm.toStringAsFixed(1)} km',
                style: const TextStyle(
                  color: Colors.deepOrange,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final saved = _savedRoutes;
    final mine = _myActivities;
    final popular = _visiblePopular;
    final openRoute = widget.onOpenRoute;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Rute',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
            child: _buildSearchField(),
          ),
          _buildFilterChips(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              children: [
                const _SectionHeader(
                  title: 'Rute Saya',
                  caption: 'Rute buatan dan hasil rekaman GPS. Ketuk rute buatan untuk membukanya di Peta.',
                ),
                if (widget.onCreateRoute != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: FilledButton.icon(
                      onPressed: widget.onCreateRoute,
                      icon: const Icon(Icons.edit_road),
                      label: const Text('Buat rute baru'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(46),
                      ),
                    ),
                  ),
                if (saved.isEmpty && mine.isEmpty)
                  _EmptyNote(
                    text: _isFiltering ? 'Tidak ada rute yang cocok.' : 'Belum ada rute. Buat rute atau rekam aktivitas lewat tab Peta, nanti muncul di sini.',
                  ),
                for (var i = 0; i < saved.length; i++)
                  _RouteCard(
                    key: ValueKey('saved-$i-${saved[i].name}'),
                    title: saved[i].name,
                    subtitle: 'Rute buatan • ${saved[i].points.length} titik',
                    distance:
                        '${_routeKm(saved[i].points).toStringAsFixed(2)} km',
                    icon: Icons.alt_route,
                    preview: ActivityRouteMap(
                      points: saved[i].points,
                      height: 150,
                    ),
                    onTap: openRoute == null ? null : () => openRoute(saved[i]),
                    trailing: PopupMenuButton<_RouteAction>(
                      tooltip: 'Opsi rute',
                      icon: const Icon(Icons.more_vert, color: Colors.grey),
                      onSelected: (action) {
                        switch (action) {
                          case _RouteAction.rename:
                            _renameRoute(saved[i]);
                          case _RouteAction.delete:
                            _confirmDelete(saved[i]);
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: _RouteAction.rename,
                          child: Text('Ubah nama'),
                        ),
                        PopupMenuItem(
                          value: _RouteAction.delete,
                          child: Text('Hapus'),
                        ),
                      ],
                    ),
                  ),
                for (var i = 0; i < mine.length; i++)
                  _RouteCard(
                    key: ValueKey(
                      'act-$i-${mine[i].date.microsecondsSinceEpoch}',
                    ),
                    title: mine[i].name,
                    subtitle: '${mine[i].type} • ${_formatDate(mine[i].date)}',
                    distance: '${mine[i].distanceKm.toStringAsFixed(2)} km',
                    icon: _iconFor(mine[i].type),
                    preview: ActivityRouteMap(
                      points: mine[i].routePoints,
                      height: 150,
                    ),
                    onTap: () => _openActivity(mine[i]),
                  ),
                const SizedBox(height: 12),
                const _SectionHeader(
                  title: 'Rute Populer',
                  caption: 'Contoh rute di sekitar Jakarta',
                ),
                if (popular.isEmpty)
                  const _EmptyNote(text: 'Tidak ada rute populer yang cocok.'),
                for (final route in popular)
                  _RouteCard(
                    key: ValueKey('pop-${route.title}'),
                    title: route.title,
                    subtitle: '${route.type} • Elevasi ${route.elevation}',
                    distance: '${route.distanceKm.toStringAsFixed(1)} km',
                    icon: _iconFor(route.type),
                    preview: RouteMap(seed: route.seed, height: 130),
                    onTap: () => _showPopularDetail(route),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      style: const TextStyle(color: Colors.white),
      onChanged: (value) => setState(() => _query = value.trim().toLowerCase()),
      decoration: InputDecoration(
        hintText: 'Cari nama rute...',
        hintStyle: const TextStyle(color: Colors.grey),
        prefixIcon: const Icon(Icons.search, color: Colors.deepOrange),
        suffixIcon: _query.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _query = '');
                },
              ),
        filled: true,
        fillColor: _card,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: _filters.map((filter) {
          final selected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                filter,
                style: TextStyle(
                  color: selected ? Colors.white : Colors.grey,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              showCheckmark: false,
              selected: selected,
              selectedColor: Colors.deepOrange,
              backgroundColor: Colors.grey[900],
              side: BorderSide.none,
              onSelected: (_) => setState(() => _selectedFilter = filter),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.caption});

  final String title;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            caption,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _EmptyNote extends StatelessWidget {
  const _EmptyNote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.grey, fontSize: 14),
      ),
    );
  }
}

class _RouteCard extends StatelessWidget {
  const _RouteCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.distance,
    required this.icon,
    required this.preview,
    this.onTap,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final String distance;
  final IconData icon;
  final Widget preview;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              preview,
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
                child: Row(
                  children: [
                    Icon(icon, color: Colors.deepOrange, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      distance,
                      style: const TextStyle(
                        color: Colors.deepOrange,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing ?? const SizedBox(width: 8),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}