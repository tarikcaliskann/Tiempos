import 'package:flutter/material.dart';

/// Tiempos logosu — `assets/images/logo.png` (canlı web `frontend/public/logo.png` ile senkron).
///
/// Güncellemek: aynı PNG’yi her iki yola kopyalayın veya `mobil/scripts/sync_logo_png.py` çalıştırın.
class TiemposWebLogo extends StatelessWidget {
  const TiemposWebLogo({
    super.key,
    this.height = 52,
    /// Mavi–mor gradient gibi koyu zeminde koyu çizgili PNG okunur olsun diye beyaza boyar.
    /// Açık kart / beyaz arka plan için `false` verin (orijinal renkler).
    this.onDarkBackground = true,
  });

  static const String _pngAsset = 'assets/images/logo.png';

  final double height;
  final bool onDarkBackground;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      _pngAsset,
      height: height,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      color: onDarkBackground ? Colors.white : null,
      colorBlendMode: onDarkBackground ? BlendMode.srcIn : null,
      semanticLabel: 'Tiempos',
    );
  }
}
