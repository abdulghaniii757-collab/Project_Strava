import 'package:flutter/material.dart';
import '../models/feed_post.dart';
import '../widgets/activity_route_map.dart';
import 'route_map.dart';

class FeedCard extends StatefulWidget {
  const FeedCard({super.key, required this.post, this.onTap, this.onDelete, this.onHide});

  final FeedPost post;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onHide;

  @override
  State<FeedCard> createState() => _FeedCardState();
}

class _FeedCardState extends State<FeedCard> {
  FeedPost get p => widget.post;

  static const _warnaFoto = [
    [Color(0xFF3B5B4A), Color(0xFF1F3329)],
    [Color(0xFF4A5568), Color(0xFF232A36)],
    [Color(0xFF6B4E3D), Color(0xFF33251C)],
  ];

  void _toggleKudos() {
    setState(() {
      p.liked = !p.liked;
      p.kudos += p.liked ? 1 : -1;
    });
  }

  void _soon(String fitur) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$fitur belum tersedia')),
    );
  }

  void _bukaMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2A2A2D),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (p.isMine)
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  title: const Text('Hapus Aktivitas', style: TextStyle(color: Colors.redAccent)),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _konfirmasiHapus();
                  },
                )
              else ...[
                ListTile(
                  leading: const Icon(Icons.visibility_off_outlined, color: Colors.white),
                  title: const Text('Sembunyikan Postingan', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    widget.onHide?.call();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.flag_outlined, color: Colors.white),
                  title: const Text('Laporkan', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Laporan terkirim')),
                    );
                  },
                ),
              ],
              ListTile(
                leading: const Icon(Icons.share_outlined, color: Colors.white),
                title: const Text('Bagikan', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _soon('Bagikan');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _konfirmasiHapus() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus aktivitas?'),
        content: const Text('Aktivitas yang dihapus tidak bisa dikembalikan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              widget.onDelete?.call();
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      color: const Color(0xFF1C1C1E),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: widget.onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(),
                _judul(),
                _stat(),
                const SizedBox(height: 14),
                if (p.photoCount > 0)
                  _foto()
                else if (p.source?.hasRoute ?? false)
                  ActivityRouteMap(points: p.source!.routePoints)
                else if (p.showMap)
                  RouteMap(seed: p.title.hashCode + p.userName.hashCode),
              ],
            ),
          ),
          _kudosRow(),
          _aksi(),
        ],
      ),
    );
  }

  Widget _header() {
    final inisial = p.userName.isEmpty ? '?' : p.userName[0].toUpperCase();
    final sub = p.location == null
        ? formatTanggal(p.date)
        : '${formatTanggal(p.date)} · ${p.location}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 8, 0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 21,
            backgroundColor: p.isMine ? Colors.deepOrange : Colors.blueGrey.shade600,
            child: Text(
              inisial,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        p.userName,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (p.isPro) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.deepOrange,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'PRO',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  sub,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12.5),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _bukaMenu,
            icon: Icon(Icons.more_horiz, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  Widget _judul() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            p.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (p.description != null) ...[
            const SizedBox(height: 6),
            Text(
              p.description!,
              style: TextStyle(color: Colors.grey.shade300, fontSize: 14.5),
            ),
          ],
        ],
      ),
    );
  }

  Widget _stat() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Row(
        children: [
          _statItem('Jarak', '${p.distanceKm.toStringAsFixed(2)} km'),
          const SizedBox(width: 28),
          _statItem(p.extraLabel, p.extraValue),
          const SizedBox(width: 28),
          _statItem('Waktu', formatWaktu(p.seconds)),
        ],
      ),
    );
  }

  Widget _statItem(String label, String nilai) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade400, fontSize: 12.5)),
        const SizedBox(height: 2),
        Text(
          nilai,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _foto() {
    return SizedBox(
      height: 190,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: p.photoCount,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final warna = _warnaFoto[i % _warnaFoto.length];
          return Container(
            width: 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: warna,
              ),
            ),
            child: Icon(Icons.landscape_outlined, color: Colors.white38, size: 40),
          );
        },
      ),
    );
  }

  Widget _kudosRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      child: Row(
        children: [
          SizedBox(
            width: 54,
            height: 26,
            child: Stack(
              children: [
                for (int i = 0; i < 3; i++)
                  Positioned(
                    left: i * 14.0,
                    child: CircleAvatar(
                      radius: 13,
                      backgroundColor: const Color(0xFF1C1C1E),
                      child: CircleAvatar(
                        radius: 11.5,
                        backgroundColor: Colors.primaries[(p.title.length + i * 3) % Colors.primaries.length].shade300,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            p.kudos == 0 ? 'Jadi yang pertama memberi kudos' : '${p.kudos} memberikan kudos',
            style: TextStyle(color: Colors.grey.shade300, fontSize: 13.5),
          ),
        ],
      ),
    );
  }

  Widget _aksi() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: IconButton(
              onPressed: _toggleKudos,
              icon: Icon(
                p.liked ? Icons.thumb_up : Icons.thumb_up_outlined,
                color: p.liked ? Colors.deepOrange : Colors.grey.shade300,
              ),
            ),
          ),
          Expanded(
            child: IconButton(
              onPressed: () => _soon('Komentar'),
              icon: Icon(Icons.chat_bubble_outline, color: Colors.grey.shade300),
            ),
          ),
          Expanded(
            child: IconButton(
              onPressed: () => _soon('Bagikan'),
              icon: Icon(Icons.share_outlined, color: Colors.grey.shade300),
            ),
          ),
        ],
      ),
    );
  }
}