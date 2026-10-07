import 'package:flutter/material.dart';

import '../models/activity.dart';
import '../models/challenge.dart';
import '../models/feed_post.dart';
import '../models/user_profile.dart';
import '../services/challenge_service.dart';
import '../services/local_storage.dart';
import '../widgets/trekora_logo.dart';
import 'feed_card.dart';
import 'activity_detail_page.dart';
import 'notifications_page.dart';
import 'search_page.dart';
import 'messages_page.dart';
import 'suggested_athletes_page.dart';
import 'stats_page.dart';

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
    {'nama': 'Kirana Dewi', 'ket': 'Favorit pelari di Trekora'},
    {'nama': 'Yoga Pratama', 'ket': 'Teman dari temanmu'},
    {'nama': 'Maya Salsabila', 'ket': 'Aktif minggu ini'},
  ];

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
                      onDelete: posts[i].source == null
                          ? null
                          : () {
                              setState(() => dummyActivities.remove(posts[i].source));
                              _info('Aktivitas dihapus');
                            },
                      onHide: posts[i].source != null
                          ? null
                          : () => setState(() => otherPosts.remove(posts[i])),
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


  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 4, 6),
      child: Row(
        children: [
          const TrekoraWordmark(),
          const Spacer(),
          IconButton(
            onPressed: widget.onAddActivity,
            icon: const Icon(Icons.add, color: Colors.white, size: 28),
          ),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MessagesPage()),
            ),
            icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
          ),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SearchPage()),
            ),
            icon: const Icon(Icons.search, color: Colors.white),
          ),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NotificationsPage()),
            ),
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

  Widget _judulSeksi(String teks, {String? aksi, VoidCallback? onAksi}) {
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
            GestureDetector(
              onTap: onAksi,
              child: Text(
                aksi,
                style: const TextStyle(
                  color: Colors.deepOrange,
                  fontWeight: FontWeight.w600,
                  fontSize: 13.5,
                ),
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
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const StatsPage()),
                ),
                child: Text(
                  'Lihat Selengkapnya',
                  style: TextStyle(
                    color: Colors.deepOrange.shade300,
                    fontSize: 12.5,
                  ),
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
        _judulSeksi(
          'Siapa yang Harus Diikuti',
          aksi: 'Lihat Semua',
          onAksi: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SuggestedAthletesPage(awal: _saran)),
            );
            if (mounted) setState(() {});
          },
        ),
        SizedBox(
          height: 218,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _saran.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) => _kartuSaran(_saran[i]),
          ),
        ),
      ],
    );
  }

  Widget _kartuSaran(Map<String, String> user) {
    final nama = user['nama']!;
    final sudah = followedAthletes.contains(nama);

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
                        followedAthletes.remove(nama);
                      } else {
                        followedAthletes.add(nama);
                      }
                    });
                    LocalStorage.saveFollowing(followedAthletes);
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

  Future<void> _toggleTantangan(bool sudahIkut) async {
    if (sudahIkut) {
      final keluar = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Keluar dari tantangan?'),
          content: const Text(
            'Progres kamu tetap dihitung kalau nanti gabung lagi bulan ini.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Keluar'),
            ),
          ],
        ),
      );
      if (keluar != true) return;
    }

    await ChallengeService.setJoined(!sudahIkut);
    if (!mounted) return;
    setState(() {});
    // Siapa tau jaraknya bulan ini udah lewat 50 km waktu baru gabung.
    if (!sudahIkut) await ChallengeService.checkCompletion(context);
    if (mounted) setState(() {});
  }

  Widget _progresTantangan(double km, bool selesai) {
    final progress = (km / challengeTargetKm).clamp(0.0, 1.0).toDouble();
    final sisaHari = challengeDaysLeft();

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${km.toStringAsFixed(1)} / ${challengeTargetKm.toStringAsFixed(0)} km',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                selesai
                    ? 'Tercapai!'
                    : sisaHari == 0
                        ? 'Hari terakhir'
                        : '$sisaHari hari lagi',
                style: TextStyle(
                  color: selesai ? Colors.green.shade400 : Colors.grey.shade400,
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.grey.shade800,
              color: selesai ? Colors.green.shade400 : Colors.amber,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            selesai
                ? 'Lencana sudah masuk ke profilmu.'
                : 'Tinggal ${(challengeTargetKm - km).toStringAsFixed(1)} km lagi buat dapat lencana.',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _tantangan() {
    final key = challengeMonthKey(DateTime.now());
    final ikut = joinedChallengeMonths.contains(key);
    final selesai = completedChallengeMonths.contains(key);
    final km = challengeKmFor(key);

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
              if (ikut || selesai) _progresTantangan(km, selesai),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: selesai ? null : () => _toggleTantangan(ikut),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ikut
                        ? Colors.grey.shade800
                        : Colors.deepOrange,
                    disabledBackgroundColor: Colors.green.shade700,
                    disabledForegroundColor: Colors.white,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Text(
                    selesai
                        ? 'Selesai · Lencana Didapat'
                        : ikut
                            ? 'Sudah Bergabung'
                            : 'Ikuti Tantangan',
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