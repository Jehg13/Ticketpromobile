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
      resizeToAvoidBottomInset: true,
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
              final double width = constraints.maxWidth;
              final double height = constraints.maxHeight;

              final bool smallPhone = width < 360;
              final bool phone = width < 600;
              final bool tablet = width >= 600;

              final bool shortScreen = height < 700;
              final bool veryShortScreen = height < 620;

              final double horizontalPadding = smallPhone
                  ? 16
                  : phone
                      ? 22
                      : 40;

              final double maxContentWidth =
                  tablet ? 560 : double.infinity;

              final double topPadding = veryShortScreen
                  ? 10
                  : shortScreen
                      ? 15
                      : 22;

              final double bottomSpacing =
                  veryShortScreen ? 15 : 25;

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: maxContentWidth,
                      ),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          topPadding,
                          horizontalPadding,
                          bottomSpacing,
                        ),
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment.start,
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Column(
                                children: [
                                  Text.rich(
                                    TextSpan(
                                      text: "TICKET",
                                      style: const TextStyle(
                                        fontSize: 32,
                                        color: Colors.blue,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                      children: const [
                                        TextSpan(
                                          text: "PRO",
                                          style: TextStyle(
                                            fontSize: 32,
                                            color: Colors.white,
                                            fontWeight:
                                                FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 3),

                                  const Text(
                                    "Soporte y ayuda",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white54,
                                      fontWeight:
                                          FontWeight.w500,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 25),

                            Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  LucideIcons
                                      .circle_question_mark,
                                  color: Color(0xFF4A94FF),
                                  size: 40,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: const [
                                      Text(
                                        "¿Necesitas ayuda?",
                                        style: TextStyle(
                                          fontSize: 24,
                                          color: Colors.white,
                                          fontWeight:
                                              FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        "Si tienes alguna duda contacta a nuestro equipo de soporte.",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color:
                                              Colors.blueGrey,
                                          height: 1.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 25),

                            Row(
                              children: const [
                                Icon(
                                  LucideIcons.headset,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "Contacta a soporte",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 15),

                            _buildContactCard(
                              icon: LucideIcons.mail,
                              title: "Correo electrónico",
                              description:
                                  "Envíanos un correo y te responderemos a la brevedad",
                              information:
                                  "soporte@cymez.com",
                              buttonText: "ENVIAR CORREO",
                              onPressed: _enviarCorreo,
                              accentColor: Colors.white,
                              buttonBackground:
                                  Colors.black,
                            ),

                            const SizedBox(height: 12),

                            _buildContactCard(
                              icon:
                                  LucideIcons.message_circle,
                              title: "WhatsApp",
                              description:
                                  "Escríbenos a whatsapp para una atención más rápida",
                              information:
                                  "(899) 123 4567",
                              buttonText:
                                  "MANDAR MENSAJE",
                              onPressed:
                                  _enviarWhatsApp,
                              accentColor:
                                  const Color(0xFF25D366),
                              buttonBackground:
                                  Colors.black,
                            ),

                            const SizedBox(height: 12),

                            _buildContactCard(
                              icon: LucideIcons.phone,
                              title: "Llamar al soporte",
                              description:
                                  "Llámanos directamente en nuestro horario de atención",
                              information:
                                  "(899) 123 4567",
                              buttonText:
                                  "LLAMAR AHORA",
                              onPressed: _llamar,
                              accentColor:
                                  const Color(0xFFA855F7),
                              buttonBackground:
                                  Colors.black,
                            ),

                            const SizedBox(height: 30),

                            Row(
                              children: const [
                                Icon(
                                  LucideIcons
                                      .circle_question_mark,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "Preguntas frecuentes",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 15),

                            _buildFaqItem(
                              question:
                                  "¿Cómo puedo dar seguimiento a un ticket?",
                              answer:
                                  "Puedes ingresar al menú de 'Mis Tickets' en la aplicación para ver el estado actual, comentarios y el técnico asignado en tiempo real.",
                            ),

                            _buildFaqItem(
                              question:
                                  "¿Cuánto tiempo se tarda en resolver un ticket?",
                              answer:
                                  "El tiempo varía según la prioridad: Alta (2-4 hrs), Media (24 hrs) y Baja (48 hrs hábiles).",
                            ),

                            _buildFaqItem(
                              question:
                                  "¿Cuáles son los horarios de soporte?",
                              answer:
                                  "Nuestro equipo atiende de Lunes a Viernes de 8:00 AM a 5:45 PM.",
                            ),

                            _buildFaqItem(
                              question:
                                  "¿Puedo actualizar mi evidencia?",
                              answer:
                                  "Sí, ingresa al detalle de tu ticket abierto y selecciona la opción 'Adjuntar archivo o imagen'.",
                            ),

                            _buildFaqItem(
                              question:
                                  "¿Qué información debo tener en mi reporte?",
                              answer:
                                  "Nombre del equipo afectado, descripción detallada de la falla y capturas de pantalla si es posible.",
                            ),

                            _buildFaqItem(
                              question:
                                  "¿Cómo sé si mi ticket está solucionado?",
                              answer:
                                  "Recibirás una notificación en la app y un correo informándote el cierre con la solución detallada.",
                            ),

                            const SizedBox(height: 25),

                            Container(
                              padding:
                                  const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF0D1B3E,
                                ).withOpacity(0.5),
                                borderRadius:
                                    BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(
                                    0xFF1E6FFF,
                                  ).withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding:
                                        const EdgeInsets.all(
                                            10),
                                    decoration:
                                        const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      LucideIcons.clock,
                                      color: Colors.black,
                                      size: 22,
                                    ),
                                  ),

                                  const SizedBox(width: 14),

                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,
                                      children: [
                                        Text(
                                          "Hora de atención",
                                          style: TextStyle(
                                            color:
                                                Colors.white,
                                            fontWeight:
                                                FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        SizedBox(height: 3),
                                        Text(
                                          "Lunes a Viernes de 8:00 AM a 17:45 PM",
                                          style: TextStyle(
                                            color:
                                                Colors.white70,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration:
                                            const BoxDecoration(
                                          color:
                                              Color(0xFF00FF66),
                                          shape:
                                              BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Text(
                                        "Estamos disponibles",
                                        style: TextStyle(
                                          color:
                                              Color(0xFF00FF66),
                                          fontSize: 11,
                                          fontWeight:
                                              FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 25),

                            const Center(
                              child: Text(
                                "© 2026 Cymez",
                                style: TextStyle(
                                  color: Colors.white30,
                                  fontSize: 11,
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
      ),
    );
  }

  Widget _buildFaqItem({
    required String question,
    required String answer,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1B3E).withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF1E6FFF).withOpacity(0.2),
        ),
      ),
      child: Theme(
        data: ThemeData(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          iconColor: const Color(0xFF2575FC),
          collapsedIconColor:
              const Color(0xFF2575FC),
          title: Text(
            question,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          children: [
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(
                16,
                0,
                16,
                14,
              ),
              child: Text(
                answer,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12.5,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
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
    required Color buttonBackground,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1B3E).withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accentColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.12),
                  borderRadius:
                      BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: accentColor,
                  size: 22,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 17,
                        color: accentColor,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white54,
                        height: 1.3,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      information,
                      style: TextStyle(
                        fontSize: 13,
                        color: accentColor,
                        fontWeight:
                            FontWeight.w600,
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
            height: 42,
            child: OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                backgroundColor:
                    buttonBackground,
                foregroundColor:
                    Colors.white,
                side: BorderSide(
                  color:
                      accentColor.withOpacity(0.60),
                  width: 1,
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(10),
                ),
              ),
              child: Text(
                buttonText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight:
                      FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}