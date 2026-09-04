import 'package:flutter/material.dart';

import '../../services/session_service.dart';
import '../../widgets/loading_screen.dart';
import '../../services/admin/dispositivos_services.dart';
import '../../widgets/admin_notification_bell.dart';
import '../../widgets/admin_only_drawer_item.dart';
import 'avisosadmin_screen.dart';
import 'cambios_screen.dart';
import 'home_screen.dart';
import 'perfiladmin_screen.dart';
import 'tickets_screen.dart';
import 'users_screen.dart';

class DispositivosScreen extends StatefulWidget {
  const DispositivosScreen({super.key});

  @override
  State<DispositivosScreen> createState() => _DispositivosScreenState();
}

class _DispositivosScreenState extends State<DispositivosScreen> {
  final Color bgDark = const Color(0xFF0B0F19);
  final Color cardDark = const Color(0xFF121826);
  final Color inputBg = const Color(0xFF172033);
  final Color primaryGradientStart = const Color(0xFF2563EB);
  final Color primaryGradientEnd = const Color(0xFF4F46E5);

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nombreEquipoController = TextEditingController();
  final TextEditingController _idEquipoController = TextEditingController();

  String? _selectedUsuarioVincular;
  String _selectedFiltroEstado = 'Todos los dispositivos';

  List<Map<String, dynamic>> _dispositivos = [];
  List<Map<String, dynamic>> _usuarios = [];

  bool _cargando = true;
  bool _operando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _nombreEquipoController.dispose();
    _idEquipoController.dispose();
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    if (!mounted) return;

    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final resultado = await DispositivosService.obtenerDatos(
        pagina: 1,
        porPagina: 10,
      );

      final usuarios = await DispositivosService.obtenerTodosLosUsuarios();

      if (!mounted) return;

      setState(() {
        _dispositivos = List<Map<String, dynamic>>.from(
          resultado['dispositivos'] ?? [],
        );

        _usuarios = usuarios;

        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _cargando = false;
        _error = _limpiarError(e);
      });
    }
  }

  String _limpiarError(Object error) {
    final mensaje = error.toString();

    if (mensaje.startsWith('Exception: ')) {
      return mensaje.substring(11);
    }

    return mensaje;
  }

  String _texto(dynamic valor) {
    if (valor == null) return '';
    return valor.toString().trim();
  }

  int? _toInt(dynamic valor) {
    if (valor is int) return valor;
    return int.tryParse(valor?.toString() ?? '');
  }

  String _usuarioNombre(Map<String, dynamic> usuario) {
    final nombre = _texto(
      usuario['name'] ??
          usuario['nombre'] ??
          usuario['nombre_completo'] ??
          usuario['nombreCompleto'] ??
          usuario['full_name'] ??
          usuario['fullname'] ??
          usuario['usuario'] ??
          usuario['login'] ??
          usuario['username'],
    );

    return nombre;
  }

  String _usuarioLogin(Map<String, dynamic> usuario) {
    return _texto(
      usuario['login'] ??
          usuario['username'] ??
          usuario['usuario'] ??
          usuario['user'] ??
          usuario['email'],
    );
  }

  String _usuarioId(Map<String, dynamic> usuario) {
    return _texto(
      usuario['id'] ??
          usuario['user_id'] ??
          usuario['usuario_id'] ??
          usuario['id_usuario'],
    );
  }

  String _usuarioCorreo(Map<String, dynamic> usuario) {
    return _texto(
      usuario['email'] ?? usuario['correo'] ?? usuario['correo_electronico'],
    );
  }

  String _usuarioTextoCompleto(Map<String, dynamic> usuario) {
    final nombre = _usuarioNombre(usuario);
    final login = _usuarioLogin(usuario);

    if (nombre.isEmpty && login.isEmpty) {
      return 'Usuario sin datos';
    }

    if (nombre.isEmpty) {
      return login;
    }

    if (login.isEmpty) {
      return nombre;
    }

    return '$nombre — $login';
  }

  String _dispositivoUsuario(Map<String, dynamic> dispositivo) {
    final usuario = dispositivo['usuario'];

    if (usuario is Map) {
      return _texto(
        usuario['name'] ??
            usuario['nombre'] ??
            usuario['nombre_completo'] ??
            usuario['login'] ??
            usuario['username'],
      );
    }

    return _texto(
      dispositivo['nombre_usuario'] ??
          dispositivo['usuario_nombre'] ??
          dispositivo['usuarioName'] ??
          dispositivo['name'] ??
          dispositivo['login'],
    );
  }

  String _dispositivoLogin(Map<String, dynamic> dispositivo) {
    final usuario = dispositivo['usuario'];

    if (usuario is Map) {
      return _texto(
        usuario['login'] ?? usuario['username'] ?? usuario['usuario'],
      );
    }

    return _texto(
      dispositivo['login'] ??
          dispositivo['username'] ??
          dispositivo['usuario_login'] ??
          dispositivo['usuarioLogin'],
    );
  }

  String _dispositivoEquipo(Map<String, dynamic> dispositivo) {
    return _texto(
      dispositivo['nombre_equipo'] ??
          dispositivo['equipo'] ??
          dispositivo['nombre'] ??
          dispositivo['nombreEquipo'],
    );
  }

  String _dispositivoIdEquipo(Map<String, dynamic> dispositivo) {
    return _texto(
      dispositivo['id_equipo'] ??
          dispositivo['idEquipo'] ??
          dispositivo['identificador'],
    );
  }

  String _dispositivoEstado(Map<String, dynamic> dispositivo) {
    final estado = _texto(dispositivo['estado']).toLowerCase();

    if (estado == 'vinculado') {
      return 'Vinculado';
    }

    return 'Desvinculado';
  }

  List<Map<String, dynamic>> get _listaFiltrada {
    final busqueda = _searchController.text.toLowerCase().trim();

    return _dispositivos.where((item) {
      final usuario = _dispositivoUsuario(item).toLowerCase();
      final login = _dispositivoLogin(item).toLowerCase();
      final equipo = _dispositivoEquipo(item).toLowerCase();
      final idEquipo = _dispositivoIdEquipo(item).toLowerCase();
      final estado = _dispositivoEstado(item);

      final matchesSearch =
          usuario.contains(busqueda) ||
          login.contains(busqueda) ||
          equipo.contains(busqueda) ||
          idEquipo.contains(busqueda);

      if (_selectedFiltroEstado == 'Vinculados') {
        return matchesSearch && estado == 'Vinculado';
      }

      if (_selectedFiltroEstado == 'Desvinculados') {
        return matchesSearch && estado == 'Desvinculado';
      }

      return matchesSearch;
    }).toList();
  }

  int get _total => _dispositivos.length;

  int get _vinculados => _dispositivos
      .where((item) => _dispositivoEstado(item) == 'Vinculado')
      .length;

  int get _desvinculados => _dispositivos
      .where((item) => _dispositivoEstado(item) == 'Desvinculado')
      .length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        backgroundColor: cardDark,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
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
          const AdminNotificationBell(),
          const Padding(
            padding: EdgeInsets.only(right: 16, left: 4),
            child: AdminProfileMenu(radius: 16),
          ),
        ],
      ),
      drawer: _buildAppDrawer(),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_cargando) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.blueAccent),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.redAccent,
                size: 48,
              ),
              const SizedBox(height: 12),
              const Text(
                'No se pudieron cargar los dispositivos',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _cargarDatos,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: Colors.blueAccent,
      backgroundColor: cardDark,
      onRefresh: _cargarDatos,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(),
            const SizedBox(height: 20),
            _buildFormVincular(),
            const SizedBox(height: 20),
            _buildTablaDispositivosMobile(
              _listaFiltrada,
              _total,
              _vinculados,
              _desvinculados,
            ),
          ],
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
                          const AdminDrawerRole(),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _drawerItem(
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
          _drawerItem(
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
          _drawerItem(
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
          _drawerItem(
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
          _drawerItem(
            Icons.devices_other,
            'Dispositivos',
            selected: true,
            onTap: () {
              Navigator.pop(context);
            },
          ),
          _drawerItem(
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
          _drawerItem(
            Icons.person_outline,
            'Mi perfil',
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
            Icons.logout_rounded,
            'Cerrar sesión',
            isExit: true,
            onTap: _cerrarSesion,
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(
    IconData icon,
    String title, {
    bool selected = false,
    bool isExit = false,
    VoidCallback? onTap,
  }) {
    final color = isExit
        ? Colors.redAccent
        : selected
        ? Colors.white
        : const Color(0xFF94A3B8);

    final item = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        tileColor: selected ? const Color(0xFF4F46E5) : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        leading: Icon(icon, color: color, size: 20),
        title: Text(
          title,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: onTap,
      ),
    );
    if (title == 'Cambios' || title == 'Usuarios') {
      return AdminOnlyDrawerItem(child: item);
    }
    return item;
  }

  Future<void> _cerrarSesion() async {
    await SessionService.clearSession();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  Widget _buildSectionHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.devices, color: Colors.blueAccent, size: 22),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dispositivos',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Administra y vincula los equipos',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFormVincular() {
    return Container(
      width: double.infinity,
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
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.link, color: Colors.blue, size: 18),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vincular dispositivo',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Asigna un equipo a un usuario',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildLabel('Usuario'),
          _buildUsuarioSelector(
            value: _selectedUsuarioVincular,
            onChanged: (value) {
              setState(() {
                _selectedUsuarioVincular = value;
              });
            },
          ),
          const SizedBox(height: 12),
          _buildLabel('Nombre del equipo'),
          TextField(
            controller: _nombreEquipoController,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: _inputDecoration(
              Icons.desktop_windows,
              'Ej. PC-OFICINA-01',
            ),
          ),
          const SizedBox(height: 12),
          _buildLabel('ID del equipo'),
          TextField(
            controller: _idEquipoController,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: _inputDecoration(
              Icons.fingerprint,
              'Ej. DESKTOP-A8F32K',
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Este identificador debe ser único.',
            style: TextStyle(color: Colors.grey, fontSize: 10),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 42,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryGradientStart, primaryGradientEnd],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ElevatedButton(
                onPressed: _operando ? null : _vincularDispositivo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  disabledBackgroundColor: Colors.transparent,
                ),
                child: _operando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.link, size: 18, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Vincular dispositivo',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsuarioSelector({
    required String? value,
    required ValueChanged<String?> onChanged,
  }) {
    final usuarioActual = _usuarios.where(
      (usuario) => _usuarioLogin(usuario) == value,
    );

    final textoActual = usuarioActual.isNotEmpty
        ? _usuarioTextoCompleto(usuarioActual.first)
        : null;

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () async {
        final seleccionado = await _mostrarSelectorUsuario(
          usuarioInicial: value,
        );

        if (seleccionado != null) {
          onChanged(seleccionado);
        }
      },
      child: InputDecorator(
        decoration: _inputDecoration(
          Icons.person_outline,
          'Selecciona un usuario',
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                textoActual ?? 'Selecciona un usuario',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: textoActual == null ? Colors.grey : Colors.white,
                  fontSize: 13,
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  Future<String?> _mostrarSelectorUsuario({String? usuarioInicial}) async {
    final searchController = TextEditingController();
    String busqueda = '';

    final resultado = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final usuariosFiltrados = _usuarios.where((usuario) {
              final nombre = _usuarioNombre(usuario).toLowerCase();
              final login = _usuarioLogin(usuario).toLowerCase();
              final correo = _usuarioCorreo(usuario).toLowerCase();
              final id = _usuarioId(usuario).toLowerCase();

              return nombre.contains(busqueda) ||
                  login.contains(busqueda) ||
                  correo.contains(busqueda) ||
                  id.contains(busqueda);
            }).toList();

            return AlertDialog(
              backgroundColor: cardDark,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 24,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              titlePadding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
              contentPadding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              title: Row(
                children: [
                  const Icon(
                    Icons.people_alt_outlined,
                    color: Colors.blueAccent,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Seleccionar usuario',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    '${usuariosFiltrados.length}/${_usuarios.length}',
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                height: 430,
                child: Column(
                  children: [
                    TextField(
                      controller: searchController,
                      autofocus: true,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      onChanged: (texto) {
                        setModalState(() {
                          busqueda = texto.toLowerCase().trim();
                        });
                      },
                      decoration: _inputDecoration(
                        Icons.search,
                        'Buscar por nombre, usuario o correo',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: usuariosFiltrados.isEmpty
                          ? const Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.person_off_outlined,
                                    color: Colors.grey,
                                    size: 38,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'No se encontraron usuarios',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              itemCount: usuariosFiltrados.length,
                              separatorBuilder: (_, _) => const Divider(
                                color: Colors.white10,
                                height: 1,
                              ),
                              itemBuilder: (context, index) {
                                final usuario = usuariosFiltrados[index];

                                final login = _usuarioLogin(usuario);
                                final nombre = _usuarioNombre(usuario);
                                final correo = _usuarioCorreo(usuario);
                                final id = _usuarioId(usuario);

                                final seleccionado =
                                    login.isNotEmpty && login == usuarioInicial;

                                return InkWell(
                                  borderRadius: BorderRadius.circular(8),
                                  onTap: login.isEmpty
                                      ? null
                                      : () {
                                          Navigator.pop(dialogContext, login);
                                        },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 10,
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 38,
                                          height: 38,
                                          decoration: BoxDecoration(
                                            color: Colors.blue.withValues(
                                              alpha: 0.12,
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.person,
                                            color: Colors.blueAccent,
                                            size: 19,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                nombre.isEmpty ? login : nombre,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              if (login.isNotEmpty)
                                                Text(
                                                  '@$login',
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    color: Colors.blueAccent,
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              if (correo.isNotEmpty)
                                                Text(
                                                  correo,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              if (id.isNotEmpty)
                                                Text(
                                                  'ID: $id',
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 9,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        if (seleccionado)
                                          const Icon(
                                            Icons.check_circle,
                                            color: Colors.greenAccent,
                                            size: 20,
                                          )
                                        else
                                          const Icon(
                                            Icons.chevron_right,
                                            color: Colors.grey,
                                            size: 20,
                                          ),
                                      ],
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
          },
        );
      },
    );

    searchController.dispose();

    return resultado;
  }

  Widget _buildTablaDispositivosMobile(
    List<Map<String, dynamic>> lista,
    int total,
    int vinculados,
    int desvinculados,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dispositivos registrados',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            'Equipos registrados en TicketPro',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey, fontSize: 11),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCounterChip(
                  Icons.desktop_windows,
                  '$total total',
                  Colors.blue,
                ),
                const SizedBox(width: 6),
                _buildCounterDotChip(Colors.green, '$vinculados vinculados'),
                const SizedBox(width: 6),
                _buildCounterDotChip(
                  Colors.orange,
                  '$desvinculados desvinculados',
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            onChanged: (_) {
              setState(() {});
            },
            decoration: _inputDecoration(Icons.search, 'Buscar equipo o ID...'),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _selectedFiltroEstado,
            dropdownColor: cardDark,
            isExpanded: true,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: _inputDecoration(Icons.filter_alt, ''),
            items: ['Todos los dispositivos', 'Vinculados', 'Desvinculados']
                .map((estado) {
                  return DropdownMenuItem<String>(
                    value: estado,
                    child: Text(estado, overflow: TextOverflow.ellipsis),
                  );
                })
                .toList(),
            onChanged: (value) {
              if (value == null) return;

              setState(() {
                _selectedFiltroEstado = value;
              });
            },
          ),
          const SizedBox(height: 16),
          if (lista.isEmpty)
            _buildEmptyState()
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: lista.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = lista[index];

                final usuario = _dispositivoUsuario(item);
                final login = _dispositivoLogin(item);
                final equipo = _dispositivoEquipo(item);
                final idEquipo = _dispositivoIdEquipo(item);
                final estado = _dispositivoEstado(item);

                final estadoVinculado = estado == 'Vinculado';

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: inputBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.03),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.person_outline,
                            color: Colors.blueAccent,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              usuario.isEmpty ? 'Sin usuario' : usuario,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: estadoVinculado
                                  ? Colors.green.withValues(alpha: 0.15)
                                  : Colors.orange.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              estado,
                              style: TextStyle(
                                color: estadoVinculado
                                    ? Colors.greenAccent
                                    : Colors.orangeAccent,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 22),
                        child: Text(
                          login.isEmpty ? '' : '@$login',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const Divider(color: Colors.white10, height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.desktop_windows,
                            color: Colors.grey,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              equipo,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: bgDark,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                idEquipo,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 10,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          InkWell(
                            onTap: _operando
                                ? null
                                : () => _showEditarModal(item),
                            child: const Padding(
                              padding: EdgeInsets.all(4),
                              child: Icon(
                                Icons.edit,
                                color: Colors.blueAccent,
                                size: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          InkWell(
                            onTap: _operando
                                ? null
                                : () => _showCambiarEstadoModal(item),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Icon(
                                estadoVinculado ? Icons.link_off : Icons.link,
                                color: estadoVinculado
                                    ? Colors.orange
                                    : Colors.green,
                                size: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          InkWell(
                            onTap: _operando
                                ? null
                                : () => _showEliminarModal(item),
                            child: const Padding(
                              padding: EdgeInsets.all(4),
                              child: Icon(
                                Icons.delete,
                                color: Colors.redAccent,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 35),
      child: const Column(
        children: [
          Icon(Icons.devices_other, color: Colors.grey, size: 40),
          SizedBox(height: 10),
          Text(
            'No se encontraron dispositivos',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Intenta cambiar los filtros de búsqueda.',
            style: TextStyle(color: Colors.grey, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Future<void> _vincularDispositivo() async {
    if (_selectedUsuarioVincular == null) {
      _mostrarMensaje('Debes seleccionar un usuario.');
      return;
    }

    final nombreEquipo = _nombreEquipoController.text.trim();
    final idEquipo = _idEquipoController.text.trim();

    if (nombreEquipo.isEmpty) {
      _mostrarMensaje('Debes ingresar el nombre del equipo.');
      return;
    }

    if (idEquipo.isEmpty) {
      _mostrarMensaje('Debes ingresar el ID del equipo.');
      return;
    }

    setState(() {
      _operando = true;
    });

    try {
      await DispositivosService.crearDispositivo(
        login: _selectedUsuarioVincular!,
        nombreEquipo: nombreEquipo,
        idEquipo: idEquipo,
      );

      if (!mounted) return;

      _nombreEquipoController.clear();
      _idEquipoController.clear();

      setState(() {
        _selectedUsuarioVincular = null;
      });

      _mostrarMensaje('Dispositivo vinculado correctamente.');

      await _cargarDatos();
    } catch (e) {
      if (!mounted) return;

      _mostrarMensaje(_limpiarError(e));
    } finally {
      if (mounted) {
        setState(() {
          _operando = false;
        });
      }
    }
  }

  Future<void> _actualizarDispositivo({
    required int id,
    required String login,
    required String nombreEquipo,
    required String idEquipo,
    required String estado,
  }) async {
    setState(() {
      _operando = true;
    });

    try {
      await DispositivosService.actualizarDispositivo(
        id: id,
        login: login,
        nombreEquipo: nombreEquipo,
        idEquipo: idEquipo,
        estado: estado.toLowerCase(),
      );

      if (!mounted) return;

      _mostrarMensaje('Dispositivo actualizado correctamente.');

      await _cargarDatos();
    } catch (e) {
      if (!mounted) return;

      _mostrarMensaje(_limpiarError(e));
    } finally {
      if (mounted) {
        setState(() {
          _operando = false;
        });
      }
    }
  }

  Future<void> _cambiarEstado(Map<String, dynamic> item) async {
    final id = _toInt(item['id']);

    if (id == null) {
      _mostrarMensaje('No se pudo identificar el dispositivo.');
      return;
    }

    setState(() {
      _operando = true;
    });

    try {
      final actualizado = await DispositivosService.cambiarEstado(id);




      if (!mounted) return;

      setState(() {
        final index = _dispositivos.indexWhere(
          (elemento) => _toInt(elemento['id']) == id,
        );

        if (index >= 0) {
          _dispositivos[index] = {..._dispositivos[index], ...actualizado};
        }
      });

      _mostrarMensaje('Estado del dispositivo actualizado correctamente.');

      await _cargarDatos();
    } catch (e) {
      if (!mounted) return;

      _mostrarMensaje(_limpiarError(e));
    } finally {
      if (mounted) {
        setState(() {
          _operando = false;
        });
      }
    }
  }

  Future<void> _eliminarDispositivo(Map<String, dynamic> item) async {
    final id = _toInt(item['id']);

    if (id == null) {
      _mostrarMensaje('No se pudo identificar el dispositivo.');
      return;
    }

    setState(() {
      _operando = true;
    });

    try {
      await DispositivosService.eliminarDispositivo(id);

      if (!mounted) return;

      _mostrarMensaje('Dispositivo eliminado correctamente.');

      await _cargarDatos();
    } catch (e) {
      if (!mounted) return;

      _mostrarMensaje(_limpiarError(e));
    } finally {
      if (mounted) {
        setState(() {
          _operando = false;
        });
      }
    }
  }

  void _showEditarModal(Map<String, dynamic> item) {
    final editEquipo = TextEditingController(text: _dispositivoEquipo(item));

    final editId = TextEditingController(text: _dispositivoIdEquipo(item));

    String? usuarioSeleccionado = _dispositivoLogin(item);

    if (!_usuarios.any(
      (usuario) => _usuarioLogin(usuario) == usuarioSeleccionado,
    )) {
      usuarioSeleccionado = null;
    }

    String estado = _dispositivoEstado(item);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: cardDark,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 24,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.edit, color: Colors.blue, size: 18),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Editar dispositivo',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Usuario'),
                    _buildUsuarioSelector(
                      value: usuarioSeleccionado,
                      onChanged: (value) {
                        setModalState(() {
                          usuarioSeleccionado = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildLabel('Nombre del equipo'),
                    TextField(
                      controller: editEquipo,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: _inputDecoration(
                        Icons.desktop_windows,
                        'Nombre del equipo',
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildLabel('ID del equipo'),
                    TextField(
                      controller: editId,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: _inputDecoration(
                        Icons.fingerprint,
                        'ID del equipo',
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildLabel('Estado'),
                    DropdownButtonFormField<String>(
                      initialValue: estado,
                      dropdownColor: cardDark,
                      isExpanded: true,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: _inputDecoration(
                        Icons.check_circle_outline,
                        'Selecciona el estado',
                      ),
                      items: ['Vinculado', 'Desvinculado'].map((estadoItem) {
                        return DropdownMenuItem<String>(
                          value: estadoItem,
                          child: Text(
                            estadoItem,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value == null) return;

                        setModalState(() {
                          estado = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    editEquipo.dispose();
                    editId.dispose();
                    Navigator.pop(dialogContext);
                  },
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGradientStart,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    if (usuarioSeleccionado == null) {
                      _mostrarMensaje('Debes seleccionar un usuario.');
                      return;
                    }

                    if (editEquipo.text.trim().isEmpty) {
                      _mostrarMensaje('Debes ingresar el nombre del equipo.');
                      return;
                    }

                    if (editId.text.trim().isEmpty) {
                      _mostrarMensaje('Debes ingresar el ID del equipo.');
                      return;
                    }

                    final id = _toInt(item['id']);

                    if (id == null) {
                      _mostrarMensaje('No se pudo identificar el dispositivo.');
                      return;
                    }

                    Navigator.pop(dialogContext);

                    await _actualizarDispositivo(
                      id: id,
                      login: usuarioSeleccionado!,
                      nombreEquipo: editEquipo.text.trim(),
                      idEquipo: editId.text.trim(),
                      estado: estado,
                    );

                    editEquipo.dispose();
                    editId.dispose();
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showCambiarEstadoModal(Map<String, dynamic> item) {
    final estado = _dispositivoEstado(item);

    final esVinculado = estado == 'Vinculado';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: cardDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            esVinculado ? 'Desvincular dispositivo' : 'Vincular dispositivo',
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (esVinculado ? Colors.orange : Colors.green)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  esVinculado
                      ? 'El dispositivo quedará marcado como desvinculado del usuario.'
                      : 'El dispositivo volverá a quedar marcado como vinculado al usuario.',
                  style: TextStyle(
                    color: esVinculado ? Colors.orange : Colors.greenAccent,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _dispositivoEquipo(item),
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: esVinculado ? Colors.orange : Colors.green,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                Navigator.pop(dialogContext);
                await _cambiarEstado(item);
              },
              child: Text(esVinculado ? 'Desvincular' : 'Vincular'),
            ),
          ],
        );
      },
    );
  }

  void _showEliminarModal(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: cardDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            'Eliminar dispositivo',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Esta acción es permanente y no se puede deshacer.',
                  style: TextStyle(color: Colors.redAccent, fontSize: 12),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _dispositivoEquipo(item),
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                Navigator.pop(dialogContext);
                await _eliminarDispositivo(item);
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  void _mostrarMensaje(String mensaje, {bool isError = false}) {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        final color = isError
            ? const Color(0xFFEF4444)
            : const Color(0xFF22C55E);
        final icon = isError
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
                  isError ? 'Error' : 'Éxito',
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

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
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

  InputDecoration _inputDecoration(IconData icon, String hint) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: Colors.grey, size: 18),
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
      filled: true,
      fillColor: inputBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.blueAccent, width: 1),
      ),
    );
  }

  Widget _buildCounterChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildCounterDotChip(Color color, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        ],
      ),
    );
  }
}
