import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../services/session_service.dart';
import 'admin/home_screen.dart';
import 'user/home_screen.dart';
import 'welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _contentController;
  late AnimationController _ambientController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;

  late Animation<double> _contentOpacity;
  late Animation<Offset> _contentSlide;
  late Animation<double> _ambientScale;
  late Animation<double> _ambientOpacity;

  @override
  void initState() {
    super.initState();

    // ==========================================================
    // ANIMACIÓN DEL LOGO
    // ==========================================================

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 1200,
      ),
    );

    _logoScale = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOutBack,
    );

    _logoOpacity = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeIn,
    );

    // ==========================================================
    // ANIMACIÓN DEL CONTENIDO
    // ==========================================================

    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 900,
      ),
    );

    _contentOpacity = CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeIn,
    );

    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: Curves.easeOut,
      ),
    );

    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);

    _ambientScale = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _ambientController, curve: Curves.easeInOut),
    );

    _ambientOpacity = Tween<double>(begin: 0.45, end: 0.9).animate(
      CurvedAnimation(parent: _ambientController, curve: Curves.easeInOut),
    );

    // ==========================================================
    // INICIAR
    // ==========================================================

    _iniciarSplash();
  }

  Future<void> _iniciarSplash() async {
    _logoController.forward();

    await Future.delayed(
      const Duration(
        milliseconds: 400,
      ),
    );

    if (!mounted) return;

    _contentController.forward();

    await Future.delayed(
      const Duration(
        milliseconds: 2400,
      ),
    );

    if (!mounted) return;

    await _verificarSesion();
  }

  // ==========================================================
  // VERIFICAR SESIÓN
  // ==========================================================

Future<void> _verificarSesion() async {
  try {
    final bool tieneSesion = await SessionService.isLoggedIn();

    if (!mounted) return;

    if (tieneSesion) {
      final role = (await SessionService.getRole() ?? '')
          .toLowerCase()
          .replaceAll('á', 'a')
          .replaceAll('é', 'e')
          .replaceAll('í', 'i')
          .replaceAll('ó', 'o')
          .replaceAll('ú', 'u')
          .trim();

      final privAdmin = (await SessionService.getPrivAdmin() ?? '')
          .trim()
          .toUpperCase();

      if (!mounted) return;

      final destino =
          privAdmin == 'Y' &&
                  (role == 'gerente ti' || role == 'soporte tecnico')
              ? const AdminScreen()
              : const HomeScreen();

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (
            context,
            animation,
            secondaryAnimation,
          ) {
            return destino;
          },
          transitionsBuilder: (
            context,
            animation,
            secondaryAnimation,
            child,
          ) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(
            milliseconds: 500,
          ),
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (
            context,
            animation,
            secondaryAnimation,
          ) {
            return const WelcomeScreen();
          },
          transitionsBuilder: (
            context,
            animation,
            secondaryAnimation,
            child,
          ) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(
            milliseconds: 500,
          ),
        ),
      );
    }
  } catch (e) {
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const WelcomeScreen(),
      ),
    );
  }
}

  @override
  void dispose() {
    _logoController.dispose();
    _contentController.dispose();
    _ambientController.dispose();

    super.dispose();
  }

  // ==========================================================
  // LOGO
  // ==========================================================

  Widget _buildTicketLogo() {
    return SizedBox(
      width: 168,
      height: 168,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 168,
            height: 168,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              gradient: RadialGradient(colors: [const Color(0xFF426BFF).withValues(alpha: 0.24), Colors.transparent]),
            ),
          ),
          Container(
            width: 132,
            height: 132,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(colors: [Color(0xFF1D3477), Color(0xFF0D1634)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
              boxShadow: [BoxShadow(color: const Color(0xFF3B82F6).withValues(alpha: 0.38), blurRadius: 38, spreadRadius: 4)],
            ),
            child: Center(child: CustomPaint(size: const Size(78, 78), painter: _TicketLogoPainter())),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingPanel() {
    return Container(
      width: 244,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1531).withValues(alpha: 0.76),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.09)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 22, offset: const Offset(0, 10))],
      ),
      child: const Row(
        children: [
          SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4, valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5A8CFF)))),
          SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Preparando tu espacio', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)), SizedBox(height: 3), Text('Verificando sesión segura', style: TextStyle(color: Color(0xFF9EACC9), fontSize: 10))])),
        ],
      ),
    );
  }

  Widget _buildProductBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF132554).withValues(alpha: 0.74),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF75A1FF).withValues(alpha: 0.24)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_rounded, color: Color(0xFF78A4FF), size: 14),
          SizedBox(width: 7),
          Text('SOPORTE INTELIGENTE', style: TextStyle(color: Color(0xFFD8E4FF), fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1.05)),
        ],
      ),
    );
  }

  Widget _buildFloatingTicket({required IconData icon, required String label, required Alignment alignment, required double phase}) {
    return Align(
      alignment: alignment,
      child: AnimatedBuilder(
        animation: _ambientController,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, math.sin(phase + _ambientController.value * 12) * 7),
          child: Opacity(opacity: 0.56 + (_ambientController.value * 0.22), child: child),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF101D41).withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 16, offset: const Offset(0, 7))],
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, color: const Color(0xFF77A4FF), size: 14), const SizedBox(width: 6), Text(label, style: const TextStyle(color: Color(0xFFC9D6F3), fontSize: 9, fontWeight: FontWeight.w600))]),
        ),
      ),
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: Stack(
        children: [
          // ====================================================
          // FONDO
          // ====================================================

          Positioned.fill(
            child: CustomPaint(
              painter: _BackgroundPainter(),
            ),
          ),

          const Positioned.fill(
            child: IgnorePointer(child: CustomPaint(painter: _GridPainter())),
          ),

          Positioned(
            top: -100,
            right: -120,
            child: AnimatedBuilder(
              animation: _ambientController,
              builder: (context, child) => Opacity(
                opacity: _ambientOpacity.value,
                child: Transform.scale(scale: _ambientScale.value, child: child),
              ),
              child: Container(
                width: 310,
                height: 310,
                decoration: const BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [Color(0x664F7DFF), Colors.transparent])),
              ),
            ),
          ),

          Positioned.fill(
            child: IgnorePointer(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 140, 24, 140),
                child: _buildFloatingTicket(icon: Icons.bolt_rounded, label: 'Prioridad alta', alignment: const Alignment(-1.0, -0.32), phase: 0.4),
              ),
            ),
          ),

          Positioned.fill(
            child: IgnorePointer(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 140, 24, 140),
                child: _buildFloatingTicket(icon: Icons.check_circle_rounded, label: 'Todo en orden', alignment: const Alignment(1.0, 0.20), phase: 2.7),
              ),
            ),
          ),

          Positioned(
            bottom: 40,
            left: -130,
            child: AnimatedBuilder(
              animation: _ambientController,
              builder: (context, child) => Opacity(
                opacity: 1 - (_ambientOpacity.value * 0.55),
                child: Transform.scale(scale: 2 - _ambientScale.value, child: child),
              ),
              child: Container(
                width: 270,
                height: 270,
                decoration: const BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [Color(0x332F8DFF), Colors.transparent])),
              ),
            ),
          ),

          // ====================================================
          // CONTENIDO
          // ====================================================

          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                ),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    // ==================================================
                    // LOGO
                    // ==================================================

                    FadeTransition(opacity: _contentOpacity, child: _buildProductBadge()),

                    const SizedBox(height: 20),

                    ScaleTransition(
                      scale: _logoScale,
                      child: FadeTransition(
                        opacity: _logoOpacity,
                        child: _buildTicketLogo(),
                      ),
                    ),

                    const SizedBox(height: 26),

                    // ==================================================
                    // NOMBRE
                    // ==================================================

                    SlideTransition(
                      position: _contentSlide,
                      child: FadeTransition(
                        opacity: _contentOpacity,
                        child: Column(
                          children: [
                            RichText(
                              textAlign: TextAlign.center,
                              text: const TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Ticket',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 40,
                                      fontWeight:
                                          FontWeight.w800,
                                      letterSpacing: -1.5,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Pro',
                                    style: TextStyle(
                                      color: Color(
                                        0xFF4F63FF,
                                      ),
                                      fontSize: 40,
                                      fontWeight:
                                          FontWeight.w800,
                                      letterSpacing: -1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(
                              height: 8,
                            ),

                            const Text(
                              'Gestiona. Atiende. Soluciona.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(
                                  0xFFB8C0D9,
                                ),
                                fontSize: 14,
                                fontWeight:
                                    FontWeight.w400,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 52),

                    // ==================================================
                    // LOADING
                    // ==================================================

                    FadeTransition(opacity: _contentOpacity, child: _buildLoadingPanel()),
                  ],
                ),
              ),
            ),
          ),

          // ====================================================
          // VERSION
          // ====================================================

          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _contentOpacity,
              child: const Text(
                'TICKETPRO  •  SOPORTE INTERNO',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF6C7898),
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// PAINTER DEL LOGO
// ==================================================================

class _TicketLogoPainter extends CustomPainter {
  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final paint = Paint()
      ..color = const Color(0xFF4F63FF)
      ..style = PaintingStyle.fill;

    final double width = size.width;
    final double height = size.height;

    final Rect ticketRect = Rect.fromLTWH(
      5,
      12,
      width - 10,
      height - 24,
    );

    final Path ticketPath = Path();

    ticketPath.moveTo(
      ticketRect.left + 10,
      ticketRect.top,
    );

    ticketPath.lineTo(
      ticketRect.right - 10,
      ticketRect.top,
    );

    ticketPath.lineTo(
      ticketRect.right,
      ticketRect.top + 10,
    );

    ticketPath.lineTo(
      ticketRect.right,
      ticketRect.bottom - 10,
    );

    ticketPath.lineTo(
      ticketRect.right - 10,
      ticketRect.bottom,
    );

    ticketPath.lineTo(
      ticketRect.left + 10,
      ticketRect.bottom,
    );

    ticketPath.lineTo(
      ticketRect.left,
      ticketRect.bottom - 10,
    );

    ticketPath.lineTo(
      ticketRect.left,
      ticketRect.top + 10,
    );

    ticketPath.close();

    canvas.drawPath(
      ticketPath,
      paint,
    );

    // ==========================================================
    // MUESCA IZQUIERDA
    // ==========================================================

    final Paint notchPaint = Paint()
      ..color = const Color(0xFF101A3D)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(
        ticketRect.left,
        ticketRect.center.dy,
      ),
      7,
      notchPaint,
    );

    // ==========================================================
    // CHECK
    // ==========================================================

    final Paint checkPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final Path checkPath = Path();

    checkPath.moveTo(
      width * 0.27,
      height * 0.51,
    );

    checkPath.lineTo(
      width * 0.43,
      height * 0.67,
    );

    checkPath.lineTo(
      width * 0.76,
      height * 0.34,
    );

    canvas.drawPath(
      checkPath,
      checkPaint,
    );
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) {
    return false;
  }
}

class _GridPainter extends CustomPainter {
  const _GridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF91AEFF).withValues(alpha: 0.035)
      ..strokeWidth = 1;
    const spacing = 32.0;
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

// ==================================================================
// FONDO
// ==================================================================

class _BackgroundPainter extends CustomPainter {
  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final paint = Paint();

    // Gradiente superior
    paint.shader = const RadialGradient(
      center: Alignment.topCenter,
      radius: 1.2,
      colors: [
        Color(0xFF111B40),
        Color(0xFF0D1117),
      ],
    ).createShader(
      Rect.fromLTWH(
        0,
        0,
        size.width,
        size.height,
      ),
    );

    canvas.drawRect(
      Rect.fromLTWH(
        0,
        0,
        size.width,
        size.height,
      ),
      paint,
    );

    // ==========================================================
    // PUNTOS INFERIORES
    // ==========================================================

    final dotPaint = Paint()
      ..color = const Color(0xFF1C2A61);

    const double spacing = 18;

    for (double y = size.height - 140;
        y < size.height;
        y += spacing) {
      for (double x = 0;
          x < size.width;
          x += spacing) {
        final distanceFromBottom =
            size.height - y;

        final opacity =
            (distanceFromBottom / 140)
                .clamp(0.0, 1.0);

        dotPaint.color = Color.fromRGBO(
          59,
          91,
          255,
          opacity * 0.45,
        );

        canvas.drawCircle(
          Offset(x, y),
          1.2,
          dotPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) {
    return false;
  }
}
