import 'package:flutter/material.dart';

import '../../services/session_service.dart';
import 'avisosadmin_screen.dart';
import 'backup_screen.dart';
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
  final TextEditingController _nombreEquipoController =
      TextEditingController();
  final TextEditingController _idEquipoController = TextEditingController();

  String? _selectedUsuarioVincular;
  String _selectedFiltroEstado = 'Todos los dispositivos';

  final List<String> _usuariosList = [
    'Fernando Reyes — freyes',
    'Jesus Hinojosa — jhinojosa',
  ];

  final List<Map<String, String>> dispositivos = [
    {
      'usuario': 'Fernando Reyes',
      'login': 'freyes',
      'equipo': 'IMPRESORA-ADM-1',
      'idEquipo': 'HP-975S2',
      'estado': 'Vinculado',
    },
    {
      'usuario': 'Fernando Reyes',
      'login': 'freyes',
      'equipo': 'PHONE-ADM-3',
      'idEquipo': 'CELLPHONE-C9756A',
      'estado': 'Vinculado',
    },
    {
      'usuario': 'Fernando Reyes',
      'login': 'freyes',
      'equipo': 'LAP-ADM-2',
      'idEquipo': 'LENOVO-15970',
      'estado': 'Vinculado',
    },
    {
      'usuario': 'Jesus Hinojosa',
      'login': 'jhinojosa',
      'equipo': 'IMPRESORA-TI-1',
      'idEquipo': 'PRINTER-DF784',
      'estado': 'Vinculado',
    },
    {
      'usuario': 'Jesus Hinojosa',
      'login': 'jhinojosa',
      'equipo': 'PHONE-TI-1',
      'idEquipo': 'CELLPHONE-201547',
      'estado': 'Vinculado',
    },
    {
      'usuario': 'Jesus Hinojosa',
      'login': 'jhinojosa',
      'equipo': 'PC-TI-3',
      'idEquipo': 'DESKTOP-15FER9',
      'estado': 'Vinculado',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _nombreEquipoController.dispose();
    _idEquipoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = dispositivos.length;
    final vinculados =
        dispositivos.where((d) => d['estado'] == 'Vinculado').length;
    final desvinculados =
        dispositivos.where((d) => d['estado'] == 'Desvinculado').length;
    final busqueda = _searchController.text.toLowerCase().trim();

    final listaFiltrada = dispositivos.where((item) {
      final matchesSearch =
          item['usuario']!.toLowerCase().contains(busqueda) ||
          item['login']!.toLowerCase().contains(busqueda) ||
          item['equipo']!.toLowerCase().contains(busqueda) ||
          item['idEquipo']!.toLowerCase().contains(busqueda);

      if (_selectedFiltroEstado == 'Vinculados') {
        return matchesSearch && item['estado'] == 'Vinculado';
      }

      if (_selectedFiltroEstado == 'Desvinculados') {
        return matchesSearch && item['estado'] == 'Desvinculado';
      }

      return matchesSearch;
    }).toList();

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
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_none,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AvisosadminScreen(),
                    ),
                  );
                },
              ),
              Positioned(
                right: 8,
                top: 10,
                child: Container(
                  constraints: const BoxConstraints(
                    minWidth: 15,
                    minHeight: 15,
                  ),
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4F46E5),
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    '2',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.only(right: 16, left: 4),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFF4F46E5),
              child: Text(
                'JH',
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
      drawer: _buildAppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(),
            const SizedBox(height: 20),
            _buildFormVincular(),
            const SizedBox(height: 20),
            _buildTablaDispositivosMobile(
              listaFiltrada,
              total,
              vinculados,
              desvinculados,
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
            decoration: const BoxDecoration(
              color: Color(0xFF0D1630),
            ),
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
                  child: const Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Color(0xFF4F46E5),
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
            Icons.dashboard_rounded,
            'Inicio',
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
            Icons.confirmation_number_outlined,
            'Tickets',
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
            Icons.sync_alt_rounded,
            'Cambios',
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
            Icons.people_outline,
            'Usuarios',
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
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const AvisosadminScreen(),
                ),
              );
            },
          ),
          _drawerItem(
            Icons.backup_outlined,
            'Backups',
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
            Icons.person_outline,
            'Mi perfil',
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

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: selected
            ? const Color(0xFF4F46E5)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: color,
          size: 20,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: selected
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  Future<void> _cerrarSesion() async {
    await SessionService.clearSession();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/',
      (route) => false,
    );
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
          child: const Icon(
            Icons.devices,
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
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
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
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
        ),
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
                child: const Icon(
                  Icons.link,
                  color: Colors.blue,
                  size: 18,
                ),
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
          const SizedBox(height: 16),
          _buildLabel('Usuario'),
          DropdownButtonFormField<String>(
            initialValue: _selectedUsuarioVincular,
            dropdownColor: cardDark,
            isExpanded: true,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
            ),
            decoration: _inputDecoration(
              Icons.person_outline,
              'Selecciona un usuario',
            ),
            items: _usuariosList.map((usuario) {
              return DropdownMenuItem<String>(
                value: usuario,
                child: Text(
                  usuario,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
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
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
            ),
            decoration: _inputDecoration(
              Icons.desktop_windows,
              'Ej. PC-OFICINA-01',
            ),
          ),
          const SizedBox(height: 12),
          _buildLabel('ID del equipo'),
          TextField(
            controller: _idEquipoController,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
            ),
            decoration: _inputDecoration(
              Icons.fingerprint,
              'Ej. DESKTOP-A8F32K',
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Este identificador debe ser único.',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 42,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primaryGradientStart,
                    primaryGradientEnd,
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ElevatedButton(
                onPressed: _vincularDispositivo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.link,
                      size: 18,
                      color: Colors.white,
                    ),
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

  Widget _buildTablaDispositivosMobile(
    List<Map<String, String>> lista,
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
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
        ),
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
                  Icons.desktop_windows,
                  '$total total',
                  Colors.blue,
                ),
                const SizedBox(width: 6),
                _buildCounterDotChip(
                  Colors.green,
                  '$vinculados vinculados',
                ),
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
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
            ),
            onChanged: (_) {
              setState(() {});
            },
            decoration: _inputDecoration(
              Icons.search,
              'Buscar equipo o ID...',
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
              Icons.filter_alt,
              '',
            ),
            items: [
              'Todos los dispositivos',
              'Vinculados',
              'Desvinculados',
            ].map((estado) {
              return DropdownMenuItem<String>(
                value: estado,
                child: Text(
                  estado,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
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
                final estadoVinculado =
                    item['estado'] == 'Vinculado';

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
                              item['usuario']!,
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
                              item['estado']!,
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
                          '@${item['login']!}',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const Divider(
                        color: Colors.white10,
                        height: 16,
                      ),
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
                              item['equipo']!,
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
                                item['idEquipo']!,
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
                            onTap: () => _showEditarModal(item),
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
                            onTap: () =>
                                _showDesvincularModal(item),
                            child: const Padding(
                              padding: EdgeInsets.all(4),
                              child: Icon(
                                Icons.link_off,
                                color: Colors.orange,
                                size: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          InkWell(
                            onTap: () => _showEliminarModal(item),
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
          Icon(
            Icons.devices_other,
            color: Colors.grey,
            size: 40,
          ),
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
            style: TextStyle(
              color: Colors.grey,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  void _showEditarModal(Map<String, String> item) {
    final editEquipo = TextEditingController(
      text: item['equipo'],
    );
    final editId = TextEditingController(
      text: item['idEquipo'],
    );

    String? usuarioSeleccionado;

    for (final usuario in _usuariosList) {
      final partes = usuario.split('—');

      if (partes.length > 1 &&
          partes[0].trim() == item['usuario'] &&
          partes[1].trim() == item['login']) {
        usuarioSeleccionado = usuario;
        break;
      }
    }

    usuarioSeleccionado ??=
        _usuariosList.isNotEmpty ? _usuariosList.first : null;

    String estado = item['estado']!;

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
                    child: const Icon(
                      Icons.edit,
                      color: Colors.blue,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Editar dispositivo',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
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
                    DropdownButtonFormField<String>(
                      initialValue: usuarioSeleccionado,
                      dropdownColor: cardDark,
                      isExpanded: true,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                      decoration: _inputDecoration(
                        Icons.person_outline,
                        'Selecciona un usuario',
                      ),
                      items: _usuariosList.map((usuario) {
                        return DropdownMenuItem<String>(
                          value: usuario,
                          child: Text(
                            usuario,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                        );
                      }).toList(),
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
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                      decoration: _inputDecoration(
                        Icons.desktop_windows,
                        'Nombre del equipo',
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildLabel('ID del equipo'),
                    TextField(
                      controller: editId,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                      ),
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
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                      decoration: _inputDecoration(
                        Icons.check_circle_outline,
                        'Selecciona el estado',
                      ),
                      items: [
                        'Vinculado',
                        'Desvinculado',
                      ].map((estadoItem) {
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
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGradientStart,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    if (usuarioSeleccionado == null ||
                        editEquipo.text.trim().isEmpty ||
                        editId.text.trim().isEmpty) {
                      return;
                    }

                    final userParts =
                        usuarioSeleccionado!.split('—');

                    if (userParts.length < 2) return;

                    final nuevoId = editId.text.trim();

                    final idDuplicado = dispositivos.any(
                      (dispositivo) =>
                          dispositivo != item &&
                          dispositivo['idEquipo']!
                                  .toLowerCase() ==
                              nuevoId.toLowerCase(),
                    );

                    if (idDuplicado) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'El ID del equipo ya está registrado.',
                          ),
                        ),
                      );
                      return;
                    }

                    setState(() {
                      item['usuario'] = userParts[0].trim();
                      item['login'] = userParts[1].trim();
                      item['equipo'] = editEquipo.text.trim();
                      item['idEquipo'] = nuevoId;
                      item['estado'] = estado;
                    });

                    editEquipo.dispose();
                    editId.dispose();

                    Navigator.pop(dialogContext);
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

  void _showDesvincularModal(Map<String, String> item) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: cardDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            'Desvincular dispositivo',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'El dispositivo quedará marcado como desvinculado del usuario.',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                item['equipo']!,
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
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  item['estado'] = 'Desvinculado';
                });

                Navigator.pop(dialogContext);
              },
              child: const Text('Desvincular'),
            ),
          ],
        );
      },
    );
  }

  void _showEliminarModal(Map<String, String> item) {
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
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
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
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                item['equipo']!,
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
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  dispositivos.remove(item);
                });

                Navigator.pop(dialogContext);
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  void _vincularDispositivo() {
    if (_selectedUsuarioVincular == null ||
        _nombreEquipoController.text.trim().isEmpty ||
        _idEquipoController.text.trim().isEmpty) {
      return;
    }

    final userParts = _selectedUsuarioVincular!.split('—');

    if (userParts.length < 2) return;

    final idEquipo = _idEquipoController.text.trim();

    final existeId = dispositivos.any(
      (dispositivo) =>
          dispositivo['idEquipo']!.toLowerCase() ==
          idEquipo.toLowerCase(),
    );

    if (existeId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'El ID del equipo ya está registrado.',
          ),
        ),
      );
      return;
    }

    setState(() {
      dispositivos.add({
        'usuario': userParts[0].trim(),
        'login': userParts[1].trim(),
        'equipo': _nombreEquipoController.text.trim(),
        'idEquipo': idEquipo,
        'estado': 'Vinculado',
      });

      _nombreEquipoController.clear();
      _idEquipoController.clear();
      _selectedUsuarioVincular = null;
    });
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
