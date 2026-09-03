import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';

import '../../services/api_service.dart';
import '../../widgets/loading_screen.dart';
import '../../services/session_service.dart';
import '../../services/admin/perfiladmin_service.dart';
import '../../widgets/admin_notification_bell.dart';
import 'avisosadmin_screen.dart';
import 'cambios_screen.dart';
import 'dispositivos_screen.dart';
import 'tickets_screen.dart';
import 'users_screen.dart';
import 'home_screen.dart';

class PerfiladminScreen extends StatefulWidget {
  const PerfiladminScreen({super.key});

  @override
  State<PerfiladminScreen> createState() => _PerfiladminScreenState();
}

class _PerfiladminScreenState extends State<PerfiladminScreen> {
  final Color bgDark = const Color(0xFF0B0F19);
  final Color cardDark = const Color(0xFF121826);
  final Color inputBg = const Color(0xFF172033);
  final Color primaryGradientStart = const Color(0xFF2563EB);
  final Color primaryGradientEnd = const Color(0xFF4F46E5);

  final TextEditingController _nombreController = TextEditingController(
    text: 'Jesus Hinojosa',
  );
  final TextEditingController _usuarioController = TextEditingController(
    text: 'jhinojosa',
  );
  final TextEditingController _correoController = TextEditingController(
    text: 'jefehi13@gmail.com',
  );
  final TextEditingController _telefonoController = TextEditingController(
    text: '8951235410',
  );
  final TextEditingController _cymezController = TextEditingController(
    text: 'Cymez',
  );
  final TextEditingController _departamentoController = TextEditingController(
    text: 'Tecnologias',
  );
  final TextEditingController _rolController = TextEditingController(
    text: 'Gerente Ti',
  );
  final TextEditingController _oficinaController = TextEditingController(
    text: 'Reynosa',
  );
  final TextEditingController _numEmpleadoController = TextEditingController(
    text: '256070',
  );
  PlatformFile? _fotoNueva;
  Uint8List? _fotoPreviewBytes;
  String? _fotoUrl;
  bool _tieneFoto = false;
  bool _actualizandoFoto = false;
  bool _eliminandoFoto = false;
  bool _hayCambios = false;
  bool _guardandoCambios = false;
  final Map<String, String> _valoresOriginales = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        backgroundColor: bgDark,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          children: const [
            Text(
              'Ticket',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            Text(
              'Pro',
              style: TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              const AdminNotificationBell(),
              Positioned(
                right: 10,
                top: 12,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.purpleAccent,
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    '2',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16, left: 8),
            child: const AdminProfileMenu(radius: 16),
          ),
        ],
      ),
      drawer: _buildAppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderPerfil(),
            const SizedBox(height: 20),
            _buildCardFotoPerfil(),
            const SizedBox(height: 16),
            _buildCardInformacionPersonalLaboral(),
            const SizedBox(height: 16),
            _buildCardInformacionCuenta(),
            const SizedBox(height: 16),
            _buildCardSeguridad(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _suscribirCambios();
    _cargarPerfil();
  }

  void _suscribirCambios() {
    final controllers = [
      _nombreController,
      _usuarioController,
      _correoController,
      _telefonoController,
      _departamentoController,
      _rolController,
      _numEmpleadoController,
    ];

    for (final controller in controllers) {
      controller.addListener(_evaluarCambios);
    }
  }

  void _evaluarCambios() {
    final cambios = _camposEditables
        .map((campo) => _obtenerValorActual(campo))
        .toList();
    final originales = _camposEditables
        .map((campo) => _valoresOriginales[campo] ?? '')
        .toList();

    final hayCambios = List.generate(
      _camposEditables.length,
      (index) => cambios[index] != originales[index],
    ).any((cambio) => cambio);

    if (_hayCambios != hayCambios) {
      setState(() {
        _hayCambios = hayCambios;
      });
    }
  }

  Future<void> _cargarPerfil() async {
    final usuarioSesion = await SessionService.getUser();
    if (!mounted) return;
    if (usuarioSesion == null) return;
    final data = Map<String, dynamic>.from(usuarioSesion);
    _nombreController.text = data['name']?.toString() ?? '';
    _usuarioController.text = data['login']?.toString() ?? '';
    _correoController.text = data['email']?.toString() ?? '';
    _telefonoController.text = _formatearTelefono(
      data['phone']?.toString() ?? '',
    );
    _departamentoController.text = data['departamento']?.toString() ?? '';
    _oficinaController.text = data['oficina']?.toString() ?? '';
    _rolController.text = data['role']?.toString() ?? '';
    _numEmpleadoController.text = data['numero_empleado']?.toString() ?? '';

    _valoresOriginales.clear();
    for (final campo in _camposEditables) {
      _valoresOriginales[campo] = _obtenerValorActual(campo);
    }

    final pictureApi =
        (data['picture'] ??
                data['picture_url'] ??
                data['foto'] ??
                data['foto_perfil'])
            ?.toString() ??
        '';
    final fotoGuardada = await SessionService.getPicture() ?? '';
    final picture = _esFotoPersonalizada(fotoGuardada)
        ? fotoGuardada
        : pictureApi;
    final esFotoCustom = _esFotoPersonalizada(picture);
    setState(() {
      _fotoUrl = esFotoCustom ? ApiService.storageFileUrl(picture) : null;
      _tieneFoto = esFotoCustom;
      _hayCambios = false;
    });
  }

  List<String> get _camposEditables => const [
    'nombre',
    'usuario',
    'correo',
    'telefono',
    'departamento',
    'role',
    'numeroempleado',
  ];

  String _obtenerValorActual(String campo) {
    switch (campo) {
      case 'nombre':
        return _nombreController.text.trim();
      case 'usuario':
        return _usuarioController.text.trim();
      case 'correo':
        return _correoController.text.trim();
      case 'telefono':
        return _telefonoController.text.replaceAll(RegExp(r'\D'), '').trim();
      case 'departamento':
        return _departamentoController.text.trim();
      case 'role':
        return _rolController.text.trim();
      case 'numeroempleado':
        return _numEmpleadoController.text.trim();
      default:
        return '';
    }
  }

  String _formatearTelefono(String value) {
    final digits = value
        .replaceAll(RegExp(r'\D'), '')
        .substring(
          0,
          value.replaceAll(RegExp(r'\D'), '').length > 10
              ? 10
              : value.replaceAll(RegExp(r'\D'), '').length,
        );

    if (digits.isEmpty) return '';
    if (digits.length <= 3) return digits;
    if (digits.length <= 6) {
      return '(${digits.substring(0, 3)}) ${digits.substring(3)}';
    }
    return '(${digits.substring(0, 3)}) ${digits.substring(3, 6)}-${digits.substring(6)}';
  }

  Future<void> _guardarCambiosPerfil() async {
    if (_guardandoCambios || !_hayCambios) return;

    final nombre = _nombreController.text.trim();
    final usuario = _usuarioController.text.trim();
    final correo = _correoController.text.trim();
    final telefono = _telefonoController.text
        .replaceAll(RegExp(r'\D'), '')
        .trim();
    final departamento = _departamentoController.text.trim();
    final rol = _rolController.text.trim();
    final numeroEmpleado = _numEmpleadoController.text.trim();

    setState(() => _guardandoCambios = true);

    try {
      final respuesta = await PerfiladminService.actualizarPerfilAdmin(
        name: nombre,
        login: usuario,
        email: correo,
        phone: telefono,
        departamento: departamento,
        role: rol,
        numeroEmpleado: numeroEmpleado,
      );

      if (!mounted) return;

      final usuarioActualizado = respuesta['usuario'] as Map<String, dynamic>?;
      if (usuarioActualizado != null) {
        await SessionService.saveSession(
          token: await SessionService.getToken() ?? '',
          user: usuarioActualizado,
        );
      }

      _valoresOriginales['nombre'] = nombre;
      _valoresOriginales['usuario'] = usuario;
      _valoresOriginales['correo'] = correo;
      _valoresOriginales['telefono'] = telefono;
      _valoresOriginales['departamento'] = departamento;
      _valoresOriginales['role'] = rol;
      _valoresOriginales['numeroempleado'] = numeroEmpleado;

      setState(() {
        _hayCambios = false;
        _guardandoCambios = false;
      });

      _mostrarMensaje(
        respuesta['message']?.toString() ??
            'Información actualizada correctamente.',
        false,
      );
    } catch (e) {
      if (mounted) {
        setState(() => _guardandoCambios = false);
      }
      _mostrarMensaje(e.toString().replaceFirst('Exception: ', ''), true);
    }
  }

  Widget _buildHeaderPerfil() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Mi perfil',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Gestión y actualización directa de tu información administrativa',
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildCardFotoPerfil() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                Icons.camera_alt_outlined,
                color: Colors.blueAccent,
                size: 18,
              ),
              SizedBox(width: 8),
              Text(
                'Foto de perfil',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Stack(
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.blueAccent.withValues(alpha: 0.5),
                    width: 2,
                  ),
                  color: inputBg,
                ),
                child: ClipOval(
                  child: _fotoPreviewBytes != null
                      ? Image.memory(_fotoPreviewBytes!, fit: BoxFit.cover)
                      : _fotoUrl != null && _fotoUrl!.isNotEmpty
                      ? Image.network(
                          '$_fotoUrl?profile_refresh=${_fotoUrl.hashCode}',
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Image.asset(
                            'assets/images/user.png',
                            fit: BoxFit.cover,
                            width: 110,
                            height: 110,
                          ),
                        )
                      : Image.asset(
                          'assets/images/user.png',
                          fit: BoxFit.cover,
                          width: 110,
                          height: 110,
                        ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: _seleccionarFoto,
                    icon: const Icon(
                      Icons.camera_alt,
                      color: Colors.black,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
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
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _fotoNueva == null || _actualizandoFoto
                      ? null
                      : _actualizarFoto,
                  icon: const Icon(Icons.upload, size: 16),
                  label: const Text(
                    'Actualizar foto',
                    style: TextStyle(fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGradientStart,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: !_tieneFoto || _eliminandoFoto
                    ? null
                    : _eliminarFoto,
                icon: const Icon(
                  Icons.delete_outline,
                  size: 16,
                  color: Colors.redAccent,
                ),
                label: const Text(
                  'Eliminar foto',
                  style: TextStyle(color: Colors.redAccent, fontSize: 12),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.redAccent),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardInformacionPersonalLaboral() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.person_outline,
                  color: Colors.blueAccent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Información personal y laboral',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Como Gerente TI con permisos de administrador puedes modificar tus datos.',
                      style: TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.blueAccent.withValues(alpha: 0.5),
                ),
                borderRadius: BorderRadius.circular(20),
                color: Colors.blueAccent.withValues(alpha: 0.08),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.shield_outlined,
                    color: Colors.blueAccent,
                    size: 14,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Modo Administrador',
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(color: Colors.white10, height: 24),
          _buildSectionTitle(
            Icons.person,
            'Datos personales',
            'Información de contacto y acceso',
          ),
          const SizedBox(height: 12),
          _buildFieldEditable(
            'Nombre completo',
            _nombreController,
            Icons.person_outline,
            isEditable: true,
          ),
          _buildFieldEditable(
            'Usuario',
            _usuarioController,
            Icons.alternate_email,
            isEditable: true,
          ),
          _buildFieldEditable(
            'Correo electrónico',
            _correoController,
            Icons.email_outlined,
            isEditable: true,
          ),
          _buildFieldEditable(
            'Teléfono',
            _telefonoController,
            Icons.phone_outlined,
            isEditable: true,
          ),
          const Divider(color: Colors.white10, height: 28),
          _buildSectionTitle(
            Icons.business_center,
            'Datos laborales',
            'Información correspondiente a tu puesto',
          ),
          const SizedBox(height: 12),
          _buildFieldEditable(
            'Cymez',
            _cymezController,
            Icons.business,
            isEditable: false,
          ),
          _buildFieldEditable(
            'Departamento',
            _departamentoController,
            Icons.work_outline,
            isEditable: true,
          ),
          _buildFieldEditable(
            'Rol',
            _rolController,
            Icons.shield_outlined,
            isEditable: true,
          ),
          _buildFieldEditable(
            'Oficina / Sucursal',
            _oficinaController,
            Icons.location_on_outlined,
            isEditable: false,
          ),
          _buildFieldEditable(
            'Número de empleado',
            _numEmpleadoController,
            Icons.badge_outlined,
            isEditable: true,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton.icon(
              onPressed: _hayCambios && !_guardandoCambios
                  ? _guardarCambiosPerfil
                  : null,
              icon: Icon(
                _guardandoCambios ? Icons.sync_rounded : Icons.save_outlined,
                size: 18,
              ),
              label: Text(
                _guardandoCambios
                    ? 'Guardando...'
                    : (_hayCambios ? 'Guardar cambios' : 'Sin cambios'),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _hayCambios && !_guardandoCambios
                    ? primaryGradientStart
                    : inputBg,
                foregroundColor: _hayCambios && !_guardandoCambios
                    ? Colors.white
                    : Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: Colors.blue, size: 16),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.grey, fontSize: 10),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCardInformacionCuenta() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.info_outline, color: Colors.blueAccent, size: 18),
              SizedBox(width: 8),
              Text(
                'Información de la cuenta',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Estado de la cuenta',
                    style: TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Activa',
                      style: TextStyle(
                        color: Colors.greenAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  Text(
                    'Rol en el sistema',
                    style: TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Gerente TI',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: inputBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: const [
                Icon(Icons.sync, color: Colors.blueAccent, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mantén tu información actualizada',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Una información correcta nos ayuda a darte un mejor soporte y atención.',
                        style: TextStyle(color: Colors.grey, fontSize: 10),
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

  Widget _buildCardSeguridad() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.security,
                  color: Colors.blueAccent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Seguridad de tu cuenta',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Administra las credenciales de acceso a tu perfil administrativo',
                      style: TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSecurityCard(
            Icons.key,
            'Contraseña de acceso',
            'Última actualización: 21 ago. 2026',
            Icons.shield_outlined,
            'Actualizar contraseña',
            _showModalActualizarContrasena,
          ),
          const SizedBox(height: 12),
          _buildSecurityCard(
            Icons.verified_user_outlined,
            'Verificación en dos pasos',
            'Agrega una capa adicional de seguridad a tu cuenta.',
            Icons.add_circle_outline,
            'Activar',
            _showModalVerificacion2Pasos,
            status: 'Desactivada',
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityCard(
    IconData icon,
    String title,
    String description,
    IconData buttonIcon,
    String buttonText,
    VoidCallback onPressed, {
    String? status,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: inputBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.grey, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      description,
                      style: const TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (status != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  status,
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ],
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onPressed,
              icon: Icon(buttonIcon, size: 14, color: Colors.blueAccent),
              label: Text(
                buttonText,
                style: const TextStyle(color: Colors.blueAccent, fontSize: 12),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.blueAccent),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showModalActualizarContrasena() {
    final actualCtrl = TextEditingController();
    final nuevaCtrl = TextEditingController();
    final confirmarCtrl = TextEditingController();
    var actualizando = false;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.shield_outlined,
                color: Colors.blue,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Actualizar contraseña',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.grey, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cambia tu contraseña de acceso',
              style: TextStyle(color: Colors.grey, fontSize: 10),
            ),
            const SizedBox(height: 16),
            _buildLabelModal('Contraseña actual'),
            _buildInputModal(
              'Ingresa tu contraseña actual',
              controller: actualCtrl,
              isPassword: true,
            ),
            const SizedBox(height: 12),
            _buildLabelModal('Nueva contraseña'),
            _buildInputModal(
              'Ingresa tu nueva contraseña',
              controller: nuevaCtrl,
              isPassword: true,
            ),
            const SizedBox(height: 6),
            const Text(
              'Mínimo 8 caracteres, mayúscula, minúscula, número y símbolo.',
              style: TextStyle(color: Colors.grey, fontSize: 10),
            ),
            const SizedBox(height: 12),
            _buildLabelModal('Confirmar nueva contraseña'),
            _buildInputModal(
              'Confirma tu nueva contraseña',
              controller: confirmarCtrl,
              isPassword: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGradientStart,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              if (actualizando) return;
              actualizando = true;
              final password = nuevaCtrl.text;
              final cumple =
                  password.length >= 8 &&
                  RegExp(r'[A-Z]').hasMatch(password) &&
                  RegExp(r'[a-z]').hasMatch(password) &&
                  RegExp(r'[0-9]').hasMatch(password) &&
                  RegExp(r'[^A-Za-z0-9]').hasMatch(password);
              if (!cumple) {
                _mostrarMensaje(
                  'La contraseña no cumple los requisitos.',
                  true,
                );
                actualizando = false;
                return;
              }
              if (password != confirmarCtrl.text) {
                _mostrarMensaje('Las contraseñas no coinciden.', true);
                actualizando = false;
                return;
              }
              Navigator.pop(context);
              try {
                final respuesta = await PerfiladminService.actualizarPassword(
                  passwordActual: actualCtrl.text,
                  password: password,
                  confirmacion: confirmarCtrl.text,
                );
                if (!mounted) return;
                _mostrarMensaje(
                  respuesta['message']?.toString() ?? 'Solicitud completada.',
                  respuesta['success'] != true,
                );
              } catch (e) {
                if (mounted) {
                  _mostrarMensaje(e.toString(), true);
                }
              } finally {
                actualCtrl.dispose();
                nuevaCtrl.dispose();
                confirmarCtrl.dispose();
              }
            },
            child: const Text(
              'Actualizar contraseña',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _showModalVerificacion2Pasos() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Verificación en dos pasos',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Para activar la verificación en dos pasos desde la versión web:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              _buildPasoItem('1.', 'Ingresa a tu perfil desde la cuenta web.'),
              _buildPasoItem(
                '2.',
                'Haz clic en "Activar verificación en dos pasos".',
              ),
              _buildPasoItem(
                '3.',
                'Descarga Google Authenticator o Microsoft Authenticator.',
              ),
              _buildPasoItem(
                '4.',
                'Escanea el código QR que aparece en la web.',
              ),
              _buildPasoItem(
                '5.',
                'Ingresa el código de 6 dígitos generado por la app y guarda la configuración.',
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC084FC),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 10,
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Entendido',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFF0D1630),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 36, 20, 20),
            decoration: const BoxDecoration(color: Color(0xFF0D1630)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Ticket',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                      TextSpan(
                        text: 'Pro',
                        style: TextStyle(
                          color: Color(0xFF3B82F6),
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const AdminAvatar(radius: 16),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Jesus Hinojosa',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Administrador',
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            Icons.dashboard_rounded,
            'Inicio',
            onTap: () {
              Navigator.pop(context);
              navigateWithLoading(
                context,
                const AdminScreen(),
                mensaje: 'Cargando inicio...',
              );
            },
          ),
          _buildDrawerItem(
            Icons.confirmation_number_outlined,
            'Tickets',
            onTap: () {
              Navigator.pop(context);
              navigateWithLoading(
                context,
                const TicketsScreen(),
                mensaje: 'Cargando tickets...',
              );
            },
          ),
          _buildDrawerItem(
            Icons.sync_alt_rounded,
            'Cambios',
            onTap: () {
              Navigator.pop(context);
              navigateWithLoading(
                context,
                const CambiosScreen(),
                mensaje: 'Cargando cambios...',
              );
            },
          ),
          _buildDrawerItem(
            Icons.people_outline,
            'Usuarios',
            onTap: () {
              Navigator.pop(context);
              navigateWithLoading(
                context,
                const UserScreen(),
                mensaje: 'Cargando usuarios...',
              );
            },
          ),
          _buildDrawerItem(
            Icons.devices_other,
            'Dispositivos',
            onTap: () {
              Navigator.pop(context);
              navigateWithLoading(
                context,
                const DispositivosScreen(),
                mensaje: 'Cargando dispositivos...',
              );
            },
          ),
          _buildDrawerItem(
            Icons.campaign_outlined,
            'Avisos',
            onTap: () {
              Navigator.pop(context);
              navigateWithLoading(
                context,
                const AvisosadminScreen(),
                mensaje: 'Cargando avisos...',
              );
            },
          ),
          _buildDrawerItem(
            Icons.person_outline,
            'Mi perfil',
            selected: true,
            onTap: () {
              Navigator.pop(context);
            },
          ),
          const Divider(color: Colors.white10, height: 24),
          _buildDrawerItem(
            Icons.logout_rounded,
            'Cerrar sesión',
            isExit: true,
            onTap: () async {
              await SessionService.clearSession();

              if (!mounted) {
                return;
              }

              if (!context.mounted) {
                return;
              }

              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    IconData icon,
    String title, {
    bool selected = false,
    bool isExit = false,
    VoidCallback? onTap,
  }) {
    final itemColor = isExit
        ? Colors.redAccent
        : selected
        ? Colors.white
        : const Color(0xFF94A3B8);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        tileColor: selected ? const Color(0xFF4F46E5) : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        leading: Icon(icon, color: itemColor, size: 20),
        title: Text(
          title,
          style: TextStyle(
            color: itemColor,
            fontSize: 14,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildFieldEditable(
    String label,
    TextEditingController controller,
    IconData icon, {
    required bool isEditable,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Icon(
                    isEditable ? Icons.edit_outlined : Icons.lock_outline,
                    color: isEditable ? Colors.blueAccent : Colors.grey,
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isEditable ? 'Editable' : 'FIJO',
                    style: TextStyle(
                      color: isEditable ? Colors.blueAccent : Colors.grey,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            readOnly: !isEditable,
            keyboardType: label == 'Teléfono'
                ? TextInputType.phone
                : TextInputType.text,
            inputFormatters: label == 'Teléfono'
                ? [FilteringTextInputFormatter.digitsOnly]
                : null,
            onChanged: label == 'Teléfono'
                ? (value) {
                    final formatted = _formatearTelefono(value);
                    if (formatted != value) {
                      controller.value = TextEditingValue(
                        text: formatted,
                        selection: TextSelection.collapsed(
                          offset: formatted.length,
                        ),
                      );
                    }
                  }
                : null,
            style: TextStyle(
              color: isEditable ? Colors.white : Colors.white54,
              fontSize: 13,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.grey, size: 18),
              filled: true,
              fillColor: inputBg,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabelModal(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInputModal(
    String hint, {
    TextEditingController? controller,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
        filled: true,
        fillColor: inputBg,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Future<void> _seleccionarFoto() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
    );
    if (!mounted || result.isEmpty) {
      return;
    }
    final archivo = result.single;
    final bytes = await archivo.readAsBytes();
    if (bytes.length > 2 * 1024 * 1024) {
      _mostrarMensaje('La imagen no debe superar 2 MB.', true);
      return;
    }
    if (!mounted) return;
    setState(() {
      _fotoNueva = archivo;
      _fotoPreviewBytes = bytes;
    });
  }

  Future<void> _actualizarFoto() async {
    final archivo = _fotoNueva;
    if (archivo == null) return;
    setState(() => _actualizandoFoto = true);
    final respuesta = await PerfiladminService.actualizarFoto(archivo);
    if (!mounted) return;
    final usuario = respuesta['usuario'] ?? respuesta['user'];
    final datos = respuesta['data'];
    final picture =
        respuesta['picture']?.toString() ??
        respuesta['picture_url']?.toString() ??
        (usuario is Map ? usuario['picture']?.toString() : null) ??
        (datos is Map ? datos['picture']?.toString() : null);
    if (respuesta['success'] == true && picture != null && picture.isNotEmpty) {
      await SessionService.updatePicture(picture);
    }
    setState(() {
      _actualizandoFoto = false;
      if (respuesta['success'] == true) {
        if (picture != null && picture.isNotEmpty) {
          _fotoUrl = ApiService.storageFileUrl(picture);
          _tieneFoto = true;
          _fotoNueva = null;
          _fotoPreviewBytes = null;
        }
      }
    });
    _mostrarMensaje(
      respuesta['message']?.toString() ?? 'Solicitud completada.',
      respuesta['success'] != true,
    );
  }

  Future<void> _eliminarFoto() async {
    setState(() => _eliminandoFoto = true);
    final respuesta = await PerfiladminService.eliminarFoto();
    if (!mounted) return;
    final usuario = respuesta['usuario'] ?? respuesta['user'];
    final picture =
        respuesta['picture']?.toString() ??
        (usuario is Map ? usuario['picture']?.toString() : null);
    if (respuesta['success'] == true && picture != null) {
      await SessionService.updatePicture(picture);
    }
    setState(() {
      _eliminandoFoto = false;
      if (respuesta['success'] == true) {
        _fotoUrl = null;
        _tieneFoto = false;
        _fotoNueva = null;
        _fotoPreviewBytes = null;
      }
    });
    _mostrarMensaje(
      respuesta['message']?.toString() ?? 'Solicitud completada.',
      respuesta['success'] != true,
    );
  }

  bool _esFotoPersonalizada(String picture) {
    final normalized = picture.trim().toLowerCase();
    return normalized.isNotEmpty &&
        normalized != 'user.png' &&
        !normalized.endsWith('/user.png') &&
        !normalized.contains('profile-photos/user.png');
  }

  void _mostrarMensaje(String mensaje, bool esError) {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        final color = esError
            ? const Color(0xFFEF4444)
            : const Color(0xFF22C55E);
        final icon = esError
            ? Icons.error_outline_rounded
            : Icons.check_circle_rounded;

        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          backgroundColor: const Color(0xFF111827),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 30),
                ),
                const SizedBox(height: 16),
                Text(
                  esError ? 'Error' : 'Éxito',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  mensaje,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Aceptar'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPasoItem(String num, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$num ',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _usuarioController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    _cymezController.dispose();
    _departamentoController.dispose();
    _rolController.dispose();
    _oficinaController.dispose();
    _numEmpleadoController.dispose();
    super.dispose();
  }
}
