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

  Map<String, dynamic> toJson() => {
    'name': name,
    'type': type,
    'distanceKm': distanceKm,
    'duration': duration,
    'date': date.toIso8601String(),
  };

  factory Activity.fromJson(Map<String, dynamic> json) => Activity(
    name: json['name'] as String,
    type: json['type'] as String,
    distanceKm: (json['distanceKm'] as num).toDouble(),
    duration: json['duration'] as String,
    date: DateTime.parse(json['date'] as String),
  );
}

final List<Activity> dummyActivities = [];
