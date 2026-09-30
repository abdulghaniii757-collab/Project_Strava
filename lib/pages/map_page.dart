import 'package:flutter/material.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key, required this.onAddActivity});

  final VoidCallback onAddActivity;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: CustomPaint(painter: _CityMapPainter())),
          SafeArea(
            child: Column(
              children: [
                _topBar(),
                const SizedBox(height: 12),
                _filters(),
                const Spacer(),
                _mapActions(),
                _routeCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _topBar() => Container(
    margin: const EdgeInsets.symmetric(horizontal: 14),
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(17),
      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 14)],
    ),
    child: const Row(
      children: [
        Icon(Icons.directions_run, color: Color(0xFFE84B16), size: 30),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            'Cari',
            style: TextStyle(fontSize: 23, fontWeight: FontWeight.w700),
          ),
        ),
        Icon(Icons.bookmark_border, size: 29),
        SizedBox(width: 8),
        Text(
          'Simpan',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );

  Widget _filters() => SizedBox(
    height: 52,
    child: ListView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      children: const [
        _MapChip('Rute', selected: true),
        _MapChip('Panjang'),
        _MapChip('Kesulitan'),
        _MapChip('Elevasi'),
        _MapChip('Permukaan'),
      ],
    ),
  );

  Widget _mapActions() => Align(
    alignment: Alignment.centerRight,
    child: Padding(
      padding: const EdgeInsets.only(right: 16, bottom: 10),
      child: Column(
        children: [
          _roundAction(Icons.layers_outlined, badge: '2'),
          const SizedBox(height: 10),
          _roundAction(Icons.threed_rotation, label: '3D'),
          const SizedBox(height: 10),
          _roundAction(Icons.my_location),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'create-route',
            onPressed: onAddActivity,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            icon: const Icon(Icons.edit_location_alt_outlined),
            label: const Text(
              'Buat Rute',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _roundAction(IconData icon, {String? label, String? badge}) => Stack(
    clipBehavior: Clip.none,
    children: [
      Container(
        width: 64,
        height: 64,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: label == null
              ? Icon(icon, size: 32)
              : Text(
                  label,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      ),
      if (badge != null)
        Positioned(
          right: -2,
          top: -5,
          child: Container(
            padding: const EdgeInsets.all(7),
            decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
            child: Text(
              badge,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
    ],
  );

  Widget _routeCard() => Container(
    margin: const EdgeInsets.fromLTRB(14, 0, 14, 10),
    height: 142,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 12)],
    ),
    child: Row(
      children: [
        Container(
          width: 136,
          decoration: const BoxDecoration(
            color: Color(0xFF55735F),
            borderRadius: BorderRadius.horizontal(left: Radius.circular(22)),
          ),
          child: const Icon(Icons.park_outlined, color: Colors.white, size: 54),
        ),
        const Expanded(
          child: Padding(
            padding: EdgeInsets.fromLTRB(14, 15, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Jalan Tanjung Gedong-J...',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 11),
                Row(
                  children: [
                    Icon(Icons.directions_run, size: 22, color: Colors.black54),
                    SizedBox(width: 6),
                    Text(
                      'Mudah',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF4D9427),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(width: 7),
                    Text(
                      '7 km · 24,3 m · 0j 56m',
                      style: TextStyle(fontSize: 15, color: Colors.black54),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      Icons.explore_outlined,
                      size: 22,
                      color: Color(0xFFE84B16),
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Dibuat untuk Anda',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFFE84B16),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(right: 14),
          child: Icon(Icons.bookmark_border, size: 28),
        ),
      ],
    ),
  );
}

class _MapChip extends StatelessWidget {
  const _MapChip(this.label, {this.selected = false});
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(right: 10),
    padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 11),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(28),
      border: Border.all(
        color: selected ? const Color(0xFFE84B16) : Colors.black12,
        width: selected ? 2 : 1,
      ),
    ),
    child: Text(
      label,
      style: TextStyle(
        fontSize: 16,
        color: selected ? const Color(0xFFE84B16) : Colors.black,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
      ),
    ),
  );
}

class _CityMapPainter extends CustomPainter {
  const _CityMapPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFE7E5DE),
    );
    final road = Paint()
      ..color = const Color(0xFFCAD4D7)
      ..strokeWidth = 2;
    final major = Paint()
      ..color = const Color(0xFFF3A98B)
      ..strokeWidth = 4;
    final route = Paint()
      ..color = const Color(0xFFE84B16)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    for (var x = -size.height; x < size.width + size.height; x += 34) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height * .7, size.height),
        road,
      );
    }
    for (var y = 20.0; y < size.height; y += 43) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y - 35), road);
    }
    for (var i = 0; i < 6; i++) {
      canvas.drawLine(
        Offset(size.width * .1, size.height * (.18 + i * .14)),
        Offset(size.width * .85, size.height * (.08 + i * .15)),
        major,
      );
    }
    final path = Path()
      ..moveTo(size.width * .48, size.height * .55)
      ..lineTo(size.width * .57, size.height * .61)
      ..lineTo(size.width * .66, size.height * .57)
      ..lineTo(size.width * .74, size.height * .68)
      ..lineTo(size.width * .66, size.height * .79)
      ..lineTo(size.width * .52, size.height * .72)
      ..lineTo(size.width * .45, size.height * .61)
      ..close();
    canvas.drawPath(path, route);
    canvas.drawCircle(
      Offset(size.width * .48, size.height * .55),
      14,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      Offset(size.width * .48, size.height * .55),
      9,
      Paint()..color = const Color(0xFF1475C9),
    );
  }

  @override
  bool shouldRepaint(covariant _CityMapPainter oldDelegate) => false;
}
