import 'package:flutter/material.dart';

import '../services/session_service.dart';
import 'login_screen.dart';
import 'admin/home_screen.dart';

class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key, this.message, this.canAccessAdmin = false});

  final String? message;
  final bool canAccessAdmin;

  Future<void> _logout(BuildContext context) async {
    await SessionService.clearSession();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050814),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(top: -100, left: -90, child: _glow(const Color(0xFF2563EB), 260)),
            Positioned(bottom: -130, right: -100, child: _glow(const Color(0xFF06B6D4), 300)),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(
                    20,
                    26,
                    20,
                    22 + MediaQuery.of(context).padding.bottom,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xF20B1026),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: const Color(0xFF60A5FA).withValues(alpha: 0.22)),
                    boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 35, offset: Offset(0, 18))],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0x402563EB), Color(0x1A06B6D4)]),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: const Color(0x3360A5FA)),
                        ),
                        child: const Icon(Icons.build_circle_outlined, size: 62, color: Color(0xFF93C5FD)),
                      ),
                      const SizedBox(height: 22),
                      const Text('TICKETPRO', style: TextStyle(color: Color(0xFF93C5FD), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 4)),
                      const SizedBox(height: 10),
                      const Text('Estamos en\nmantenimiento', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 26, height: 1.12, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 18),
                      Container(height: 2, width: 52, color: const Color(0xFF60A5FA)),
                      const SizedBox(height: 18),
                      Text(
                        message?.trim().isNotEmpty == true ? message! : 'Estamos realizando mejoras. Intenta nuevamente más tarde.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70, height: 1.55, fontSize: 14),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(color: const Color(0x142563EB), borderRadius: BorderRadius.circular(14)),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.schedule_rounded, size: 17, color: Color(0xFF93C5FD)),
                            SizedBox(width: 8),
                            Flexible(child: Text('Trabajamos para volver lo antes posible.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFBFDBFE), fontSize: 11))),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      if (canAccessAdmin)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const AdminScreen())),
                              icon: const Icon(Icons.admin_panel_settings_outlined),
                              label: const Text('Ir al panel administrativo'),
                              style: FilledButton.styleFrom(backgroundColor: const Color(0xFF2563EB), padding: const EdgeInsets.symmetric(vertical: 14)),
                            ),
                          ),
                        ),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _logout(context),
                          icon: const Icon(Icons.logout),
                          label: const Text('Cerrar sesión'),
                          style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Color(0xFF60A5FA)), padding: const EdgeInsets.symmetric(vertical: 14)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text('SOPORTE TECNICO CYMEZ', style: TextStyle(color: Colors.white38, fontSize: 9, letterSpacing: 2)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _glow(Color color, double size) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.12)),
      ),
    );
  }
}
