import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:project_strava/models/activity.dart';

void main() {
  test('rute GPS ikut tersimpan dan kebaca lagi', () {
    final activity = Activity(
      name: 'Lari pagi',
      type: 'Lari',
      distanceKm: 1.2,
      duration: '07:30',
      date: DateTime(2026, 10, 6, 6, 30),
      routePoints: const [LatLng(-6.2, 106.8), LatLng(-6.201, 106.801)],
    );

    final restored = Activity.fromJson(activity.toJson());

    expect(restored.hasRoute, isTrue);
    expect(restored.routePoints, activity.routePoints);
    expect(restored.type, 'Lari');
  });

  test('aktivitas lama tanpa rute tetap bisa dibaca', () {
    final restored = Activity.fromJson({
      'name': 'Jalan sore',
      'type': 'Jalan Kaki',
      'distanceKm': 2,
      'duration': '25:00',
      'date': '2026-10-01T17:00:00.000',
    });

    expect(restored.hasRoute, isFalse);
    expect(restored.routePoints, isEmpty);
  });
}
