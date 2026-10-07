import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../services/local_storage.dart';

class SuggestedAthletesPage extends StatefulWidget {
  const SuggestedAthletesPage({super.key, required this.awal});

  final List<Map<String, String>> awal;

  @override
  State<SuggestedAthletesPage> createState() => _SuggestedAthletesPageState();
}

class _SuggestedAthletesPageState extends State<SuggestedAthletesPage> {
  static const _bg = Color(0xFF121212);
  late final List<Map<String, String>> _daftar = [
    ...widget.awal,
    {'nama': 'Dimas Prakoso', 'ket': 'Tangerang Selatan, Banten'},
    {'nama': 'Nadia Putri', 'ket': 'Bandung, Jawa Barat'},
    {'nama': 'Bagas Wicaksono', 'ket': 'Jakarta Selatan'},
    {'nama': 'Sinta Maharani', 'ket': 'Yogyakarta'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        title: const Text('Siapa yang Harus Diikuti', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: _daftar.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final u = _daftar[i];
          final nama = u['nama']!;
          final sudah = followedAthletes.contains(nama);

          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.primaries[nama.length % Colors.primaries.length].shade400,
                  child: Text(
                    nama[0],
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(nama, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      Text(u['ket']!, style: TextStyle(color: Colors.grey.shade500, fontSize: 12.5)),
                    ],
                  ),
                ),
                ElevatedButton(
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
                    backgroundColor: sudah ? Colors.grey.shade800 : Colors.deepOrange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: Text(sudah ? 'Diikuti' : 'Ikuti'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}