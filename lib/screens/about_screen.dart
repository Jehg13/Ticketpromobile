import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _enviarCorreo() async {
    final Uri uri = Uri(
      scheme: 'mailto',
      path: 'soporte@cymez.com',
      queryParameters: {
        'subject': 'Solicitud de soporte TicketPro',
      },
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _enviarWhatsApp() async {
    final Uri uri = Uri.parse(
      'https://wa.me/52XXXXXXXXXX',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    }
  }

  Future<void> _llamar() async {
    final Uri uri = Uri(
      scheme: 'tel',
      path: '+52XXXXXXXXXX',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

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
        child: Stack(
          children: [
            const Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _AboutGridPainter(),
                ),
              ),
            ),
            Positioned(
              top: -120,
              right: -100,
              child: IgnorePointer(
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Color(0x553D8BFF),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -150,
              left: -110,
              child: IgnorePointer(
                child: Container(
                  width: 330,
                  height: 330,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Color(0x331677FF),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final double width = constraints.maxWidth;
                  final bool smallPhone = width < 360;
                  final bool phone = width < 600;
                  final bool tablet = width >= 600;

                  final double horizontalPadding = smallPhone
                      ? 16
                      : phone
                          ? 22
                          : 32;

                  final double contentWidth =
                      tablet ? 680 : width;

                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      18,
                      horizontalPadding,
                      28,
                    ),
                    child: Center(
                      child: SizedBox(
                        width: contentWidth,
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            _buildHeader(
                              smallPhone: smallPhone,
                            ),
                            const SizedBox(height: 28),
                            _buildHero(
                              smallPhone: smallPhone,
                            ),
                            const SizedBox(height: 24),
                            _buildSectionTitle(
                              icon: LucideIcons.headset,
                              title: 'Contacta a soporte',
                              subtitle:
                                  'Elige el canal que prefieras para recibir atención.',
                            ),
                            const SizedBox(height: 14),
                            _buildContactCard(
                              icon: LucideIcons.mail,
                              title: 'Correo electrónico',
                              description:
                                  'Envíanos un correo y nuestro equipo te responderá a la brevedad.',
                              information:
                                  'soporte@cymez.com',
                              buttonText: 'ENVIAR CORREO',
                              onPressed: _enviarCorreo,
                              accentColor:
                                  const Color(0xFF4A94FF),
                            ),
                            const SizedBox(height: 12),
                            _buildContactCard(
                              icon:
                                  LucideIcons.message_circle,
                              title: 'WhatsApp',
                              description:
                                  'Escríbenos para recibir una atención rápida y directa.',
                              information:
                                  '(899) 123 4567',
                              buttonText: 'MANDAR MENSAJE',
                              onPressed: _enviarWhatsApp,
                              accentColor:
                                  const Color(0xFF25D366),
                            ),
                            const SizedBox(height: 12),
                            _buildContactCard(
                              icon: LucideIcons.phone,
                              title: 'Llamar al soporte',
                              description:
                                  'Comunícate directamente con nuestro equipo durante el horario de atención.',
                              information:
                                  '(899) 123 4567',
                              buttonText: 'LLAMAR AHORA',
                              onPressed: _llamar,
                              accentColor:
                                  const Color(0xFFA855F7),
                            ),
                            const SizedBox(height: 30),
                            _buildSectionTitle(
                              icon: LucideIcons.circle_question_mark,
                              title: 'Preguntas frecuentes',
                              subtitle:
                                  'Encuentra respuestas rápidas a las dudas más comunes.',
                            ),
                            const SizedBox(height: 14),
                            _buildFaqItem(
                              question:
                                  '¿Cómo puedo dar seguimiento a un ticket?',
                              answer:
                                  'Puedes ingresar al menú de Mis Tickets en la aplicación para consultar el estado actual, comentarios y técnico asignado.',
                            ),
                            _buildFaqItem(
                              question:
                                  '¿Cuánto tiempo se tarda en resolver un ticket?',
                              answer:
                                  'El tiempo depende de la prioridad: Alta (2-4 hrs), Media (24 hrs) y Baja (48 hrs hábiles).',
                            ),
                            _buildFaqItem(
                              question:
                                  '¿Cuáles son los horarios de soporte?',
                              answer:
                                  'Nuestro equipo atiende de lunes a viernes de 8:00 AM a 5:45 PM.',
                            ),
                            _buildFaqItem(
                              question:
                                  '¿Puedo actualizar mi evidencia?',
                              answer:
                                  'Sí. Ingresa al detalle de tu ticket abierto y selecciona la opción Adjuntar archivo o imagen.',
                            ),
                            _buildFaqItem(
                              question:
                                  '¿Qué información debo tener en mi reporte?',
                              answer:
                                  'Incluye el nombre del equipo afectado, una descripción detallada de la falla y capturas de pantalla cuando sea posible.',
                            ),
                            _buildFaqItem(
                              question:
                                  '¿Cómo sé si mi ticket está solucionado?',
                              answer:
                                  'Recibirás una notificación en la aplicación y un correo informándote el cierre junto con la solución aplicada.',
                            ),
                            const SizedBox(height: 20),
                            _buildSupportHours(
                              smallPhone: smallPhone,
                            ),
                            const SizedBox(height: 26),
                            Center(
                              child: Text(
                                '© 2026 Cymez',
                                style: TextStyle(
                                  color:
                                      Colors.white.withValues(alpha: 0.32),
                                  fontSize: 10,
                                  fontWeight:
                                      FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
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

  Widget _buildHeader({
    required bool smallPhone,
  }) {
    return Row(
      children: [
        Container(
          width: smallPhone ? 42 : 46,
          height: smallPhone ? 42 : 46,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF4A94FF),
                Color(0xFF1C54B8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.16),
            ),
            boxShadow: [
              BoxShadow(
                color:
                    const Color(0xFF1677FF).withValues(alpha: 0.28),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            LucideIcons.ticket_check,
            color: Colors.white,
            size: smallPhone ? 21 : 23,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  text: 'TICKET',
                  style: TextStyle(
                    color: const Color(0xFF3D8BFF),
                    fontSize: smallPhone ? 22 : 25,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                  children: const [
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
              const SizedBox(height: 2),
              Text(
                'Soporte y ayuda',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.48),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF102653)
                .withValues(alpha: 0.62),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color:
                  const Color(0xFF75A1FF).withValues(alpha:0.16),
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                LucideIcons.shield_check,
                color: Color(0xFF70A5FF),
                size: 13,
              ),
              SizedBox(width: 5),
              Text(
                'SEGURO',
                style: TextStyle(
                  color: Color(0xFFD8E4FF),
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHero({
    required bool smallPhone,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        smallPhone ? 18 : 22,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF11285A).withValues(alpha: 0.82),
            const Color(0xFF0B1733).withValues(alpha: 0.78),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color:
              const Color(0xFF4A94FF).withValues(alpha:0.18),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.20),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: smallPhone ? 50 : 56,
            height: smallPhone ? 50 : 56,
            decoration: BoxDecoration(
              color:
                  const Color(0xFF1677FF).withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color:
                    const Color(0xFF4A94FF).withValues(alpha:0.12),
              ),
            ),
            child: Icon(
              LucideIcons.circle_question_mark,
              color: const Color(0xFF69A4FF),
              size: smallPhone ? 25 : 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  '¿Necesitas ayuda?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: smallPhone ? 21 : 24,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  'Estamos aquí para ayudarte. Consulta las preguntas frecuentes o contacta directamente con nuestro equipo de soporte.',
                  style: TextStyle(
                    color: const Color(0xFFB1C4E8),
                    fontSize: smallPhone ? 11.5 : 12.5,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color:
                const Color(0xFF1677FF).withValues(alpha: 0.11),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF69A4FF),
            size: 19,
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String description,
    required String information,
    required String buttonText,
    required VoidCallback onPressed,
    required Color accentColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0D1B3E).withValues(alpha: 0.76),
            const Color(0xFF09152F).withValues(alpha: 0.82),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.18),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.13),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.11),
                  borderRadius:
                      BorderRadius.circular(14),
                  border: Border.all(
                    color:
                        accentColor.withValues(alpha: 0.10),
                  ),
                ),
                child: Icon(
                  icon,
                  color: accentColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      information,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.86),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 43,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    accentColor.withValues(alpha: 0.12),
                foregroundColor: Colors.white,
                elevation: 0,
                side: BorderSide(
                  color: accentColor.withValues(alpha: 0.32),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 16,
                    color: accentColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    buttonText,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem({
    required String question,
    required String answer,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0D1B3E).withValues(alpha: 0.70),
            const Color(0xFF09152F).withValues(alpha: 0.70),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              const Color(0xFF3D8BFF).withValues(alpha: 0.13),
        ),
      ),
      child: Theme(
        data: ThemeData(
          splashColor:
              const Color(0xFF3D8BFF).withValues(alpha: 0.05),
          highlightColor:
              const Color(0xFF3D8BFF).withValues(alpha: 0.04),
          dividerColor: Colors.transparent,
          expansionTileTheme:
              const ExpansionTileThemeData(
            tilePadding:
                EdgeInsets.symmetric(horizontal: 15),
            childrenPadding: EdgeInsets.zero,
          ),
        ),
        child: ExpansionTile(
          iconColor: const Color(0xFF69A4FF),
          collapsedIconColor:
              Colors.white.withValues(alpha: 0.35),
          tilePadding:
              const EdgeInsets.symmetric(horizontal: 15),
          childrenPadding: EdgeInsets.zero,
          title: Text(
            question,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(
                15,
                0,
                15,
                15,
              ),
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color:
                    const Color(0xFF1677FF).withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF3D8BFF)
                      .withValues(alpha: 0.08),
                ),
              ),
              child: Text(
                answer,
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 11.5,
                  height: 1.45,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportHours({
    required bool smallPhone,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        smallPhone ? 14 : 16,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF11285A).withValues(alpha: 0.78),
            const Color(0xFF0B1733).withValues(alpha: 0.88),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color:
              const Color(0xFF3D8BFF).withValues(alpha: 0.16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: smallPhone ? 44 : 48,
            height: smallPhone ? 44 : 48,
            decoration: BoxDecoration(
              color:
                  const Color(0xFF1677FF).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              LucideIcons.clock_3,
              color: const Color(0xFF69A4FF),
              size: smallPhone ? 22 : 24,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Horario de atención',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Lunes a Viernes · 8:00 AM a 5:45 PM',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color:
                  const Color(0xFF57D697).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color:
                    const Color(0xFF57D697).withValues(alpha: 0.18),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 7,
                  height: 7,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Color(0xFF57D697),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                SizedBox(width: 6),
                Text(
                  'ACTIVO',
                  style: TextStyle(
                    color: Color(0xFF57D697),
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
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

class _AboutGridPainter extends CustomPainter {
  const _AboutGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF91B7FF).withValues(alpha: 0.035)
      ..strokeWidth = 1;

    const double spacing = 34;

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) {
    return false;
  }
}
