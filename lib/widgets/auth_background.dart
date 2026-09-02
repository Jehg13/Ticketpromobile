import 'package:flutter/material.dart';

class AuthBackground extends StatelessWidget {
  final Widget child;

  const AuthBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF001F56),
            Color(0xFF082B67),
            Color(0xFF0B1D45),
            Color(0xFF070B18),
            Color(0xFF050814),
          ],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          stops: [0.0, 0.22, 0.48, 0.76, 1.0],
        ),
      ),
      child: Stack(
        children: [
          const Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _AuthGridPainter(),
              ),
            ),
          ),
          const _AuthGlow(
            top: -160,
            right: -120,
            size: 380,
            colors: [
              Color(0x663D8BFF),
              Color(0x183D8BFF),
              Colors.transparent,
            ],
          ),
          const _AuthGlow(
            bottom: -180,
            left: -140,
            size: 400,
            colors: [
              Color(0x442E7BFF),
              Color(0x142E7BFF),
              Colors.transparent,
            ],
          ),
          const _AuthGlow(
            top: 260,
            left: -120,
            size: 240,
            colors: [
              Color(0x222F7DFF),
              Colors.transparent,
            ],
          ),
          child,
        ],
      ),
    );
  }
}

class _AuthGlow extends StatelessWidget {
  final double? top;
  final double? right;
  final double? bottom;
  final double? left;
  final double size;
  final List<Color> colors;

  const _AuthGlow({
    this.top,
    this.right,
    this.bottom,
    this.left,
    required this.size,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      right: right,
      bottom: bottom,
      left: left,
      child: IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: colors),
          ),
        ),
      ),
    );
  }
}

class _AuthGridPainter extends CustomPainter {
  const _AuthGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF91B7FF).withValues(alpha: 0.028)
      ..strokeWidth = 1;

    const spacing = 36.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
