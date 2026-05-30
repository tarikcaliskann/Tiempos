import 'package:flutter/material.dart';

/// Web `/logo.svg` yerine vektör benzeri — gradient kare + "T".
class TiemposBrandMark extends StatelessWidget {
  const TiemposBrandMark({super.key, this.size = 44});

  final double size;

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(size * 0.22);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: r,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2563EB),
            Color(0xFF7C3AED),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E1B4B).withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        'T',
        style: TextStyle(
          fontSize: size * 0.48,
          fontWeight: FontWeight.w900,
          color: Colors.white,
          height: 1,
          letterSpacing: -0.5,
        ),
      ),
    );
  }
}
