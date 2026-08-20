import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'user/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController correoController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  bool recordarUsuario = false;
  bool mostrarPassword = false;

  @override
  void dispose() {
    correoController.dispose();
    passwordController.dispose();
    super.dispose();
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

              final double titleSize = smallPhone
                  ? 29
                  : phone
                      ? 34
                      : 42;

              final double topPadding = veryShortScreen
                  ? 10
                  : shortScreen
                      ? 15
                      : 22;

              final double logoSpacing = veryShortScreen
                  ? 18
                  : shortScreen
                      ? 24
                      : 35;

              final double formSpacing = veryShortScreen
                  ? 20
                  : shortScreen
                      ? 25
                      : 35;

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
                              MainAxisAlignment.center,
                          crossAxisAlignment:
                              CrossAxisAlignment.center,
                          children: [
                            _buildLogo(
                              smallPhone: smallPhone,
                            ),

                            SizedBox(
                              height: logoSpacing,
                            ),

                            Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "Bienvenido de Nuevo",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: titleSize,
                                    color: Colors.white,
                                    fontWeight:
                                        FontWeight.bold,
                                    height: 1.1,
                                  ),
                                ),

                                const SizedBox(height: 10),

                                Text(
                                  "Inicia sesión para gestionar\n"
                                  "y dar seguimiento a tus tickets",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize:
                                        smallPhone ? 14 : 16,
                                    color: Colors.white54,
                                    height: 1.45,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(
                              height: formSpacing,
                            ),

                            _buildFormulario(
                              smallPhone: smallPhone,
                              shortScreen: shortScreen,
                            ),

                            SizedBox(
                              height: veryShortScreen
                                  ? 18
                                  : 28,
                            ),

                            _buildCorporateAccessDivider(),

                            SizedBox(
                              height: veryShortScreen
                                  ? 18
                                  : 24,
                            ),

                            _buildLoginButton(
                              smallPhone: smallPhone,
                            ),

                            SizedBox(
                              height: veryShortScreen
                                  ? 15
                                  : 20,
                            ),

                            _buildSecurityCard(
                              smallPhone: smallPhone,
                            ),

                            SizedBox(
                              height: veryShortScreen
                                  ? 15
                                  : 25,
                            ),

                            const Text(
                              "© 2026 Cymez",
                              style: TextStyle(
                                color: Colors.white30,
                                fontSize: 11,
                              ),
                            ),

                            const SizedBox(height: 5),
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
    final double logoSize = smallPhone ? 34 : 40;

    return Column(
      children: [
        Text.rich(
          TextSpan(
            text: "TICKET",
            style: TextStyle(
              fontSize: logoSize,
              color: const Color(0xFF3D8BFF),
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
            children: [
              TextSpan(
                text: "PRO",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: logoSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 4),

        Text(
          "Plataforma de soporte interno",
          style: TextStyle(
            fontSize: smallPhone ? 14 : 16,
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Correo electrónico",
          style: TextStyle(
            fontSize: 14,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 8),

        TextField(
          controller: correoController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: "Ingresa tu correo electrónico",
            hintStyle: const TextStyle(
              color: Colors.white38,
              fontSize: 14,
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.04),
            prefixIcon: const Icon(
              LucideIcons.mail,
              color: Color(0xFF4A94FF),
              size: 20,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(14),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.10),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFF3D8BFF),
                width: 1.5,
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
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 8),

        TextField(
          controller: passwordController,
          obscureText: !mostrarPassword,
          textInputAction: TextInputAction.done,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: "Ingresa tu contraseña",
            hintStyle: const TextStyle(
              color: Colors.white38,
              fontSize: 14,
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.04),
            prefixIcon: const Icon(
              LucideIcons.lock,
              color: Color(0xFF4A94FF),
              size: 20,
            ),
            suffixIcon: IconButton(
              onPressed: () {
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
                size: 20,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(14),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.10),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFF3D8BFF),
                width: 1.5,
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
          height: shortScreen ? 8 : 12,
        ),

        Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
          crossAxisAlignment:
              CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: recordarUsuario,
                    onChanged: (value) {
                      setState(() {
                        recordarUsuario =
                            value ?? false;
                      });
                    },
                    activeColor:
                        const Color(0xFF1677FF),
                    checkColor: Colors.white,
                    side: const BorderSide(
                      color: Colors.white38,
                      width: 1.5,
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

                  const Flexible(
                    child: Text(
                      "Recuérdame",
                      overflow:
                          TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white70,
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
                onPressed: () {
                  // Recuperar contraseña
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize:
                      const Size(0, 40),
                  tapTargetSize:
                      MaterialTapTargetSize
                          .shrinkWrap,
                ),
                child: const Text(
                  "¿Olvidaste tu contraseña?",
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  overflow:
                      TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Color(0xFF4A94FF),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
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
            color: Colors.white.withOpacity(0.12),
          ),
        ),

        const SizedBox(width: 12),

        const Text(
          "ACCESO CORPORATIVO",
          style: TextStyle(
            color: Colors.white38,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Container(
            height: 1,
            color: Colors.white.withOpacity(0.12),
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
      height: smallPhone ? 52 : 55,
      child: ElevatedButton(
        onPressed: () {
          final String correo =
              correoController.text.trim();

          final String password =
              passwordController.text;

          debugPrint("Correo: $correo");
          debugPrint("Password: $password");
          debugPrint(
            "Recordar: $recordarUsuario",
          );

          // ==========================================
          // NAVEGAR A HOMESCREEN
          // ==========================================

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  const HomeScreen(),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor:
              const Color(0xFF1677FF),
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor:
              const Color(0xFF1677FF)
                  .withOpacity(0.35),
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(15),
          ),
        ),
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Icon(
              LucideIcons.log_in,
              size: 20,
            ),

            const SizedBox(width: 10),

            const Text(
              "INICIAR SESIÓN",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0B1733)
                .withOpacity(0.95),
            const Color(0xFF102653)
                .withOpacity(0.70),
          ],
        ),
        borderRadius:
            BorderRadius.circular(17),
        border: Border.all(
          color:
              const Color(0xFF3D8BFF)
                  .withOpacity(0.15),
        ),
      ),
      child: Row(
        children: [
          Container(
            width:
                smallPhone ? 42 : 44,
            height:
                smallPhone ? 42 : 44,
            decoration: BoxDecoration(
              color:
                  const Color(0xFF1677FF)
                      .withOpacity(0.11),
              borderRadius:
                  BorderRadius.circular(13),
            ),
            child: Icon(
              LucideIcons.shield_check,
              color:
                  const Color(0xFF4A94FF),
              size:
                  smallPhone ? 22 : 23,
            ),
          ),

          const SizedBox(width: 13),

          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  "Acceso seguro",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),

                SizedBox(height: 4),

                Text(
                  "Tus datos están protegidos",
                  style: TextStyle(
                    color: Colors.white54,
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
