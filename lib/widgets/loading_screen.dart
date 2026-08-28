import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  final String mensaje;

  const LoadingScreen({
    super.key,
    this.mensaje = 'Cargando...',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050814),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF0F1535),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.confirmation_number_outlined,
                color: Color(0xFF3B82F6),
                size: 45,
              ),
            ),

            const SizedBox(height: 25),

            // Indicador
            const SizedBox(
              width: 35,
              height: 35,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: Color(0xFF3B82F6),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              mensaje,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}