import 'package:flutter/material.dart';

import '../models/feed_post.dart';
import '../models/post_comment.dart';
import '../models/user_profile.dart';
import '../services/local_storage.dart';

Future<void> showCommentSheet(BuildContext context, FeedPost post) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF1C1C1E),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => _CommentSheet(post: post),
  );
}

class _CommentSheet extends StatefulWidget {
  const _CommentSheet({required this.post});

  final FeedPost post;

  @override
  State<_CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<_CommentSheet> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();

  List<PostComment> get _komentar =>
      postComments[widget.post.commentKey] ?? const [];

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _kirim() async {
    final teks = _controller.text.trim();
    if (teks.isEmpty) return;

    setState(() {
      postComments.putIfAbsent(widget.post.commentKey, () => []).add(
        PostComment(author: currentUser.name, text: teks, date: DateTime.now()),
      );
      _controller.clear();
    });
    await LocalStorage.saveComments(postComments);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _hapus(PostComment komentar) async {
    setState(() {
      final list = postComments[widget.post.commentKey];
      list?.remove(komentar);
      if (list != null && list.isEmpty) {
        postComments.remove(widget.post.commentKey);
      }
    });
    await LocalStorage.saveComments(postComments);
  }

  @override
  Widget build(BuildContext context) {
    final komentar = _komentar;
    final tinggiMaks = MediaQuery.of(context).size.height * 0.6;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade700,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: Text(
                komentar.isEmpty ? 'Komentar' : 'Komentar (${komentar.length})',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Divider(height: 1, color: Colors.grey.shade800),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: tinggiMaks),
              child: komentar.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 36),
                      child: Text(
                        'Belum ada komentar.\nJadi yang pertama berkomentar!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    )
                  : ListView.builder(
                      controller: _scroll,
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: komentar.length,
                      itemBuilder: (context, i) => _item(komentar[i]),
                    ),
            ),
            Divider(height: 1, color: Colors.grey.shade800),
            _input(),
          ],
        ),
      ),
    );
  }

  Widget _item(PostComment komentar) {
    final inisial = komentar.author.isEmpty ? '?' : komentar.author[0].toUpperCase();
    final milikku = komentar.author == currentUser.name;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 4, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 17,
            backgroundColor: milikku ? Colors.deepOrange : Colors.blueGrey.shade600,
            child: Text(
              inisial,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        komentar.author,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _waktuLalu(komentar.date),
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  komentar.text,
                  style: TextStyle(color: Colors.grey.shade300, fontSize: 14),
                ),
              ],
            ),
          ),
          if (milikku)
            IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: () => _hapus(komentar),
              icon: Icon(Icons.delete_outline, size: 20, color: Colors.grey.shade500),
            ),
        ],
      ),
    );
  }

  Widget _input() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              autofocus: _komentar.isEmpty,
              minLines: 1,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              style: const TextStyle(color: Colors.white),
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Tulis komentar...',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                filled: true,
                fillColor: const Color(0xFF2A2A2D),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: _controller.text.trim().isEmpty ? null : _kirim,
            icon: Icon(
              Icons.send,
              color: _controller.text.trim().isEmpty
                  ? Colors.grey.shade700
                  : Colors.deepOrange,
            ),
          ),
        ],
      ),
    );
  }
}

String _waktuLalu(DateTime date) {
  final selisih = DateTime.now().difference(date);
  if (selisih.inMinutes < 1) return 'baru saja';
  if (selisih.inHours < 1) return '${selisih.inMinutes} mnt';
  if (selisih.inDays < 1) return '${selisih.inHours} j';
  if (selisih.inDays < 7) return '${selisih.inDays} h';
  return formatTanggal(date);
}
