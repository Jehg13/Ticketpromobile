import 'package:flutter/material.dart';

import 'login_screen.dart';
import 'recoverpassword_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({Key? key})
      : super(key: key ?? const Key('reset_password_screen'));

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _emailController =
      TextEditingController(text: 'jefehi13@gmail.com');
  final TextEditingController _passwordController =
      TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF090C15);
    const cardBackgroundColor = Color(0xFF0F1527);
    const cardBorderColor = Color(0xFF1E2942);
    const primaryBlue = Color(0xFF2563EB);
    const buttonColor = Color(0xFF1E293B);
    const iconContainerColor = Color(0xFF0C1D38);
    const iconBorderColor = Color(0xFF1E3A8A);
    const textColorMuted = Color(0xFF64748B);
    const textColorSubtle = Color(0xFF94A3B8);
    const inputBorderColor = Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 24.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  child: RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: 'TICKET',
                          style: TextStyle(
                            color: primaryBlue,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        TextSpan(
                          text: 'PRO',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Sistema de soporte',
                  style: TextStyle(
                    color: textColorMuted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20.0),
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
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: iconContainerColor,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: iconBorderColor,
                                width: 1.5,
                              ),
                            ),
                            child: const Icon(
                              Icons.lock_outline_rounded,
                              color: primaryBlue,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'SEGURIDAD DE CUENTA',
                                  style: TextStyle(
                                    color: primaryBlue,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Nueva contraseña',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(
                        color: cardBorderColor,
                        height: 1,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Crea una nueva contraseña para recuperar el acceso a tu cuenta de TicketPro.',
                        style: TextStyle(
                          color: textColorSubtle,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildLabel('CORREO ELECTRÓNICO'),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _emailController,
                        readOnly: true,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                        decoration: _buildInputDecoration(
                          hintText: '',
                          icon: Icons.mail_outline,
                          inputBorderColor: inputBorderColor,
                          textColorMuted: textColorMuted,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildLabel('NUEVA CONTRASEÑA'),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                        decoration: _buildInputDecoration(
                          hintText: 'Ingresa tu nueva contraseña',
                          icon: Icons.lock_outline,
                          inputBorderColor: inputBorderColor,
                          textColorMuted: textColorMuted,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildLabel('CONFIRMAR CONTRASEÑA'),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                        decoration: _buildInputDecoration(
                          hintText: 'Repite tu nueva contraseña',
                          icon: Icons.verified_user_outlined,
                          inputBorderColor: inputBorderColor,
                          textColorMuted: textColorMuted,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: inputBorderColor,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Requisitos de seguridad',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildRequirementItem(
                              'Mínimo 8 caracteres',
                            ),
                            _buildRequirementItem(
                              'Una letra mayúscula',
                            ),
                            _buildRequirementItem(
                              'Una letra minúscula',
                            ),
                            _buildRequirementItem(
                              'Un número',
                            ),
                            _buildRequirementItem(
                              'Un símbolo especial (! @ # \$ % &)',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const RecoverPasswordScreen(),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.check,
                            size: 18,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Restablecer contraseña',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: buttonColor,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(
                                color: Color(0xFF334155),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
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
                                    fontSize: 13,
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
                const SizedBox(height: 24),
                const Text(
                  '© 2026 TicketPro\nEste proceso está protegido y es confidencial.',
                  style: TextStyle(
                    color: textColorMuted,
                    fontSize: 11,
                    height: 1.4,
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

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF94A3B8),
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    required IconData icon,
    required Color inputBorderColor,
    required Color textColorMuted,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: textColorMuted.withOpacity(0.6),
        fontSize: 13,
      ),
      prefixIcon: Icon(
        icon,
        color: textColorMuted,
        size: 18,
      ),
      filled: true,
      fillColor: const Color(0xFF090C15),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 12,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: inputBorderColor,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: Color(0xFF2563EB),
          width: 1.5,
        ),
      ),
    );
  }

  Widget _buildRequirementItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF475569),
                width: 1.5,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
