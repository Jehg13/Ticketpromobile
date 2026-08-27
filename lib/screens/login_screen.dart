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
            builder: (context) =>
                const AdminScreen(),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                const HomeScreen(),
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
          backgroundColor:
              const Color(0xFF16213E),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(12),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor:
          const Color(0xFF070B18),
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
            stops: [
              0.0,
              0.25,
              0.65,
              1.0,
            ],
          ),
        ),
        child: SafeArea(
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
                      ? 16
                      : phone
                          ? 22
                          : 40;

              final double maxContentWidth =
                  tablet ? 560 : double.infinity;

              final double titleSize =
                  smallPhone
                      ? 29
                      : phone
                          ? 34
                          : 42;

              final double topPadding =
                  veryShortScreen
                      ? 10
                      : shortScreen
                          ? 15
                          : 22;

              final double logoSpacing =
                  veryShortScreen
                      ? 18
                      : shortScreen
                          ? 24
                          : 35;

              final double formSpacing =
                  veryShortScreen
                      ? 20
                      : shortScreen
                          ? 25
                          : 35;

              final double bottomSpacing =
                  veryShortScreen ? 15 : 25;

              return SingleChildScrollView(
                physics:
                    const BouncingScrollPhysics(),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior
                        .onDrag,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight:
                        constraints.maxHeight,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(
                        maxWidth:
                            maxContentWidth,
                      ),
                      child: Padding(
                        padding:
                            EdgeInsets.fromLTRB(
                          horizontalPadding,
                          topPadding,
                          horizontalPadding,
                          bottomSpacing,
                        ),
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .center,
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .center,
                          children: [
                            _buildLogo(
                              smallPhone:
                                  smallPhone,
                            ),
                            SizedBox(
                              height: logoSpacing,
                            ),
                            Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .center,
                              children: [
                                Text(
                                  "Bienvenido de Nuevo",
                                  textAlign:
                                      TextAlign
                                          .center,
                                  style: TextStyle(
                                    fontSize:
                                        titleSize,
                                    color:
                                        Colors.white,
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                    height: 1.1,
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "Inicia sesión para gestionar\n"
                                  "y dar seguimiento a tus tickets",
                                  textAlign:
                                      TextAlign
                                          .center,
                                  style: TextStyle(
                                    fontSize:
                                        smallPhone
                                            ? 14
                                            : 16,
                                    color:
                                        Colors
                                            .white54,
                                    height: 1.45,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: formSpacing,
                            ),
                            _buildFormulario(
                              smallPhone:
                                  smallPhone,
                              shortScreen:
                                  shortScreen,
                            ),
                            SizedBox(
                              height:
                                  veryShortScreen
                                      ? 18
                                      : 28,
                            ),
                            _buildCorporateAccessDivider(),
                            SizedBox(
                              height:
                                  veryShortScreen
                                      ? 18
                                      : 24,
                            ),
                            _buildLoginButton(
                              smallPhone:
                                  smallPhone,
                            ),
                            SizedBox(
                              height:
                                  veryShortScreen
                                      ? 15
                                      : 20,
                            ),
                            _buildSecurityCard(
                              smallPhone:
                                  smallPhone,
                            ),
                            SizedBox(
                              height:
                                  veryShortScreen
                                      ? 15
                                      : 25,
                            ),
                            const Text(
                              "© 2026 Cymez",
                              style: TextStyle(
                                color:
                                    Colors.white30,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(
                              height: 5,
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

  Widget _buildLogo({
    required bool smallPhone,
  }) {
    final double logoSize =
        smallPhone ? 34 : 40;

    return Column(
      children: [
        Text.rich(
          TextSpan(
            text: "TICKET",
            style: TextStyle(
              fontSize: logoSize,
              color:
                  const Color(0xFF3D8BFF),
              fontWeight:
                  FontWeight.bold,
              letterSpacing: 0.5,
            ),
            children: [
              TextSpan(
                text: "PRO",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: logoSize,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Plataforma de soporte interno",
          style: TextStyle(
            fontSize:
                smallPhone ? 14 : 16,
            color: Colors.white38,
            letterSpacing: 0.3,
          ),
        ),
      ],
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
          "Usuario o correo electrónico",
          style: TextStyle(
            fontSize: 14,
            color: Colors.white,
            fontWeight:
                FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller:
              usuarioController,
          keyboardType:
              TextInputType.text,
          textInputAction:
              TextInputAction.next,
          enabled:
              !iniciandoSesion,
          autocorrect: false,
          enableSuggestions: false,
          textCapitalization:
              TextCapitalization.none,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
          decoration:
              InputDecoration(
            hintText:
                "Ingresa tu usuario o correo",
            hintStyle:
                const TextStyle(
              color: Colors.white38,
              fontSize: 14,
            ),
            filled: true,
            fillColor:
                Colors.white
                    .withOpacity(0.04),
            prefixIcon:
                const Icon(
              LucideIcons.user,
              color:
                  Color(0xFF4A94FF),
              size: 20,
            ),
            enabledBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(
                14,
              ),
              borderSide:
                  BorderSide(
                color: Colors.white
                    .withOpacity(0.10),
                width: 1,
              ),
            ),
            focusedBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(
                14,
              ),
              borderSide:
                  const BorderSide(
                color:
                    Color(0xFF3D8BFF),
                width: 1.5,
              ),
            ),
            disabledBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(
                14,
              ),
              borderSide:
                  BorderSide(
                color: Colors.white
                    .withOpacity(0.06),
                width: 1,
              ),
            ),
            contentPadding:
                const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          "Contraseña",
          style: TextStyle(
            fontSize: 14,
            color: Colors.white,
            fontWeight:
                FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller:
              passwordController,
          obscureText:
              !mostrarPassword,
          textInputAction:
              TextInputAction.done,
          enabled:
              !iniciandoSesion,
          onSubmitted: (_) =>
              iniciarSesion(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
          decoration:
              InputDecoration(
            hintText:
                "Ingresa tu contraseña",
            hintStyle:
                const TextStyle(
              color: Colors.white38,
              fontSize: 14,
            ),
            filled: true,
            fillColor:
                Colors.white
                    .withOpacity(0.04),
            prefixIcon:
                const Icon(
              LucideIcons.lock,
              color:
                  Color(0xFF4A94FF),
              size: 20,
            ),
            suffixIcon:
                IconButton(
              onPressed:
                  iniciandoSesion
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
                color:
                    Colors.white54,
                size: 20,
              ),
            ),
            enabledBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(
                14,
              ),
              borderSide:
                  BorderSide(
                color: Colors.white
                    .withOpacity(0.10),
                width: 1,
              ),
            ),
            focusedBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(
                14,
              ),
              borderSide:
                  const BorderSide(
                color:
                    Color(0xFF3D8BFF),
                width: 1.5,
              ),
            ),
            disabledBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(
                14,
              ),
              borderSide:
                  BorderSide(
                color: Colors.white
                    .withOpacity(0.06),
                width: 1,
              ),
            ),
            contentPadding:
                const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
        SizedBox(
          height:
              shortScreen ? 8 : 12,
        ),
        Row(
          mainAxisAlignment:
              MainAxisAlignment
                  .spaceBetween,
          crossAxisAlignment:
              CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Row(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  Checkbox(
                    value:
                        recordarUsuario,
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
                        const Color(
                      0xFF1677FF,
                    ),
                    checkColor:
                        Colors.white,
                    side:
                        const BorderSide(
                      color:
                          Colors.white38,
                      width: 1.5,
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius
                              .circular(5),
                    ),
                    visualDensity:
                        VisualDensity
                            .compact,
                    materialTapTargetSize:
                        MaterialTapTargetSize
                            .shrinkWrap,
                  ),
                  const Flexible(
                    child: Text(
                      "Recuérdame",
                      overflow:
                          TextOverflow
                              .ellipsis,
                      style: TextStyle(
                        color:
                            Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: TextButton(
                onPressed:
                    iniciandoSesion
                        ? null
                        : () {},
                style:
                    TextButton.styleFrom(
                  padding:
                      EdgeInsets.zero,
                  minimumSize:
                      const Size(0, 40),
                  tapTargetSize:
                      MaterialTapTargetSize
                          .shrinkWrap,
                ),
                child:
                    const Text(
                  "¿Olvidaste tu contraseña?",
                  textAlign:
                      TextAlign.right,
                  maxLines: 2,
                  overflow:
                      TextOverflow.ellipsis,
                  style: TextStyle(
                    color:
                        Color(0xFF4A94FF),
                    fontSize: 13,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCorporateAccessDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: Colors.white
                .withOpacity(0.12),
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          "ACCESO CORPORATIVO",
          style: TextStyle(
            color: Colors.white38,
            fontSize: 10,
            fontWeight:
                FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 1,
            color: Colors.white
                .withOpacity(0.12),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton({
    required bool smallPhone,
  }) {
    return SizedBox(
      width: double.infinity,
      height:
          smallPhone ? 52 : 55,
      child: ElevatedButton(
        onPressed:
            iniciandoSesion
                ? null
                : iniciarSesion,
        style:
            ElevatedButton.styleFrom(
          backgroundColor:
              const Color(
            0xFF1677FF,
          ),
          disabledBackgroundColor:
              const Color(
            0xFF1677FF,
          ).withOpacity(0.55),
          foregroundColor:
              Colors.white,
          disabledForegroundColor:
              Colors.white70,
          elevation: 8,
          shadowColor:
              const Color(
            0xFF1677FF,
          ).withOpacity(0.35),
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              15,
            ),
          ),
        ),
        child: iniciandoSesion
            ? const SizedBox(
                width: 22,
                height: 22,
                child:
                    CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor:
                      AlwaysStoppedAnimation<
                          Color>(
                    Colors.white,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .center,
                children: [
                  const Icon(
                    LucideIcons.log_in,
                    size: 20,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  const Text(
                    "INICIAR SESIÓN",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          FontWeight.w700,
                      letterSpacing: 0.6,
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
        smallPhone ? 13 : 15,
      ),
      decoration:
          BoxDecoration(
        gradient:
            LinearGradient(
          colors: [
            const Color(0xFF0B1733)
                .withOpacity(0.95),
            const Color(0xFF102653)
                .withOpacity(0.70),
          ],
        ),
        borderRadius:
            BorderRadius.circular(
          17,
        ),
        border: Border.all(
          color:
              const Color(
            0xFF3D8BFF,
          ).withOpacity(0.15),
        ),
      ),
      child: Row(
        children: [
          Container(
            width:
                smallPhone ? 42 : 44,
            height:
                smallPhone ? 42 : 44,
            decoration:
                BoxDecoration(
              color:
                  const Color(
                0xFF1677FF,
              ).withOpacity(0.11),
              borderRadius:
                  BorderRadius.circular(
                13,
              ),
            ),
            child: Icon(
              LucideIcons.shield_check,
              color:
                  const Color(
                0xFF4A94FF,
              ),
              size:
                  smallPhone ? 22 : 23,
            ),
          ),
          const SizedBox(width: 13),
          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  "Acceso seguro",
                  style: TextStyle(
                    color:
                        Colors.white,
                    fontSize: 13,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Tus datos están protegidos",
                  style: TextStyle(
                    color:
                        Colors.white54,
                    fontSize: 11,
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
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),
    );
  }
}