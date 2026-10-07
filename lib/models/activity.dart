import 'package:latlong2/latlong.dart';

class Activity {
  const Activity({
    required this.name,
    required this.type,
    required this.distanceKm,
    required this.duration,
    required this.date,
    this.routePoints = const [],
  });

  final String name;
  final String type;
  final double distanceKm;
  final String duration;
  final DateTime date;

<<<<<<< HEAD
=======
  /// Titik GPS rute yang direkam dari halaman Peta. Kosong kalau aktivitasnya
  /// ditambah manual.
  final List<LatLng> routePoints;

  bool get hasRoute => routePoints.length > 1;

>>>>>>> 55e8c4b70038aaa6754a400e0274880266a10e3c
  Map<String, dynamic> toJson() => {
    'name': name,
    'type': type,
    'distanceKm': distanceKm,
    'duration': duration,
    'date': date.toIso8601String(),
<<<<<<< HEAD
=======
    // Disimpan ringkas sebagai [lat, lng] biar data di HP nggak bengkak.
    if (hasRoute)
      'route': routePoints
          .map((p) => [_round(p.latitude), _round(p.longitude)])
          .toList(),
>>>>>>> 55e8c4b70038aaa6754a400e0274880266a10e3c
  };

  factory Activity.fromJson(Map<String, dynamic> json) => Activity(
    name: json['name'] as String,
    type: json['type'] as String,
    distanceKm: (json['distanceKm'] as num).toDouble(),
    duration: json['duration'] as String,
    date: DateTime.parse(json['date'] as String),
<<<<<<< HEAD
=======
    // Aktivitas lama (sebelum ada fitur rute) nggak punya 'route'.
    routePoints: (json['route'] as List? ?? const [])
        .map((p) {
          final latLng = p as List;
          return LatLng(
            (latLng[0] as num).toDouble(),
            (latLng[1] as num).toDouble(),
          );
        })
        .toList(),
>>>>>>> 55e8c4b70038aaa6754a400e0274880266a10e3c
  );
}

// 6 angka desimal = presisi ~10 cm, udah lebih dari cukup buat GPS HP.
double _round(double value) => double.parse(value.toStringAsFixed(6));

final List<Activity> dummyActivities = [];
