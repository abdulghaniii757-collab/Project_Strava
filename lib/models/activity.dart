class Activity {
  const Activity({
    required this.name,
    required this.type,
    required this.distanceKm,
    required this.duration,
    required this.date,
  });

  final String name;
  final String type;
  final double distanceKm;
  final String duration;
  final DateTime date;
}

final List<Activity> dummyActivities = [];
