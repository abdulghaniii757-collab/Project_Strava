import 'package:flutter/material.dart';

class ChatThread {
  ChatThread({required this.nama, required this.pesanTerakhir, required this.waktu});

  final String nama;
  final String pesanTerakhir;
  final String waktu;
}

final List<ChatThread> _dummyChat = [
  ChatThread(nama: 'Kirana Dewi', pesanTerakhir: 'Besok lari bareng yuk!', waktu: '09:14'),
  ChatThread(nama: 'Yoga Pratama', pesanTerakhir: 'Mantap pace-nya kemarin 🔥', waktu: 'Kemarin'),
  ChatThread(nama: 'Dimas Prakoso', pesanTerakhir: 'Rute Dago masih oke?', waktu: 'Senin'),
];

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  static const _bg = Color(0xFF121212);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        title: const Text('Pesan', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.separated(
        itemCount: _dummyChat.length,
        separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade800),
        itemBuilder: (context, i) {
          final c = _dummyChat[i];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: Colors.primaries[c.nama.length % Colors.primaries.length].shade400,
              child: Text(
                c.nama[0],
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(c.nama, style: const TextStyle(color: Colors.white)),
            subtitle: Text(
              c.pesanTerakhir,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey.shade500),
            ),
            trailing: Text(c.waktu, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ruang obrolan belum tersedia')),
              );
            },
          );
        },
      ),
    );
  }
}