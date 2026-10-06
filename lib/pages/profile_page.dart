import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../models/activity.dart';
import '../models/gear.dart';
import '../models/user_profile.dart';
import '../services/local_storage.dart';
import '../widgets/trekora_logo.dart';
import 'activity_detail_page.dart';
import 'add_activity_page.dart';
import 'help_page.dart';
import 'login_page.dart';

const _orange = Color(0xFFFC4C02);
const _bg = Color(0xFF121212);
const _card = Color(0xFF1E1E1E);
const _chipGrey = Color(0xFF2C2C2C);
const _muted = Color(0xFFA0A0A0);

/// Target jarak mingguan (km), disimpan di memori selama app berjalan.
double _weeklyGoalKm = 10;

// ---------- statistik ----------

/// Jumlah pengikut. Selalu 0 karena app belum punya server, jadi belum ada
/// akun lain yang bisa ngikutin user. "Mengikuti" dihitung dari
/// followedAthletes (atlet yang diikuti lewat tombol Ikuti di Home).
const _followers = 0;

/// Angka contoh buat kartu "Statistik Saya". Masih statis, belum dihitung
/// dari aktivitas yang dicatat.
const _sampleActivitiesPerWeek = 8;
const _sampleAvgTimePerWeek = '2h 15m';
const _sampleAvgDistancePerWeek = 24.8;
const _sampleTotalElevation = 45.0;

// ---------- perlengkapan (gear) ----------

/// Daftar perlengkapan. Dimuat dari penyimpanan permanen saat tab Profil
/// pertama kali dibuka (lihat _ProfilePageState.initState).
final List<Gear> _gearList = [];

double _gearTotalKm(Gear gear) => dummyActivities
    .where((a) => a.type == gear.type)
    .fold<double>(0, (sum, a) => sum + a.distanceKm);

// ---------- lencana pencapaian ----------

class _Badge {
  const _Badge({
    required this.title,
    required this.description,
    required this.icon,
    required this.unlocked,
  });

  final String title;
  final String description;
  final IconData icon;
  final bool unlocked;
}

List<_Badge> _computeBadges() {
  final totalKm = dummyActivities.fold<double>(0, (sum, a) => sum + a.distanceKm);
  final count = dummyActivities.length;
  final streak = _weekStreak();
  final sportsUsed = dummyActivities.map((a) => a.type).toSet().length;

  return [
    _Badge(
      title: 'Aktivitas Pertama',
      description: 'Catat aktivitas pertamamu',
      icon: Icons.flag,
      unlocked: count >= 1,
    ),
    _Badge(
      title: '10 Aktivitas',
      description: 'Catat 10 aktivitas',
      icon: Icons.repeat,
      unlocked: count >= 10,
    ),
    _Badge(
      title: 'Jarak 50 km',
      description: 'Kumpulin total jarak 50 km',
      icon: Icons.social_distance,
      unlocked: totalKm >= 50,
    ),
    _Badge(
      title: 'Jarak 100 km',
      description: 'Kumpulin total jarak 100 km',
      icon: Icons.terrain,
      unlocked: totalKm >= 100,
    ),
    _Badge(
      title: 'Beruntun 3 Minggu',
      description: 'Aktif 3 minggu berturut-turut',
      icon: Icons.local_fire_department,
      unlocked: streak >= 3,
    ),
    _Badge(
      title: 'Multi-Olahraga',
      description: 'Coba minimal 2 jenis olahraga',
      icon: Icons.sports,
      unlocked: sportsUsed >= 2,
    ),
  ];
}

const _months = [
  'JAN', 'FEB', 'MAR', 'APR', 'MEI', 'JUN',
  'JUL', 'AGS', 'SEP', 'OKT', 'NOV', 'DES',
];

class _Sport {
  const _Sport(this.type, this.icon);

  final String type;
  final IconData icon;
}

const _sports = [
  _Sport('Lari', Icons.directions_run),
  _Sport('Sepeda', Icons.directions_bike),
  _Sport('Jalan Kaki', Icons.directions_walk),
];

IconData _iconFor(String type) {
  for (final s in _sports) {
    if (s.type == type) return s.icon;
  }
  return Icons.directions_run;
}

// ---------- helper perhitungan ----------

/// Senin dari minggu tempat [d] berada (jam di-reset ke 00:00).
DateTime _startOfWeek(DateTime d) =>
    DateTime(d.year, d.month, d.day - (d.weekday - 1));

int _durationToSeconds(String duration) {
  final parts = duration.split(':');
  final minutes = int.tryParse(parts[0]) ?? 0;
  final seconds = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
  return minutes * 60 + seconds;
}

String _fmtDuration(int totalSeconds) {
  final hours = totalSeconds ~/ 3600;
  final minutes = (totalSeconds % 3600) ~/ 60;
  return hours > 0 ? '${hours}j ${minutes}m' : '${minutes}m';
}

String _fmtKm(double v) =>
    v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);

String _fmtDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

double _paceSecPerKm(Activity a) =>
    a.distanceKm <= 0 ? 0 : _durationToSeconds(a.duration) / a.distanceKm;

String _fmtPace(double secPerKm) {
  final total = secPerKm.round();
  return '${total ~/ 60}:${(total % 60).toString().padLeft(2, '0')} /km';
}

String _fmtSpeed(Activity a) {
  final hours = _durationToSeconds(a.duration) / 3600;
  return hours <= 0 ? '-' : '${(a.distanceKm / hours).toStringAsFixed(1)} km/j';
}

String _fmtClock(int totalSeconds) {
  final h = totalSeconds ~/ 3600;
  final m = (totalSeconds % 3600) ~/ 60;
  final sec = totalSeconds % 60;
  final mm = m.toString().padLeft(2, '0');
  final ss = sec.toString().padLeft(2, '0');
  return h > 0 ? '$h:$mm:$ss' : '$m:$ss';
}

/// Total jarak per minggu untuk 12 minggu terakhir (index 11 = minggu ini).
List<double> _weeklyDistances(String type) {
  final thisWeek = _startOfWeek(DateTime.now());
  final result = List<double>.filled(12, 0);
  for (final a in dummyActivities) {
    if (a.type != type) continue;
    final diffDays = thisWeek.difference(_startOfWeek(a.date)).inDays;
    final diffWeeks = (diffDays / 7).round();
    if (diffWeeks >= 0 && diffWeeks < 12) {
      result[11 - diffWeeks] += a.distanceKm;
    }
  }
  return result;
}

/// Label bulan di bawah grafik: muncul di minggu yang memuat tanggal 1.
Map<int, String> _monthLabels() {
  final thisWeek = _startOfWeek(DateTime.now());
  final labels = <int, String>{};
  for (var i = 0; i < 12; i++) {
    final start = DateTime(thisWeek.year, thisWeek.month, thisWeek.day - 7 * (11 - i));
    final end = DateTime(start.year, start.month, start.day + 6);
    if (end.month != start.month) {
      labels[i] = _months[end.month - 1];
    } else if (start.day == 1) {
      labels[i] = _months[start.month - 1];
    }
  }
  return labels;
}

/// Jumlah minggu berturut-turut yang punya minimal 1 aktivitas.
int _weekStreak() {
  final activeWeeks = <DateTime>{
    for (final a in dummyActivities) _startOfWeek(a.date),
  };
  var cursor = _startOfWeek(DateTime.now());
  if (!activeWeeks.contains(cursor)) {
    cursor = DateTime(cursor.year, cursor.month, cursor.day - 7);
  }
  var streak = 0;
  while (activeWeeks.contains(cursor)) {
    streak++;
    cursor = DateTime(cursor.year, cursor.month, cursor.day - 7);
  }
  return streak;
}

// ---------- periode (Minggu / Bulan / Tahun) ----------

enum _Period { week, month, year }

String _periodTitle(_Period p) {
  switch (p) {
    case _Period.week:
      return 'Minggu ini';
    case _Period.month:
      return 'Bulan ini';
    case _Period.year:
      return 'Tahun ini';
  }
}

String _periodShort(_Period p) {
  switch (p) {
    case _Period.week:
      return 'Minggu';
    case _Period.month:
      return 'Bulan';
    case _Period.year:
      return 'Tahun';
  }
}

/// Apakah tanggal [d] masuk ke periode berjalan (minggu/bulan/tahun ini).
bool _inPeriod(DateTime d, _Period p) {
  final now = DateTime.now();
  switch (p) {
    case _Period.week:
      return _startOfWeek(d) == _startOfWeek(now);
    case _Period.month:
      return d.year == now.year && d.month == now.month;
    case _Period.year:
      return d.year == now.year;
  }
}

/// Total jarak per bulan untuk 12 bulan terakhir (index 11 = bulan ini).
List<double> _monthlyDistances(String type) {
  final now = DateTime.now();
  final result = List<double>.filled(12, 0);
  for (final a in dummyActivities) {
    if (a.type != type) continue;
    final diff = (now.year - a.date.year) * 12 + (now.month - a.date.month);
    if (diff >= 0 && diff < 12) {
      result[11 - diff] += a.distanceKm;
    }
  }
  return result;
}

/// Total jarak per tahun untuk 5 tahun terakhir (index 4 = tahun ini).
List<double> _yearlyDistances(String type) {
  final now = DateTime.now();
  final result = List<double>.filled(5, 0);
  for (final a in dummyActivities) {
    if (a.type != type) continue;
    final diff = now.year - a.date.year;
    if (diff >= 0 && diff < 5) {
      result[4 - diff] += a.distanceKm;
    }
  }
  return result;
}

class _ChartSeries {
  const _ChartSeries({
    required this.values,
    required this.labels,
    required this.caption,
  });

  final List<double> values;
  final Map<int, String> labels;
  final String caption;
}

_ChartSeries _seriesFor(_Period period, String type) {
  final now = DateTime.now();
  switch (period) {
    case _Period.week:
      return _ChartSeries(
        values: _weeklyDistances(type),
        labels: _monthLabels(),
        caption: '12 minggu terakhir',
      );
    case _Period.month:
      return _ChartSeries(
        values: _monthlyDistances(type),
        labels: {
          for (var i = 1; i < 12; i += 2)
            i: _months[DateTime(now.year, now.month - (11 - i), 1).month - 1],
        },
        caption: '12 bulan terakhir',
      );
    case _Period.year:
      return _ChartSeries(
        values: _yearlyDistances(type),
        labels: {
          for (var i = 0; i < 5; i++) i: '${now.year - (4 - i)}',
        },
        caption: '5 tahun terakhir',
      );
  }
}

enum _ActivitySort { newest, longest }

String _sortLabel(_ActivitySort s) =>
    s == _ActivitySort.newest ? 'Terbaru' : 'Terjauh';

enum _AvatarAction { camera, gallery, file, remove }

/// Kecilin gambar (sisi terpanjang maks 512 px) biar base64-nya ga kegedean
/// waktu disimpen di shared_preferences. Error kalau bytes bukan gambar.
Future<Uint8List> _shrinkImage(Uint8List bytes) async {
  const maxSide = 512;
  final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
  final descriptor = await ui.ImageDescriptor.encoded(buffer);
  final scale = maxSide / math.max(descriptor.width, descriptor.height);
  final codec = await descriptor.instantiateCodec(
    targetWidth: scale < 1 ? (descriptor.width * scale).round() : null,
    targetHeight: scale < 1 ? (descriptor.height * scale).round() : null,
  );
  final frame = await codec.getNextFrame();
  final data = await frame.image.toByteData(format: ui.ImageByteFormat.png);
  frame.image.dispose();
  codec.dispose();
  descriptor.dispose();
  buffer.dispose();
  return data!.buffer.asUint8List();
}

// ---------- dialog yang dipakai bareng (Profil & Pengaturan) ----------

/// Buka dialog edit profil lalu simpan. Balikin true kalau ada perubahan.
Future<bool> _promptEditProfile(BuildContext context) async {
  final result = await showDialog<_ProfileForm>(
    context: context,
    builder: (context) => _EditProfileDialog(initial: currentUser),
  );
  if (result == null) return false;
  currentUser.name = result.name;
  currentUser.location = result.location;
  currentUser.bio = result.bio;
  await LocalStorage.saveProfile(currentUser);
  return true;
}

/// Buka dialog target mingguan lalu simpan. Balikin true kalau ada perubahan.
Future<bool> _promptEditGoal(BuildContext context) async {
  final value = await showDialog<double>(
    context: context,
    builder: (context) => _EditGoalDialog(initial: _weeklyGoalKm),
  );
  if (value == null) return false;
  _weeklyGoalKm = value;
  await LocalStorage.saveGoal(_weeklyGoalKm);
  return true;
}

// ---------- halaman ----------

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, this.refreshTick = 0});

  /// Dinaikin sama MainNavigation tiap ada aktivitas baru, biar halaman ini
  /// ikut digambar ulang walaupun aktivitasnya ditambah dari tab lain.
  final int refreshTick;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _tab = 0; // 0 = Kemajuan, 1 = Aktivitas, 2 = Lainnya
  String _sport = 'Lari';
  _Period _period = _Period.week;
  String _activityFilter = 'Semua';
  _ActivitySort _activitySort = _ActivitySort.newest;

  @override
  void initState() {
    super.initState();
    _loadPersisted();
  }

  Future<void> _loadPersisted() async {
    final goal = await LocalStorage.loadGoal();
    final gear = await LocalStorage.loadGear();
    if (!mounted) return;
    setState(() {
      if (goal != null) _weeklyGoalKm = goal;
      _gearList
        ..clear()
        ..addAll(gear);
    });
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openAddActivity() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddActivityPage()),
    );
    if (mounted) setState(() {});
  }

  Future<void> _editProfile() async {
    if (await _promptEditProfile(context) && mounted) setState(() {});
  }

  Future<void> _openSearch() async {
    final picked = await showSearch<Activity?>(
      context: context,
      delegate: _ActivitySearchDelegate(),
    );
    if (picked != null && mounted) await _openDetail(picked);
  }

  Future<void> _openSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const _SettingsPage()),
    );
    if (mounted) setState(() {});
  }

  void _openHelp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HelpPage()),
    );
  }

  /// Buka file explorer (aplikasi Files) buat milih foto profil.
  Future<void> _pickAvatarFromFile() async {
    try {
      final file = await FilePicker.pickFile(
        dialogTitle: 'Pilih foto profil',
        // Pakai custom + ekstensi (bukan FileType.image) biar di Android yang
        // kebuka file explorer, bukan pemilih foto/galeri.
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'webp', 'gif', 'bmp'],
      );
      if (file == null) return;

      final bytes = await _shrinkImage(await file.readAsBytes());
      setState(() => currentUser.avatarBase64 = base64Encode(bytes));
      await LocalStorage.saveProfile(currentUser);
    } catch (_) {
      if (mounted) _showSnack('File itu ga bisa dipakai, pilih file gambar ya.');
    }
  }

  Future<void> _showAvatarMenu() async {
    final source = await showModalBottomSheet<_AvatarAction>(
      context: context,
      backgroundColor: _card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: _chipGrey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined, color: Colors.white),
              title: const Text('Ambil Foto', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context, _AvatarAction.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: Colors.white),
              title: const Text('Pilih dari Galeri', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context, _AvatarAction.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.folder_open_outlined, color: Colors.white),
              title: const Text('Pilih dari File', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context, _AvatarAction.file),
            ),
            if (currentUser.avatarBase64.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
                title: const Text('Hapus Foto', style: TextStyle(color: Colors.redAccent)),
                onTap: () => Navigator.pop(context, _AvatarAction.remove),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (source == null) return;

    if (source == _AvatarAction.remove) {
      setState(() => currentUser.avatarBase64 = '');
      await LocalStorage.saveProfile(currentUser);
      return;
    }
    if (source == _AvatarAction.file) {
      await _pickAvatarFromFile();
      return;
    }

    try {
      final picked = await ImagePicker().pickImage(
        source: source == _AvatarAction.camera ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      if (picked == null) return;

      final bytes = await picked.readAsBytes();
      final encoded = base64Encode(bytes);

      setState(() => currentUser.avatarBase64 = encoded);
      await LocalStorage.saveProfile(currentUser);
    } catch (_) {
      if (mounted) _showSnack('Gagal ambil foto, coba lagi ya.');
    }
  }

  Future<void> _shareProfile() async {
    final totalKm = dummyActivities.fold<double>(0, (sum, a) => sum + a.distanceKm);
    final text = '${currentUser.name} di Trekora: '
        '${dummyActivities.length} aktivitas, ${_fmtKm(totalKm)} km total';
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) _showSnack('Ringkasan profil disalin ke clipboard');
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final activities = dummyActivities;

    return Material(
      color: _bg,
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 96),
          children: [
            _buildHeader(activities.length),
            _buildTabBar(),
            if (_tab == 0) _buildProgress(),
            if (_tab == 1) _buildActivityList(activities),
            if (_tab == 2) _buildMore(),
          ],
        ),
      ),
    );
  }

  // ----- header -----

  Widget _buildHeader(int activityCount) {
    final name = currentUser.name.trim();
    final initial = name.isEmpty ? '?' : name[0].toUpperCase();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _CircleIconButton(icon: Icons.add, onTap: _openAddActivity),
              const Spacer(),
              _CircleIconButton(
                icon: Icons.search,
                onTap: _openSearch,
              ),
              const SizedBox(width: 10),
              _CircleIconButton(
                icon: Icons.settings_outlined,
                onTap: _openSettings,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              // Ketuk foto: langsung buka file explorer.
              // Ketuk ikon kamera kecil / tahan lama: menu kamera, galeri, hapus.
              GestureDetector(
                onTap: _pickAvatarFromFile,
                onLongPress: _showAvatarMenu,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 42,
                      backgroundColor: _orange,
                      backgroundImage: currentUser.avatarBase64.isEmpty
                          ? null
                          : MemoryImage(base64Decode(currentUser.avatarBase64)),
                      child: currentUser.avatarBase64.isEmpty
                          ? Text(
                              initial,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 44,
                                fontWeight: FontWeight.w500,
                              ),
                            )
                          : null,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: GestureDetector(
                        onTap: _showAvatarMenu,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _chipGrey,
                            border: Border.all(color: _bg, width: 2),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentUser.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$activityCount aktivitas',
                      style: const TextStyle(color: Colors.white70, fontSize: 18),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (currentUser.location.trim().isNotEmpty) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(Icons.place_outlined, size: 18, color: _muted),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    currentUser.location.trim(),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: _muted, fontSize: 15),
                  ),
                ),
              ],
            ),
          ],
          if (currentUser.bio.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              currentUser.bio.trim(),
              style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.4),
            ),
          ],
          const SizedBox(height: 16),
          Text(
            '$_followers pengikut  •  ${followedAthletes.length} mengikuti',
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _outlinedAction('Edit profil', _editProfile)),
              const SizedBox(width: 12),
              Expanded(child: _outlinedAction('Bagikan profil', _shareProfile)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _outlinedAction(String label, VoidCallback onTap) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Color(0xFF3A3A3A), width: 1.5),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(vertical: 14),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      onPressed: onTap,
      child: Text(label),
    );
  }

  // ----- tab bar -----

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF2E2E2E))),
      ),
      child: Row(
        children: [
          _tabItem(0, Icons.assessment, 'Kemajuan'),
          _tabItem(1, Icons.timeline, 'Aktivitas'),
          _tabItem(2, Icons.menu, 'Lainnya'),
        ],
      ),
    );
  }

  Widget _tabItem(int index, IconData icon, String label) {
    final selected = _tab == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _tab = index),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Icon(icon, size: 28, color: selected ? Colors.white : _muted),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : _muted,
                fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 10),
            Container(height: 3, color: selected ? _orange : Colors.transparent),
          ],
        ),
      ),
    );
  }

  // ----- tab Kemajuan -----

  Widget _buildProgress() {
    final series = _seriesFor(_period, _sport);
    final periodActivities = dummyActivities
        .where((a) => a.type == _sport && _inPeriod(a.date, _period))
        .toList();
    final periodKm = periodActivities.fold<double>(
      0,
      (sum, a) => sum + a.distanceKm,
    );
    final periodSeconds = periodActivities.fold<int>(
      0,
      (sum, a) => sum + _durationToSeconds(a.duration),
    );

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final s in _sports)
                      _SportChip(
                        label: s.type,
                        icon: s.icon,
                        selected: _sport == s.type,
                        onTap: () => setState(() => _sport = s.type),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildPeriodToggle(),
                const SizedBox(height: 22),
                Text(
                  _periodTitle(_period),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _StatItem(label: 'Jarak', value: '${_fmtKm(periodKm)} km'),
                    const SizedBox(width: 28),
                    _StatItem(label: 'Waktu', value: _fmtDuration(periodSeconds)),
                    const SizedBox(width: 28),
                    _StatItem(label: 'Aktivitas', value: '${periodActivities.length}'),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  series.caption,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 210,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: _WeeklyChartPainter(
                      values: series.values,
                      monthLabels: series.labels,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildMyStatsCard(),
          const SizedBox(height: 16),
          _buildGoalCard(),
          const SizedBox(height: 16),
          _buildStreakCard(),
          const SizedBox(height: 16),
          _buildRecordsCard(),
          const SizedBox(height: 16),
          _buildBadgesCard(),
          const SizedBox(height: 16),
          _buildGearCard(),
        ],
      ),
    );
  }

  Widget _buildPeriodToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _chipGrey,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          for (final p in _Period.values)
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _period = p),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: _period == p ? _orange : Colors.transparent,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    _periodShort(p),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _period == p ? Colors.white : _muted,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ----- kartu Sosial & Statistik Saya -----

  Widget _buildMyStatsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.people_outline, color: _orange),
              SizedBox(width: 8),
              Text(
                'Sosial',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _StatItem(label: 'Mengikuti', value: '${followedAthletes.length}'),
              const SizedBox(width: 40),
              const _StatItem(label: 'Pengikut', value: '$_followers'),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1, color: Color(0xFF2E2E2E)),
          const SizedBox(height: 16),
          const Row(
            children: [
              Icon(Icons.insights, color: _orange),
              SizedBox(width: 8),
              Text(
                'Statistik Saya',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _statRow('Aktivitas / Minggu', '$_sampleActivitiesPerWeek'),
          _statRow('Rata-rata Waktu / Minggu', _sampleAvgTimePerWeek),
          _statRow('Rata-rata Jarak / Minggu', '${_fmtKm(_sampleAvgDistancePerWeek)} km'),
          _statRow('Total Elevasi', '${_fmtKm(_sampleTotalElevation)} m'),
        ],
      ),
    );
  }

  Widget _statRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: const TextStyle(color: _muted, fontSize: 15)),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ----- kartu Target Mingguan -----

  Future<void> _editGoal() async {
    if (await _promptEditGoal(context) && mounted) setState(() {});
  }

  Future<void> _addGear() async {
    final gear = await showDialog<Gear>(
      context: context,
      builder: (context) => const _AddGearDialog(),
    );
    if (gear != null && mounted) {
      setState(() => _gearList.add(gear));
      await LocalStorage.saveGear(_gearList);
    }
  }

  void _removeGear(Gear gear) {
    final index = _gearList.indexOf(gear);
    setState(() => _gearList.removeAt(index));
    LocalStorage.saveGear(_gearList);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${gear.name} dihapus dari perlengkapan'),
          action: SnackBarAction(
            label: 'Urungkan',
            textColor: _orange,
            onPressed: () {
              if (!mounted) return;
              setState(() => _gearList.insert(math.min(index, _gearList.length), gear));
              LocalStorage.saveGear(_gearList);
            },
          ),
        ),
      );
  }

  Widget _buildGoalCard() {
    final now = DateTime.now();
    final doneKm = dummyActivities
        .where((a) => _inPeriod(a.date, _Period.week))
        .fold<double>(0, (sum, a) => sum + a.distanceKm);
    final progress = math.min(1.0, doneKm / _weeklyGoalKm);
    final reached = doneKm >= _weeklyGoalKm;
    final daysLeft = 8 - now.weekday; // termasuk hari ini
    final remaining = _weeklyGoalKm - doneKm;
    final perDay = remaining / daysLeft;

    final message = reached
        ? 'Target tercapai, mantap!'
        : 'Kurang ${_fmtKm(remaining)} km lagi';
    final hint = reached
        ? 'Terus semangat, jangan berhenti di sini'
        : 'Sisa $daysLeft hari • butuh sekitar ${perDay.toStringAsFixed(1)} km/hari';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flag, color: _orange),
              const SizedBox(width: 8),
              const Text(
                'Target Mingguan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: _editGoal,
                child: const Text(
                  'Ubah',
                  style: TextStyle(color: _orange, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                _fmtKm(doneKm),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                ' / ${_fmtKm(_weeklyGoalKm)} km',
                style: const TextStyle(color: _muted, fontSize: 18),
              ),
              const Spacer(),
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                  color: _orange,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: _chipGrey,
              valueColor: const AlwaysStoppedAnimation(_orange),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(hint, style: const TextStyle(color: _muted, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildStreakCard() {
    final streak = _weekStreak();
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final activeDays = <int>{
      for (final a in dummyActivities)
        if (a.date.year == now.year && a.date.month == now.month) a.date.day,
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Text(
                'Beruntun',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
              Text('Bulan ini', style: TextStyle(color: _muted, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.local_fire_department,
                        size: 120,
                        color: streak > 0 ? _orange : const Color(0xFF9E9E9E),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 30),
                        child: Text(
                          '$streak',
                          style: const TextStyle(
                            color: _card,
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    'Minggu',
                    style: TextStyle(
                      color: Color(0xFFBDBDBD),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.end,
                  children: [
                    for (var d = 1; d <= daysInMonth; d++)
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: activeDays.contains(d)
                              ? _orange
                              : const Color(0xFF3A3A3A),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ----- kartu Rekor Pribadi -----

  Future<void> _openDetail(Activity a) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ActivityDetailPage(activity: a)),
    );
    if (mounted) setState(() {});
  }

  Widget _buildRecordsCard() {
    final list = dummyActivities.where((a) => a.type == _sport).toList();

    Widget body;
    if (list.isEmpty) {
      body = const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Text(
          'Belum ada rekor. Catat aktivitas dulu ya.',
          style: TextStyle(color: _muted, fontSize: 15),
        ),
      );
    } else {
      final longest = list.reduce((a, b) => b.distanceKm > a.distanceKm ? b : a);
      final longestTime = list.reduce(
        (a, b) => _durationToSeconds(b.duration) > _durationToSeconds(a.duration) ? b : a,
      );
      final fastest = list.reduce((a, b) => _paceSecPerKm(b) < _paceSecPerKm(a) ? b : a);
      final isBike = _sport == 'Sepeda';

      body = Column(
        children: [
          _RecordRow(
            icon: Icons.straighten,
            label: 'Jarak Terjauh',
            value: '${_fmtKm(longest.distanceKm)} km',
            activity: longest,
            onTap: () => _openDetail(longest),
          ),
          const Divider(height: 1, color: Color(0xFF2E2E2E)),
          _RecordRow(
            icon: Icons.timer_outlined,
            label: 'Durasi Terlama',
            value: _fmtClock(_durationToSeconds(longestTime.duration)),
            activity: longestTime,
            onTap: () => _openDetail(longestTime),
          ),
          const Divider(height: 1, color: Color(0xFF2E2E2E)),
          _RecordRow(
            icon: Icons.speed,
            label: isBike ? 'Kecepatan Terbaik' : 'Pace Terbaik',
            value: isBike ? _fmtSpeed(fastest) : _fmtPace(_paceSecPerKm(fastest)),
            activity: fastest,
            onTap: () => _openDetail(fastest),
          ),
        ],
      );
    }

    return Material(
      color: _card,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.emoji_events, color: _orange),
                const SizedBox(width: 8),
                const Text(
                  'Rekor Pribadi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(_sport, style: const TextStyle(color: _muted, fontSize: 15)),
              ],
            ),
            const SizedBox(height: 8),
            body,
          ],
        ),
      ),
    );
  }

  // ----- kartu Lencana Pencapaian -----

  Widget _buildBadgesCard() {
    final badges = _computeBadges();
    final unlockedCount = badges.where((b) => b.unlocked).length;

    return Material(
      color: _card,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.military_tech, color: _orange),
                const SizedBox(width: 8),
                const Text(
                  'Lencana Pencapaian',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '$unlockedCount/${badges.length}',
                  style: const TextStyle(color: _muted, fontSize: 15),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                for (final b in badges)
                  SizedBox(
                    width: 82,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _showSnack(
                        b.unlocked ? b.description : '${b.description} (belum terbuka)',
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: b.unlocked
                                  ? const Color(0x33FC4C02)
                                  : _chipGrey,
                            ),
                            child: Icon(
                              b.unlocked ? b.icon : Icons.lock_outline,
                              color: b.unlocked ? _orange : const Color(0xFF6A6A6A),
                              size: 26,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            b.title,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: b.unlocked ? Colors.white : _muted,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ----- kartu Perlengkapan (gear) -----

  Widget _buildGearCard() {
    return Material(
      color: _card,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.checkroom, color: _orange),
                const SizedBox(width: 8),
                const Text(
                  'Perlengkapan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _addGear,
                  icon: const Icon(Icons.add, color: _orange, size: 18),
                  label: const Text(
                    'Tambah',
                    style: TextStyle(color: _orange, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            if (_gearList.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Belum ada perlengkapan tercatat.',
                  style: TextStyle(color: _muted, fontSize: 15),
                ),
              )
            else
              for (final gear in _gearList) _gearRow(gear),
          ],
        ),
      ),
    );
  }

  Widget _gearRow(Gear gear) {
    final km = _gearTotalKm(gear);
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0x33FC4C02),
            child: Icon(_iconFor(gear.type), color: _orange, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gear.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  '${gear.type} • ${_fmtKm(km)} km',
                  style: const TextStyle(color: _muted, fontSize: 13),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _removeGear(gear),
            icon: const Icon(Icons.delete_outline, color: _muted, size: 20),
          ),
        ],
      ),
    );
  }

  // ----- tab Aktivitas -----

  Widget _buildActivityList(List<Activity> activities) {
    if (activities.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(48),
        child: Center(
          child: Text(
            'Belum ada aktivitas.\nTekan tombol + untuk mencatat.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _muted, fontSize: 15),
          ),
        ),
      );
    }

    final filtered = _activityFilter == 'Semua'
        ? List<Activity>.from(activities)
        : activities.where((a) => a.type == _activityFilter).toList();
    filtered.sort(
      (a, b) => _activitySort == _ActivitySort.newest
          ? b.date.compareTo(a.date)
          : b.distanceKm.compareTo(a.distanceKm),
    );

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildActivityFilterBar(),
          const SizedBox(height: 16),
          if (filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text(
                  'Ga ada aktivitas $_activityFilter.',
                  style: const TextStyle(color: _muted, fontSize: 15),
                ),
              ),
            )
          else
            for (final a in filtered)
              _ActivityTile(
                activity: a,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ActivityDetailPage(activity: a),
                    ),
                  );
                  if (mounted) setState(() {});
                },
              ),
        ],
      ),
    );
  }

  Widget _buildActivityFilterBar() {
    final options = ['Semua', ..._sports.map((s) => s.type)];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final label in options)
              _SportChip(
                label: label,
                icon: label == 'Semua' ? Icons.apps : _iconFor(label),
                selected: _activityFilter == label,
                onTap: () => setState(() => _activityFilter = label),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Text(
              'Urutkan:',
              style: TextStyle(color: _muted, fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 10),
            for (final s in _ActivitySort.values)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _activitySort = s),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _activitySort == s ? _orange : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _activitySort == s ? _orange : const Color(0xFF444444),
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      _sortLabel(s),
                      style: TextStyle(
                        color: _activitySort == s ? Colors.white : _muted,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  // ----- tab Lainnya -----

  Widget _buildMore() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Material(
        color: _card,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.settings_outlined, color: Colors.white),
              title: const Text('Pengaturan', style: TextStyle(color: Colors.white)),
              trailing: const Icon(Icons.chevron_right, color: _muted),
              onTap: _openSettings,
            ),
            const Divider(height: 1, color: Color(0xFF2E2E2E)),
            ListTile(
              leading: const Icon(Icons.help_outline, color: Colors.white),
              title: const Text('Bantuan', style: TextStyle(color: Colors.white)),
              trailing: const Icon(Icons.chevron_right, color: _muted),
              onTap: _openHelp,
            ),
            const Divider(height: 1, color: Color(0xFF2E2E2E)),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text('Keluar', style: TextStyle(color: Colors.redAccent)),
              onTap: _logout,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- widget kecil ----------

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _chipGrey,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 46,
          height: 46,
          child: Icon(icon, color: Colors.white),
        ),
      ),
    );
  }
}

class _SportChip extends StatelessWidget {
  const _SportChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? _orange : _muted;
    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: selected ? _orange : const Color(0xFF444444),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: color, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _RecordRow extends StatelessWidget {
  const _RecordRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.activity,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final Activity activity;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: const Color(0x33FC4C02),
              child: Icon(icon, color: _orange, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(color: _muted, fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${activity.name} • ${_fmtDate(activity.date)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: _muted, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: _muted),
          ],
        ),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.activity, required this.onTap});

  final Activity activity;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: _card,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0x33FC4C02),
                  child: Icon(_iconFor(activity.type), color: _orange),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${activity.type} • ${_fmtDate(activity.date)}',
                        style: const TextStyle(color: _muted, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${_fmtKm(activity.distanceKm)} km',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      activity.duration,
                      style: const TextStyle(color: _muted, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileForm {
  const _ProfileForm({
    required this.name,
    required this.location,
    required this.bio,
  });

  final String name;
  final String location;
  final String bio;
}

class _EditProfileDialog extends StatefulWidget {
  const _EditProfileDialog({required this.initial});

  final UserProfile initial;

  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  late final TextEditingController _name =
      TextEditingController(text: widget.initial.name);
  late final TextEditingController _location =
      TextEditingController(text: widget.initial.location);
  late final TextEditingController _bio =
      TextEditingController(text: widget.initial.bio);
  String? _nameError;

  @override
  void dispose() {
    _name.dispose();
    _location.dispose();
    _bio.dispose();
    super.dispose();
  }

  InputDecoration _decoration(String label, {String? hint, String? error}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      errorText: error,
      labelStyle: const TextStyle(color: _muted),
      hintStyle: const TextStyle(color: Color(0xFF666666)),
      counterStyle: const TextStyle(color: _muted),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF555555)),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: _orange),
      ),
    );
  }

  void _submit() {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = 'Nama tidak boleh kosong');
      return;
    }
    Navigator.pop(
      context,
      _ProfileForm(
        name: name,
        location: _location.text.trim(),
        bio: _bio.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: _card,
      title: const Text('Edit profil', style: TextStyle(color: Colors.white)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _name,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              inputFormatters: [LengthLimitingTextInputFormatter(40)],
              decoration: _decoration('Nama', error: _nameError),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _location,
              style: const TextStyle(color: Colors.white),
              inputFormatters: [LengthLimitingTextInputFormatter(40)],
              decoration: _decoration('Lokasi', hint: 'Misal: Jakarta, Indonesia'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _bio,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              maxLength: 120,
              decoration: _decoration('Bio', hint: 'Ceritakan sedikit tentang dirimu'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal', style: TextStyle(color: _muted)),
        ),
        TextButton(
          onPressed: _submit,
          child: const Text('Simpan', style: TextStyle(color: _orange)),
        ),
      ],
    );
  }
}

class _EditGoalDialog extends StatefulWidget {
  const _EditGoalDialog({required this.initial});

  final double initial;

  @override
  State<_EditGoalDialog> createState() => _EditGoalDialogState();
}

class _EditGoalDialogState extends State<_EditGoalDialog> {
  late final TextEditingController _controller =
      TextEditingController(text: _fmtKm(widget.initial));
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = double.tryParse(_controller.text.trim().replaceAll(',', '.'));
    if (value == null || value <= 0 || value > 1000) {
      setState(() => _error = 'Masukkan angka yang valid (1 - 1000)');
      return;
    }
    Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: _card,
      title: const Text('Target mingguan', style: TextStyle(color: Colors.white)),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: 'Target jarak',
          labelStyle: const TextStyle(color: _muted),
          suffixText: 'km',
          suffixStyle: const TextStyle(color: _muted),
          errorText: _error,
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF555555)),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: _orange),
          ),
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal', style: TextStyle(color: _muted)),
        ),
        TextButton(
          onPressed: _submit,
          child: const Text('Simpan', style: TextStyle(color: _orange)),
        ),
      ],
    );
  }
}

class _AddGearDialog extends StatefulWidget {
  const _AddGearDialog();

  @override
  State<_AddGearDialog> createState() => _AddGearDialogState();
}

class _AddGearDialogState extends State<_AddGearDialog> {
  final _nameController = TextEditingController();
  String _type = 'Lari';
  String? _nameError;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = 'Nama ga boleh kosong');
      return;
    }
    Navigator.pop(context, Gear(name: name, type: _type));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: _card,
      title: const Text('Tambah perlengkapan', style: TextStyle(color: Colors.white)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Nama',
                hintText: 'Misal: Sepatu Lari Biru',
                errorText: _nameError,
                labelStyle: const TextStyle(color: _muted),
                hintStyle: const TextStyle(color: Color(0xFF666666)),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF555555)),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: _orange),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Jenis Olahraga',
              style: TextStyle(color: _muted, fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final s in _sports)
                  _SportChip(
                    label: s.type,
                    icon: s.icon,
                    selected: _type == s.type,
                    onTap: () => setState(() => _type = s.type),
                  ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal', style: TextStyle(color: _muted)),
        ),
        TextButton(
          onPressed: _submit,
          child: const Text('Simpan', style: TextStyle(color: _orange)),
        ),
      ],
    );
  }
}

// ---------- pencarian aktivitas ----------

class _ActivitySearchDelegate extends SearchDelegate<Activity?> {
  _ActivitySearchDelegate()
      : super(
          searchFieldLabel: 'Cari nama atau jenis aktivitas',
          searchFieldStyle: const TextStyle(color: Colors.white, fontSize: 17),
        );

  @override
  ThemeData appBarTheme(BuildContext context) {
    final base = Theme.of(context);
    return base.copyWith(
      scaffoldBackgroundColor: _bg,
      appBarTheme: const AppBarTheme(
        backgroundColor: _card,
        foregroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(color: _muted),
      ),
      textSelectionTheme: const TextSelectionThemeData(cursorColor: _orange),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) => [
        if (query.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () => query = '',
          ),
      ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildResults(BuildContext context) => _buildList(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildList(context);

  Widget _buildList(BuildContext context) {
    final q = query.trim().toLowerCase();
    final results = dummyActivities
        .where((a) =>
            q.isEmpty ||
            a.name.toLowerCase().contains(q) ||
            a.type.toLowerCase().contains(q))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    if (results.isEmpty) {
      return Container(
        color: _bg,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(32),
        child: Text(
          dummyActivities.isEmpty
              ? 'Belum ada aktivitas untuk dicari.'
              : 'Ga ketemu aktivitas "${query.trim()}".',
          textAlign: TextAlign.center,
          style: const TextStyle(color: _muted, fontSize: 15),
        ),
      );
    }

    return Container(
      color: _bg,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final a in results)
            _ActivityTile(activity: a, onTap: () => close(context, a)),
        ],
      ),
    );
  }
}

// ---------- halaman Pengaturan ----------

class _SettingsPage extends StatefulWidget {
  const _SettingsPage();

  @override
  State<_SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<_SettingsPage> {
  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<bool> _confirm(String title, String message, String action) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _card,
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: Text(message, style: const TextStyle(color: _muted)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: _muted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(action, style: const TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    return ok == true;
  }

  Future<void> _editProfile() async {
    if (await _promptEditProfile(context) && mounted) {
      setState(() {});
      _showSnack('Profil disimpan');
    }
  }

  Future<void> _editGoal() async {
    if (await _promptEditGoal(context) && mounted) {
      setState(() {});
      _showSnack('Target mingguan disimpan');
    }
  }

  Future<void> _removeAvatar() async {
    if (!await _confirm('Hapus foto profil?', 'Foto profil akan diganti inisial nama.', 'Hapus')) {
      return;
    }
    setState(() => currentUser.avatarBase64 = '');
    await LocalStorage.saveProfile(currentUser);
    if (mounted) _showSnack('Foto profil dihapus');
  }

  Future<void> _clearActivities() async {
    if (!await _confirm(
      'Hapus semua aktivitas?',
      'Semua ${dummyActivities.length} aktivitas akan dihapus permanen.',
      'Hapus',
    )) {
      return;
    }
    setState(dummyActivities.clear);
    await LocalStorage.saveActivities(dummyActivities);
    if (mounted) _showSnack('Semua aktivitas dihapus');
  }

  Future<void> _clearGear() async {
    if (!await _confirm(
      'Hapus semua perlengkapan?',
      'Semua ${_gearList.length} perlengkapan akan dihapus permanen.',
      'Hapus',
    )) {
      return;
    }
    setState(_gearList.clear);
    await LocalStorage.saveGear(_gearList);
    if (mounted) _showSnack('Semua perlengkapan dihapus');
  }

  Future<void> _resetAll() async {
    if (!await _confirm(
      'Reset semua data?',
      'Aktivitas, profil, foto, target, dan perlengkapan akan dihapus, '
          'lalu kamu dikeluarkan dari akun.',
      'Reset',
    )) {
      return;
    }
    await LocalStorage.clearAll();
    dummyActivities.clear();
    _gearList.clear();
    followedAthletes.clear();
    _weeklyGoalKm = 10;
    currentUser
      ..name = 'Pengguna'
      ..bio = ''
      ..location = ''
      ..followers = 0
      ..following = 0
      ..avatarBase64 = '';
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  void _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: 'Trekora',
      applicationVersion: '1.0.0',
      applicationIcon: Image.asset(trekoraLogoPath, width: 48, height: 48),
      children: const [
        Text('Aplikasi pencatat aktivitas lari, sepeda, dan jalan kaki.'),
      ],
    );
  }

  Widget _section(String title, List<Widget> tiles) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              title,
              style: const TextStyle(
                color: _muted,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Material(
            color: _card,
            borderRadius: BorderRadius.circular(18),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (var i = 0; i < tiles.length; i++) ...[
                  if (i > 0) const Divider(height: 1, color: Color(0xFF2E2E2E)),
                  tiles[i],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    bool danger = false,
  }) {
    final color = danger ? Colors.redAccent : Colors.white;
    return ListTile(
      enabled: onTap != null,
      leading: Icon(icon, color: onTap == null ? const Color(0xFF555555) : color),
      title: Text(
        title,
        style: TextStyle(color: onTap == null ? const Color(0xFF555555) : color),
      ),
      subtitle: subtitle == null
          ? null
          : Text(subtitle, style: const TextStyle(color: _muted, fontSize: 13)),
      trailing: danger ? null : const Icon(Icons.chevron_right, color: _muted),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        foregroundColor: Colors.white,
        title: const Text('Pengaturan'),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          _section('AKUN', [
            _tile(
              icon: Icons.person_outline,
              title: 'Edit profil',
              subtitle: currentUser.name,
              onTap: _editProfile,
            ),
            _tile(
              icon: Icons.no_photography_outlined,
              title: 'Hapus foto profil',
              subtitle: currentUser.avatarBase64.isEmpty ? 'Belum ada foto' : null,
              onTap: currentUser.avatarBase64.isEmpty ? null : _removeAvatar,
            ),
          ]),
          _section('LATIHAN', [
            _tile(
              icon: Icons.flag_outlined,
              title: 'Target mingguan',
              subtitle: '${_fmtKm(_weeklyGoalKm)} km per minggu',
              onTap: _editGoal,
            ),
          ]),
          _section('DATA', [
            _tile(
              icon: Icons.delete_sweep_outlined,
              title: 'Hapus semua aktivitas',
              subtitle: '${dummyActivities.length} aktivitas tersimpan',
              onTap: dummyActivities.isEmpty ? null : _clearActivities,
              danger: true,
            ),
            _tile(
              icon: Icons.delete_outline,
              title: 'Hapus semua perlengkapan',
              subtitle: '${_gearList.length} perlengkapan tersimpan',
              onTap: _gearList.isEmpty ? null : _clearGear,
              danger: true,
            ),
            _tile(
              icon: Icons.restart_alt,
              title: 'Reset semua data',
              subtitle: 'Kembali seperti baru install',
              onTap: _resetAll,
              danger: true,
            ),
          ]),
          _section('LAINNYA', [
            _tile(
              icon: Icons.info_outline,
              title: 'Tentang aplikasi',
              subtitle: 'Versi 1.0.0',
              onTap: _showAbout,
            ),
          ]),
        ],
      ),
    );
  }
}

// ---------- grafik ----------

class _WeeklyChartPainter extends CustomPainter {
  _WeeklyChartPainter({required this.values, required this.monthLabels});

  final List<double> values;
  final Map<int, String> monthLabels;

  void _drawText(Canvas canvas, String text, Offset anchor, {bool centerX = false}) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(color: Color(0xFFCCCCCC), fontSize: 14),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final dx = centerX ? anchor.dx - tp.width / 2 : anchor.dx;
    tp.paint(canvas, Offset(dx, anchor.dy - tp.height / 2));
  }

  @override
  void paint(Canvas canvas, Size size) {
    const leftPad = 8.0;
    const rightPad = 64.0;
    const topPad = 12.0;
    const bottomPad = 34.0;

    final chartLeft = leftPad;
    final chartRight = size.width - rightPad;
    final chartTop = topPad;
    final chartBottom = size.height - bottomPad;
    final chartHeight = chartBottom - chartTop;

    final maxValue = values.isEmpty ? 0.0 : values.reduce(math.max);
    final axisMax = maxValue <= 6 ? 6.0 : (maxValue / 6).ceil() * 6.0;

    // garis bantu + label sumbu Y
    final gridPaint = Paint()
      ..color = const Color(0x33FFFFFF)
      ..strokeWidth = 1;
    for (final fraction in [1.0, 0.5]) {
      final y = chartBottom - chartHeight * fraction;
      canvas.drawLine(Offset(chartLeft, y), Offset(chartRight, y), gridPaint);
    }
    for (final fraction in [1.0, 0.5, 0.0]) {
      final y = chartBottom - chartHeight * fraction;
      _drawText(canvas, '${_fmtKm(axisMax * fraction)} km', Offset(chartRight + 14, y));
    }

    final n = values.length;
    if (n == 0) return;
    final step = n > 1 ? (chartRight - chartLeft - 6) / (n - 1) : 0.0;
    final points = <Offset>[
      for (var i = 0; i < n; i++)
        Offset(
          chartLeft + 6 + i * step,
          chartBottom - math.min(1.0, math.max(0.0, values[i] / axisMax)) * chartHeight,
        ),
    ];

    // garis penghubung
    final linePaint = Paint()
      ..color = _orange
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(path, linePaint);

    // garis vertikal di periode terakhir (sekarang)
    final last = points.last;
    canvas.drawLine(
      Offset(last.dx, chartTop),
      Offset(last.dx, chartBottom),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 2,
    );

    // titik tiap periode
    final dotFill = Paint()..color = _card;
    final dotStroke = Paint()
      ..color = _orange
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    for (final p in points.take(n - 1)) {
      canvas.drawCircle(p, 5.5, dotFill);
      canvas.drawCircle(p, 5.5, dotStroke);
    }
    canvas.drawCircle(last, 10, Paint()..color = const Color(0x59FC4C02));
    canvas.drawCircle(last, 6.5, Paint()..color = _orange);

    // label sumbu X
    monthLabels.forEach((index, label) {
      if (index < n) {
        _drawText(canvas, label, Offset(points[index].dx, chartBottom + 22), centerX: true);
      }
    });
  }

  @override
  bool shouldRepaint(covariant _WeeklyChartPainter oldDelegate) => true;
}
