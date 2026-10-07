import 'package:flutter/material.dart';
import '../models/activity.dart';
import '../services/local_storage.dart';
<<<<<<< HEAD
=======
import '../widgets/activity_route_map.dart';
>>>>>>> 55e8c4b70038aaa6754a400e0274880266a10e3c
import 'add_activity_page.dart';

class ActivityDetailPage extends StatefulWidget {
  const ActivityDetailPage({super.key, required this.activity});

  final Activity activity;

  @override
  State<ActivityDetailPage> createState() => _ActivityDetailPageState();
}

class _ActivityDetailPageState extends State<ActivityDetailPage> {
  late Activity _activity = widget.activity;

  IconData get _icon {
    switch (_activity.type) {
      case 'Sepeda':
        return Icons.directions_bike;
      case 'Jalan Kaki':
        return Icons.directions_walk;
      default:
        return Icons.directions_run;
    }
  }

  double get _paceMinPerKm {
    final parts = _activity.duration.split(':');
    final minutes = int.tryParse(parts[0]) ?? 0;
    final seconds = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
    final totalMinutes = minutes + seconds / 60;
    if (_activity.distanceKm <= 0) return 0;
    return totalMinutes / _activity.distanceKm;
  }

  Future<void> _edit() async {
    final result = await Navigator.push<Activity>(
      context,
      MaterialPageRoute(
        builder: (context) => AddActivityPage(existing: _activity),
      ),
    );
    if (result != null && mounted) {
      setState(() => _activity = result);
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus aktivitas?'),
        content: Text('"${_activity.name}" akan dihapus permanen dan ga bisa dibalikin lagi.'),
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

    if (confirmed == true) {
      dummyActivities.remove(_activity);
      await LocalStorage.saveActivities(dummyActivities);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final activity = _activity;
    final pace = _paceMinPerKm;
    final paceMin = pace.floor();
    final paceSec = ((pace - paceMin) * 60).round();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Aktivitas'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _edit,
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit',
          ),
          IconButton(
            onPressed: _delete,
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Hapus',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.deepOrange.shade50,
                  child: Icon(_icon, color: Colors.deepOrange, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.name,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(activity.type, style: TextStyle(color: Colors.grey.shade600)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _StatBox(
                    label: 'Jarak',
                    value: '${activity.distanceKm.toStringAsFixed(2)} km',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: _StatBox(label: 'Waktu', value: activity.duration)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatBox(
                    label: 'Pace',
                    value: pace > 0
                        ? '$paceMin:${paceSec.toString().padLeft(2, '0')} /km'
                        : '-',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatBox(
                    label: 'Tanggal',
                    value: '${activity.date.day.toString().padLeft(2, '0')}/'
                        '${activity.date.month.toString().padLeft(2, '0')}/'
                        '${activity.date.year}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (activity.hasRoute)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: ActivityRouteMap(points: activity.routePoints, height: 260),
              )
            else
              Container(
                width: double.infinity,
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.map_outlined, size: 40, color: Colors.grey.shade500),
                      const SizedBox(height: 8),
                      Text(
                        'Aktivitas ini nggak direkam lewat Peta, jadi belum ada rutenya',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.deepOrange.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
