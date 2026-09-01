import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/perfil_usuario_service.dart';
import '../../services/session_service.dart';
import '../../widgets/loading_screen.dart';
import 'home_screen.dart' as home;
import 'mistickets_screen.dart';

class MiPerfilScreen extends StatefulWidget {
  const MiPerfilScreen({super.key});

  @override
  State<MiPerfilScreen> createState() => _MiPerfilScreenState();
}

class _MiPerfilScreenState extends State<MiPerfilScreen> {
  final Map<String, dynamic> _perfil = {};
  bool _cargandoPerfil = true;
  bool _procesandoFoto = false;
  String? _fotoNuevaPath;
  String? _fotoNuevaNombre;
  Uint8List? _fotoNuevaBytes;

  static const Color backgroundColor = Color(0xFF060A17);
  static const Color cardColor = Color(0xFF0B1021);
  static const Color secondaryColor = Color(0xFF0D1427);
  static const Color primaryColor = Color(0xFF2563EB);

  @override
  void initState() {
    super.initState();
    _cargarPerfil();
  }

  Future<void> _cargarPerfil() async {
    try {
      final response = await PerfilUsuarioService.obtenerPerfil();
      final usuario = response['usuario'] ?? response['user'];
      final perfilData = response['data'];
      final usuarioNormalizado =
          usuario ??
          (perfilData is Map
              ? (perfilData['usuario'] ?? perfilData['user'])
              : null);

      if (!mounted) return;

      setState(() {
        _perfil.clear();
        if (usuarioNormalizado is Map) {
          _perfil.addAll(Map<String, dynamic>.from(usuarioNormalizado));
        }
        _cargandoPerfil = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _cargandoPerfil = false);
      _mostrarMensaje(_limpiarError(e), isError: true);
    }
  }

  String _getPerfilValue(String key, {String fallback = ''}) {
    final value = _perfil[key];
    if (value == null) return fallback;
    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }

  String _limpiarError(Object e) {
    final texto = e.toString();
    if (texto.startsWith('Exception: ')) {
      return texto.replaceFirst('Exception: ', '');
    }
    return texto;
  }

  void _mostrarMensaje(String mensaje, {bool isError = false}) {
    if (!mounted) return;
    home.showUserMessage(context, mensaje, isError: isError);
  }

  Future<void> _mostrarDialogoSolicitarCambio() async {
    final campoController = ValueNotifier<String>('nombre');
    final nuevoValorController = TextEditingController();
    final motivoController = TextEditingController();
    var enviando = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: cardColor,
          title: const Text(
            'Solicitar cambio',
            style: TextStyle(color: Colors.white),
          ),
          content: SizedBox(
            width: 420,
            child: ValueListenableBuilder<String>(
              valueListenable: campoController,
              builder: (context, campo, _) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: campo,
                      dropdownColor: secondaryColor,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Campo a actualizar',
                        labelStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: backgroundColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'nombre',
                          child: Text('Nombre'),
                        ),
                        DropdownMenuItem(
                          value: 'correo',
                          child: Text('Correo electrónico'),
                        ),
                        DropdownMenuItem(
                          value: 'oficina',
                          child: Text('Oficina'),
                        ),
                        DropdownMenuItem(
                          value: 'departamento',
                          child: Text('Departamento'),
                        ),
                        DropdownMenuItem(
                          value: 'telefono',
                          child: Text('Teléfono'),
                        ),
                        DropdownMenuItem(
                          value: 'usuario',
                          child: Text('Usuario'),
                        ),
                        DropdownMenuItem(
                          value: 'numeroempleado',
                          child: Text('Número de empleado'),
                        ),
                        DropdownMenuItem(value: 'role', child: Text('Rol')),
                      ],
                      onChanged: (value) =>
                          campoController.value = value ?? 'nombre',
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: nuevoValorController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Nuevo valor',
                        labelStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: backgroundColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: motivoController,
                      maxLines: 4,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Motivo del cambio',
                        labelStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: backgroundColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () async {
                if (enviando) return;
                final campo = campoController.value;
                final nuevoValor = nuevoValorController.text.trim();
                final motivo = motivoController.text.trim();

                if (nuevoValor.isEmpty || motivo.isEmpty) {
                  _mostrarMensaje(
                    'Debes completar el nuevo valor y el motivo.',
                    isError: true,
                  );
                  return;
                }

                enviando = true;
                Navigator.pop(dialogContext);

                try {
                  final response = await PerfilUsuarioService.solicitarCambio(
                    campo: campo,
                    nuevoValor: nuevoValor,
                    motivo: motivo,
                  );
                  _mostrarMensaje(
                    response['message']?.toString() ??
                        'Solicitud enviada correctamente.',
                  );
                } catch (e) {
                  _mostrarMensaje(_limpiarError(e), isError: true);
                }
              },
              child: const Text('Enviar solicitud'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _mostrarDialogoPassword() async {
    final actualController = TextEditingController();
    final nuevaController = TextEditingController();
    final confirmarController = TextEditingController();
    var actualizando = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: cardColor,
          title: const Text(
            'Actualizar contraseña',
            style: TextStyle(color: Colors.white),
          ),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: actualController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Contraseña actual',
                    labelStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: backgroundColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: nuevaController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Nueva contraseña',
                    labelStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: backgroundColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: confirmarController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Confirmar contraseña',
                    labelStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: backgroundColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Debe contener al menos 8 caracteres, 1 mayúscula, 1 número y 1 símbolo.',
                    style: TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () async {
                if (actualizando) return;
                final actual = actualController.text;
                final nueva = nuevaController.text;
                final confirmar = confirmarController.text;

                if (actual.trim().isEmpty ||
                    nueva.trim().isEmpty ||
                    confirmar.trim().isEmpty) {
                  _mostrarMensaje(
                    'Todos los campos de contraseña son obligatorios.',
                    isError: true,
                  );
                  return;
                }

                final regex = RegExp(
                  r'^(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$',
                );
                if (!regex.hasMatch(nueva)) {
                  _mostrarMensaje(
                    'La contraseña debe tener 8 caracteres, mayúsculas, números y símbolos.',
                    isError: true,
                  );
                  return;
                }

                if (nueva != confirmar) {
                  _mostrarMensaje(
                    'La confirmación de contraseña no coincide.',
                    isError: true,
                  );
                  return;
                }

                actualizando = true;
                Navigator.pop(dialogContext);

                try {
                  final response =
                      await PerfilUsuarioService.actualizarPassword(
                        passwordActual: actual,
                        password: nueva,
                        confirmPassword: confirmar,
                      );
                  _mostrarMensaje(
                    response['message']?.toString() ??
                        'Contraseña actualizada correctamente.',
                  );
                } catch (e) {
                  _mostrarMensaje(_limpiarError(e), isError: true);
                }
              },
              child: const Text('Actualizar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _mostrarDialogoMfa() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: cardColor,
          title: const Text(
            'Verificación en dos pasos',
            style: TextStyle(color: Colors.white),
          ),
          content: const SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Para activar la verificación en dos pasos desde la versión web:',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  '1. Ingresa a tu perfil desde la cuenta web.',
                  style: TextStyle(color: Colors.white70),
                ),
                Text(
                  '2. Haz clic en “Activar verificación en dos pasos”.',
                  style: TextStyle(color: Colors.white70),
                ),
                Text(
                  '3. Descarga Google Authenticator o Microsoft Authenticator.',
                  style: TextStyle(color: Colors.white70),
                ),
                Text(
                  '4. Escanea el código QR que aparece en la web.',
                  style: TextStyle(color: Colors.white70),
                ),
                Text(
                  '5. Ingresa el código de 6 dígitos generado por la app y guarda la configuración.',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Entendido'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _seleccionarFoto() async {
    try {
      final file = await FilePicker.pickFile(type: FileType.image);
      if (file == null) {
        return;
      }

      final bytes = await file.readAsBytes();
      setState(() {
        _fotoNuevaPath = file.path;
        _fotoNuevaNombre = file.name;
        _fotoNuevaBytes = bytes;
      });
    } catch (e) {
      _mostrarMensaje(_limpiarError(e), isError: true);
    }
  }

  Future<void> _subirFotoSeleccionada() async {
    if ((_fotoNuevaPath == null || _fotoNuevaPath!.isEmpty) &&
        (_fotoNuevaBytes == null || _fotoNuevaBytes!.isEmpty)) {
      _mostrarMensaje(
        'Selecciona una imagen antes de actualizar la foto.',
        isError: true,
      );
      return;
    }

    try {
      setState(() => _procesandoFoto = true);

      final response = await PerfilUsuarioService.actualizarFoto(
        path: _fotoNuevaBytes == null ? _fotoNuevaPath : null,
        bytes: _fotoNuevaBytes ?? await File(_fotoNuevaPath!).readAsBytes(),
        fileName: _fotoNuevaNombre ?? 'profile-photo.png',
      );

      final usuarioRespuesta = response['usuario'] ?? response['user'];
      final respuestaData = response['data'];
      final nuevaFoto =
          response['picture']?.toString() ??
          (usuarioRespuesta is Map
              ? usuarioRespuesta['picture']?.toString()
              : null) ??
          (respuestaData is Map ? respuestaData['picture']?.toString() : null);
      if (nuevaFoto != null && nuevaFoto.isNotEmpty) {
        await SessionService.updatePicture(nuevaFoto);
        setState(() {
          _perfil['picture'] = nuevaFoto;
          _fotoNuevaPath = null;
          _fotoNuevaNombre = null;
          _fotoNuevaBytes = null;
        });
      } else {
        setState(() {
          _fotoNuevaPath = null;
          _fotoNuevaNombre = null;
          _fotoNuevaBytes = null;
        });
      }

      _mostrarMensaje(
        response['message']?.toString() ?? 'Foto actualizada correctamente.',
      );
    } catch (e) {
      _mostrarMensaje(_limpiarError(e), isError: true);
    } finally {
      if (mounted) {
        setState(() => _procesandoFoto = false);
      }
    }
  }

  Future<void> _eliminarFoto() async {
    final tieneFotoPerfil = _getPerfilValue('picture').isNotEmpty;
    if (!tieneFotoPerfil) {
      return;
    }

    try {
      final response = await PerfilUsuarioService.eliminarFoto();
      final nuevaFoto = response['picture']?.toString();
      await SessionService.updatePicture(nuevaFoto ?? '');
      if (nuevaFoto != null && nuevaFoto.isNotEmpty) {
        setState(() {
          _perfil['picture'] = nuevaFoto;
        });
      } else {
        setState(() {
          _perfil['picture'] = '';
        });
      }
      _mostrarMensaje(
        response['message']?.toString() ?? 'Foto eliminada correctamente.',
      );
    } catch (e) {
      _mostrarMensaje(_limpiarError(e), isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;
    final nombreUsuario = _getPerfilValue('name', fallback: 'Usuario');
    final departamento = _getPerfilValue(
      'departamento',
      fallback: 'Sin departamento',
    );
    final login = _getPerfilValue('login', fallback: 'Sin usuario');
    final rol = _getPerfilValue('role', fallback: 'Sin rol');

    return Scaffold(
      backgroundColor: const Color(0xFF050B16),
      appBar: isDesktop
          ? null
          : AppBar(
              backgroundColor: const Color(0xFF0B1324),
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
              title: const AppLogo(fontSize: 20),
              actions: [
                home.UserHeaderActions(
                  onNotifications: () => home.showUserNotifications(context),
                ),
              ],
            ),
      drawer: isDesktop
          ? null
          : const TicketProNavigationDrawer(activeRoute: 'Mi perfil'),
      body: _cargandoPerfil
          ? const LoadingScreen(mensaje: 'Cargando tu perfil...')
          : Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF050B16), Color(0xFF0C1323)],
                ),
              ),
              child: Row(
                children: [
                  if (isDesktop)
                    const SizedBox(
                      width: 260,
                      child: TicketProNavigationDrawer(
                        activeRoute: 'Mi perfil',
                      ),
                    ),
                  Expanded(
                    child: SafeArea(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                          horizontal: isDesktop ? 32.0 : 16.0,
                          vertical: 24.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(
                              isDesktop,
                              nombreUsuario,
                              departamento,
                              login,
                              rol,
                            ),
                            const SizedBox(height: 24),
                            _buildMainLayout(isDesktop, screenWidth),
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

  Widget _buildHeader(
    bool isDesktop,
    String nombreUsuario,
    String departamento,
    String login,
    String rol,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF101C32), Color(0xFF0E172A), Color(0xFF111F38)],
        ),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.14),
            blurRadius: 32,
            spreadRadius: 1,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  child: const Text(
                    'Cuenta activa',
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 0.8,
                      color: Color(0xFFB9D7FF),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Mi perfil',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Consulta y administra tu información personal y de tu cuenta.',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                ),
              ],
            ),
          ),
          if (isDesktop) ...[
            home.UserHeaderActions(
              onNotifications: () => home.showUserNotifications(context),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // ESTRUCTURA PRINCIPAL
  // ============================================================

  Widget _buildMainLayout(bool isDesktop, double screenWidth) {
    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 7,
            child: Column(
              children: [
                _buildInfoPersonalCard(),

                const SizedBox(height: 16),

                _buildBannerSolicitarCambio(),

                const SizedBox(height: 16),

                _buildSeguridadCuentaCard(),
              ],
            ),
          ),

          const SizedBox(width: 20),

          Expanded(
            flex: 4,
            child: Column(
              children: [
                _buildFotoPerfilCard(),

                const SizedBox(height: 16),

                _buildInfoCuentaCard(),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        _buildFotoPerfilCard(),

        const SizedBox(height: 16),

        _buildInfoPersonalCard(),

        const SizedBox(height: 16),

        _buildBannerSolicitarCambio(),

        const SizedBox(height: 16),

        _buildSeguridadCuentaCard(),

        const SizedBox(height: 16),

        _buildInfoCuentaCard(),
      ],
    );
  }

  // ============================================================
  // INFORMACIÓN PERSONAL
  // ============================================================

  Widget _buildInfoPersonalCard() {
    final nombre = _getPerfilValue('name', fallback: 'Sin nombre');
    final login = _getPerfilValue('login', fallback: 'Sin usuario');
    final email = _getPerfilValue('email', fallback: 'Sin correo');
    final oficina = _getPerfilValue('oficina', fallback: 'Sin oficina');
    final departamento = _getPerfilValue(
      'departamento',
      fallback: 'Sin departamento',
    );
    final telefono = _getPerfilValue('phone', fallback: 'Sin teléfono');
    final empresa = _getPerfilValue('empresa', fallback: 'TicketPro');
    final numeroEmpleado = _getPerfilValue(
      'numero_empleado',
      fallback: 'Sin número',
    );
    final rol = _getPerfilValue('role', fallback: 'Sin rol');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0D152B), Color(0xFF0B1120)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.person_outline_rounded,
                color: Color(0xFF93C5FD),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Información personal y laboral',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Datos principales de la cuenta y la información del usuario.',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final personal = [
                _infoTile(
                  'Nombre completo',
                  nombre,
                  Icons.person_outline,
                  double.infinity,
                ),
                _infoTile(
                  'Correo electrónico',
                  email,
                  Icons.email_outlined,
                  double.infinity,
                ),
                _infoTile(
                  'Teléfono',
                  telefono,
                  Icons.phone_outlined,
                  double.infinity,
                ),
                _infoTile(
                  'Usuario de acceso',
                  login,
                  Icons.account_circle_outlined,
                  double.infinity,
                ),
              ];
              final laboral = [
                _infoTile(
                  'Empresa',
                  empresa,
                  Icons.apartment_outlined,
                  double.infinity,
                ),
                _infoTile(
                  'Departamento',
                  departamento,
                  Icons.account_tree_outlined,
                  double.infinity,
                ),
                _infoTile(
                  'Oficina / Sucursal',
                  oficina,
                  Icons.desktop_windows_outlined,
                  double.infinity,
                ),
                _infoTile(
                  'Número de empleado',
                  numeroEmpleado,
                  Icons.badge_outlined,
                  double.infinity,
                ),
                _infoTile(
                  'Rol',
                  rol,
                  Icons.verified_user_outlined,
                  double.infinity,
                ),
              ];
              if (constraints.maxWidth <= 760) {
                return Column(
                  children: [
                    _buildInfoGroup(
                      'Datos personales',
                      Icons.person_outline,
                      personal,
                    ),
                    const SizedBox(height: 14),
                    _buildInfoGroup(
                      'Datos laborales',
                      Icons.work_outline,
                      laboral,
                    ),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildInfoGroup(
                      'Datos personales',
                      Icons.person_outline,
                      personal,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildInfoGroup(
                      'Datos laborales',
                      Icons.work_outline,
                      laboral,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoGroup(String title, IconData icon, List<Widget> tiles) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF091326),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF93C5FD), size: 17),
              const SizedBox(width: 7),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'FIJO',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.lock_outline_rounded,
                color: Colors.white38,
                size: 15,
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...tiles,
        ],
      ),
    );
  }

  // ============================================================
  // INFO TILE
  // ============================================================

  Widget _infoTile(String label, String value, IconData icon, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0B1220), Color(0xFF0D1729)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primaryColor.withValues(alpha: 0.22),
                  const Color(0xFF1E3A8A).withValues(alpha: 0.28),
                ],
              ),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
            ),
            child: Icon(icon, color: const Color(0xFFBFDBFE), size: 18),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),

                const SizedBox(height: 2),

                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BANNER SOLICITAR CAMBIO
  // ============================================================

  Widget _buildBannerSolicitarCambio() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF0F1C32), Color(0xFF101A2F)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.16)),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFDBEAFE), Color(0xFFBFDBFE)],
              ),
              shape: BoxShape.circle,
            ),
            child: const Text(
              'i',
              style: TextStyle(
                color: backgroundColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Si alguna de tu información es incorrecta o requiere actualización, solicita un cambio a través del botón solicitar cambio.',
              style: TextStyle(color: Colors.grey, fontSize: 12, height: 1.3),
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              backgroundColor: secondaryColor,
              side: const BorderSide(color: Colors.white12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: _mostrarDialogoSolicitarCambio,
            icon: const Icon(
              Icons.edit_note_rounded,
              color: Colors.white,
              size: 16,
            ),
            label: const Text(
              'Solicitar cambio',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SEGURIDAD
  // ============================================================

  Widget _buildSeguridadCuentaCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0D152B), Color(0xFF0B1120)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.shield_outlined, color: Color(0xFF93C5FD), size: 20),
              SizedBox(width: 8),
              Text(
                'Seguridad de tu cuenta',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Administra tu información relacionada con la seguridad de tu cuenta',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0B1220), Color(0xFF101A2C)],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1F4D9B), Color(0xFF1D4ED8)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.lock_outline_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contraseña',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Última actualización: No registrada',
                      style: TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              TextButton.icon(
                onPressed: _mostrarDialogoPassword,
                icon: const Icon(Icons.password_rounded),
                label: const Text('Actualizar contraseña'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  backgroundColor: secondaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: _mostrarDialogoMfa,
                icon: const Icon(Icons.verified_user_outlined),
                label: const Text('Autenticación en dos pasos'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  backgroundColor: secondaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FOTO DE PERFIL
  // ============================================================

  Widget _buildFotoPerfilCard() {
    final fotoUrl = ApiService.profileImageUrl(_getPerfilValue('picture'));
    final nombreUsuario = _getPerfilValue('name', fallback: 'Usuario');
    final tieneFotoPerfil = fotoUrl.isNotEmpty;
    final hayFotoNueva =
        (_fotoNuevaPath != null && _fotoNuevaPath!.isNotEmpty) ||
        (_fotoNuevaBytes != null && _fotoNuevaBytes!.isNotEmpty);
    final imagenActual = hayFotoNueva && _fotoNuevaBytes == null
        ? FileImage(File(_fotoNuevaPath!))
        : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0D152B), Color(0xFF0B1120)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(
                Icons.camera_alt_outlined,
                color: Color(0xFF93C5FD),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Foto de perfil',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Actualización del perfil',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _procesandoFoto ? null : _seleccionarFoto,
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF60A5FA), Color(0xFF2563EB)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withValues(alpha: 0.24),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 63,
                    backgroundColor: const Color(0xFF091326),
                    backgroundImage: _fotoNuevaBytes != null
                        ? MemoryImage(_fotoNuevaBytes!)
                        : imagenActual ??
                              (tieneFotoPerfil
                                  ? NetworkImage(
                                      '$fotoUrl?profile_refresh=${fotoUrl.hashCode}',
                                    )
                                  : const AssetImage('assets/images/user.png')),
                    child: !hayFotoNueva && !tieneFotoPerfil
                        ? Text(
                            nombreUsuario.isNotEmpty
                                ? nombreUsuario
                                      .trim()
                                      .split(RegExp(r'\s+'))
                                      .take(2)
                                      .map((p) => p[0])
                                      .join()
                                      .toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 38,
                            ),
                          )
                        : null,
                  ),
                ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      size: 16,
                      color: backgroundColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Formatos permitidos: JPG, PNG',
            style: TextStyle(color: Colors.grey, fontSize: 11),
          ),
          const Text(
            'Tamaño máximo: 2 MB',
            style: TextStyle(color: Colors.grey, fontSize: 11),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              onPressed: (_procesandoFoto || !hayFotoNueva)
                  ? null
                  : _subirFotoSeleccionada,
              child: Text(
                _procesandoFoto ? 'Subiendo foto...' : 'Actualizar foto',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                backgroundColor: backgroundColor,
                side: const BorderSide(color: Colors.white12),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: (_procesandoFoto || !tieneFotoPerfil)
                  ? null
                  : _eliminarFoto,
              child: const Text(
                'Eliminar foto',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INFORMACIÓN DE LA CUENTA
  // ============================================================

  Widget _buildInfoCuentaCard() {
    final rol = _getPerfilValue('role', fallback: 'Usuario');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0D152B), Color(0xFF0B1120)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: Color(0xFF93C5FD),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Información de la cuenta',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fecha de creación',
                      style: TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'No disponible',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Rol en el sistema',
                      style: TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      rol,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Estado de la cuenta',
            style: TextStyle(color: Colors.grey, fontSize: 11),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF064E3B).withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF10B981).withValues(alpha: 0.4),
              ),
            ),
            child: const Text(
              'Activa',
              style: TextStyle(
                color: Color(0xFF10B981),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0B1220), Color(0xFF101A2C)],
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: const Row(
              children: [
                Icon(Icons.sync_rounded, color: Color(0xFF93C5FD), size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mantén tu información actualizada',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Una información correcta nos ayuda a darte un mejor soporte y atención.',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                          height: 1.3,
                        ),
                      ),
                    ],
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

// ==================================================================
// AVATAR SIN DEPENDENCIA DE INTERNET
// ==================================================================

class UserAvatar extends StatelessWidget {
  final String name;
  final double radius;
  final double fontSize;

  const UserAvatar({
    super.key,
    required this.name,
    this.radius = 20,
    this.fontSize = 14,
  });

  String _getInitials(String name) {
    final String cleanName = name.trim();

    if (cleanName.isEmpty) {
      return 'U';
    }

    final List<String> parts = cleanName
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: SessionService.getUser(),
      builder: (context, snapshot) {
        final picture = snapshot.data?['picture']?.toString() ?? '';
        final imageUrl = ApiService.profileImageUrl(picture);
        return CircleAvatar(
          radius: radius,
          backgroundColor: const Color(0xFF2563EB),
          backgroundImage: imageUrl.isEmpty
              ? null
              : NetworkImage('$imageUrl?profile_refresh=${picture.hashCode}'),
          child: imageUrl.isEmpty
              ? Text(
                  _getInitials(name),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: fontSize,
                  ),
                )
              : null,
        );
      },
    );
  }
}

// ==================================================================
// LOGO
// ==================================================================

class AppLogo extends StatelessWidget {
  final double fontSize;

  const AppLogo({super.key, this.fontSize = 26});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
        children: const [
          TextSpan(
            text: 'Ticket',
            style: TextStyle(color: Colors.white),
          ),
          TextSpan(
            text: 'Pro',
            style: TextStyle(color: Color(0xFF2563EB)),
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// DRAWER
// ==================================================================

class AppNavigationDrawer extends StatelessWidget {
  final String activeRoute;

  const AppNavigationDrawer({super.key, this.activeRoute = 'Mi perfil'});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: const Color(0xFF0B1021),
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppLogo(fontSize: 26),

            const SizedBox(height: 24),

            const Row(
              children: [
                home.UserAvatar(radius: 20),

                SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Juan Pérez',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      Text(
                        'Administración',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            const Divider(color: Colors.white12, height: 1),

            const SizedBox(height: 20),

            _drawerItem(
              icon: Icons.home_rounded,
              title: 'Inicio',
              isActive: activeRoute == 'Inicio',
              onTap: () {},
            ),

            _drawerItem(
              icon: Icons.confirmation_number_outlined,
              title: 'Mis tickets',
              isActive: activeRoute == 'Mis tickets',
              onTap: () {},
            ),

            _drawerItem(
              icon: Icons.build_outlined,
              title: 'Crear ticket',
              isActive: activeRoute == 'Crear ticket',
              onTap: () {},
            ),

            _drawerItem(
              icon: Icons.warning_amber_rounded,
              title: 'Avisos',
              isActive: activeRoute == 'Avisos',
              onTap: () {},
            ),

            _drawerItem(
              icon: Icons.person_outline_rounded,
              title: 'Mi perfil',
              isActive: activeRoute == 'Mi perfil',
              onTap: () {},
            ),

            const Divider(color: Colors.white12, height: 1),

            _drawerItem(
              icon: Icons.logout_rounded,
              title: 'Cerrar sesión',
              color: Colors.white70,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String title,
    bool isActive = false,
    Color? color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: isActive
          ? BoxDecoration(
              color: const Color(0xFF2563EB),
              borderRadius: BorderRadius.circular(10),
            )
          : null,
      child: ListTile(
        leading: Icon(
          icon,
          color: color ?? (isActive ? Colors.white : Colors.grey),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: color ?? (isActive ? Colors.white : Colors.grey),
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        dense: true,
        onTap: onTap,
      ),
    );
  }
}
