import 'package:flutter/material.dart';

/// Dialog untuk mengisi nama rute. Hasilnya nama yang sudah dirapikan (bisa
/// kosong kalau pengguna tidak mengisi), atau null kalau dialog dibatalkan.
Future<String?> showRouteNameDialog(
  BuildContext context, {
  String initialName = '',
  String title = 'Ubah nama rute',
  String confirmLabel = 'Simpan',
}) {
  return showDialog<String>(
    context: context,
    builder: (context) => RouteNameDialog(
      initialName: initialName,
      title: title,
      confirmLabel: confirmLabel,
    ),
  );
}

class RouteNameDialog extends StatefulWidget {
  const RouteNameDialog({
    super.key,
    required this.initialName,
    required this.title,
    required this.confirmLabel,
  });

  final String initialName;
  final String title;
  final String confirmLabel;

  @override
  State<RouteNameDialog> createState() => _RouteNameDialogState();
}

class _RouteNameDialogState extends State<RouteNameDialog> {
  // Controller diurus dialog ini sendiri. Kalau di-dispose dari luar, TextField
  // masih terpakai selama animasi dialog menutup dan itu bikin error.
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialName,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() => Navigator.pop(context, _controller.text.trim());

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(labelText: 'Nama rute'),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        FilledButton(onPressed: _submit, child: Text(widget.confirmLabel)),
      ],
    );
  }
}