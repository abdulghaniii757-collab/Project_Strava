import 'package:flutter/material.dart';
import '../models/activity.dart';
import '../services/local_storage.dart';

class AddActivityPage extends StatefulWidget {
  const AddActivityPage({super.key, this.existing});

  /// Kalau diisi, halaman ini jadi mode edit buat aktivitas ini.
  /// Kalau null, halaman ini buat nambah aktivitas baru.
  final Activity? existing;

  @override
  State<AddActivityPage> createState() => _AddActivityPageState();
}

int _durationStringToSeconds(String duration) {
  final parts = duration.split(':');
  final minutes = int.tryParse(parts[0]) ?? 0;
  final seconds = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
  return minutes * 60 + seconds;
}

class _AddActivityPageState extends State<AddActivityPage> {
  final _nameController = TextEditingController();
  final _distanceController = TextEditingController();
  final _hoursController = TextEditingController();
  final _minutesController = TextEditingController();
  final _secondsController = TextEditingController();
  String _selectedType = 'Lari';

  final List<Map<String, dynamic>> _types = [
    {'label': 'Lari', 'icon': Icons.directions_run},
    {'label': 'Sepeda', 'icon': Icons.directions_bike},
    {'label': 'Jalan Kaki', 'icon': Icons.directions_walk},
  ];

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e == null) return;

    _nameController.text = e.name;
    _distanceController.text = e.distanceKm % 1 == 0
        ? e.distanceKm.toInt().toString()
        : e.distanceKm.toString();
    _selectedType = e.type;

    final totalSeconds = _durationStringToSeconds(e.duration);
    _hoursController.text = '${totalSeconds ~/ 3600}';
    _minutesController.text = '${(totalSeconds % 3600) ~/ 60}';
    _secondsController.text = '${totalSeconds % 60}';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _distanceController.dispose();
    _hoursController.dispose();
    _minutesController.dispose();
    _secondsController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final distance = double.tryParse(_distanceController.text.trim());
    final hours = int.tryParse(_hoursController.text.trim()) ?? 0;
    final minutes = int.tryParse(_minutesController.text.trim()) ?? 0;
    final seconds = int.tryParse(_secondsController.text.trim()) ?? 0;

    final totalSeconds = hours * 3600 + minutes * 60 + seconds;

    if (name.isEmpty ||
        distance == null ||
        distance <= 0 ||
        totalSeconds <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi semua data dengan benar ya!')),
      );
      return;
    }

    // Format tetap MM:SS (jam diubah jadi menit) supaya halaman lain tetap cocok.
    final duration =
        '${(totalSeconds ~/ 60).toString().padLeft(2, '0')}:${(totalSeconds % 60).toString().padLeft(2, '0')}';

    final newActivity = Activity(
      name: name,
      type: _selectedType,
      distanceKm: distance,
      duration: duration,
      // Edit: tanggal aslinya dipertahankan. Baru: pakai waktu sekarang.
      date: widget.existing?.date ?? DateTime.now(),
<<<<<<< HEAD
=======
      // Rute GPS hasil rekaman peta jangan sampai hilang waktu diedit.
      routePoints: widget.existing?.routePoints ?? const [],
>>>>>>> 55e8c4b70038aaa6754a400e0274880266a10e3c
    );

    if (_isEditing) {
      final idx = dummyActivities.indexOf(widget.existing!);
      if (idx != -1) dummyActivities[idx] = newActivity;
    } else {
      dummyActivities.insert(0, newActivity);
    }
    await LocalStorage.saveActivities(dummyActivities);

    if (mounted) Navigator.pop(context, newActivity);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Aktivitas' : 'Tambah Aktivitas'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nama Aktivitas',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'Misal: Lari Sore di Taman',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Jenis Olahraga',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _types.map((t) {
                final selected = _selectedType == t['label'];
                return ChoiceChip(
                  label: Text(t['label']),
                  avatar: Icon(
                    t['icon'],
                    size: 18,
                    color: selected ? Colors.white : Colors.deepOrange,
                  ),
                  selected: selected,
                  selectedColor: Colors.deepOrange,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : Colors.black,
                  ),
                  onSelected: (_) {
                    setState(() {
                      _selectedType = t['label'];
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Text(
              'Jarak (km)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _distanceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                hintText: 'Misal: 5.2',
                border: OutlineInputBorder(),
                suffixText: 'km',
              ),
            ),
            const SizedBox(height: 20),
            const Text('Durasi', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _hoursController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: '0',
                      labelText: 'Jam',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _minutesController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: '0',
                      labelText: 'Menit',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _secondsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: '0',
                      labelText: 'Detik',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _save,
                child: Text(_isEditing ? 'Simpan Perubahan' : 'Simpan Aktivitas'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
