import 'package:flutter/material.dart';

/// Hasil dialog simpan aktivitas: jenis olahraga + nama aktivitas.
typedef SavedActivityInfo = ({String type, String name});

/// Jenis aktivitas yang bisa direkam, sama kayak di halaman Tambah Aktivitas.
const activityTypes = [
  ('Lari', Icons.directions_run),
  ('Sepeda', Icons.directions_bike),
  ('Jalan Kaki', Icons.directions_walk),
];

IconData activityIcon(String type) =>
    activityTypes.firstWhere((t) => t.$1 == type, orElse: () => activityTypes.last).$2;

/// Kata kerja buat tiap jenis, misal "Bersepeda" buat "Sepeda".
String activityVerb(String type) => switch (type) {
  'Lari' => 'Lari',
  'Sepeda' => 'Bersepeda',
  _ => 'Jalan kaki',
};

/// Ditampilin sebelum mulai merekam di Peta. Balikin `null` kalau batal.
Future<String?> showActivityTypePicker(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Text(
              'Mau rekam aktivitas apa?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          for (final (label, icon) in activityTypes)
            ListTile(
              leading: Icon(icon, color: Colors.deepOrange),
              title: Text(label),
              onTap: () => Navigator.pop(context, label),
            ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}

/// Ditampilin setelah rekaman di Peta selesai. Jenisnya udah keisi dari pilihan
/// waktu mulai, tapi masih bisa diganti. Balikin `null` kalau user milih
/// "Buang" (rekamannya nggak disimpan).
Future<SavedActivityInfo?> showSaveActivityDialog(
  BuildContext context, {
  required String summary,
  required String initialType,
}) {
  return showDialog<SavedActivityInfo>(
    context: context,
    // Cuma bisa ditutup lewat tombol, biar rekaman nggak kebuang gara-gara
    // nggak sengaja ketuk di luar dialog atau pencet tombol back.
    barrierDismissible: false,
    builder: (context) => PopScope(
      canPop: false,
      child: _SaveActivityDialog(summary: summary, initialType: initialType),
    ),
  );
}

class _SaveActivityDialog extends StatefulWidget {
  const _SaveActivityDialog({required this.summary, required this.initialType});

  final String summary;
  final String initialType;

  @override
  State<_SaveActivityDialog> createState() => _SaveActivityDialogState();
}

class _SaveActivityDialogState extends State<_SaveActivityDialog> {
  late String _type = widget.initialType;
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// Nama otomatis ala Strava, misalnya "Lari pagi" atau "Bersepeda sore".
  String get _defaultName {
    final hour = DateTime.now().hour;
    final waktu = hour < 11
        ? 'pagi'
        : hour < 15
            ? 'siang'
            : hour < 18
                ? 'sore'
                : 'malam';
    return '${activityVerb(_type)} $waktu';
  }

  Future<void> _discard() async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buang rekaman?'),
        content: const Text('Rute dan jarak yang barusan direkam bakal hilang.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Buang', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (yakin == true && mounted) Navigator.pop(context);
  }

  void _save() {
    final name = _nameController.text.trim();
    Navigator.pop<SavedActivityInfo>(
      context,
      (type: _type, name: name.isEmpty ? _defaultName : name),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Simpan aktivitas'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.summary, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            const Text('Jenis aktivitas'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final (label, icon) in activityTypes)
                  ChoiceChip(
                    avatar: Icon(icon, size: 18),
                    label: Text(label),
                    selected: _type == label,
                    onSelected: (_) => setState(() => _type = label),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'Nama aktivitas',
                hintText: _defaultName,
                helperText: 'Kosongkan buat pakai "$_defaultName"',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _discard,
          child: const Text('Buang', style: TextStyle(color: Colors.red)),
        ),
        FilledButton(onPressed: _save, child: const Text('Simpan')),
      ],
    );
  }
}
