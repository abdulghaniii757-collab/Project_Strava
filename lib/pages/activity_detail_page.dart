import 'package:flutter/material.dart';
import '../models/activity.dart';

class ActivityDetailPage extends StatelessWidget {
  const ActivityDetailPage({super.key, required this.activity});

  final Activity activity;

  IconData get _icon {
    switch (activity.type) {
      case 'Sepeda':
        return Icons.directions_bike;
      case 'Jalan Kaki':
        return Icons.directions_walk;
      default:
        return Icons.directions_run;
    }
  }

  double get _paceMinPerKm {
    final parts = activity.duration.split(':');
    final minutes = int.tryParse(parts[0]) ?? 0;
    final seconds = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
    final totalMinutes = minutes + seconds / 60;
    if (activity.distanceKm <= 0) return 0;
    return totalMinutes / activity.distanceKm;
  }

  @override
  Widget build(BuildContext context) {
    final pace = _paceMinPerKm;
    final paceMin = pace.floor();
    final paceSec = ((pace - paceMin) * 60).round();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Aktivitas'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
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
                    Text('Peta rute belum tersedia', style: TextStyle(color: Colors.grey.shade600)),
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
