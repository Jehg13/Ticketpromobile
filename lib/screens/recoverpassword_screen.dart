import 'package:flutter/material.dart';

import 'login_screen.dart';
import 'resetpassword_screen.dart';

class RecoverPasswordScreen extends StatelessWidget {
  const RecoverPasswordScreen({Key? key})
      : super(key: key ?? const Key('recover_password_screen'));

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF090C15);
    const cardBackgroundColor = Color(0xFF0F1527);
    const cardBorderColor = Color(0xFF1E2942);
    const primaryBlue = Color(0xFF1665FF);
    const iconContainerColor = Color(0xFF0C1D38);
    const iconBorderColor = Color(0xFF1E3A8A);
    const textColorMuted = Color(0xFF8E9BAE);
    const inputBorderColor = Color(0xFF1E3A8A);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 24,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: iconContainerColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: iconBorderColor,
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.lock_outline_rounded,
                    color: primaryBlue,
                    size: 26,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Recuperar contraseña',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Ingresa tu correo electrónico y te enviaremos instrucciones para recuperar tu contraseña.',
                  style: TextStyle(
                    color: textColorMuted,
                    fontSize: 13,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardBackgroundColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: cardBorderColor,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Correo electrónico',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'correo@ejemplo.com',
                          hintStyle: const TextStyle(
                            color: Color(0xFF475569),
                            fontSize: 14,
                          ),
                          prefixIcon: const Icon(
                            Icons.mail_outline,
                            color: textColorMuted,
                            size: 20,
                          ),
                          filled: true,
                          fillColor: backgroundColor,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: inputBorderColor,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: primaryBlue,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ResetPasswordScreen(),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.mail_outline,
                            size: 18,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Enviar enlace de recuperación',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: InkWell(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const LoginScreen(),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(6),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(
                                  Icons.arrow_back,
                                  size: 16,
                                  color: primaryBlue,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Volver al inicio de sesión',
                                  style: TextStyle(
                                    color: primaryBlue,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  '© 2026 TicketPro. Todos los derechos reservados.',
                  style: TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}