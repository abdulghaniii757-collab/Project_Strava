import 'package:flutter/material.dart';

class NotificationItem {
  NotificationItem({
    required this.name,
    required this.aksi,
    required this.waktu,
    required this.icon,
  });

  final String name;
  final String aksi;
  final String waktu;
  final IconData icon;
}

final List<NotificationItem> _dummyNotifikasi = [
  NotificationItem(
    name: 'Kirana Dewi',
<<<<<<< HEAD
    aksi: 'memberikan kudos pada aktivitas lari pagimu',
=======
    aksi: 'menyukai aktivitas lari pagimu',
>>>>>>> 55e8c4b70038aaa6754a400e0274880266a10e3c
    waktu: '2 jam lalu',
    icon: Icons.thumb_up,
  ),
  NotificationItem(
    name: 'Yoga Pratama',
    aksi: 'mengomentari aktivitasmu: "Mantap, lanjutkan!"',
    waktu: '5 jam lalu',
    icon: Icons.chat_bubble,
  ),
  NotificationItem(
<<<<<<< HEAD
    name: 'Strava',
=======
    name: 'Trekora',
>>>>>>> 55e8c4b70038aaa6754a400e0274880266a10e3c
    aksi: 'Tantangan 50 KM Bulan Ini akan berakhir 3 hari lagi',
    waktu: '1 hari lalu',
    icon: Icons.emoji_events,
  ),
  NotificationItem(
    name: 'Maya Salsabila',
    aksi: 'mulai mengikuti kamu',
    waktu: '2 hari lalu',
    icon: Icons.person_add,
  ),
];

<<<<<<< HEAD
=======
void addNotification(NotificationItem item) => _dummyNotifikasi.insert(0, item);

>>>>>>> 55e8c4b70038aaa6754a400e0274880266a10e3c
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  static const _bg = Color(0xFF121212);
  static const _card = Color(0xFF1C1C1E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        title: const Text('Notifikasi', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: _dummyNotifikasi.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final n = _dummyNotifikasi[i];
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.deepOrange,
                  child: Icon(n.icon, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(
                        TextSpan(
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          children: [
                            TextSpan(
                              text: n.name,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(text: ' ${n.aksi}'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(n.waktu, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}