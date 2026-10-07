import 'package:flutter/material.dart';

/// Lokasi file logo Trekora (lihat folder assets/images).
const trekoraLogoPath = 'assets/images/trekora_logo.png';

/// Logo Trekora + tulisan nama aplikasi, dipakai di halaman login dan header beranda.
class TrekoraWordmark extends StatelessWidget {
  const TrekoraWordmark({
    super.key,
    this.logoSize = 28,
    this.fontSize = 25,
    this.fontWeight = FontWeight.w800,
  });

  final double logoSize;
  final double fontSize;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(trekoraLogoPath, width: logoSize, height: logoSize),
        SizedBox(width: logoSize * 0.3),
        Text(
          'Trekora',
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
            fontWeight: fontWeight,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
