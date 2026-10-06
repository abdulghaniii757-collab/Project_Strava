import 'package:latlong2/latlong.dart';

class SavedRoute {
  const SavedRoute({required this.name, required this.points});

  final String name;
  final List<LatLng> points;

  Map<String, dynamic> toJson() => {
    'name': name,
    'points': points
        .map((point) => {'latitude': point.latitude, 'longitude': point.longitude})
        .toList(),
  };

  factory SavedRoute.fromJson(Map<String, dynamic> json) => SavedRoute(
    name: json['name'] as String,
    points: (json['points'] as List)
        .map((point) {
          final coordinates = point as Map<String, dynamic>;
          return LatLng(
            (coordinates['latitude'] as num).toDouble(),
            (coordinates['longitude'] as num).toDouble(),
          );
        })
        .toList(),
  );
}
