import '../models/activity.dart';

class FeedPost {
  FeedPost({
    required this.userName,
    required this.title,
    required this.date,
    required this.distanceKm,
    required this.seconds,
    required this.extraLabel,
    required this.extraValue,
    this.location,
    this.description,
    this.source,
    this.isMine = false,
    this.isPro = false,
    this.liked = false,
    this.kudos = 0,
    this.photoCount = 0,
    this.showMap = false,
  });

  final String userName;
  final String title;
  final DateTime date;
  final double distanceKm;
  final int seconds;
  final String extraLabel;
  final String extraValue;
  final String? location;
  final String? description;
  final Activity? source;
  final bool isMine;
  final bool isPro;
  bool liked;
  int kudos;
  final int photoCount;
  final bool showMap;

  factory FeedPost.fromActivity(Activity activity) {
    final parts = activity.duration.split(':');
    final minutes = int.tryParse(parts[0]) ?? 0;
    final sec = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;

    return FeedPost(
      userName: 'Kamu',
      title: activity.name,
      date: activity.date,
      distanceKm: activity.distanceKm,
      seconds: minutes * 60 + sec,
      extraLabel: activity.type,
      extraValue: '${activity.distanceKm.toStringAsFixed(1)} km',
      location: 'Sekitar Anda',
      description: 'Aktivitas baru ditambahkan',
      source: activity,
      isMine: true,
      liked: false,
      kudos: 0,
      photoCount: 0,
      showMap: true,
    );
  }
}

String formatTanggal(DateTime date) {
  final months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];
  return '${date.day} ${months[date.month - 1]}';
}

String formatWaktu(int seconds) {
  final hours = seconds ~/ 3600;
  final minutes = (seconds % 3600) ~/ 60;
  if (hours > 0) {
    return '${hours}j ${minutes}m';
  }
  return '${minutes}m';
}

final List<FeedPost> otherPosts = [];
