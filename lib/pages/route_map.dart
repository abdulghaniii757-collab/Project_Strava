import 'dart:math';
import 'package:flutter/material.dart';

// Peta rute tiruan: latar jalan-jalan + garis oranye. Bentuknya beda-beda per seed.
class RouteMap extends StatelessWidget {
  const RouteMap({super.key, required this.seed, this.height = 190});

  final int seed;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(painter: _RoutePainter(seed)),
    );
  }
}

class _RoutePainter extends CustomPainter {
  _RoutePainter(this.seed);

  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = Random(seed);

    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF262B32));

    final jalan = Paint()
      ..color = const Color(0xFF363D46)
      ..strokeWidth = 7
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 6; i++) {
      final y = size.height * (i + 0.5) / 6;
      canvas.drawLine(
        Offset(0, y + rnd.nextDouble() * 16 - 8),
        Offset(size.width, y + rnd.nextDouble() * 30 - 15),
        jalan,
      );
    }
    for (int i = 0; i < 9; i++) {
      final x = size.width * (i + 0.5) / 9;
      canvas.drawLine(
        Offset(x + rnd.nextDouble() * 20 - 10, 0),
        Offset(x + rnd.nextDouble() * 40 - 20, size.height),
        jalan,
      );
    }

    // rute: elips yang jari-jarinya digoyang biar kelihatan kayak jalur lari
    final cx = size.width * (0.42 + rnd.nextDouble() * 0.16);
    final cy = size.height * 0.5;
    final rx = size.width * (0.22 + rnd.nextDouble() * 0.14);
    final ry = size.height * (0.24 + rnd.nextDouble() * 0.12);
    final fase = rnd.nextDouble() * pi * 2;
    final gelombang = 3 + rnd.nextInt(3);

    final titik = <Offset>[];
    const jumlah = 70;
    for (int i = 0; i <= jumlah; i++) {
      final t = i / jumlah * pi * 2;
      final goyang = 1 + 0.18 * sin(gelombang * t + fase);
      titik.add(Offset(cx + rx * goyang * cos(t), cy + ry * goyang * sin(t)));
    }

    final path = Path()..moveTo(titik.first.dx, titik.first.dy);
    for (final p in titik.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.deepOrange
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke,
    );

    // titik start (hijau) dan finish (putih)
    canvas.drawCircle(titik.first, 6, Paint()..color = Colors.greenAccent.shade700);
    canvas.drawCircle(titik[jumlah ~/ 2], 5, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _RoutePainter old) => old.seed != seed;
}