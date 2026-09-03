import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../services/admin/perfiladmin_service.dart';
import '../../services/session_service.dart';
import 'avisosadmin_screen.dart';
import 'backup_screen.dart';
import 'cambios_screen.dart';
import 'dispositivos_screen.dart';
import 'tickets_screen.dart';
import 'users_screen.dart';

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
  bool _cargandoPerfil = true;
  bool _actualizandoFoto = false;
  bool _eliminandoFoto = false;
  bool _guardandoPassword = false;

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
              IconButton(
                icon: const Icon(Icons.notifications_none, color: Colors.grey),
                onPressed: () {},
              ),
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
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blueAccent.withValues(alpha: 0.2),
              child: const Text(
                'JH',
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: _buildAppDrawer(),
      body: _cargandoPerfil
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
    _cargarPerfil();
  }

  Future<void> _cargarPerfil() async {
    try {
      final respuesta = await PerfiladminService.obtenerPerfil();
      final usuario = respuesta['usuario'];
      if (!mounted) return;
      if (usuario is Map) {
        setState(() {
          _nombreController.text = _valor(
            usuario['name'],
            _nombreController.text,
          );
          _usuarioController.text = _valor(
            usuario['login'],
            _usuarioController.text,
          );
          _correoController.text = _valor(
            usuario['email'],
            _correoController.text,
          );
          _telefonoController.text = _valor(
            usuario['phone'] ?? usuario['telefono'],
            _telefonoController.text,
          );
          _cymezController.text = _valor(
            usuario['empresa'],
            _cymezController.text,
          );
          _departamentoController.text = _valor(
            usuario['departamento'],
            _departamentoController.text,
          );
          _rolController.text = _valor(usuario['role'], _rolController.text);
          _oficinaController.text = _valor(
            usuario['oficina'],
            _oficinaController.text,
          );
          _numEmpleadoController.text = _valor(
            usuario['numero_empleado'],
            _numEmpleadoController.text,
          );
          _fotoUrl =
              respuesta['picture_url']?.toString() ??
              usuario['picture_url']?.toString() ??
              usuario['picture']?.toString();
          _tieneFoto = _esFotoPersonalizada(_fotoUrl);
          _cargandoPerfil = false;
        });
      } else {
        throw Exception('La respuesta no contiene información del perfil.');
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _cargandoPerfil = false);
      _mostrarMensaje(error.toString().replaceFirst('Exception: ', ''), true);
    }
  }

  String _valor(dynamic value, String fallback) {
    final texto = value?.toString().trim() ?? '';
    return texto.isEmpty ? fallback : texto;
  }

  bool _esFotoPersonalizada(String? value) {
    if (value == null || value.trim().isEmpty) return false;
    return !value.contains('profile-photos/user.png') &&
        !value.endsWith('/user.png');
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
                      : _tieneFoto && _fotoUrl != null
                      ? Image.network(
                          _fotoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _avatarInicial(),
                        )
                      : _avatarInicial(),
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
                    icon: const Icon(
                      Icons.camera_alt,
                      color: Colors.black,
                      size: 16,
                    ),
                    onPressed: _seleccionarFoto,
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

  Widget _avatarInicial() {
    final nombre = _nombreController.text.trim();
    final iniciales = nombre.isEmpty
        ? 'U'
        : nombre
              .split(RegExp(r'\s+'))
              .take(2)
              .map((parte) => parte[0].toUpperCase())
              .join();
    return Center(
      child: Text(
        iniciales,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
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
              onPressed: () {},
              icon: const Icon(Icons.save_outlined, size: 18),
              label: const Text(
                'Sin cambios',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: inputBg,
                foregroundColor: Colors.grey,
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
    final actual = TextEditingController();
    final nueva = TextEditingController();
    final confirmacion = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
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
              onPressed: () => Navigator.pop(dialogContext),
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
              controller: actual,
              isPassword: true,
            ),
            const SizedBox(height: 12),
            _buildLabelModal('Nueva contraseña'),
            _buildInputModal(
              'Ingresa tu nueva contraseña',
              controller: nueva,
              isPassword: true,
            ),
            const SizedBox(height: 12),
            _buildLabelModal('Confirmar nueva contraseña'),
            _buildInputModal(
              'Confirma tu nueva contraseña',
              controller: confirmacion,
              isPassword: true,
            ),
            const SizedBox(height: 8),
            const Text(
              'Mínimo 8 caracteres, mayúscula, minúscula, número y símbolo.',
              style: TextStyle(color: Colors.grey, fontSize: 10),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGradientStart,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: _guardandoPassword
                ? null
                : () async {
                    final valor = nueva.text;
                    final valida =
                        valor.length >= 8 &&
                        RegExp(r'[A-Z]').hasMatch(valor) &&
                        RegExp(r'[a-z]').hasMatch(valor) &&
                        RegExp(r'\d').hasMatch(valor) &&
                        RegExp(r'[^A-Za-z0-9]').hasMatch(valor);
                    if (!valida) {
                      _mostrarMensaje(
                        'La nueva contraseña no cumple los requisitos.',
                        true,
                      );
                      return;
                    }
                    if (valor != confirmacion.text) {
                      _mostrarMensaje(
                        'La confirmación de contraseña no coincide.',
                        true,
                      );
                      return;
                    }
                    setState(() => _guardandoPassword = true);
                    try {
                      await PerfiladminService.actualizarPassword(
                        passwordActual: actual.text,
                        password: valor,
                        confirmPassword: confirmacion.text,
                      );
                      if (!mounted) return;
                      Navigator.pop(dialogContext);
                      _mostrarMensaje(
                        'Contraseña actualizada correctamente.',
                        false,
                      );
                    } catch (error) {
                      _mostrarMensaje(
                        error.toString().replaceFirst('Exception: ', ''),
                        true,
                      );
                    } finally {
                      if (mounted) setState(() => _guardandoPassword = false);
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
                  child: const Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Color(0xFF4F46E5),
                        child: Text(
                          'JH',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
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
              Navigator.pushReplacementNamed(context, '/admin');
            },
          ),
          _buildDrawerItem(
            Icons.confirmation_number_outlined,
            'Tickets',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TicketsScreen()),
              );
            },
          ),
          _buildDrawerItem(
            Icons.sync_alt_rounded,
            'Cambios',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CambiosScreen()),
              );
            },
          ),
          _buildDrawerItem(
            Icons.people_outline,
            'Usuarios',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UserScreen()),
              );
            },
          ),
          _buildDrawerItem(
            Icons.devices_other,
            'Dispositivos',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DispositivosScreen(),
                ),
              );
            },
          ),
          _buildDrawerItem(
            Icons.campaign_outlined,
            'Avisos',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AvisosadminScreen(),
                ),
              );
            },
          ),
          _buildDrawerItem(
            Icons.backup_outlined,
            'Backups',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BackupScreen()),
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF4F46E5) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isExit
              ? Colors.redAccent
              : selected
              ? Colors.white
              : const Color(0xFF94A3B8),
          size: 20,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isExit
                ? Colors.redAccent
                : selected
                ? Colors.white
                : const Color(0xFF94A3B8),
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
    final resultado = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
    );
    if (!mounted || resultado.isEmpty) return;
    final archivo = resultado.single;
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
    try {
      final respuesta = await PerfiladminService.actualizarFoto(archivo);
      if (!mounted) return;
      setState(() {
        _fotoUrl = respuesta['picture_url']?.toString();
        _tieneFoto = true;
        _fotoNueva = null;
        _fotoPreviewBytes = null;
      });
      _mostrarMensaje('Foto actualizada correctamente.', false);
    } catch (error) {
      _mostrarMensaje(error.toString().replaceFirst('Exception: ', ''), true);
    } finally {
      if (mounted) setState(() => _actualizandoFoto = false);
    }
  }

  Future<void> _eliminarFoto() async {
    setState(() => _eliminandoFoto = true);
    try {
      await PerfiladminService.eliminarFoto();
      if (!mounted) return;
      setState(() {
        _fotoUrl = null;
        _tieneFoto = false;
        _fotoNueva = null;
        _fotoPreviewBytes = null;
      });
      _mostrarMensaje('Foto eliminada correctamente.', false);
    } catch (error) {
      _mostrarMensaje(error.toString().replaceFirst('Exception: ', ''), true);
    } finally {
      if (mounted) setState(() => _eliminandoFoto = false);
    }
  }

  void _mostrarMensaje(String mensaje, bool esError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: esError ? Colors.redAccent : Colors.green,
      ),
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
