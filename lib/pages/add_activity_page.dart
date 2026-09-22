import 'package:flutter/material.dart';
import '../models/activity.dart';

class AddActivityPage extends StatefulWidget {
  const AddActivityPage({super.key});

  @override
  State<AddActivityPage> createState() => _AddActivityPageState();
}

class _AddActivityPageState extends State<AddActivityPage> {
  final _nameController = TextEditingController();
  final _distanceController = TextEditingController();
  final _minutesController = TextEditingController();
  final _secondsController = TextEditingController();
  String _selectedType = 'Lari';

  final List<Map<String, dynamic>> _types = [
    {'label': 'Lari', 'icon': Icons.directions_run},
    {'label': 'Sepeda', 'icon': Icons.directions_bike},
    {'label': 'Jalan Kaki', 'icon': Icons.directions_walk},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _distanceController.dispose();
    _minutesController.dispose();
    _secondsController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    final distance = double.tryParse(_distanceController.text.trim());
    final minutes = int.tryParse(_minutesController.text.trim()) ?? 0;
    final seconds = int.tryParse(_secondsController.text.trim()) ?? 0;

    if (name.isEmpty ||
        distance == null ||
        distance <= 0 ||
        (minutes == 0 && seconds == 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi semua data dengan benar ya!')),
      );
      return;
    }

    final duration =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    dummyActivities.insert(
      0,
      Activity(
        name: name,
        type: _selectedType,
        distanceKm: distance,
        duration: duration,
        date: DateTime.now(),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Aktivitas'),
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
                child: const Text('Simpan Aktivitas'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
