import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Web `public/logo.svg` ile aynı varlık (`assets/images/logo.svg`).
class TiemposWebLogo extends StatelessWidget {
  const TiemposWebLogo({super.key, this.height = 52});

  static const String _asset = 'assets/images/logo.svg';

  final double height;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      _asset,
      height: height,
      fit: BoxFit.contain,
      semanticsLabel: 'Tiempos',
    );
  }
}
