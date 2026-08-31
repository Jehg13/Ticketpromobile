import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/session_service.dart';
import '../../services/admin/users_services.dart';
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

  final TextEditingController searchController = TextEditingController();

  List<UsuarioItem> usuarios = [];

  bool cargando = true;
  bool eliminando = false;

  String? error;

  int paginaActual = 1;
  int ultimaPagina = 1;
  int totalUsuarios = 0;

  int totalActivos = 0;
  int totalInactivos = 0;
  int totalAdministradores = 0;

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

  Future<void> _cargarUsuarios({int pagina = 1}) async {
    if (!mounted) return;

    setState(() {
      cargando = true;
      error = null;
    });

    try {
      final respuesta = await UsersService.obtenerUsuarios(
        estado: _estadoApi(),
        buscar: searchQuery.trim(),
        pagina: pagina,
      );

      if (!mounted) return;

      if (respuesta['success'] == true) {
        final usuariosData = respuesta['usuarios'];

        final lista = usuariosData is List
            ? usuariosData
                  .whereType<Map>()
                  .map(
                    (item) =>
                        UsuarioItem.fromMap(Map<String, dynamic>.from(item)),
                  )
                  .toList()
            : <UsuarioItem>[];

        final pagination = respuesta['pagination'] is Map
            ? Map<String, dynamic>.from(respuesta['pagination'])
            : <String, dynamic>{};

        setState(() {
          usuarios = lista;

          paginaActual = _toInt(pagination['current_page'], pagina);

          ultimaPagina = _toInt(pagination['last_page'], 1);

          totalUsuarios = _toInt(pagination['total'], lista.length);

          _cargarEstadisticas(respuesta);

          cargando = false;
        });
      } else {
        setState(() {
          usuarios = [];
          cargando = false;
          error =
              respuesta['message']?.toString() ??
              'No se pudieron obtener los usuarios.';
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        cargando = false;
        error = 'No se pudieron cargar los usuarios.';
      });
    }
  }

  void _cargarEstadisticas(Map<String, dynamic> respuesta) {
    final estadisticas = UsersService.obtenerEstadisticas(respuesta);

    totalActivos = estadisticas['usuariosActivos'] ?? 0;

    totalInactivos = estadisticas['usuariosInactivos'] ?? 0;

    totalAdministradores = estadisticas['administradores'] ?? 0;

    if (totalUsuarios == 0) {
      totalUsuarios = estadisticas['totalUsuarios'] ?? 0;
    }
  }

  String _estadoApi() {
    switch (selectedFilter) {
      case 'Activos':
        return 'activa';

      case 'Inactivos':
        return 'inactiva';

      default:
        return 'todos';
    }
  }

  Future<void> _buscar() async {
    await _cargarUsuarios(pagina: 1);
  }

  Future<void> _cambiarPagina(int pagina) async {
    if (pagina < 1 || pagina > ultimaPagina) {
      return;
    }

    await _cargarUsuarios(pagina: pagina);
  }

  int _toInt(dynamic value, [int defecto = 0]) {
    if (value is int) return value;

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '') ?? defecto;
  }

  List<UsuarioItem> get usuariosMostrados {
    if (searchQuery.trim().isEmpty) {
      return usuarios;
    }

    final query = searchQuery.trim().toLowerCase();

    return usuarios.where((user) {
      return user.nombre.toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query) ||
          user.login.toLowerCase().contains(query) ||
          user.departamento.toLowerCase().contains(query) ||
          user.oficina.toLowerCase().contains(query) ||
          user.empresa.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final usuariosMostrados = usuariosMostradosGetter();

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
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          const AdminAvatar(radius: 16),
          const SizedBox(width: 12),
        ],
      ),
      drawer: const CustomSidebar(activeMenu: 'Usuarios'),
      body: RefreshIndicator(
        color: accentBlue,
        backgroundColor: cardBg,
        onRefresh: () => _cargarUsuarios(pagina: paginaActual),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
              _buildKpis(),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildFilterChip('Todos'),
                  _buildFilterChip('Activos', dotColor: greenAccent),
                  _buildFilterChip('Inactivos', dotColor: redAccent),
                ],
              ),
              const SizedBox(height: 12),
              _buildSearch(),
              const SizedBox(height: 16),
              if (cargando)
                _buildLoading()
              else if (error != null)
                _buildError()
              else if (usuariosMostrados.isEmpty)
                _buildEmpty()
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
              if (!cargando && error == null) _buildPagination(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  List<UsuarioItem> usuariosMostradosGetter() {
    return usuariosMostrados;
  }

  Widget _buildKpis() {
    return SizedBox(
      height: 90,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          KPIStatCard(
            title: 'Total de usuarios',
            count: totalUsuarios.toString(),
            icon: Icons.people_outline,
            iconColor: accentBlue,
          ),
          const SizedBox(width: 10),
          KPIStatCard(
            title: 'Cuentas activas',
            count: totalActivos.toString(),
            icon: Icons.person_add_alt_1_outlined,
            iconColor: greenAccent,
          ),
          const SizedBox(width: 10),
          KPIStatCard(
            title: 'Cuentas inactivas',
            count: totalInactivos.toString(),
            icon: Icons.person_off_outlined,
            iconColor: redAccent,
          ),
          const SizedBox(width: 10),
          KPIStatCard(
            title: 'Administradores',
            count: totalAdministradores.toString(),
            icon: Icons.security,
            iconColor: primaryBlue,
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Container(
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
              },
              onSubmitted: (_) => _buscar(),
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

                _cargarUsuarios(pagina: 1);
              },
              icon: const Icon(Icons.close, color: textMuted, size: 18),
            ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(35),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white10),
      ),
      child: const Column(
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: accentBlue,
            ),
          ),
          SizedBox(height: 14),
          Text(
            'Cargando usuarios...',
            style: TextStyle(color: textMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: redAccent.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: redAccent, size: 40),
          const SizedBox(height: 10),
          Text(
            error ?? 'Ocurrió un error.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: textMuted, fontSize: 12),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: () => _cargarUsuarios(pagina: paginaActual),
            style: ElevatedButton.styleFrom(backgroundColor: accentBlue),
            icon: const Icon(Icons.refresh, color: Colors.white, size: 16),
            label: const Text(
              'Reintentar',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Container(
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
            textAlign: TextAlign.center,
            style: TextStyle(color: textMuted, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination() {
    final desde = usuarios.isEmpty
        ? 0
        : ((paginaActual - 1) * usuarios.length) + 1;

    final hasta = usuarios.isEmpty ? 0 : desde + usuarios.length - 1;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Mostrando $desde-$hasta de $totalUsuarios usuarios',
              style: const TextStyle(color: textMuted, fontSize: 11),
            ),
          ),
          Row(
            children: [
              _buildPageBtn(
                icon: Icons.chevron_left,
                disabled: paginaActual <= 1,
                onTap: paginaActual > 1
                    ? () => _cambiarPagina(paginaActual - 1)
                    : null,
              ),
              const SizedBox(width: 4),
              _buildPageBtn(text: paginaActual.toString(), selected: true),
              const SizedBox(width: 4),
              _buildPageBtn(
                icon: Icons.chevron_right,
                disabled: paginaActual >= ultimaPagina,
                onTap: paginaActual < ultimaPagina
                    ? () => _cambiarPagina(paginaActual + 1)
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, {Color? dotColor}) {
    final isSelected = selectedFilter == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = label;
        });

        _cargarUsuarios(pagina: 1);
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
    return InkWell(
      onTap: disabled ? null : onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 30,
        height: 30,
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
              ? Icon(
                  icon,
                  color: disabled ? Colors.white24 : textWhite,
                  size: 17,
                )
              : Text(
                  text ?? '',
                  style: TextStyle(
                    color: selected ? textWhite : textMuted,
                    fontSize: 11,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
        ),
      ),
    );
  }

  Future<void> _mostrarDetalleUsuario(
    BuildContext context,
    UsuarioItem user,
  ) async {
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
                _buildSheetHandle(),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Información del usuario',
                      style: TextStyle(
                        color: textWhite,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _buildStatusBadge(user.estado),
                  ],
                ),
                const Text(
                  'Detalle completo de la cuenta',
                  style: TextStyle(color: textMuted, fontSize: 11),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 38,
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
                      const SizedBox(height: 10),
                      Text(
                        user.nombre,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: textWhite,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        user.email.isEmpty ? 'Sin correo' : user.email,
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
                _buildContactCard(user),
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
                _buildPermissions(user),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSheetHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildContactCard(UsuarioItem user) {
    return Container(
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
              const Icon(Icons.email_outlined, color: textMuted, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Correo electrónico',
                      style: TextStyle(color: textMuted, fontSize: 10),
                    ),
                    Text(
                      user.email.isEmpty ? 'Sin correo' : user.email,
                      style: const TextStyle(color: textWhite, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white10, height: 16),
          Row(
            children: [
              const Icon(Icons.phone_outlined, color: textMuted, size: 18),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Teléfono',
                    style: TextStyle(color: textMuted, fontSize: 10),
                  ),
                  Text(
                    user.telefono.isEmpty ? 'Sin teléfono' : user.telefono,
                    style: const TextStyle(color: textWhite, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPermissions(UsuarioItem user) {
    if (user.permisos.isEmpty) {
      return const Text(
        'Sin permisos asignados',
        style: TextStyle(color: textMuted, fontSize: 12),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: user.permisos.map((permission) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: primaryBlue.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: primaryBlue.withValues(alpha: 0.4)),
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
    );
  }

  Future<void> _mostrarEditarUsuario(
    BuildContext context,
    UsuarioItem user,
  ) async {
    final detalle = await UsersService.obtenerUsuario(user.login);

    if (!context.mounted) return;

    UsuarioItem usuarioEditar = user;

    if (detalle['success'] == true && detalle['usuario'] is Map) {
      usuarioEditar = UsuarioItem.fromMap(
        Map<String, dynamic>.from(detalle['usuario']),
      );
    }

    final nombreCtrl = TextEditingController(text: usuarioEditar.nombre);

    final numEmpCtrl = TextEditingController(text: usuarioEditar.numEmpleado);

    final loginCtrl = TextEditingController(text: usuarioEditar.login);

    final emailCtrl = TextEditingController(text: usuarioEditar.email);

    final telCtrl = TextEditingController(
      text: _formatearTelefono(usuarioEditar.telefono),
    );

    final passwordCtrl = TextEditingController();
    bool passwordVisible = false;
    final empresaCtrl = TextEditingController(text: usuarioEditar.empresa);
    final rolCtrl = TextEditingController(
      text: usuarioEditar.rol.isEmpty ? 'usuario' : usuarioEditar.rol,
    );
    final departamentoCtrl = TextEditingController(
      text: usuarioEditar.departamento,
    );

    String selectedEstado = usuarioEditar.estado.isEmpty
        ? 'Activa'
        : usuarioEditar.estado;

    String selectedAdmin = usuarioEditar.permisos.contains('Admin')
        ? 'Sí'
        : 'No';

    int? selectedEmpresaId = usuarioEditar.empresaId;

    String selectedEmpresa = usuarioEditar.empresa;

    int? selectedOficinaId = usuarioEditar.oficinaId;

    String selectedOficina = usuarioEditar.oficina;

    bool cargandoEmpresas = false;
    bool cargandoOficinas = false;

    List<Map<String, dynamic>> empresas = [];
    List<Map<String, dynamic>> oficinas = [];

    cargandoEmpresas = true;
    final empresasRespuesta = await UsersService.obtenerEmpresas();
    if (empresasRespuesta['success'] == true &&
        empresasRespuesta['empresas'] is List) {
      empresas = (empresasRespuesta['empresas'] as List)
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }
    cargandoEmpresas = false;

    final empresaId = selectedEmpresaId;

    if (empresaId != null) {
      cargandoOficinas = true;

      final respuesta = await UsersService.obtenerOficinasPorEmpresa(empresaId);

      if (respuesta['success'] == true && respuesta['oficinas'] is List) {
        oficinas = (respuesta['oficinas'] as List)
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }

      cargandoOficinas = false;
    } else {
      cargandoOficinas = true;

      final empresasRespuesta = await UsersService.obtenerEmpresas();

      if (empresasRespuesta['success'] == true &&
          empresasRespuesta['empresas'] is List) {
        empresas = (empresasRespuesta['empresas'] as List)
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();

        for (final empresa in empresas) {
          final empresaIdActual = _toInt(empresa['id']);

          if (empresaIdActual <= 0) {
            continue;
          }

          final respuesta = await UsersService.obtenerOficinasPorEmpresa(
            empresaIdActual,
          );

          if (respuesta['success'] == true && respuesta['oficinas'] is List) {
            oficinas.addAll(
              (respuesta['oficinas'] as List)
                  .whereType<Map>()
                  .map((item) => Map<String, dynamic>.from(item))
                  .toList(),
            );
          }
        }
      }

      cargandoOficinas = false;
    }

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                  children: [
                    _buildSheetHandle(),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1E3A8A), Color(0xFF312E81)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 14,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Row(
                        children: [
                          CircleAvatar(
                            radius: 21,
                            backgroundColor: Colors.white12,
                            child: Icon(
                              Icons.edit_outlined,
                              color: Colors.white,
                              size: 21,
                            ),
                          ),
                          SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Editar usuario',
                                style: TextStyle(
                                  color: textWhite,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                'Actualiza la información de la cuenta',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInputField('Nombre', nombreCtrl),
                    const SizedBox(height: 10),
                    _buildInputField(
                      'Número de empleado',
                      numEmpCtrl,
                      suffix: IconButton(
                        tooltip: 'Generar número disponible',
                        onPressed: () {
                          numEmpCtrl.text = _generarNumeroEmpleado();
                          numEmpCtrl.selection = TextSelection.collapsed(
                            offset: numEmpCtrl.text.length,
                          );
                        },
                        icon: const Icon(
                          Icons.auto_awesome,
                          color: accentBlue,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildInputField('Login', loginCtrl, enabled: false),
                    const SizedBox(height: 10),
                    _buildInputField('Correo electrónico', emailCtrl),
                    const SizedBox(height: 10),
                    _buildInputField(
                      'Teléfono',
                      telCtrl,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [TelefonoInputFormatter()],
                      hintText: '(899) 123-4567',
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Nueva contraseña',
                      style: TextStyle(color: textMuted, fontSize: 11),
                    ),
                    const SizedBox(height: 4),
                    _buildPasswordField(
                      passwordCtrl,
                      'Nueva contraseña temporal',
                      obscureText: !passwordVisible,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: passwordVisible
                                ? 'Ocultar contraseña'
                                : 'Mostrar contraseña',
                            onPressed: () {
                              setModalState(() {
                                passwordVisible = !passwordVisible;
                              });
                            },
                            icon: Icon(
                              passwordVisible
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: textMuted,
                              size: 18,
                            ),
                          ),
                          IconButton(
                            tooltip: 'Generar contraseña temporal',
                            onPressed: () {
                              setModalState(() {
                                passwordCtrl.text =
                                    _generarContrasenaTemporal();
                                passwordVisible = true;
                              });
                              passwordCtrl.selection = TextSelection.collapsed(
                                offset: passwordCtrl.text.length,
                              );
                            },
                            icon: const Icon(
                              Icons.auto_awesome,
                              color: accentBlue,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Ubicación',
                      style: TextStyle(
                        color: textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (cargandoEmpresas)
                      const Padding(
                        padding: EdgeInsets.all(10),
                        child: Center(
                          child: CircularProgressIndicator(color: accentBlue),
                        ),
                      )
                    else
                      _buildInputField('Empresa', empresaCtrl, enabled: false),
                    const SizedBox(height: 10),
                    if (cargandoOficinas)
                      const Padding(
                        padding: EdgeInsets.all(10),
                        child: Center(
                          child: CircularProgressIndicator(color: accentBlue),
                        ),
                      )
                    else
                      _buildMapDropdown(
                        label: 'Oficina',
                        value: selectedOficinaId,
                        items: oficinas,
                        idKey: 'id',
                        nameKeys: const ['nombre', 'name', 'descripcion'],
                        fallback: selectedOficina,
                        onChanged: (value) async {
                          if (value == null) {
                            return;
                          }

                          final oficina = oficinas.firstWhere(
                            (item) => _toInt(item['id']) == value,
                            orElse: () => <String, dynamic>{},
                          );

                          final empresaRelacionadaId = _toInt(
                            oficina['empresa_id'],
                          );
                          final empresaRelacionada = empresas.firstWhere(
                            (item) =>
                                _toInt(item['id']) == empresaRelacionadaId,
                            orElse: () => <String, dynamic>{},
                          );

                          setModalState(() {
                            selectedOficinaId = value;
                            selectedOficina = _nombreMap(oficina);
                            selectedEmpresaId = empresaRelacionadaId == 0
                                ? selectedEmpresaId
                                : empresaRelacionadaId;
                            selectedEmpresa = empresaRelacionadaId == 0
                                ? selectedEmpresa
                                : _nombreMap(empresaRelacionada);
                            empresaCtrl.text = selectedEmpresa;
                            departamentoCtrl.text = '';
                          });
                        },
                      ),
                    const SizedBox(height: 10),
                    _buildInputField('Departamento', departamentoCtrl),
                    const SizedBox(height: 16),
                    const Text(
                      'Configuración de cuenta',
                      style: TextStyle(
                        color: textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildInputField('Rol', rolCtrl),
                    const SizedBox(height: 10),
                    _buildDropdown(
                      label: 'Estado',
                      value: selectedEstado,
                      items: const ['Activa', 'Inactiva'],
                      onChanged: (value) {
                        if (value != null) {
                          setModalState(() {
                            selectedEstado = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildDropdown(
                      label: 'Permiso administrador',
                      value: selectedAdmin,
                      items: const ['No', 'Sí'],
                      onChanged: (value) {
                        if (value != null) {
                          setModalState(() {
                            selectedAdmin = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Cancelar',
                            style: TextStyle(color: textWhite),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentBlue,
                          ),
                          onPressed: () async {
                            if (selectedEmpresaId == null) {
                              _mostrarMensaje(
                                context,
                                'Debes seleccionar una empresa.',
                                error: true,
                              );
                              return;
                            }

                            if (selectedOficinaId == null) {
                              _mostrarMensaje(
                                context,
                                'Debes seleccionar una oficina.',
                                error: true,
                              );
                              return;
                            }

                            final nombreDepartamento = departamentoCtrl.text
                                .trim();
                            final departamentoFinal = nombreDepartamento;
                            final telefono = _soloDigitos(telCtrl.text);

                            if (telefono.isNotEmpty && telefono.length != 10) {
                              _mostrarMensaje(
                                context,
                                'El teléfono debe contener 10 dígitos.',
                                error: true,
                              );
                              return;
                            }

                            if (numEmpCtrl.text.trim().isEmpty) {
                              _mostrarMensaje(
                                context,
                                'El número de empleado es obligatorio.',
                                error: true,
                              );
                              return;
                            }

                            final numeroDuplicado = usuarios.any(
                              (item) =>
                                  item.login != user.login &&
                                  item.numEmpleado.trim().toLowerCase() ==
                                      numEmpCtrl.text.trim().toLowerCase(),
                            );

                            if (numeroDuplicado) {
                              _mostrarMensaje(
                                context,
                                'El número de empleado ya está asignado a otro usuario.',
                                error: true,
                              );
                              return;
                            }

                            Navigator.pop(context);

                            await _guardarUsuario(
                              user: user,
                              nombre: nombreCtrl.text,
                              email: emailCtrl.text,
                              phone: telefono,
                              password: passwordCtrl.text,
                              numeroEmpleado: numEmpCtrl.text,
                              role: rolCtrl.text,
                              active: selectedEstado,
                              privAdmin: selectedAdmin,
                              oficinaId: selectedOficinaId!,
                              departamento: departamentoFinal,
                            );
                          },
                          icon: const Icon(
                            Icons.save,
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
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _guardarUsuario({
    required UsuarioItem user,
    required String nombre,
    required String email,
    required String phone,
    required String password,
    required String numeroEmpleado,
    required String role,
    required String active,
    required String privAdmin,
    required int oficinaId,
    required String departamento,
  }) async {
    _mostrarCargando();

    final activeApi = active.trim().toUpperCase();
    final privAdminApi = privAdmin.trim().toUpperCase();

    final respuesta = await UsersService.actualizarUsuario(
      login: user.login,
      nombre: nombre,
      email: email,
      phone: phone,
      password: password,
      numeroEmpleado: numeroEmpleado,
      role: role,
      active: activeApi == 'ACTIVA' || activeApi == 'Y' ? 'Y' : 'N',
      privAdmin:
          privAdminApi == 'SÍ' || privAdminApi == 'SI' || privAdminApi == 'Y'
          ? 'Y'
          : 'N',
      oficinaId: oficinaId,
      departamento: departamento,
    );

    if (mounted) {
      Navigator.of(context).pop();
    }

    if (!mounted) return;

    if (respuesta['success'] == true) {
      _mostrarMensaje(
        context,
        respuesta['message']?.toString() ??
            'Usuario actualizado correctamente.',
      );

      await _cargarUsuarios(pagina: paginaActual);
    } else {
      final errores = respuesta['errors'];
      final detalleError = errores is Map
          ? errores.values
                .whereType<List>()
                .expand((mensajes) => mensajes)
                .map((mensaje) => mensaje.toString().trim())
                .firstWhere((mensaje) => mensaje.isNotEmpty, orElse: () => '')
          : '';
      _mostrarMensaje(
        context,
        detalleError.isNotEmpty
            ? detalleError
            : respuesta['message']?.toString() ??
                  'No se pudo actualizar el usuario.',
        error: true,
      );
    }
  }

  Future<void> _mostrarEliminarUsuario(
    BuildContext context,
    UsuarioItem user,
  ) async {
    final passwordCtrl = TextEditingController();
    final safeContext = context;

    final confirmar = await showDialog<bool>(
      context: safeContext,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: cardBg,
          title: const Text(
            'Eliminar usuario',
            style: TextStyle(color: textWhite, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '¿Seguro que deseas eliminar a ${user.nombre}?',
                style: const TextStyle(color: textMuted, fontSize: 13),
              ),
              const SizedBox(height: 14),
              _buildPasswordField(passwordCtrl, 'Tu contraseña actual'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar', style: TextStyle(color: textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: redAccent),
              onPressed: () {
                if (passwordCtrl.text.trim().isEmpty) {
                  _mostrarMensaje(
                    dialogContext,
                    'Debes proporcionar tu contraseña.',
                    error: true,
                  );
                  return;
                }

                Navigator.pop(dialogContext, true);
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

    if (confirmar != true) {
      passwordCtrl.dispose();
      return;
    }

    final password = passwordCtrl.text.trim();

    passwordCtrl.dispose();

    _mostrarCargando();

    final respuesta = await UsersService.eliminarUsuario(
      login: user.login,
      password: password,
    );

    if (mounted) {
      Navigator.of(safeContext).pop();
    }

    if (!mounted) return;

    if (respuesta['success'] == true) {
      _mostrarMensaje(
        safeContext,
        respuesta['message']?.toString() ?? 'Usuario eliminado correctamente.',
      );

      if (usuarios.length == 1 && paginaActual > 1) {
        await _cargarUsuarios(pagina: paginaActual - 1);
      } else {
        await _cargarUsuarios(pagina: paginaActual);
      }
    } else {
      _mostrarMensaje(
        safeContext,
        respuesta['message']?.toString() ?? 'No se pudo eliminar el usuario.',
        error: true,
      );
    }
  }

  void _mostrarCargando() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return const Center(
          child: CircularProgressIndicator(color: accentBlue),
        );
      },
    );
  }

  void _mostrarMensaje(
    BuildContext context,
    String mensaje, {
    bool error = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: error ? redAccent : greenAccent,
        content: Text(mensaje, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  String _generarNumeroEmpleado() {
    final usados = usuarios
        .map((user) => user.numEmpleado.trim())
        .where((numero) => numero.isNotEmpty)
        .toSet();
    final random = Random();

    for (var intento = 0; intento < 100; intento++) {
      final numero = (100000 + random.nextInt(900000)).toString();
      if (!usados.contains(numero)) {
        return numero;
      }
    }

    return DateTime.now().millisecondsSinceEpoch.toString().substring(7);
  }

  String _generarContrasenaTemporal() {
    const mayusculas = 'ABCDEFGHJKLMNPQRSTUVWXYZ';
    const minusculas = 'abcdefghijkmnpqrstuvwxyz';
    const numeros = '23456789';
    const especiales = '@#%*-_';
    const todos = '$mayusculas$minusculas$numeros$especiales';
    final random = Random.secure();
    final caracteres = <String>[
      mayusculas[random.nextInt(mayusculas.length)],
      minusculas[random.nextInt(minusculas.length)],
      numeros[random.nextInt(numeros.length)],
      especiales[random.nextInt(especiales.length)],
    ];

    while (caracteres.length < 12) {
      caracteres.add(todos[random.nextInt(todos.length)]);
    }

    caracteres.shuffle(random);
    return caracteres.join();
  }

  String _soloDigitos(String value) {
    return value.replaceAll(RegExp(r'\D'), '');
  }

  String _formatearTelefono(String value) {
    final digits = _soloDigitos(
      value,
    ).substring(0, min(_soloDigitos(value).length, 10));

    if (digits.length <= 3) return digits;
    if (digits.length <= 6) {
      return '(${digits.substring(0, 3)}) ${digits.substring(3)}';
    }

    return '(${digits.substring(0, 3)}) '
        '${digits.substring(3, 6)}-${digits.substring(6)}';
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller, {
    bool enabled = true,
    Widget? suffix,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: textMuted, fontSize: 11)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          decoration: BoxDecoration(
            color: enabled ? cardBg : Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white10),
          ),
          child: TextField(
            controller: controller,
            enabled: enabled,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            style: const TextStyle(color: textWhite, fontSize: 12),
            decoration: InputDecoration(
              border: InputBorder.none,
              isDense: true,
              hintText: hintText,
              hintStyle: const TextStyle(color: textMuted, fontSize: 12),
              suffixIcon: suffix,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(
    TextEditingController controller,
    String hint, {
    bool obscureText = true,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(color: textWhite, fontSize: 12),
        decoration: InputDecoration(
          icon: const Icon(Icons.lock_outline, color: textMuted, size: 16),
          hintText: hint,
          hintStyle: const TextStyle(color: textMuted, fontSize: 12),
          border: InputBorder.none,
          suffixIcon: trailing,
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    final dropdownValue = items.contains(value) ? value : items.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: textMuted, fontSize: 11)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: dropdownValue,
              dropdownColor: cardBg,
              isExpanded: true,
              style: const TextStyle(color: textWhite, fontSize: 12),
              items: items.map((item) {
                return DropdownMenuItem(value: item, child: Text(item));
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMapDropdown({
    required String label,
    required int? value,
    required List<Map<String, dynamic>> items,
    required String idKey,
    required List<String> nameKeys,
    required String fallback,
    required ValueChanged<int?> onChanged,
  }) {
    final ids = items
        .map((item) => _toInt(item[idKey]))
        .where((id) => id > 0)
        .toList();

    int? dropdownValue = ids.contains(value) ? value : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: textMuted, fontSize: 11)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: dropdownValue,
              hint: Text(
                fallback.isEmpty ? 'Seleccionar $label' : fallback,
                style: const TextStyle(color: textMuted, fontSize: 12),
              ),
              dropdownColor: cardBg,
              isExpanded: true,
              style: const TextStyle(color: textWhite, fontSize: 12),
              items: items.map((item) {
                final id = _toInt(item[idKey]);

                return DropdownMenuItem<int>(
                  value: id,
                  child: Text(_nombreMap(item, keys: nameKeys)),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  String _nombreMap(Map<String, dynamic> item, {List<String>? keys}) {
    final posibles =
        keys ??
        const [
          'nombre',
          'name',
          'descripcion',
          'departamento',
          'oficina',
          'empresa',
        ];

    for (final key in posibles) {
      final value = item[key];

      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }

    return 'Sin nombre';
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
                  value.isEmpty ? 'Sin información' : value,
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

  Widget _buildStatusBadge(String status) {
    final isActiva =
        status.toLowerCase() == 'activa' ||
        status.toLowerCase() == 'activo' ||
        status.toLowerCase() == 'a';

    final bg = isActiva
        ? greenAccent.withValues(alpha: 0.15)
        : redAccent.withValues(alpha: 0.15);

    final text = isActiva ? greenAccent : redAccent;

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
            status.isEmpty ? 'Sin estado' : status,
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
        role.isEmpty ? 'Sin rol' : role,
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

  int? empresaId;
  int? oficinaId;
  int? departamentoId;

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
    this.empresaId,
    this.oficinaId,
    this.departamentoId,
  });

  factory UsuarioItem.fromMap(Map<String, dynamic> map) {
    final empresaData = _extraerMap(map, [
      'empresa',
      'empresa_data',
      'company',
    ]);

    final oficinaData = _extraerMap(map, ['oficina', 'oficina_data', 'office']);

    final departamentoData = _extraerMap(map, [
      'departamento',
      'departamento_data',
      'department',
    ]);

    final permisosData = map['permisos'] ?? map['permissions'];

    final permisos = <String>[];

    if (permisosData is List) {
      for (final permiso in permisosData) {
        if (permiso is Map) {
          final nombre =
              permiso['nombre'] ?? permiso['name'] ?? permiso['descripcion'];

          if (nombre != null) {
            permisos.add(nombre.toString());
          }
        } else {
          permisos.add(permiso.toString());
        }
      }
    }

    final privAdmin = map['priv_admin'] ?? map['privAdmin'] ?? map['admin'];

    if (_esAdministrador(privAdmin) && !permisos.contains('Admin')) {
      permisos.add('Admin');
    }

    final estado = _textoCampo(map, ['estado', 'status', 'active']);

    return UsuarioItem(
      nombre: _textoCampo(map, ['name', 'nombre']),
      email: _textoCampo(map, ['email', 'correo']),
      login: _textoCampo(map, ['login', 'usuario', 'username']),
      numEmpleado: _textoCampo(map, [
        'numero_empleado',
        'numEmpleado',
        'numeroEmpleado',
      ]),
      empresa: _nombreRelacion(empresaData, map, [
        'empresa',
        'empresa_nombre',
        'nombre_empresa',
      ]),
      oficina: _nombreRelacion(oficinaData, map, [
        'oficina',
        'oficina_nombre',
        'nombre_oficina',
      ]),
      departamento: _nombreRelacion(departamentoData, map, [
        'departamento',
        'departamento_nombre',
        'nombre_departamento',
      ]),
      rol: _textoCampo(map, ['role', 'rol', 'tipo_rol']),
      estado: _normalizarEstado(estado),
      telefono: _textoCampo(map, ['phone', 'telefono', 'tel']),
      permisos: permisos,
      empresaId: _idRelacion(empresaData, map, ['empresa_id']),
      oficinaId: _idRelacion(oficinaData, map, ['oficina_id']),
      departamentoId: _idRelacion(departamentoData, map, ['departamento_id']),
    );
  }

  String getInitials() {
    final texto = nombre.trim();

    if (texto.isEmpty) {
      return '?';
    }

    final parts = texto.split(RegExp(r'\s+'));

    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }

    return parts[0][0].toUpperCase();
  }

  static Map<String, dynamic>? _extraerMap(
    Map<String, dynamic> map,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = map[key];

      if (value is Map) {
        return Map<String, dynamic>.from(value);
      }
    }

    return null;
  }

  static String _textoCampo(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final value = map[key];

      if (value != null &&
          value.toString().trim().isNotEmpty &&
          value.toString() != 'null') {
        return value.toString().trim();
      }
    }

    return '';
  }

  static String _nombreRelacion(
    Map<String, dynamic>? relation,
    Map<String, dynamic> root,
    List<String> rootKeys,
  ) {
    if (relation != null) {
      final nombre =
          relation['nombre'] ??
          relation['name'] ??
          relation['descripcion'] ??
          relation['empresa'] ??
          relation['oficina'] ??
          relation['departamento'];

      if (nombre != null && nombre.toString().trim().isNotEmpty) {
        return nombre.toString().trim();
      }
    }

    for (final key in rootKeys) {
      final value = root[key];

      if (value is String &&
          value.trim().isNotEmpty &&
          value.trim().toLowerCase() != 'null') {
        return value.trim();
      }
    }

    return _textoCampo(root, rootKeys);
  }

  static int? _idRelacion(
    Map<String, dynamic>? relation,
    Map<String, dynamic> root,
    List<String> rootKeys,
  ) {
    if (relation != null) {
      final id = relation['id'];

      if (id != null) {
        return int.tryParse(id.toString());
      }
    }

    for (final key in rootKeys) {
      final value = root[key];

      if (value != null) {
        return int.tryParse(value.toString());
      }
    }

    return null;
  }

  static String _normalizarEstado(String value) {
    final estado = value.trim().toLowerCase();

    if (estado == '1' ||
        estado == 'true' ||
        estado == 'activo' ||
        estado == 'activa' ||
        estado == 'a') {
      return 'Activa';
    }

    if (estado == '0' ||
        estado == 'false' ||
        estado == 'inactivo' ||
        estado == 'inactiva' ||
        estado == 'i') {
      return 'Inactiva';
    }

    return value.isEmpty ? 'Sin estado' : value;
  }

  static bool _esAdministrador(dynamic value) {
    if (value == null) return false;

    final texto = value.toString().trim().toLowerCase();

    return texto == '1' ||
        texto == 'true' ||
        texto == 'si' ||
        texto == 'sí' ||
        texto == 'yes';
  }
}

class TelefonoInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final limited = digits.substring(0, min(digits.length, 10));
    String formatted;

    if (limited.length <= 3) {
      formatted = limited;
    } else if (limited.length <= 6) {
      formatted = '(${limited.substring(0, 3)}) ${limited.substring(3)}';
    } else {
      formatted =
          '(${limited.substring(0, 3)}) '
          '${limited.substring(3, 6)}-${limited.substring(6)}';
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
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
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF111D35), Color(0xFF0B1224)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.09)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF60A5FA), Color(0xFF4F46E5)],
                  ),
                ),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFF172554),
                  child: Text(
                    item.getInitials(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.nombre.isEmpty ? item.login : item.nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      item.email.isEmpty ? item.login : item.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
          const SizedBox(height: 10),
          Row(
            children: [
              Flexible(child: _buildRoleBadge(item.rol)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      item.departamento.isEmpty
                          ? 'Sin departamento'
                          : item.departamento,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      [
                            if (item.empresa.isNotEmpty) item.empresa,
                            if (item.oficina.isNotEmpty) item.oficina,
                          ].join(' / ').isEmpty
                          ? 'Sin ubicación'
                          : [
                              if (item.empresa.isNotEmpty) item.empresa,
                              if (item.oficina.isNotEmpty) item.oficina,
                            ].join(' / '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: Color(0xFF60A5FA),
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Row(
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
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final isActiva =
        status.toLowerCase() == 'activa' || status.toLowerCase() == 'activo';

    final bg = isActiva
        ? const Color(0xFF00A86B).withValues(alpha: 0.15)
        : const Color(0xFFE11D48).withValues(alpha: 0.15);

    final text = isActiva ? const Color(0xFF00A86B) : const Color(0xFFE11D48);

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
        role.isEmpty ? 'Sin rol' : role,
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
                            'Gerente Ti',
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
          _drawerItem(
            context,
            Icons.dashboard_rounded,
            'Inicio',
            selected: activeMenu == 'Inicio',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const AdminScreen()),
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
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const TicketsScreen()),
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
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const CambiosScreen()),
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
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const DispositivosScreen()),
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
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const AvisosadminScreen()),
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
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const PerfiladminScreen()),
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

              if (!context.mounted) {
                return;
              }

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
}
