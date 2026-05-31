import 'package:flutter/material.dart';

/// Küçük marka — `assets/images/logo.png` (web `public/logo.png` ile aynı dosya).
class TiemposBrandMark extends StatelessWidget {
  const TiemposBrandMark({
    super.key,
    this.size = 44,
    this.onDarkBackground = false,
  });

  final double size;
  final bool onDarkBackground;

  static const String _pngAsset = 'assets/images/logo.png';

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      _pngAsset,
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      color: onDarkBackground ? Colors.white : null,
      colorBlendMode: onDarkBackground ? BlendMode.srcIn : null,
      semanticLabel: 'Tiempos',
    );
  }
}
