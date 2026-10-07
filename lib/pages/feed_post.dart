import 'package:flutter/material.dart';

import '../models/activity.dart';
import '../models/feed_post.dart';
<<<<<<< HEAD
=======
import '../widgets/trekora_logo.dart';
>>>>>>> 55e8c4b70038aaa6754a400e0274880266a10e3c
import 'feed_card.dart';
import 'activity_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.onAddActivity});

  final VoidCallback onAddActivity;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const _bg = Color(0xFF121212);
  static const _card = Color(0xFF1C1C1E);
  static const _targetMingguKm = 20.0;

  final List<Map<String, String>> _saran = [
    {'nama': 'Rafi Ananda', 'ket': 'Sering lari pagi di sekitar kamu'},
<<<<<<< HEAD
    {'nama': 'Kirana Dewi', 'ket': 'Favorit pelari di Strava'},
=======
    {'nama': 'Kirana Dewi', 'ket': 'Favorit pelari di Trekora'},
>>>>>>> 55e8c4b70038aaa6754a400e0274880266a10e3c
    {'nama': 'Yoga Pratama', 'ket': 'Teman dari temanmu'},
    {'nama': 'Maya Salsabila', 'ket': 'Aktif minggu ini'},
  ];
  final Set<String> _diikuti = {};
  bool _ikutTantangan = false;

  // ---- data ringkasan minggu ini ----
  List<Activity> get _aktivitasMingguIni {
    final now = DateTime.now();
    return dummyActivities
        .where((a) => now.difference(a.date).inDays < 7)
        .toList();
  }

  int _detik(Activity a) {
    final parts = a.duration.split(':');
    final m = int.tryParse(parts[0]) ?? 0;
    final s = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
    return m * 60 + s;
  }

  @override
  Widget build(BuildContext context) {
    final mine = [...dummyActivities]..sort((a, b) => b.date.compareTo(a.date));
    final posts = [...mine.map(FeedPost.fromActivity), ...otherPosts];

    // tantangan disisipin setelah 2 postingan pertama
    final sisipIndex = posts.length < 2 ? posts.length : 2;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _topBar(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  _cuplikanMingguan(),
                  if (mine.isEmpty) _kosong(),
                  _siapaDiikuti(),
                  for (int i = 0; i < posts.length; i++) ...[
                    if (i == sisipIndex) _tantangan(),
                    FeedCard(
                      post: posts[i],
                      onTap: posts[i].source == null
                          ? null
                          : () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ActivityDetailPage(
                                  activity: posts[i].source!,
                                ),
                              ),
                            ),
                    ),
                  ],
                  if (sisipIndex == posts.length) _tantangan(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- bagian-bagian ----------

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 4, 6),
      child: Row(
        children: [
<<<<<<< HEAD
          Icon(
            Icons.directions_run,
            color: Colors.deepOrange.shade400,
            size: 26,
          ),
          const SizedBox(width: 6),
          const Text(
            'strava',
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
=======
          const TrekoraWordmark(),
>>>>>>> 55e8c4b70038aaa6754a400e0274880266a10e3c
          const Spacer(),
          IconButton(
            onPressed: widget.onAddActivity,
            icon: const Icon(Icons.add, color: Colors.white, size: 28),
          ),
          IconButton(
            onPressed: () => _info('Pesan'),
            icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
          ),
          IconButton(
            onPressed: () => _info('Pencarian'),
            icon: const Icon(Icons.search, color: Colors.white),
          ),
          IconButton(
            onPressed: () => _info('Notifikasi'),
            icon: const Icon(Icons.notifications_none, color: Colors.white),
          ),
        ],
      ),
    );
  }

  void _info(String fitur) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('$fitur belum tersedia')));
  }

  Widget _judulSeksi(String teks, {String? aksi}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              teks,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (aksi != null)
            Text(
              aksi,
              style: const TextStyle(
                color: Colors.deepOrange,
                fontWeight: FontWeight.w600,
                fontSize: 13.5,
              ),
            ),
        ],
      ),
    );
  }

  Widget _cuplikanMingguan() {
    final list = _aktivitasMingguIni;
    final jumlah = list.length;
    final km = list.fold<double>(0, (sum, a) => sum + a.distanceKm);
    final detik = list.fold<int>(0, (sum, a) => sum + _detik(a));
    final progress = (km / _targetMingguKm).clamp(0.0, 1.0).toDouble();

    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      color: _card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Cuplikan Mingguan Anda',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                'Lihat Selengkapnya',
                style: TextStyle(
                  color: Colors.deepOrange.shade300,
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _angka('Aktivitas', '$jumlah'),
              _angka('Waktu', '${detik ~/ 3600}j ${(detik % 3600) ~/ 60}m'),
              _angka('Jarak', '${km.toStringAsFixed(2)} km'),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.grey.shade800,
              color: Colors.deepOrange,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Target mingguan ${_targetMingguKm.toStringAsFixed(0)} km · ${(progress * 100).round()}% tercapai',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _angka(String label, String nilai) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        ),
        const SizedBox(height: 4),
        Text(
          nilai,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _kosong() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Row(
        children: [
          const Icon(Icons.timer_outlined, color: Colors.deepOrange, size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Belum ada aktivitasmu. Catat yang pertama yuk!',
              style: TextStyle(color: Colors.grey.shade300),
            ),
          ),
          TextButton(
            onPressed: widget.onAddActivity,
            child: const Text(
              'Tambah',
              style: TextStyle(color: Colors.deepOrange),
            ),
          ),
        ],
      ),
    );
  }

  Widget _siapaDiikuti() {
    if (_saran.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _judulSeksi('Siapa yang Harus Diikuti', aksi: 'Lihat Semua'),
        SizedBox(
          height: 218,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _saran.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, i) => _kartuSaran(_saran[i]),
          ),
        ),
      ],
    );
  }

  Widget _kartuSaran(Map<String, String> user) {
    final nama = user['nama']!;
    final sudah = _diikuti.contains(nama);

    return Container(
      width: 215,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors
                .primaries[nama.length % Colors.primaries.length]
                .shade400,
            child: Text(
              nama[0],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            nama,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user['ket']!,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey.shade400, fontSize: 12.5),
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      if (sudah) {
                        _diikuti.remove(nama);
                      } else {
                        _diikuti.add(nama);
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: sudah
                        ? Colors.grey.shade800
                        : Colors.deepOrange,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    sudah ? 'Diikuti' : 'Ikuti',
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _saran.remove(user)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.deepOrange,
                    side: const BorderSide(color: Colors.deepOrange),
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('Hapus', style: TextStyle(fontSize: 13)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tantangan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tantangan yang Disarankan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Biar lebih semangat, ikut tantangan dan dapatkan lencana!',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 13.5),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Lebih dari 12.000 atlet telah bergabung',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 12.5),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: Colors.amber,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.wb_sunny,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tantangan 50 KM Bulan Ini',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Kumpulkan 50 km lari atau jalan sebelum akhir bulan.',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () =>
                      setState(() => _ikutTantangan = !_ikutTantangan),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _ikutTantangan
                        ? Colors.grey.shade800
                        : Colors.deepOrange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Text(
                    _ikutTantangan ? 'Sudah Bergabung' : 'Ikuti Tantangan',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
