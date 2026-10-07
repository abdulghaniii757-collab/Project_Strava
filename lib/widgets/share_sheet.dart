import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/feed_post.dart';

Future<void> showShareSheet(BuildContext context, FeedPost post) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF1C1C1E),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => _ShareSheet(post: post),
  );
}

class _ShareSheet extends StatelessWidget {
  const _ShareSheet({required this.post});

  final FeedPost post;

  Future<void> _salin(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: post.shareLink));
    if (!context.mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Link disalin')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade700,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Bagikan Aktivitas',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              post.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey.shade400),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.fromLTRB(12, 4, 4, 4),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2D),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.link, color: Colors.grey.shade400, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SelectableText(
                      post.shareLink,
                      maxLines: 1,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Salin link',
                    onPressed: () => _salin(context),
                    icon: Icon(Icons.copy, color: Colors.grey.shade300, size: 20),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: () => _salin(context),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: const Icon(Icons.copy),
              label: const Text('Salin Link'),
            ),
          ],
        ),
      ),
    );
  }
}
