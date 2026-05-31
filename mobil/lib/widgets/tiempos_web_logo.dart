import 'package:flutter/material.dart';

/// Tiempos logosu — mobilde `assets/images/logo.png` kullanılır.
///
/// `logo.svg` içinde gömülü raster olduğu için `flutter_svg` ile güvenilir
/// çizilmiyor. Web’deki `public/logo.svg` güncellenince aynı PNG’yi üretmek için:
/// `python3 mobil/scripts/extract_logo_png.py` (veya projedeki eşdeğer script).
class TiemposWebLogo extends StatelessWidget {
  const TiemposWebLogo({super.key, this.height = 52});

  static const String _pngAsset = 'assets/images/logo.png';

  final double height;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      _pngAsset,
      height: height,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      semanticLabel: 'Tiempos',
    );
  }
}
