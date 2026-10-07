import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Peta kecil (nggak bisa digeser) yang nampilin rute GPS asli sebuah aktivitas,
/// lengkap dengan titik mulai (hijau) dan titik selesai (oranye).
class ActivityRouteMap extends StatelessWidget {
  const ActivityRouteMap({super.key, required this.points, this.height = 190});

  final List<LatLng> points;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      // IgnorePointer: biar tap di kartu feed tetap kebaca sama kartunya.
      child: IgnorePointer(
        child: FlutterMap(
          options: MapOptions(
            initialCameraFit: CameraFit.coordinates(
              coordinates: points,
              padding: const EdgeInsets.all(28),
              maxZoom: 17,
            ),
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.none,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.project_strava',
            ),
            PolylineLayer(
              polylines: [
                Polyline(
                  points: points,
                  strokeWidth: 4,
                  color: Colors.deepOrange,
                  borderStrokeWidth: 1.5,
                  borderColor: Colors.white,
                ),
              ],
            ),
            MarkerLayer(
              markers: [
                _dot(points.first, Colors.green),
                _dot(points.last, Colors.deepOrange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Marker _dot(LatLng point, Color color) => Marker(
    point: point,
    width: 14,
    height: 14,
    child: Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
    ),
  );
}
