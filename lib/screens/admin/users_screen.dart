import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/admin/users_services.dart';
import '../../widgets/loading_screen.dart';
import '../../services/session_service.dart';
import '../../widgets/admin_notification_bell.dart';
import 'avisosadmin_screen.dart';
import 'cambios_screen.dart';
import 'dispositivos_screen.dart';
import 'home_screen.dart';
import 'perfiladmin_screen.dart';
import 'tickets_screen.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  static const Color background = Color(0xFF070B18);
  static const Color cardBg = Color(0xFF0F172A);
  static const Color sidebarBg = Color(0xFF0D1630);
  static const Color primaryBlue = Color(0xFF4F46E5);
  static const Color accentBlue = Color(0xFF3B82F6);
  static const Color greenAccent = Color(0xFF00A86B);
  static const Color redAccent = Color(0xFFE11D48);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textWhite = Colors.white;

  String selectedFilter = 'Todos';
  String searchQuery = '';
  bool _isLoading = false;
  int _paginaActual = 1;
  int _ultimaPagina = 1;
  int _totalUsuarios = 0;
  Map<String, dynamic> _estadisticas = {};

  final TextEditingController searchController = TextEditingController();
  List<UsuarioItem> usuarios = [];

  @override
  void initState() {
    super.initState();
    _cargarUsuarios();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<UsuarioItem> get usuariosFiltrados {
    return usuarios.where((user) {
      final coincideEstado =
          selectedFilter == 'Todos' ||
          (selectedFilter == 'Activos' && user.estado == 'Activa') ||
          (selectedFilter == 'Inactivos' && user.estado == 'Inactiva');

      final query = searchQuery.toLowerCase();

      final coincideBusqueda =
          query.isEmpty ||
          user.nombre.toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query) ||
          user.login.toLowerCase().contains(query) ||
          user.departamento.toLowerCase().contains(query);

      return coincideEstado && coincideBusqueda;
    }).toList();
  }

  Future<void> _cargarUsuarios({bool resetPage = false}) async {
    if (_isLoading) return;

    if (resetPage) {
      _paginaActual = 1;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final estado = selectedFilter == 'Activos'
          ? 'activos'
          : selectedFilter == 'Inactivos'
          ? 'inactivos'
          : 'todos';

      final respuesta = await UsersService.obtenerUsuarios(
        estado: estado,
        buscar: searchQuery,
        pagina: _paginaActual,
      );

      if (!mounted) return;

      final rawUsuarios = (respuesta['usuarios'] as List?) ?? const [];
      final nuevaLista = rawUsuarios
          .whereType<Map>()
          .map((item) => UsuarioItem.fromMap(Map<String, dynamic>.from(item)))
          .toList();

      final pagination = respuesta['pagination'] is Map
          ? Map<String, dynamic>.from(respuesta['pagination'])
          : <String, dynamic>{};
      final estadisticas = respuesta['estadisticas'] is Map
          ? Map<String, dynamic>.from(respuesta['estadisticas'])
          : <String, dynamic>{};

      setState(() {
        usuarios = nuevaLista;
        _totalUsuarios = _toInt(
          pagination['total'] ?? estadisticas['total'] ?? 0,
        );
        _ultimaPagina = _toInt(pagination['last_page'] ?? 1);
        _estadisticas = estadisticas;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        usuarios = [];
        _totalUsuarios = 0;
        _ultimaPagina = 1;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  Future<void> _irAPagina(int pagina) async {
    if (pagina < 1 || pagina > _ultimaPagina) return;
    _paginaActual = pagina;
    await _cargarUsuarios();
  }

  @override
  Widget build(BuildContext context) {
    final usuariosMostrados = usuariosFiltrados;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: sidebarBg,
        foregroundColor: Colors.white,
        elevation: 0,
        title: RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'Ticket',
                style: TextStyle(
                  color: textWhite,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              TextSpan(
                text: 'Pro',
                style: TextStyle(
                  color: accentBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
        actions: [
          const AdminNotificationBell(),
          const SizedBox(width: 8),
          const AdminProfileMenu(radius: 16),
          const SizedBox(width: 12),
        ],
      ),
      drawer: const CustomSidebar(activeMenu: 'Usuarios'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Usuarios',
              style: TextStyle(
                color: textWhite,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Consulta y administra la información de los usuarios del sistema',
              style: TextStyle(color: textMuted, fontSize: 13),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 90,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  KPIStatCard(
                    title: 'Total de usuarios',
                    count: _totalUsuarios.toString(),
                    icon: Icons.people_outline,
                    iconColor: accentBlue,
                  ),
                  const SizedBox(width: 10),
                  KPIStatCard(
                    title: 'Cuentas activas',
                    count: _toInt(_estadisticas['activos'] ?? 0).toString(),
                    icon: Icons.person_add_alt_1_outlined,
                    iconColor: greenAccent,
                  ),
                  const SizedBox(width: 10),
                  KPIStatCard(
                    title: 'Cuentas inactivas',
                    count: _toInt(_estadisticas['inactivos'] ?? 0).toString(),
                    icon: Icons.person_off_outlined,
                    iconColor: redAccent,
                  ),
                  const SizedBox(width: 10),
                  KPIStatCard(
                    title: 'Administradores',
                    count: _toInt(
                      _estadisticas['administradores'] ?? 0,
                    ).toString(),
                    icon: Icons.security,
                    iconColor: primaryBlue,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildFilterChip('Todos'),
                _buildFilterChip('Activos', dotColor: greenAccent),
                _buildFilterChip('Inactivos', dotColor: redAccent),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: textMuted, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                        _cargarUsuarios(resetPage: true);
                      },
                      style: const TextStyle(color: textWhite, fontSize: 13),
                      decoration: const InputDecoration(
                        hintText: 'Buscar usuario...',
                        hintStyle: TextStyle(color: textMuted, fontSize: 13),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                  if (searchQuery.isNotEmpty)
                    IconButton(
                      onPressed: () {
                        searchController.clear();
                        setState(() {
                          searchQuery = '';
                        });
                      },
                      icon: const Icon(Icons.close, color: textMuted, size: 18),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 26),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (usuariosMostrados.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white10),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.people_outline, color: textMuted, size: 40),
                    SizedBox(height: 10),
                    Text(
                      'No se encontraron usuarios',
                      style: TextStyle(
                        color: textWhite,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Intenta cambiar el filtro o la búsqueda.',
                      style: TextStyle(color: textMuted, fontSize: 11),
                    ),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: usuariosMostrados.length,
                itemBuilder: (context, index) {
                  final user = usuariosMostrados[index];

                  return UserCard(
                    item: user,
                    onView: () => _mostrarDetalleUsuario(context, user),
                    onEdit: () => _mostrarEditarUsuario(context, user),
                    onDelete: () => _mostrarEliminarUsuario(context, user),
                  );
                },
              ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Mostrando ${usuariosMostrados.length} de $_totalUsuarios usuarios',
                    style: const TextStyle(color: textMuted, fontSize: 11),
                  ),
                  Row(
                    children: [
                      _buildPageBtn(
                        icon: Icons.chevron_left,
                        disabled: _paginaActual <= 1,
                        onTap: _paginaActual > 1
                            ? () => _irAPagina(_paginaActual - 1)
                            : null,
                      ),
                      const SizedBox(width: 4),
                      _buildPageBtn(
                        text: '$_paginaActual',
                        selected: true,
                        disabled: false,
                      ),
                      const SizedBox(width: 4),
                      _buildPageBtn(
                        icon: Icons.chevron_right,
                        disabled: _paginaActual >= _ultimaPagina,
                        onTap: _paginaActual < _ultimaPagina
                            ? () => _irAPagina(_paginaActual + 1)
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, {Color? dotColor}) {
    final bool isSelected = selectedFilter == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = label;
        });
        _cargarUsuarios(resetPage: true);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? primaryBlue : cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? primaryBlue : Colors.white10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? textWhite : textMuted,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (dotColor != null) ...[
              const SizedBox(width: 6),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPageBtn({
    String? text,
    IconData? icon,
    bool selected = false,
    bool disabled = false,
    VoidCallback? onTap,
  }) {
    final child = Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: selected
            ? primaryBlue
            : disabled
            ? Colors.white.withValues(alpha: 0.02)
            : cardBg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: selected ? primaryBlue : Colors.white10),
      ),
      child: Center(
        child: icon != null
            ? Icon(icon, color: disabled ? Colors.white24 : textWhite, size: 16)
            : Text(
                text!,
                style: TextStyle(
                  color: selected ? textWhite : textMuted,
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
      ),
    );

    if (disabled || onTap == null) {
      return child;
    }

    return GestureDetector(onTap: onTap, child: child);
  }

  void _mostrarDetalleUsuario(BuildContext context, UsuarioItem user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E3A8A), Color(0xFF312E81)],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person_outline_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Información del usuario',
                              style: TextStyle(
                                color: textWhite,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Detalle completo de la cuenta',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildStatusBadge(user.estado),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: accentBlue, width: 2),
                            ),
                            child: CircleAvatar(
                              radius: 36,
                              backgroundColor: primaryBlue,
                              child: Text(
                                user.getInitials(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 4,
                            bottom: 4,
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: user.estado == 'Activa'
                                    ? greenAccent
                                    : redAccent,
                                shape: BoxShape.circle,
                                border: Border.all(color: background, width: 2),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        user.nombre,
                        style: const TextStyle(
                          color: textWhite,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        user.email,
                        style: const TextStyle(color: textMuted, fontSize: 12),
                      ),
                      const SizedBox(height: 6),
                      _buildRoleBadge(user.rol),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Información general',
                  style: TextStyle(
                    color: textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                _buildInfoTile(Icons.alternate_email, 'Login', user.login),
                _buildInfoTile(
                  Icons.badge_outlined,
                  'Número de empleado',
                  user.numEmpleado,
                ),
                _buildInfoTile(Icons.domain, 'Empresa', user.empresa),
                _buildInfoTile(
                  Icons.location_on_outlined,
                  'Oficina',
                  user.oficina,
                ),
                _buildInfoTile(
                  Icons.business_outlined,
                  'Departamento',
                  user.departamento,
                ),
                _buildInfoTile(Icons.shield_outlined, 'Rol', user.rol),
                const SizedBox(height: 16),
                const Text(
                  'Información de contacto',
                  style: TextStyle(
                    color: textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.email_outlined,
                            color: textMuted,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Correo electrónico',
                                  style: TextStyle(
                                    color: textMuted,
                                    fontSize: 10,
                                  ),
                                ),
                                Text(
                                  user.email,
                                  style: const TextStyle(
                                    color: textWhite,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(color: Colors.white10, height: 16),
                      Row(
                        children: [
                          const Icon(
                            Icons.phone_outlined,
                            color: textMuted,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Teléfono',
                                style: TextStyle(
                                  color: textMuted,
                                  fontSize: 10,
                                ),
                              ),
                              Text(
                                user.telefono,
                                style: const TextStyle(
                                  color: textWhite,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Permisos',
                  style: TextStyle(
                    color: textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: user.permisos.isEmpty
                      ? [
                          const Text(
                            'Sin permisos asignados',
                            style: TextStyle(color: textMuted, fontSize: 12),
                          ),
                        ]
                      : user.permisos.map((permission) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: primaryBlue.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: primaryBlue.withValues(alpha: 0.4),
                              ),
                            ),
                            child: Text(
                              permission,
                              style: const TextStyle(
                                color: accentBlue,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _mostrarEditarUsuario(BuildContext context, UsuarioItem user) {
    final nombreCtrl = TextEditingController(text: user.nombre);
    final numEmpCtrl = TextEditingController(text: user.numEmpleado);
    final loginCtrl = TextEditingController(text: user.login);
    final emailCtrl = TextEditingController(text: user.email);
    final telCtrl = TextEditingController(
      text: user.telefono == 'Sin teléfono'
          ? ''
          : _formatPhoneNumber(user.telefono),
    );
    final deptoCtrl = TextEditingController(text: user.departamento);
    final roleCtrl = TextEditingController(text: user.rol);
    final passwordCtrl = TextEditingController();
    bool passwordVisible = false;

    String selectedOficina = user.oficina;
    String selectedEstado = user.estado;
    String selectedAdmin = user.permisos.contains('Admin') ? 'Sí' : 'No';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 12,
                right: 12,
                bottom: MediaQuery.of(context).viewInsets.bottom + 14,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0B1220),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Container(
                          width: 48,
                          height: 5,
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF18213F), Color(0xFF111827)],
                          ),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF60A5FA),
                                    Color(0xFF4F46E5),
                                  ],
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0xFF4F46E5),
                                    blurRadius: 18,
                                    offset: Offset(0, 12),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.edit_note_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Editar usuario',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 19,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Actualiza datos, acceso y permisos.',
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.72,
                                      ),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: selectedEstado == 'Activa'
                                    ? greenAccent.withValues(alpha: 0.15)
                                    : redAccent.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: selectedEstado == 'Activa'
                                      ? greenAccent.withValues(alpha: 0.25)
                                      : redAccent.withValues(alpha: 0.25),
                                ),
                              ),
                              child: Text(
                                selectedEstado,
                                style: TextStyle(
                                  color: selectedEstado == 'Activa'
                                      ? greenAccent
                                      : redAccent,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Información personal',
                        style: TextStyle(
                          color: textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildInputField(
                              'Nombre',
                              nombreCtrl,
                              icon: Icons.person_outline_rounded,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildInputField(
                              'Empleado',
                              numEmpCtrl,
                              icon: Icons.badge_outlined,
                              trailing: InkWell(
                                onTap: () {
                                  setModalState(() {
                                    numEmpCtrl.text = _generateEmployeeNumber(
                                      usuarios,
                                    );
                                  });
                                },
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: accentBlue.withValues(alpha: 0.18),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Text(
                                    'Generar',
                                    style: TextStyle(
                                      color: accentBlue,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildInputField(
                              'Login',
                              loginCtrl,
                              icon: Icons.alternate_email_rounded,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildInputField(
                              'Teléfono',
                              telCtrl,
                              icon: Icons.phone_rounded,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              onChanged: (value) {
                                final formatted = _formatPhoneNumber(value);
                                if (formatted != value) {
                                  telCtrl.value = telCtrl.value.copyWith(
                                    text: formatted,
                                    selection: TextSelection.collapsed(
                                      offset: formatted.length,
                                    ),
                                    composing: TextRange.empty,
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _buildInputField(
                        'Correo electrónico',
                        emailCtrl,
                        icon: Icons.mail_outline_rounded,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Seguridad y acceso',
                        style: TextStyle(
                          color: textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildInputField(
                        'Nueva contraseña',
                        passwordCtrl,
                        icon: Icons.lock_outline_rounded,
                        obscureText: !passwordVisible,
                        hintText: 'Déjala vacía si no deseas cambiarla',
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () {
                                setModalState(() {
                                  passwordVisible = !passwordVisible;
                                });
                              },
                              icon: Icon(
                                passwordVisible
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                color: textMuted,
                                size: 17,
                              ),
                              splashRadius: 16,
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                            ),
                            InkWell(
                              onTap: () {
                                setModalState(() {
                                  passwordCtrl.text = _generatePassword();
                                  passwordVisible = true;
                                });
                              },
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: greenAccent.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  'Generar',
                                  style: TextStyle(
                                    color: greenAccent,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Ubicación y permisos',
                        style: TextStyle(
                          color: textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdown(
                              label: 'Oficina',
                              value: selectedOficina,
                              icon: Icons.location_on_outlined,
                              items: const ['Reynosa', 'Monterrey', 'CDMX'],
                              onChanged: (value) {
                                if (value != null) {
                                  setModalState(() {
                                    selectedOficina = value;
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildDropdown(
                              label: 'Estado',
                              value: selectedEstado,
                              icon: Icons.toggle_on_outlined,
                              items: const ['Activa', 'Inactiva'],
                              onChanged: (value) {
                                if (value != null) {
                                  setModalState(() {
                                    selectedEstado = value;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _buildInputField(
                        'Departamento',
                        deptoCtrl,
                        icon: Icons.business_outlined,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildInputField(
                              'Rol',
                              roleCtrl,
                              icon: Icons.shield_outlined,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildDropdown(
                              label: 'Admin',
                              value: selectedAdmin,
                              icon: Icons.admin_panel_settings_outlined,
                              items: const ['No', 'Sí'],
                              onChanged: (value) {
                                if (value != null) {
                                  setModalState(() {
                                    selectedAdmin = value;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                backgroundColor: Colors.white.withValues(
                                  alpha: 0.03,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Cancelar',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final currentContext = context;
                                final officeId = _resolveOficinaId(
                                  selectedOficina,
                                );
                                if (officeId == null) {
                                  if (currentContext.mounted) {
                                    _mostrarMensaje(
                                      currentContext,
                                      'Selecciona una oficina válida antes de guardar.',
                                      error: true,
                                    );
                                  }
                                  return;
                                }

                                final loginNuevo = loginCtrl.text.trim();
                                if (loginNuevo.isEmpty) {
                                  _mostrarMensaje(
                                    currentContext,
                                    'El login es obligatorio.',
                                    error: true,
                                  );
                                  return;
                                }

                                if (loginNuevo.toLowerCase() !=
                                    user.login.trim().toLowerCase()) {
                                  final loginExiste =
                                      await UsersService.existeLogin(
                                        loginNuevo,
                                      );
                                  if (!currentContext.mounted) return;
                                  if (loginExiste) {
                                    _mostrarMensaje(
                                      currentContext,
                                      'Ese login ya está asignado a otro usuario.',
                                      error: true,
                                    );
                                    return;
                                  }
                                }

                                final passwordActual =
                                    await _mostrarDialogoConfirmacionPassword(
                                      context: currentContext,
                                      usuario: user.nombre,
                                    );

                                if (passwordActual == null ||
                                    passwordActual.trim().isEmpty) {
                                  return;
                                }

                                final telefonoLimpio = telCtrl.text.trim();
                                final password = passwordCtrl.text.trim();

                                final result =
                                    await UsersService.actualizarUsuario(
                                      login: user.login.trim(),
                                      nuevoLogin: loginNuevo,
                                      nombre: nombreCtrl.text.trim(),
                                      email: emailCtrl.text.trim(),
                                      phone: telefonoLimpio.isEmpty
                                          ? null
                                          : telefonoLimpio,
                                      password: password.isEmpty
                                          ? null
                                          : password,
                                      currentPassword: passwordActual,
                                      numeroEmpleado: numEmpCtrl.text.trim(),
                                      role: roleCtrl.text.trim(),
                                      active: selectedEstado == 'Activa'
                                          ? 'Y'
                                          : 'N',
                                      privAdmin: selectedAdmin == 'Sí'
                                          ? 'Y'
                                          : 'N',
                                      oficinaId: officeId,
                                      departamento: deptoCtrl.text.trim(),
                                    );

                                if (!mounted || !currentContext.mounted) return;

                                if (result['success'] == true) {
                                  setState(() {
                                    user.nombre = nombreCtrl.text.trim();
                                    user.numEmpleado = numEmpCtrl.text.trim();
                                    user.login = loginCtrl.text.trim();
                                    user.email = emailCtrl.text.trim();
                                    user.telefono = telefonoLimpio.isEmpty
                                        ? 'Sin teléfono'
                                        : telefonoLimpio;
                                    user.departamento = deptoCtrl.text.trim();
                                    user.oficina = selectedOficina;
                                    user.rol = roleCtrl.text.trim();
                                    user.estado = selectedEstado;
                                    user.permisos = List<String>.from(
                                      user.permisos,
                                    );
                                    if (selectedAdmin == 'Sí') {
                                      if (!user.permisos.contains('Admin')) {
                                        user.permisos.add('Admin');
                                      }
                                    } else {
                                      user.permisos.remove('Admin');
                                    }
                                  });

                                  Navigator.pop(currentContext);
                                  _mostrarMensaje(
                                    currentContext,
                                    result['message']?.toString() ??
                                        'Usuario actualizado correctamente',
                                  );
                                  return;
                                }

                                _mostrarMensaje(
                                  currentContext,
                                  result['message']?.toString() ??
                                      'No se pudo actualizar el usuario.',
                                  error: true,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accentBlue,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(
                                Icons.save_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                              label: const Text(
                                'Guardar',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _mostrarEliminarUsuario(BuildContext context, UsuarioItem user) {
    final passwordCtrl = TextEditingController();
    bool passwordVisible = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: cardBg,
              title: const Text(
                'Eliminar usuario',
                style: TextStyle(color: textWhite, fontWeight: FontWeight.bold),
              ),
              content: SizedBox(
                width: 360,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¿Seguro que deseas eliminar a ${user.nombre}?',
                      style: const TextStyle(color: textMuted, fontSize: 13),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Contraseña actual',
                      style: TextStyle(color: textMuted, fontSize: 11),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D172A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.lock_outline_rounded,
                            color: textMuted,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: passwordCtrl,
                              obscureText: !passwordVisible,
                              style: const TextStyle(
                                color: textWhite,
                                fontSize: 12,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Escribe tu contraseña',
                                hintStyle: TextStyle(
                                  color: textMuted,
                                  fontSize: 12,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setDialogState(() {
                                passwordVisible = !passwordVisible;
                              });
                            },
                            icon: Icon(
                              passwordVisible
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              color: textMuted,
                              size: 17,
                            ),
                            splashRadius: 16,
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: textMuted),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: redAccent),
                  onPressed: () async {
                    final pass = passwordCtrl.text.trim();
                    if (pass.isEmpty) {
                      _mostrarMensaje(
                        context,
                        'Debes ingresar tu contraseña para eliminar al usuario.',
                        error: true,
                      );
                      return;
                    }

                    final result = await UsersService.eliminarUsuario(
                      login: user.login,
                      password: pass,
                    );

                    if (!context.mounted) return;

                    Navigator.pop(dialogContext);

                    if (result['success'] == true) {
                      setState(() {
                        usuarios.remove(user);
                      });
                      _mostrarMensaje(
                        context,
                        result['message']?.toString() ??
                            'Usuario eliminado correctamente',
                      );
                      return;
                    }

                    _mostrarMensaje(
                      context,
                      result['message']?.toString() ??
                          'No se pudo eliminar el usuario.',
                      error: true,
                    );
                  },
                  child: const Text(
                    'Eliminar',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller, {
    IconData? icon,
    bool obscureText = false,
    String? hintText,
    Widget? trailing,
    ValueChanged<String>? onChanged,
    List<TextInputFormatter>? inputFormatters,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: textMuted, fontSize: 11)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFF0D172A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: textMuted, size: 16),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: obscureText,
                  onChanged: onChanged,
                  keyboardType: keyboardType,
                  inputFormatters: inputFormatters,
                  style: const TextStyle(color: textWhite, fontSize: 12),
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: const TextStyle(color: textMuted, fontSize: 12),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 8), trailing],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    IconData? icon,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: textMuted, fontSize: 11)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF0D172A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: textMuted, size: 16),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: items.contains(value) ? value : items.first,
                    dropdownColor: cardBg,
                    isExpanded: true,
                    style: const TextStyle(color: textWhite, fontSize: 12),
                    iconEnabledColor: textMuted,
                    items: items.map((item) {
                      return DropdownMenuItem(value: item, child: Text(item));
                    }).toList(),
                    onChanged: onChanged,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatPhoneNumber(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    final limited = digits.substring(
      0,
      digits.length > 10 ? 10 : digits.length,
    );

    if (limited.length <= 3) {
      return limited.isEmpty ? '' : '(${limited.substring(0, limited.length)}';
    }

    if (limited.length <= 6) {
      return '(${limited.substring(0, 3)}) ${limited.substring(3)}';
    }

    return '(${limited.substring(0, 3)}) ${limited.substring(3, 6)}-${limited.substring(6)}';
  }

  String _generateEmployeeNumber(List<UsuarioItem> existingUsers) {
    final existingIds = existingUsers
        .map((user) => user.numEmpleado.trim())
        .where((value) => value.isNotEmpty)
        .toSet();

    final random = Random();
    int nextValue = 100000 + random.nextInt(900000);

    while (existingIds.contains(nextValue.toString())) {
      nextValue = 100000 + random.nextInt(900000);
    }

    return nextValue.toString();
  }

  String _generatePassword() {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#%^&*';
    final random = Random();
    return List.generate(12, (_) => chars[random.nextInt(chars.length)]).join();
  }

  int? _resolveOficinaId(String oficina) {
    final normalized = oficina.trim();
    const offices = {'Reynosa': 1, 'Monterrey': 2, 'CDMX': 3};

    return offices[normalized];
  }

  Widget _buildInfoTile(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Icon(icon, color: accentBlue, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: textMuted, fontSize: 10),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: textWhite,
                    fontSize: 12,
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

  Future<String?> _mostrarDialogoConfirmacionPassword({
    required BuildContext context,
    required String usuario,
  }) async {
    final controller = TextEditingController();
    bool passwordVisible = false;

    final result = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (innerContext, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF111827),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              title: const Text(
                'Confirmar edición',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Para guardar los cambios de $usuario, escribe tu contraseña actual.',
                    style: const TextStyle(color: textMuted, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D172A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.lock_outline_rounded,
                          color: textMuted,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: controller,
                            obscureText: !passwordVisible,
                            style: const TextStyle(
                              color: textWhite,
                              fontSize: 12,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Contraseña actual',
                              hintStyle: TextStyle(
                                color: textMuted,
                                fontSize: 12,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setDialogState(() {
                              passwordVisible = !passwordVisible;
                            });
                          },
                          icon: Icon(
                            passwordVisible
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                            color: textMuted,
                            size: 17,
                          ),
                          splashRadius: 16,
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: textMuted),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: accentBlue),
                  onPressed: () {
                    final pass = controller.text.trim();
                    if (pass.isEmpty) {
                      _mostrarMensaje(
                        innerContext,
                        'Debes escribir tu contraseña actual.',
                        error: true,
                      );
                      return;
                    }
                    Navigator.pop(dialogContext, pass);
                  },
                  child: const Text(
                    'Continuar',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    return result;
  }

  void _mostrarMensaje(
    BuildContext context,
    String mensaje, {
    bool error = false,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        final color = error ? const Color(0xFFEF4444) : const Color(0xFF22C55E);
        final icon = error
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
                  error ? 'Error' : 'Éxito',
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

  Widget _buildStatusBadge(String status) {
    final bool isActiva = status == 'Activa';
    final Color bg = isActiva
        ? greenAccent.withValues(alpha: 0.15)
        : redAccent.withValues(alpha: 0.15);
    final Color text = isActiva ? greenAccent : redAccent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(color: text, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              color: text,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleBadge(String role) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: primaryBlue.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryBlue.withValues(alpha: 0.3)),
      ),
      child: Text(
        role,
        style: const TextStyle(
          color: accentBlue,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class UsuarioItem {
  String nombre;
  String email;
  String login;
  String numEmpleado;
  String empresa;
  String oficina;
  String departamento;
  String rol;
  String estado;
  String telefono;
  List<String> permisos;

  UsuarioItem({
    required this.nombre,
    required this.email,
    required this.login,
    required this.numEmpleado,
    required this.empresa,
    required this.oficina,
    required this.departamento,
    required this.rol,
    required this.estado,
    required this.telefono,
    required this.permisos,
  });

  factory UsuarioItem.fromMap(Map<String, dynamic> map) {
    final nombre = (map['name'] ?? map['nombre'] ?? 'Sin nombre').toString();
    final email = (map['email'] ?? '').toString();
    final login = (map['login'] ?? '').toString();
    final numeroEmpleado = (map['numero_empleado'] ?? map['numEmpleado'] ?? '')
        .toString();
    final empresa = (map['empresa'] ?? map['company'] ?? 'Sin empresa')
        .toString();
    final oficina = (map['oficina'] ?? map['office'] ?? 'Sin oficina')
        .toString();
    final departamento = (map['departamento'] ?? 'Sin departamento').toString();
    final rol = (map['role'] ?? map['rol'] ?? 'usuario').toString();
    final estado =
        ((map['active'] ?? map['estado']) == 'Y' ||
            (map['active'] ?? map['estado']) == true ||
            (map['estado'] ?? '').toString().toLowerCase() == 'activa')
        ? 'Activa'
        : 'Inactiva';
    final telefonoRaw = (map['phone'] ?? map['telefono'] ?? '').toString();
    final permisos = <String>[];
    final privAdmin = (map['priv_admin'] ?? map['admin'] ?? 'N').toString();
    if (privAdmin.toUpperCase() == 'Y') {
      permisos.add('Admin');
    }
    final rolePermissions = map['permisos'];
    if (rolePermissions is List) {
      for (final permiso in rolePermissions) {
        if (permiso != null) {
          permisos.add(permiso.toString());
        }
      }
    }

    return UsuarioItem(
      nombre: nombre,
      email: email,
      login: login,
      numEmpleado: numeroEmpleado,
      empresa: empresa,
      oficina: oficina,
      departamento: departamento,
      rol: rol,
      estado: estado,
      telefono: telefonoRaw.isEmpty ? 'Sin teléfono' : telefonoRaw,
      permisos: permisos.isEmpty ? ['Tickets'] : permisos,
    );
  }

  String getInitials() {
    final parts = nombre.trim().split(' ');

    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }

    return parts[0][0].toUpperCase();
  }
}

class UserCard extends StatelessWidget {
  final UsuarioItem item;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const UserCard({
    super.key,
    required this.item,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFF4F46E5),
                child: Text(
                  item.getInitials(),
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.nombre,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      item.email,
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(item.estado),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(color: Colors.white10, height: 1),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: _buildRoleBadge(item.rol)),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: Text(
                  item.departamento,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 126,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: onView,
                          borderRadius: BorderRadius.circular(20),
                          child: const Padding(
                            padding: EdgeInsets.all(6),
                            child: Icon(
                              Icons.remove_red_eye_outlined,
                              color: Color(0xFF94A3B8),
                              size: 18,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: onEdit,
                          borderRadius: BorderRadius.circular(20),
                          child: const Padding(
                            padding: EdgeInsets.all(6),
                            child: Icon(
                              Icons.edit_outlined,
                              color: Color(0xFF94A3B8),
                              size: 18,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: onDelete,
                          borderRadius: BorderRadius.circular(20),
                          child: const Padding(
                            padding: EdgeInsets.all(6),
                            child: Icon(
                              Icons.delete_outline,
                              color: Color(0xFFE11D48),
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final bool isActiva = status == 'Activa';

    final Color bg = isActiva
        ? const Color(0xFF00A86B).withValues(alpha: 0.15)
        : const Color(0xFFE11D48).withValues(alpha: 0.15);

    final Color text = isActiva
        ? const Color(0xFF00A86B)
        : const Color(0xFFE11D48);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: text,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildRoleBadge(String role) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF4F46E5).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        role,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Color(0xFF3B82F6),
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class KPIStatCard extends StatelessWidget {
  final String title;
  final String count;
  final IconData icon;
  final Color iconColor;

  const KPIStatCard({
    super.key,
    required this.title,
    required this.count,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 10,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(icon, color: iconColor, size: 16),
            ],
          ),
          Text(
            count,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class CustomSidebar extends StatelessWidget {
  final String activeMenu;

  const CustomSidebar({super.key, this.activeMenu = 'Inicio'});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF0D1630),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF0D1630)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
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
                FutureBuilder<Map<String, dynamic>?>(
                  future: SessionService.getUser(),
                  builder: (context, snapshot) {
                    final user = snapshot.data ?? {};
                    final name = (user['name'] ?? 'Administrador').toString();
                    final role = (user['role'] ?? 'Admin').toString();

                    return Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const AdminAvatar(radius: 16),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name.isNotEmpty ? name : 'Administrador',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  role.isNotEmpty ? role : 'Admin',
                                  style: const TextStyle(
                                    color: Color(0xFF94A3B8),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          _drawerItem(
            context,
            Icons.dashboard_rounded,
            'Inicio',
            selected: activeMenu == 'Inicio',
            onTap: () {
              Navigator.pop(context);
              navigateWithLoading(
                context,
                const AdminScreen(),
                mensaje: 'Cargando inicio...',
              );
            },
          ),
          _drawerItem(
            context,
            Icons.confirmation_number_outlined,
            'Tickets',
            selected: activeMenu == 'Tickets',
            onTap: () {
              Navigator.pop(context);
              navigateWithLoading(
                context,
                const TicketsScreen(),
                mensaje: 'Cargando tickets...',
              );
            },
          ),
          _drawerItem(
            context,
            Icons.published_with_changes_rounded,
            'Cambios',
            selected: activeMenu == 'Cambios',
            onTap: () {
              Navigator.pop(context);
              navigateWithLoading(
                context,
                const CambiosScreen(),
                mensaje: 'Cargando cambios...',
              );
            },
          ),
          _drawerItem(
            context,
            Icons.people_outline,
            'Usuarios',
            selected: activeMenu == 'Usuarios',
            onTap: () {
              Navigator.pop(context);
            },
          ),
          _drawerItem(
            context,
            Icons.devices_other,
            'Dispositivos',
            selected: activeMenu == 'Dispositivos',
            onTap: () {
              Navigator.pop(context);
              navigateWithLoading(
                context,
                const DispositivosScreen(),
                mensaje: 'Cargando dispositivos...',
              );
            },
          ),
          _drawerItem(
            context,
            Icons.campaign_outlined,
            'Avisos',
            selected: activeMenu == 'Avisos',
            onTap: () {
              Navigator.pop(context);
              navigateWithLoading(
                context,
                const AvisosadminScreen(),
                mensaje: 'Cargando avisos...',
              );
            },
          ),
          _drawerItem(
            context,
            Icons.person_outline,
            'Mi perfil',
            selected: activeMenu == 'Mi perfil',
            onTap: () {
              Navigator.pop(context);
              navigateWithLoading(
                context,
                const PerfiladminScreen(),
                mensaje: 'Cargando perfil...',
              );
            },
          ),
          const Divider(color: Colors.white10),
          _drawerItem(
            context,
            Icons.logout,
            'Cerrar sesión',
            isExit: true,
            onTap: () async {
              Navigator.pop(context);

              await SessionService.clearSession();

              if (!context.mounted) return;

              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(
    BuildContext context,
    IconData icon,
    String title, {
    bool selected = false,
    bool isExit = false,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: selected ? const Color(0xFF4F46E5) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
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
      ),
    );
  }
}
