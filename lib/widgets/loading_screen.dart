import 'dart:async';

import 'package:flutter/material.dart';

class LoadingScreen extends StatefulWidget {
  final String mensaje;

  const LoadingScreen({
    super.key,
    this.mensaje = 'Cargando...',
  });

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

Future<void> navigateWithLoading(
  BuildContext context,
  Widget destination, {
  String mensaje = 'Cargando sección...',
}) async {
  final navigator = Navigator.of(context);
  navigator.pushReplacement(
    MaterialPageRoute(builder: (_) => LoadingScreen(mensaje: mensaje)),
  );
  await Future<void>.delayed(const Duration(milliseconds: 650));
  if (!navigator.mounted) return;
  navigator.pushReplacement(
    MaterialPageRoute(builder: (_) => destination),
  );
}

class _LoadingScreenState extends State<LoadingScreen> {
  static const frases = [
    'Preparando tu espacio de trabajo...',
    'Cargando información segura...',
    'Conectando con TicketPro...',
    'Un momento, casi terminamos...',
  ];
  int frase = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 1800), (_) {
      if (mounted) setState(() => frase = (frase + 1) % frases.length);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050814),
      body: Stack(
        children: [
          Positioned(
            top: -120,
            right: -80,
            child: _glow(const Color(0xFF2563EB), 280),
          ),
          Positioned(
            bottom: -150,
            left: -100,
            child: _glow(const Color(0xFF0EA5E9), 300),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1D4ED8), Color(0xFF0F1535)],
                    ),
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(color: Colors.white24),
                    boxShadow: const [
                      BoxShadow(color: Color(0x552563EB), blurRadius: 30),
                    ],
                  ),
                  child: const Icon(
                    Icons.confirmation_number_outlined,
                    color: Color(0xFF93C5FD),
                    size: 48,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'TicketPro',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    letterSpacing: .4,
                  ),
                ),
                const SizedBox(height: 28),
                const SizedBox(
                  width: 34,
                  height: 34,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Color(0xFF60A5FA),
                  ),
                ),
                const SizedBox(height: 18),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  child: Text(
                    widget.mensaje == 'Cargando...' ? frases[frase] : widget.mensaje,
                    key: ValueKey('${widget.mensaje}-$frase'),
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _glow(Color color, double size) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: .12),
          boxShadow: [BoxShadow(color: color.withValues(alpha: .22), blurRadius: 90)],
        ),
      ),
    );
  }
}