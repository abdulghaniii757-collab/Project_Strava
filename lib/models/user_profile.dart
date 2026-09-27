class UserProfile {
  final String name;
  final String location;
  final String avatarUrl;
  final int following;
  final int followers;
  final int totalActivities4Weeks;
  final double recentDistance;
  final String recentTime;
  final double recentElevation;

  UserProfile({
    required this.name,
    required this.location,
    required this.avatarUrl,
    required this.following,
    required this.followers,
    required this.totalActivities4Weeks,
    required this.recentDistance,
    required this.recentTime,
    required this.recentElevation,
  });
}