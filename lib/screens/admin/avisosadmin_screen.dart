import 'package:flutter/material.dart';

import '../../services/session_service.dart';
import 'backup_screen.dart';
import 'cambios_screen.dart';
import 'dispositivos_screen.dart';
import 'home_screen.dart';
import 'perfiladmin_screen.dart';
import 'tickets_screen.dart';
import 'users_screen.dart';

class AvisosadminScreen extends StatefulWidget {
  const AvisosadminScreen({super.key});

  @override
  State<AvisosadminScreen> createState() => _AvisosadminScreenState();
}

class _AvisosadminScreenState extends State<AvisosadminScreen> {
  final Color bgDark = const Color(0xFF0B0F19);
  final Color cardDark = const Color(0xFF121826);
  final Color inputBg = const Color(0xFF172033);
  final Color primaryGradientStart = const Color(0xFF2563EB);
  final Color primaryGradientEnd = const Color(0xFF4F46E5);

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _contenidoController = TextEditingController();

  String _selectedFiltroEstado = 'Todos';
  String _prioridadSeleccionada = 'Alta';
  String activeMenu = 'Avisos';

  List<Map<String, dynamic>> avisos = [
    {
      'id': 1,
      'titulo': 'Mantenimiento del servidor principal',
      'contenido':
          'Se realizará un mantenimiento programado en el servidor principal de datos este fin de semana.',
      'prioridad': 'Alta',
      'estado': 'Activo',
      'fecha': '21/02/2026',
    },
    {
      'id': 2,
      'titulo': 'Prueba de aviso',
      'contenido':
          'Aviso de prueba para verificar las notificaciones del sistema.',
      'prioridad': 'Baja',
      'estado': 'Inactivo',
      'fecha': '20/02/2026',
    },
    {
      'id': 3,
      'titulo': 'Actualización de política de contraseñas',
      'contenido':
          'A partir del próximo mes todas las contraseñas deberán cambiarse cada 90 días.',
      'prioridad': 'Media',
      'estado': 'Activo',
      'fecha': '18/02/2026',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _tituloController.dispose();
    _contenidoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = avisos.length;
    final activos = avisos.where((a) => a['estado'] == 'Activo').length;
    final inactivos = avisos.where((a) => a['estado'] == 'Inactivo').length;

    final textoBusqueda = _searchController.text.toLowerCase().trim();

    final listaFiltrada = avisos.where((item) {
      final titulo = item['titulo'].toString().toLowerCase();
      final contenido = item['contenido'].toString().toLowerCase();

      final matchesSearch =
          titulo.contains(textoBusqueda) ||
          contenido.contains(textoBusqueda);

      if (_selectedFiltroEstado == 'Activos') {
        return matchesSearch && item['estado'] == 'Activo';
      }

      if (_selectedFiltroEstado == 'Inactivos') {
        return matchesSearch && item['estado'] == 'Inactivo';
      }

      return matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        backgroundColor: AdminScreen.sidebarBg,
        foregroundColor: Colors.white,
        elevation: 0,
        title: RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'Ticket',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              TextSpan(
                text: 'Pro',
                style: TextStyle(
                  color: AdminScreen.accentBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: AdminScreen.primaryBlue,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 14,
                      minHeight: 14,
                    ),
                    child: const Text(
                      '2',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          const CircleAvatar(
            radius: 16,
            backgroundColor: AdminScreen.primaryBlue,
            child: Text(
              'JH',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      drawer: _buildAppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Gestión de Avisos',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Crea, edita y administra los avisos para los usuarios',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildCounterChip(
                          Icons.campaign_outlined,
                          '$total Total',
                          Colors.blue,
                        ),
                        const SizedBox(width: 6),
                        _buildCounterDotChip(
                          Colors.green,
                          '$activos Activos',
                        ),
                        const SizedBox(width: 6),
                        _buildCounterDotChip(
                          Colors.grey,
                          '$inactivos Inactivos',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _searchController,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                    onChanged: (_) => setState(() {}),
                    decoration: _inputDecoration(
                      Icons.search,
                      'Buscar avisos...',
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedFiltroEstado,
                    dropdownColor: cardDark,
                    isExpanded: true,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                    decoration: _inputDecoration(
                      Icons.filter_alt_outlined,
                      '',
                    ),
                    items: ['Todos', 'Activos', 'Inactivos']
                        .map(
                          (e) => DropdownMenuItem<String>(
                            value: e,
                            child: Text(e),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      if (val == null) return;
                      setState(() {
                        _selectedFiltroEstado = val;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  if (listaFiltrada.isEmpty)
                    _buildEmptyState()
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: listaFiltrada.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = listaFiltrada[index];
                        return _buildAvisoCardMobile(item);
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppDrawer() {
    return Drawer(
      backgroundColor: AdminScreen.sidebarBg,
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
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
                            color: AdminScreen.accentBlue,
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
                          backgroundColor: AdminScreen.primaryBlue,
                          child: Text(
                            'JH',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
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
                                color: AdminScreen.textMuted,
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
                  MaterialPageRoute(
                    builder: (context) => const AdminScreen(),
                  ),
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
                  MaterialPageRoute(
                    builder: (context) => const TicketsScreen(),
                  ),
                );
              },
            ),
            _drawerItem(
              context,
              Icons.sync_alt_rounded,
              'Cambios',
              selected: activeMenu == 'Cambios',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CambiosScreen(),
                  ),
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
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UserScreen(),
                  ),
                );
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
                  MaterialPageRoute(
                    builder: (context) => const DispositivosScreen(),
                  ),
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
              },
            ),
            _drawerItem(
              context,
              Icons.backup_outlined,
              'Backups',
              selected: activeMenu == 'Backups',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BackupScreen(),
                  ),
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
                  MaterialPageRoute(
                    builder: (context) => const PerfiladminScreen(),
                  ),
                );
              },
            ),
            const Divider(
              color: Colors.white10,
            ),
            _drawerItem(
              context,
              Icons.logout_rounded,
              'Cerrar sesión',
              selected: false,
              isDestructive: true,
              onTap: _cerrarSesion,
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(
    BuildContext context,
    IconData icon,
    String title, {
    required bool selected,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final Color itemColor = isDestructive
        ? Colors.redAccent
        : selected
            ? Colors.white
            : AdminScreen.textMuted;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: selected
            ? AdminScreen.primaryBlue
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: itemColor,
          size: 20,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: itemColor,
            fontSize: 14,
            fontWeight:
                selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  Future<void> _cerrarSesion() async {
    Navigator.pop(context);

    await SessionService.clearSession();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/',
      (route) => false,
    );
  }

  Widget _buildSectionHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.campaign_outlined,
                color: Colors.blueAccent,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Avisos',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Publica y administra avisos para la organización',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          height: 42,
          child: ElevatedButton.icon(
            onPressed: _showModalCrearAviso,
            icon: const Icon(
              Icons.add_circle_outline,
              size: 18,
            ),
            label: const Text(
              'Nuevo aviso',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGradientStart,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvisoCardMobile(Map<String, dynamic> item) {
    final isActivo = item['estado'] == 'Activo';

    return Container(
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPrioridadBadge(item['prioridad']),
              Row(
                children: [
                  Switch(
                    value: isActivo,
                    activeThumbColor: Colors.blueAccent,
                    onChanged: (val) {
                      setState(() {
                        item['estado'] =
                            val ? 'Activo' : 'Inactivo';
                      });
                    },
                  ),
                  Text(
                    item['estado'],
                    style: TextStyle(
                      color: isActivo
                          ? Colors.greenAccent
                          : Colors.grey,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            item['titulo'],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item['contenido'],
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
          const Divider(
            color: Colors.white10,
            height: 16,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    color: Colors.grey,
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    item['fecha'],
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  InkWell(
                    onTap: () => _showModalVerAviso(item),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.visibility_outlined,
                        color: Colors.grey,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => _showModalEditarAviso(item),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.edit_outlined,
                        color: Colors.blueAccent,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => _showModalEliminarAviso(item),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
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

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 35),
      child: const Column(
        children: [
          Icon(
            Icons.campaign_outlined,
            color: Colors.grey,
            size: 40,
          ),
          SizedBox(height: 10),
          Text(
            'No se encontraron avisos',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Intenta cambiar los filtros de búsqueda.',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrioridadBadge(String prioridad) {
    Color bg;
    Color text;

    switch (prioridad) {
      case 'Alta':
        bg = Colors.red.withValues(alpha: 0.15);
        text = Colors.redAccent;
        break;
      case 'Media':
        bg = Colors.orange.withValues(alpha: 0.15);
        text = Colors.orangeAccent;
        break;
      default:
        bg = Colors.blue.withValues(alpha: 0.15);
        text = Colors.blueAccent;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        prioridad,
        style: TextStyle(
          color: text,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showModalCrearAviso() {
    _tituloController.clear();
    _contenidoController.clear();
    _prioridadSeleccionada = 'Alta';

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.campaign_outlined,
                    color: Colors.blue,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Nuevo aviso',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(
                Icons.close,
                color: Colors.grey,
                size: 18,
              ),
              onPressed: () => Navigator.pop(dialogContext),
            ),
          ],
        ),
        content: StatefulBuilder(
          builder: (context, setStateModal) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabelModal('Título del aviso'),
                TextField(
                  controller: _tituloController,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                  decoration: _inputDecoration(
                    Icons.title,
                    'Ej. Mantenimiento de servidores',
                  ),
                ),
                const SizedBox(height: 12),
                _buildLabelModal('Contenido'),
                TextField(
                  controller: _contenidoController,
                  maxLines: 3,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                  decoration: _inputDecoration(
                    Icons.notes,
                    'Escribe el mensaje del aviso...',
                  ),
                ),
                const SizedBox(height: 12),
                _buildLabelModal('Prioridad'),
                DropdownButtonFormField<String>(
                  initialValue: _prioridadSeleccionada,
                  dropdownColor: cardDark,
                  isExpanded: true,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                  decoration: _inputDecoration(
                    Icons.flag_outlined,
                    '',
                  ),
                  items: ['Baja', 'Media', 'Alta']
                      .map(
                        (e) => DropdownMenuItem<String>(
                          value: e,
                          child: Text(e),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val == null) return;
                    setStateModal(() {
                      _prioridadSeleccionada = val;
                    });
                  },
                ),
              ],
            );
          },
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
              backgroundColor: primaryGradientStart,
            ),
            onPressed: () {
              if (_tituloController.text.trim().isEmpty) {
                return;
              }

              setState(() {
                avisos.insert(0, {
                  'id': avisos.length + 1,
                  'titulo': _tituloController.text.trim(),
                  'contenido':
                      _contenidoController.text.trim(),
                  'prioridad': _prioridadSeleccionada,
                  'estado': 'Activo',
                  'fecha': '30/08/2026',
                });
              });

              Navigator.pop(dialogContext);
            },
            child: const Text('Publicar aviso'),
          ),
        ],
      ),
    );
  }

  void _showModalVerAviso(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Detalle del aviso',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.close,
                color: Colors.grey,
                size: 18,
              ),
              onPressed: () => Navigator.pop(dialogContext),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildPrioridadBadge(item['prioridad']),
                Text(
                  item['fecha'],
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              item['titulo'],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: inputBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                item['contenido'],
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: inputBg,
            ),
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Cerrar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showModalEditarAviso(Map<String, dynamic> item) {
    final editTitulo = TextEditingController(
      text: item['titulo'],
    );
    final editContenido = TextEditingController(
      text: item['contenido'],
    );

    String editPrioridad = item['prioridad'];

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.edit,
                    color: Colors.blue,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Editar aviso',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(
                Icons.close,
                color: Colors.grey,
                size: 18,
              ),
              onPressed: () => Navigator.pop(dialogContext),
            ),
          ],
        ),
        content: StatefulBuilder(
          builder: (context, setStateModal) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabelModal('Título del aviso'),
                TextField(
                  controller: editTitulo,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                  decoration: _inputDecoration(
                    Icons.title,
                    '',
                  ),
                ),
                const SizedBox(height: 12),
                _buildLabelModal('Contenido'),
                TextField(
                  controller: editContenido,
                  maxLines: 3,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                  decoration: _inputDecoration(
                    Icons.notes,
                    '',
                  ),
                ),
                const SizedBox(height: 12),
                _buildLabelModal('Prioridad'),
                DropdownButtonFormField<String>(
                  initialValue: editPrioridad,
                  dropdownColor: cardDark,
                  isExpanded: true,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                  decoration: _inputDecoration(
                    Icons.flag_outlined,
                    '',
                  ),
                  items: ['Baja', 'Media', 'Alta']
                      .map(
                        (e) => DropdownMenuItem<String>(
                          value: e,
                          child: Text(e),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val == null) return;
                    setStateModal(() {
                      editPrioridad = val;
                    });
                  },
                ),
              ],
            );
          },
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
              backgroundColor: primaryGradientStart,
            ),
            onPressed: () {
              if (editTitulo.text.trim().isEmpty) {
                return;
              }

              setState(() {
                item['titulo'] = editTitulo.text.trim();
                item['contenido'] =
                    editContenido.text.trim();
                item['prioridad'] = editPrioridad;
              });

              editTitulo.dispose();
              editContenido.dispose();

              Navigator.pop(dialogContext);
            },
            child: const Text('Guardar cambios'),
          ),
        ],
      ),
    );
  }

  void _showModalEliminarAviso(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text(
          'Eliminar aviso',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Esta acción eliminará el aviso de forma permanente.',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              item['titulo'],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
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
            ),
            onPressed: () {
              setState(() {
                avisos.remove(item);
              });

              Navigator.pop(dialogContext);
            },
            child: const Text('Eliminar'),
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

  InputDecoration _inputDecoration(
    IconData icon,
    String hint,
  ) {
    return InputDecoration(
      prefixIcon: Icon(
        icon,
        color: Colors.grey,
        size: 18,
      ),
      hintText: hint,
      hintStyle: const TextStyle(
        color: Colors.grey,
        fontSize: 12,
      ),
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
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: Colors.blueAccent,
          width: 1,
        ),
      ),
    );
  }

  Widget _buildCounterChip(
    IconData icon,
    String text,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCounterDotChip(
    Color color,
    String text,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
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
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}