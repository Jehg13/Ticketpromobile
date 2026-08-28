import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../services/api_service.dart';
import '../services/session_service.dart';
import 'user/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usuarioController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  bool recordarUsuario = false;
  bool mostrarPassword = false;
  bool iniciandoSesion = false;

  @override
  void dispose() {
    usuarioController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> iniciarSesion() async {
    if (iniciandoSesion) return;

    final String usuario = usuarioController.text.trim();
    final String password = passwordController.text;

    if (usuario.isEmpty) {
      mostrarMensaje(
        'Ingresa tu usuario o correo electrónico.',
      );
      return;
    }

    if (password.isEmpty) {
      mostrarMensaje(
        'Ingresa tu contraseña.',
      );
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      iniciandoSesion = true;
    });

    try {
      final resultado = await ApiService.login(
        usuario: usuario,
        password: password,
        remember: recordarUsuario,
      );

      if (!mounted) return;

      final bool success =
          resultado['success'] == true;

      final bool mfaRequired =
          resultado['mfa_required'] == true;

      if (!success) {
        mostrarMensaje(
          resultado['message']?.toString() ??
              'No fue posible iniciar sesión.',
        );
        return;
      }

      if (mfaRequired) {
        mostrarMensaje(
          'Se requiere verificación de autenticación.',
        );
        return;
      }

      final String? token =
          resultado['token']?.toString();

      if (token == null || token.isEmpty) {
        mostrarMensaje(
          'El servidor no devolvió un token de acceso.',
        );
        return;
      }

      final dynamic usuarioDatos =
          resultado['user'];

      if (usuarioDatos is! Map<String, dynamic>) {
        mostrarMensaje(
          'No se recibieron los datos del usuario.',
        );
        return;
      }

      await SessionService.saveSession(
        token: token,
        user: usuarioDatos,
      );

      final String role =
          usuarioDatos['role']
                  ?.toString()
                  .trim() ??
              '';

      final String privAdmin =
          usuarioDatos['priv_admin']
                  ?.toString()
                  .trim()
                  .toUpperCase() ??
              'N';

      final String rolNormalizado = role
          .toLowerCase()
          .replaceAll('á', 'a')
          .replaceAll('é', 'e')
          .replaceAll('í', 'i')
          .replaceAll('ó', 'o')
          .replaceAll('ú', 'u');

      final bool rolPermitido =
          rolNormalizado == 'gerente ti' ||
          rolNormalizado == 'soporte tecnico';

      final bool accesoAdministrativo =
          rolPermitido && privAdmin == 'Y';

      if (accesoAdministrativo) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const AdminScreen(),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      mostrarMensaje(
        'No se pudo conectar con el servidor.',
      );
    } finally {
      if (mounted) {
        setState(() {
          iniciandoSesion = false;
        });
      }
    }
  }

  void mostrarMensaje(String mensaje) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(mensaje),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF16213E),
          margin: const EdgeInsets.all(14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFF050814),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF001F56),
              Color(0xFF082B67),
              Color(0xFF0B1D45),
              Color(0xFF070B18),
              Color(0xFF050814),
            ],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            stops: [
              0.0,
              0.22,
              0.48,
              0.76,
              1.0,
            ],
          ),
        ),
        child: Stack(
          children: [
            const Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _LoginGridPainter(),
                ),
              ),
            ),
            Positioned(
              top: -160,
              right: -120,
              child: IgnorePointer(
                child: Container(
                  width: 380,
                  height: 380,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Color(0x663D8BFF),
                        Color(0x183D8BFF),
                        Colors.transparent,
                      ],
                      stops: [
                        0.0,
                        0.45,
                        1.0,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -180,
              left: -140,
              child: IgnorePointer(
                child: Container(
                  width: 400,
                  height: 400,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Color(0x442E7BFF),
                        Color(0x142E7BFF),
                        Colors.transparent,
                      ],
                      stops: [
                        0.0,
                        0.45,
                        1.0,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 260,
              left: -120,
              child: IgnorePointer(
                child: Container(
                  width: 240,
                  height: 240,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Color(0x222F7DFF),
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
                  final double width =
                      constraints.maxWidth;

                  final double height =
                      constraints.maxHeight;

                  final bool smallPhone =
                      width < 360;

                  final bool phone =
                      width < 600;

                  final bool tablet =
                      width >= 600;

                  final bool shortScreen =
                      height < 700;

                  final bool veryShortScreen =
                      height < 620;

                  final double horizontalPadding =
                      smallPhone
                          ? 12
                          : phone
                              ? 18
                              : 28;

                  final double titleSize =
                      smallPhone
                          ? 27
                          : phone
                              ? 32
                              : 40;

                  final double contentWidth =
                      tablet ? 560 : width;

                  final double topPadding =
                      veryShortScreen
                          ? 8
                          : shortScreen
                              ? 12
                              : 18;

                  final double logoSpacing =
                      veryShortScreen
                          ? 14
                          : shortScreen
                              ? 19
                              : 27;

                  final double formSpacing =
                      veryShortScreen
                          ? 15
                          : shortScreen
                              ? 20
                              : 26;

                  return SizedBox(
                    width: width,
                    height: height,
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: contentWidth,
                          child: Padding(
                            padding:
                                EdgeInsets.fromLTRB(
                              horizontalPadding,
                              topPadding,
                              horizontalPadding,
                              veryShortScreen
                                  ? 8
                                  : 14,
                            ),
                            child: Column(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              crossAxisAlignment:
                                  CrossAxisAlignment.center,
                              children: [
                                _buildAccessPill(),
                                SizedBox(
                                  height:
                                      veryShortScreen
                                          ? 10
                                          : 14,
                                ),
                                _buildLogo(
                                  smallPhone:
                                      smallPhone,
                                ),
                                SizedBox(
                                  height:
                                      logoSpacing,
                                ),
                                Text(
                                  'Bienvenido de Nuevo',
                                  textAlign:
                                      TextAlign.center,
                                  style: TextStyle(
                                    fontSize:
                                        titleSize,
                                    color: Colors.white,
                                    fontWeight:
                                        FontWeight.w800,
                                    letterSpacing:
                                        -0.8,
                                    height: 1.05,
                                  ),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  'Inicia sesión para gestionar y dar '
                                  'seguimiento a tus tickets',
                                  textAlign:
                                      TextAlign.center,
                                  style: TextStyle(
                                    fontSize:
                                        smallPhone
                                            ? 12.5
                                            : 14,
                                    color: Colors.white
                                        .withOpacity(0.55),
                                    height: 1.4,
                                    letterSpacing:
                                        0.1,
                                  ),
                                ),
                                SizedBox(
                                  height:
                                      formSpacing,
                                ),
                                _buildFormCard(
                                  smallPhone:
                                      smallPhone,
                                  shortScreen:
                                      shortScreen,
                                ),
                                SizedBox(
                                  height:
                                      veryShortScreen
                                          ? 14
                                          : 20,
                                ),
                                _buildCorporateAccessDivider(),
                                SizedBox(
                                  height:
                                      veryShortScreen
                                          ? 14
                                          : 18,
                                ),
                                _buildLoginButton(
                                  smallPhone:
                                      smallPhone,
                                ),
                                SizedBox(
                                  height:
                                      veryShortScreen
                                          ? 12
                                          : 17,
                                ),
                                _buildSecurityCard(
                                  smallPhone:
                                      smallPhone,
                                ),
                                SizedBox(
                                  height:
                                      veryShortScreen
                                          ? 10
                                          : 17,
                                ),
                                const Text(
                                  '© 2026 Cymez',
                                  style: TextStyle(
                                    color:
                                        Colors.white30,
                                    fontSize: 10,
                                    fontWeight:
                                        FontWeight.w400,
                                    letterSpacing:
                                        0.2,
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

  Widget _buildLogo({
    required bool smallPhone,
  }) {
    final double logoTextSize =
        smallPhone ? 31 : 37;

    return Column(
      children: [
        Container(
          width: smallPhone ? 48 : 55,
          height: smallPhone ? 48 : 55,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF4A94FF),
                Color(0xFF174FAE),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius:
                BorderRadius.circular(17),
            border: Border.all(
              color: Colors.white.withOpacity(0.18),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1677FF)
                    .withOpacity(0.34),
                blurRadius: 24,
                spreadRadius: 1,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: const Color(0xFF1677FF)
                    .withOpacity(0.10),
                blurRadius: 45,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Icon(
            LucideIcons.ticket_check,
            color: Colors.white,
            size: smallPhone ? 24 : 28,
          ),
        ),
        const SizedBox(height: 10),
        Text.rich(
          TextSpan(
            text: 'TICKET',
            style: TextStyle(
              color: const Color(0xFF4A94FF),
              fontSize: logoTextSize,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              height: 1,
            ),
            children: [
              TextSpan(
                text: 'PRO',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: logoTextSize,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'Plataforma de soporte interno',
          style: TextStyle(
            fontSize: smallPhone ? 11 : 12,
            color: Colors.white.withOpacity(0.35),
            letterSpacing: 0.6,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAccessPill() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF102653)
            .withOpacity(0.58),
        borderRadius:
            BorderRadius.circular(30),
        border: Border.all(
          color: const Color(0xFF75A1FF)
              .withOpacity(0.18),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1677FF)
                .withOpacity(0.08),
            blurRadius: 18,
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            LucideIcons.shield_check,
            color: Color(0xFF70A5FF),
            size: 14,
          ),
          SizedBox(width: 7),
          Text(
            'ACCESO SEGURO',
            style: TextStyle(
              color: Color(0xFFD8E4FF),
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard({
    required bool smallPhone,
    required bool shortScreen,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        smallPhone ? 14 : 18,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF142E62)
                .withOpacity(0.72),
            const Color(0xFF09152F)
                .withOpacity(0.86),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius:
            BorderRadius.circular(23),
        border: Border.all(
          color: const Color(0xFF75A1FF)
              .withOpacity(0.16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 35,
            spreadRadius: -5,
            offset: const Offset(0, 18),
          ),
          BoxShadow(
            color: const Color(0xFF1677FF)
                .withOpacity(0.07),
            blurRadius: 35,
            spreadRadius: -10,
          ),
        ],
      ),
      child: _buildFormulario(
        smallPhone: smallPhone,
        shortScreen: shortScreen,
      ),
    );
  }

  Widget _buildFormulario({
    required bool smallPhone,
    required bool shortScreen,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'Usuario o correo electrónico',
          style: TextStyle(
            fontSize: 13,
            color: Colors.white,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
        const SizedBox(height: 8),
        _buildTextField(
          controller: usuarioController,
          hint: 'Ingresa tu usuario o correo',
          icon: LucideIcons.user,
          enabled: !iniciandoSesion,
          keyboardType: TextInputType.text,
          textInputAction:
              TextInputAction.next,
        ),
        const SizedBox(height: 15),
        const Text(
          'Contraseña',
          style: TextStyle(
            fontSize: 13,
            color: Colors.white,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
        const SizedBox(height: 8),
        _buildPasswordField(),
        SizedBox(
          height: shortScreen ? 8 : 10,
        ),
        _buildRememberRow(),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool enabled,
    required TextInputType keyboardType,
    required TextInputAction textInputAction,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autocorrect: false,
      enableSuggestions: false,
      textCapitalization:
          TextCapitalization.none,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: Colors.white38,
          fontSize: 13,
        ),
        filled: true,
        fillColor:
            Colors.white.withOpacity(0.045),
        prefixIcon: Icon(
          icon,
          color: const Color(0xFF4A94FF),
          size: 19,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(14),
          borderSide: BorderSide(
            color:
                Colors.white.withOpacity(0.09),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFF4A94FF),
            width: 1.4,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(14),
          borderSide: BorderSide(
            color:
                Colors.white.withOpacity(0.05),
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 15,
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: passwordController,
      obscureText: !mostrarPassword,
      enabled: !iniciandoSesion,
      textInputAction: TextInputAction.done,
      onSubmitted: (_) => iniciarSesion(),
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        hintText: 'Ingresa tu contraseña',
        hintStyle: const TextStyle(
          color: Colors.white38,
          fontSize: 13,
        ),
        filled: true,
        fillColor:
            Colors.white.withOpacity(0.045),
        prefixIcon: const Icon(
          LucideIcons.lock,
          color: Color(0xFF4A94FF),
          size: 19,
        ),
        suffixIcon: IconButton(
          onPressed: iniciandoSesion
              ? null
              : () {
                  setState(() {
                    mostrarPassword =
                        !mostrarPassword;
                  });
                },
          icon: Icon(
            mostrarPassword
                ? LucideIcons.eye_off
                : LucideIcons.eye,
            color: Colors.white54,
            size: 19,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(14),
          borderSide: BorderSide(
            color:
                Colors.white.withOpacity(0.09),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFF4A94FF),
            width: 1.4,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(14),
          borderSide: BorderSide(
            color:
                Colors.white.withOpacity(0.05),
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 15,
        ),
      ),
    );
  }

  Widget _buildRememberRow() {
    return SizedBox(
      height: 38,
      child: Row(
        children: [
          InkWell(
            borderRadius:
                BorderRadius.circular(8),
            onTap: iniciandoSesion
                ? null
                : () {
                    setState(() {
                      recordarUsuario =
                          !recordarUsuario;
                    });
                  },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 28,
                  height: 28,
                  child: Checkbox(
                    value: recordarUsuario,
                    onChanged:
                        iniciandoSesion
                            ? null
                            : (value) {
                                setState(() {
                                  recordarUsuario =
                                      value ?? false;
                                });
                              },
                    activeColor:
                        const Color(0xFF1677FF),
                    checkColor: Colors.white,
                    side: BorderSide(
                      color:
                          Colors.white.withOpacity(
                        0.32,
                      ),
                      width: 1.4,
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(5),
                    ),
                    visualDensity:
                        VisualDensity.compact,
                    materialTapTargetSize:
                        MaterialTapTargetSize
                            .shrinkWrap,
                  ),
                ),
                const SizedBox(width: 5),
                const Text(
                  'Recuérdame',
                  maxLines: 1,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed:
                iniciandoSesion ? null : () {},
            style: TextButton.styleFrom(
              padding: const EdgeInsets.only(
                left: 8,
                right: 0,
              ),
              minimumSize: Size.zero,
              tapTargetSize:
                  MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              '¿Olvidaste tu contraseña?',
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.visible,
              style: TextStyle(
                color: Color(0xFF5A9BFF),
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorporateAccessDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.white.withOpacity(0.14),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 13,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 4,
                height: 4,
                decoration:
                    const BoxDecoration(
                  color: Color(0xFF4A94FF),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 7),
              const Text(
                'ACCESO CORPORATIVO',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.14),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton({
    required bool smallPhone,
  }) {
    return Container(
      width: double.infinity,
      height: smallPhone ? 51 : 55,
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1677FF)
                .withOpacity(0.28),
            blurRadius: 24,
            spreadRadius: -3,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed:
            iniciandoSesion
                ? null
                : iniciarSesion,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              const Color(0xFF1677FF),
          disabledBackgroundColor:
              const Color(0xFF1677FF)
                  .withOpacity(0.55),
          foregroundColor: Colors.white,
          disabledForegroundColor:
              Colors.white70,
          elevation: 0,
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(16),
          ),
        ),
        child: iniciandoSesion
            ? const SizedBox(
                width: 21,
                height: 21,
                child:
                    CircularProgressIndicator(
                  strokeWidth: 2.3,
                  valueColor:
                      AlwaysStoppedAnimation<
                          Color>(
                    Colors.white,
                  ),
                ),
              )
            : const Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.log_in,
                    size: 19,
                  ),
                  SizedBox(width: 9),
                  Text(
                    'INICIAR SESIÓN',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight:
                          FontWeight.w700,
                      letterSpacing: 0.65,
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
        smallPhone ? 12 : 14,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0C1D3F)
                .withOpacity(0.90),
            const Color(0xFF102653)
                .withOpacity(0.58),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius:
            BorderRadius.circular(17),
        border: Border.all(
          color: const Color(0xFF4A94FF)
              .withOpacity(0.13),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: smallPhone ? 40 : 43,
            height: smallPhone ? 40 : 43,
            decoration: BoxDecoration(
              color: const Color(0xFF1677FF)
                  .withOpacity(0.10),
              borderRadius:
                  BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF4A94FF)
                    .withOpacity(0.08),
              ),
            ),
            child: Icon(
              LucideIcons.shield_check,
              color:
                  const Color(0xFF5A9BFF),
              size: smallPhone ? 21 : 22,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Acceso seguro',
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Tus datos están protegidos',
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 7,
            height: 7,
            decoration:
                const BoxDecoration(
              color: Color(0xFF57D697),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0x8857D697),
                  blurRadius: 9,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginGridPainter extends CustomPainter {
  const _LoginGridPainter();

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final paint = Paint()
      ..color =
          const Color(0xFF91B7FF)
              .withOpacity(0.028)
      ..strokeWidth = 1;

    const double spacing = 36;

    for (
      double x = 0;
      x < size.width;
      x += spacing
    ) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    for (
      double y = 0;
      y < size.height;
      y += spacing
    ) {
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

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          const Color(0xFF070B18),
      appBar: AppBar(
        backgroundColor:
            const Color(0xFF0D1630),
        foregroundColor:
            Colors.white,
        elevation: 0,
        title: const Text(
          'Tecnologías',
        ),
      ),
      body: const Center(
        child: Text(
          'Área de Tecnologías',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}