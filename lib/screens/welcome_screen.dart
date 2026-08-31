import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import 'about_screen.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030713),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF001D52),
              Color(0xFF062B68),
              Color(0xFF0A1C43),
              Color(0xFF050B1C),
              Color(0xFF030713),
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            stops: [0.0, 0.18, 0.43, 0.72, 1.0],
          ),
        ),
        child: Stack(
          children: [
            const Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _WelcomeBackgroundPainter(),
                ),
              ),
            ),

            Positioned(
              top: -180,
              right: -150,
              child: IgnorePointer(
                child: Container(
                  width: 470,
                  height: 470,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Color(0x664A9CFF),
                        Color(0x302B73D6),
                        Color(0x10255AA0),
                        Colors.transparent,
                      ],
                      stops: [0.0, 0.35, 0.65, 1.0],
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              top: 120,
              left: -180,
              child: IgnorePointer(
                child: Container(
                  width: 430,
                  height: 430,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Color(0x332C7BFF),
                        Color(0x181E58B8),
                        Colors.transparent,
                      ],
                      stops: [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: -190,
              left: -150,
              child: IgnorePointer(
                child: Container(
                  width: 500,
                  height: 500,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Color(0x553B8DFF),
                        Color(0x202665B8),
                        Color(0x0C163D78),
                        Colors.transparent,
                      ],
                      stops: [0.0, 0.35, 0.65, 1.0],
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: -120,
              right: -100,
              child: IgnorePointer(
                child: Container(
                  width: 360,
                  height: 360,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Color(0x222B78FF),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0.0, -0.15),
                      radius: 1.1,
                      colors: [
                        Colors.transparent,
                        Colors.transparent,
                        const Color(0x55000000),
                      ],
                      stops: const [0.0, 0.58, 1.0],
                    ),
                  ),
                ),
              ),
            ),

            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final height = constraints.maxHeight;

                  final bool smallPhone = width < 450;
                  final bool phone = width < 600;
                  final bool tablet = width >= 600;

                  final double horizontalPadding = smallPhone
                      ? 24
                      : phone
                          ? 32
                          : 50;

                  final double contentWidth = tablet
                      ? 760
                      : width - (horizontalPadding * 2);

                  final double titleSize = smallPhone
                      ? 38
                      : phone
                          ? 48
                          : 62;

                  final double descriptionSize = smallPhone
                      ? 11
                      : phone
                          ? 12.5
                          : 15;

                  final double topSpacing = smallPhone
                      ? 20
                      : phone
                          ? 26
                          : 42;

                  final double sectionSpacing = smallPhone
                      ? 18
                      : phone
                          ? 22
                          : 32;

                  return Padding(
                    padding: EdgeInsets.fromLTRB(
                      tablet ? 24 : horizontalPadding,
                      18,
                      tablet ? 24 : horizontalPadding,
                      16,
                    ),
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.topCenter,
                        child: SizedBox(
                          width: contentWidth,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: height - 34,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildLogo(),

                                SizedBox(
                                  height: phone ? 22 : 30,
                                ),

                                _buildSupportLabel(),

                                SizedBox(
                                  height: topSpacing,
                                ),

                                Text(
                                  'Bienvenido a',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: titleSize,
                                    fontWeight: FontWeight.w800,
                                    height: 0.98,
                                    letterSpacing: -1.5,
                                    shadows: [
                                      Shadow(
                                        color: const Color(0xFF4A94FF)
                                            .withValues(alpha: .18),
                                        blurRadius: 20,
                                      ),
                                    ],
                                  ),
                                ),

                                Text(
                                  'TicketPro',
                                  style: TextStyle(
                                    color: const Color(0xFF4A94FF),
                                    fontSize: titleSize,
                                    fontWeight: FontWeight.w800,
                                    height: 0.98,
                                    letterSpacing: -1.5,
                                    shadows: [
                                      Shadow(
                                        color: const Color(0xFF1677FF)
                                            .withValues(alpha: 0.40),
                                        blurRadius: 28,
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(
                                  height: phone ? 14 : 18,
                                ),

                                ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 650,
                                  ),
                                  child: Text(
                                    'La plataforma de gestión de tickets interna '
                                    'que conecta equipos, departamentos y '
                                    'ubicaciones para resolver lo que importa.',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.68),
                                      fontSize: descriptionSize,
                                      height: 1.45,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),

                                SizedBox(
                                  height: sectionSpacing,
                                ),

                                _buildLiveStatusCard(
                                  phone: phone,
                                ),

                                SizedBox(
                                  height: phone ? 20 : 28,
                                ),

                                _buildFeatures(
                                  width: width,
                                  smallPhone: smallPhone,
                                  phone: phone,
                                  tablet: tablet,
                                ),

                                SizedBox(
                                  height: phone ? 20 : 28,
                                ),

                                _buildLoginButton(context),

                                const SizedBox(height: 9),

                                _buildMoreButton(context),

                                SizedBox(
                                  height: phone ? 18 : 24,
                                ),

                                _buildSecurityCard(
                                  smallPhone: smallPhone,
                                ),

                                const SizedBox(height: 14),

                                Center(
                                  child: Text(
                                    '© 2026 Cymez',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.32),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF55A0FF),
                Color(0xFF1760C9),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.18),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1677FF).withValues(alpha: 0.45),
                blurRadius: 22,
                spreadRadius: 1,
                offset: const Offset(0, 7),
              ),
              BoxShadow(
                color: const Color(0xFF1677FF).withValues(alpha: 0.18),
                blurRadius: 40,
              ),
            ],
          ),
          child: const Icon(
            LucideIcons.ticket_check,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 11),
        Text.rich(
          const TextSpan(
            text: 'TICKET',
            style: TextStyle(
              color: Color(0xFF55A0FF),
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
            ),
            children: [
              TextSpan(
                text: 'PRO',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSupportLabel() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1D42).withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color(0xFF5CA5FF).withValues(alpha: 0.16),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1677FF).withValues(alpha: 0.08),
            blurRadius: 20,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: const Color(0xFF58A4FF),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF3D8BFF).withValues(alpha: 0.8),
                  blurRadius: 9,
                ),
              ],
            ),
          ),
          const SizedBox(width: 9),
          const Text(
            'PLATAFORMA DE SOPORTE INTERNO',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.7,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveStatusCard({
    required bool phone,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: phone ? 14 : 18,
        vertical: phone ? 12 : 15,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF14346E).withValues(alpha: 0.86),
            const Color(0xFF091832).withValues(alpha: 0.84),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF5AA4FF).withValues(alpha: 0.20),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1677FF).withValues(alpha: 0.12),
            blurRadius: 28,
            spreadRadius: 1,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: phone ? 42 : 48,
            height: phone ? 42 : 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF1677FF).withValues(alpha: 0.28),
                  const Color(0xFF3D8BFF).withValues(alpha: 0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFF5AA4FF).withValues(alpha: 0.12),
              ),
            ),
            child: const Icon(
              LucideIcons.activity,
              color: Color(0xFF69A4FF),
              size: 23,
            ),
          ),
          const SizedBox(width: 13),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tu soporte, siempre disponible',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Canaliza solicitudes y mantén a tu equipo conectado.',
                  style: TextStyle(
                    color: Color(0xFFB1C4E8),
                    fontSize: 11,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: const Color(0xFF57D697),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF57D697).withValues(alpha: 0.8),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatures({
    required double width,
    required bool smallPhone,
    required bool phone,
    required bool tablet,
  }) {
    final features = [
      _FeatureData(
        icon: LucideIcons.headset,
        title: 'Crea y gestiona',
        subtitle: 'tus tickets',
      ),
      _FeatureData(
        icon: LucideIcons.file_search,
        title: 'Reporta problemas',
        subtitle: 'fácilmente',
      ),
      _FeatureData(
        icon: LucideIcons.trending_up,
        title: 'Sigue el progreso',
        subtitle: 'de tus solicitudes',
      ),
    ];

    if (phone) {
      return Column(
        children: features
            .map(
              (feature) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _FeatureCard(
                  data: feature,
                  compact: true,
                ),
              ),
            )
            .toList(),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _FeatureCard(
            data: features[0],
            compact: false,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _FeatureCard(
            data: features[1],
            compact: false,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _FeatureCard(
            data: features[2],
            compact: false,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1677FF),
          foregroundColor: Colors.white,
          elevation: 10,
          shadowColor: const Color(0xFF1677FF).withValues(alpha: 0.40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.log_in,
              size: 19,
            ),
            SizedBox(width: 10),
            Text(
              'INICIAR SESIÓN',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoreButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AboutScreen(),
            ),
          );
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: const Color(0xFF10234A).withValues(alpha: 0.45),
          side: BorderSide(
            color: const Color(0xFF75B2FF).withValues(alpha: 0.16),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.info,
              size: 18,
            ),
            SizedBox(width: 9),
            Text(
              'SABER MÁS',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityCard({
    required bool smallPhone,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        smallPhone ? 12 : 15,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0C1C3B).withValues(alpha: 0.94),
            const Color(0xFF122C5A).withValues(alpha: 0.72),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: const Color(0xFF4D9BFF).withValues(alpha: 0.18),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1677FF).withValues(alpha: 0.08),
            blurRadius: 24,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: smallPhone ? 42 : 48,
            height: smallPhone ? 42 : 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF1677FF).withValues(alpha: 0.18),
                  const Color(0xFF3D8BFF).withValues(alpha: 0.06),
                ],
              ),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              LucideIcons.shield_check,
              color: const Color(0xFF4A94FF),
              size: smallPhone ? 22 : 25,
            ),
          ),
          const SizedBox(width: 13),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Seguro, confiable y eficiente',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Soporte que impulsa tu productividad',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomeBackgroundPainter extends CustomPainter {
  const _WelcomeBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFF8EBBFF).withValues(alpha: 0.035)
      ..strokeWidth = 1;

    const gridSpacing = 34.0;

    for (double x = 0; x < size.width; x += gridSpacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        gridPaint,
      );
    }

    for (double y = 0; y < size.height; y += gridSpacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    final diagonalPaint = Paint()
      ..color = const Color(0xFF5B9EFF).withValues(alpha: 0.025)
      ..strokeWidth = 1.2;

    const diagonalSpacing = 90.0;

    for (double i = -size.height;
        i < size.width + size.height;
        i += diagonalSpacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        diagonalPaint,
      );
    }

    final centerGlowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF287DFF).withValues(alpha: 0.12),
          const Color(0xFF287DFF).withValues(alpha: 0.035),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.52, size.height * 0.38),
          radius: size.width * 0.75,
        ),
      );

    canvas.drawCircle(
      Offset(size.width * 0.52, size.height * 0.38),
      size.width * 0.75,
      centerGlowPaint,
    );

    final horizonPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          const Color(0xFF3B8EFF).withValues(alpha: 0.035),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromLTWH(
          0,
          size.height * 0.58,
          size.width,
          size.height * 0.22,
        ),
      );

    canvas.drawRect(
      Rect.fromLTWH(
        0,
        size.height * 0.58,
        size.width,
        size.height * 0.22,
      ),
      horizonPaint,
    );

    final dotPaint = Paint();

    final dots = [
      Offset(size.width * 0.08, size.height * 0.18),
      Offset(size.width * 0.18, size.height * 0.32),
      Offset(size.width * 0.82, size.height * 0.17),
      Offset(size.width * 0.91, size.height * 0.38),
      Offset(size.width * 0.72, size.height * 0.76),
      Offset(size.width * 0.12, size.height * 0.78),
      Offset(size.width * 0.88, size.height * 0.82),
      Offset(size.width * 0.38, size.height * 0.12),
    ];

    for (final dot in dots) {
      dotPaint
        ..color = const Color(0xFF5EA7FF).withValues(alpha: 0.12)
        ..maskFilter = const MaskFilter.blur(
          BlurStyle.normal,
          5,
        );

      canvas.drawCircle(dot, 3.5, dotPaint);

      dotPaint
        ..color = const Color(0xFF75B4FF).withValues(alpha: 0.28)
        ..maskFilter = null;

      canvas.drawCircle(dot, 1.2, dotPaint);
    }

    final bottomGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF1677FF).withValues(alpha:0.16),
          const Color(0xFF1677FF).withValues(alpha: 0.04),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.5, size.height * 1.08),
          radius: size.width * 0.8,
        ),
      );

    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 1.08),
      size.width * 0.8,
      bottomGlow,
    );
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) {
    return false;
  }
}

class _FeatureData {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FeatureData({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}

class _FeatureCard extends StatelessWidget {
  final _FeatureData data;
  final bool compact;

  const _FeatureCard({
    required this.data,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 9,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF102858).withValues(alpha: 0.72),
              const Color(0xFF0A1734).withValues(alpha: 0.78),
            ],
          ),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: const Color(0xFF4C9AFF).withValues(alpha: 0.15),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1677FF).withValues(alpha: 0.06),
              blurRadius: 18,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF1677FF).withValues(alpha: 0.18),
                    const Color(0xFF3D8BFF).withValues(alpha: 0.06),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                data.icon,
                color: const Color(0xFF4A94FF),
                size: 20,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    data.subtitle,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 10.5,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              LucideIcons.chevron_right,
              color: Colors.white.withValues(alpha: 0.25),
              size: 17,
            ),
          ],
        ),
      );
    }

    return Container(
      constraints: const BoxConstraints(
        minHeight: 125,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF102858).withValues(alpha: 0.72),
            const Color(0xFF0A1734).withValues(alpha: 0.78),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF3D8BFF).withValues(alpha: 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1677FF).withValues(alpha: 0.06),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF1677FF).withValues(alpha: 0.18),
                  const Color(0xFF3D8BFF).withValues(alpha: 0.06),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              data.icon,
              color: const Color(0xFF4A94FF),
              size: 21,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            data.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            data.subtitle,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
