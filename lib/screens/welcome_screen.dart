import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'login_screen.dart';
import 'about_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070B18),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 0, 47, 122),
              Color(0xFF123B82),
              Color(0xFF0D1630),
              Color(0xFF070B18),
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            stops: [0.0, 0.25, 0.65, 1.0],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final bool smallPhone = width < 360;
              final bool phone = width < 600;
              final bool tablet = width >= 600;
              final double horizontalPadding = smallPhone
                  ? 18
                  : phone
                  ? 22
                  : 40;
              final double titleSize = smallPhone
                  ? 42
                  : phone
                  ? 54
                  : 66;
              final double descriptionSize = smallPhone
                  ? 12
                  : phone
                  ? 13.5
                  : 16;
              final double topSpacing = smallPhone
                  ? 28
                  : phone
                  ? 38
                  : 55;
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: tablet ? 760 : double.infinity,
                    ),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        22,
                        horizontalPadding,
                        24,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLogo(),
                          SizedBox(height: phone ? 30 : 40),
                          _buildSupportLabel(),
                          SizedBox(height: topSpacing),
                          Text(
                            'Bienvenido a',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: titleSize,
                              fontWeight: FontWeight.w800,
                              height: 0.98,
                              letterSpacing: -1.5,
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
                            ),
                          ),
                          SizedBox(height: phone ? 18 : 22),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 650),
                            child: Text(
                              'La plataforma de gestión de tickets interna '
                              'que conecta equipos, departamentos y '
                              'ubicaciones para resolver lo que importa.',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.68),
                                fontSize: descriptionSize,
                                height: 1.55,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          SizedBox(height: phone ? 30 : 42),
                          _buildFeatures(
                            width: width,
                            smallPhone: smallPhone,
                            phone: phone,
                            tablet: tablet,
                          ),
                          SizedBox(height: phone ? 30 : 42),
                          _buildLoginButton(context),
                          const SizedBox(height: 12),
                          _buildMoreButton(context),
                          SizedBox(height: phone ? 24 : 32),
                          _buildSecurityCard(smallPhone: smallPhone),
                          const SizedBox(height: 24),
                          Center(
                            child: Text(
                              '© 2026 Cymez',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.32),
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(width: 9),
        Text.rich(
          const TextSpan(
            text: 'TICKET',
            style: TextStyle(
              color: Color(0xFF3D8BFF),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.035),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: Color(0xFF3D8BFF),
              shape: BoxShape.circle,
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
                padding: const EdgeInsets.only(bottom: 10),
                child: _FeatureCard(data: feature, compact: true),
              ),
            )
            .toList(),
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _FeatureCard(data: features[0], compact: false)),
        const SizedBox(width: 12),
        Expanded(child: _FeatureCard(data: features[1], compact: false)),
        const SizedBox(width: 12),
        Expanded(child: _FeatureCard(data: features[2], compact: false)),
      ],
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1677FF),
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: const Color(0xFF1677FF).withOpacity(0.28),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(LucideIcons.log_in, size: 19),
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
      height: 52,
      child: OutlinedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AboutScreen()),
          );
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.white.withOpacity(0.035),
          side: BorderSide(color: Colors.white.withOpacity(0.12)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(LucideIcons.info, size: 18),
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

  Widget _buildSecurityCard({required bool smallPhone}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(smallPhone ? 14 : 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0B1733).withOpacity(0.95),
            const Color(0xFF102653).withOpacity(0.70),
          ],
        ),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFF3D8BFF).withOpacity(0.16)),
      ),
      child: Row(
        children: [
          Container(
            width: smallPhone ? 44 : 48,
            height: smallPhone ? 44 : 48,
            decoration: BoxDecoration(
              color: const Color(0xFF1677FF).withOpacity(0.11),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              LucideIcons.shield_check,
              color: const Color(0xFF4A94FF),
              size: smallPhone ? 23 : 25,
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
  const _FeatureCard({required this.data, required this.compact});
  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: const Color(0xFF0D1B3E).withOpacity(0.72),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFF3D8BFF).withOpacity(0.13)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFF1677FF).withOpacity(0.11),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(data.icon, color: const Color(0xFF4A94FF), size: 21),
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
              color: Colors.white.withOpacity(0.25),
              size: 17,
            ),
          ],
        ),
      );
    }
    return Container(
      constraints: const BoxConstraints(minHeight: 135),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1B3E).withOpacity(0.72),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF3D8BFF).withOpacity(0.14)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF1677FF).withOpacity(0.11),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(data.icon, color: const Color(0xFF4A94FF), size: 22),
          ),
          const SizedBox(height: 10),
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
            style: const TextStyle(color: Colors.white54, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
