class PostComment {
  const PostComment({
    required this.author,
    required this.text,
    required this.date,
  });

  final String author;
  final String text;
  final DateTime date;

  Map<String, dynamic> toJson() => {
    'author': author,
    'text': text,
    'date': date.toIso8601String(),
  };

  factory PostComment.fromJson(Map<String, dynamic> json) => PostComment(
    author: json['author'] as String? ?? 'Pengguna',
    text: json['text'] as String? ?? '',
    date: DateTime.parse(json['date'] as String),
  );
}

/// Komentar semua postingan di feed, dikelompokkan per [FeedPost.commentKey].
/// Postingan di Home dibangun ulang dari aktivitas tiap build, jadi
/// komentarnya disimpan terpisah di sini biar nggak ikut hilang.
final Map<String, List<PostComment>> postComments = {};
