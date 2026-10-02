import 'package:flutter/material.dart';

final List<Map<String, String>> _dummyHasil = [
  {'nama': 'Kirana Dewi', 'ket': 'Favorit pelari di Strava'},
  {'nama': 'Yoga Pratama', 'ket': 'Teman dari temanmu'},
  {'nama': 'Rafi Ananda', 'ket': 'Sering lari pagi di sekitar kamu'},
  {'nama': 'Maya Salsabila', 'ket': 'Aktif minggu ini'},
  {'nama': 'Dimas Prakoso', 'ket': 'Tangerang Selatan, Banten'},
  {'nama': 'Nadia Putri', 'ket': 'Bandung, Jawa Barat'},
];

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  static const _bg = Color(0xFF121212);
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasil = _dummyHasil
        .where((u) => u['nama']!.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: TextField(
          controller: _controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          onChanged: (v) => setState(() => _query = v),
          decoration: InputDecoration(
            hintText: 'Cari atlet, klub, atau aktivitas',
            hintStyle: TextStyle(color: Colors.grey.shade500),
            border: InputBorder.none,
          ),
        ),
      ),
      body: hasil.isEmpty
          ? Center(
              child: Text(
                _query.isEmpty ? 'Ketik untuk mencari' : 'Tidak ada hasil untuk "$_query"',
                style: TextStyle(color: Colors.grey.shade500),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: hasil.length,
              itemBuilder: (context, i) {
                final u = hasil[i];
                final nama = u['nama']!;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        Colors.primaries[nama.length % Colors.primaries.length].shade400,
                    child: Text(
                      nama[0],
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(nama, style: const TextStyle(color: Colors.white)),
                  subtitle: Text(u['ket']!, style: TextStyle(color: Colors.grey.shade500)),
                );
              },
            ),
    );
  }
}