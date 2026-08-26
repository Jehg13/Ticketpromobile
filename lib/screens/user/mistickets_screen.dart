import 'package:flutter/material.dart';

import 'creartickets_screen.dart';
import 'home_screen.dart';
import 'avisos_screen.dart';
import 'perfil_screen.dart';
class MisticketsScreen extends StatelessWidget {
  const MisticketsScreen({super.key});
  static const String defaultAvatar = 'assets/images/user.png';

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;

    return Scaffold(
      backgroundColor: const Color(0xFF060A17),
      appBar: isDesktop
          ? null
          : AppBar(
              backgroundColor: const Color(0xFF0B1021),
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
              title: const AppLogo(fontSize: 20),
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.notifications_none_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () {},
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundImage: AssetImage(defaultAvatar),
                  ),
                ),
              ],
            ),

      drawer: isDesktop
          ? null
          : const AppNavigationDrawer(activeRoute: 'Mis tickets'),

      body: Row(
        children: [
          if (isDesktop)
            const SizedBox(
              width: 260,
              child: AppNavigationDrawer(activeRoute: 'Mis tickets'),
            ),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isDesktop ? 24 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, isDesktop),
                  const SizedBox(height: 24),
                  _buildMainCard(context, isDesktop),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDesktop) {
    if (!isDesktop) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mis tickets',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Mis tickets / Dashboard',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mis tickets',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Mis tickets / Dashboard',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
        ),

        const SizedBox(width: 20),

        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFF0D1427),
                padding: const EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(
                Icons.notifications_none_rounded,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () {},
            ),

            const SizedBox(width: 16),

            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(
                  radius: 18,
                  backgroundImage: AssetImage(defaultAvatar),
                ),

                const SizedBox(width: 10),

                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Juan Perez',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      'administracion',
                      style: TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),

                const SizedBox(width: 4),

                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Colors.grey,
                  size: 18,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMainCard(BuildContext context, bool isDesktop) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0B1021),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.12)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mis tickets',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Consulta y da seguimiento a todos tus tickets registrados',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 20),

                _buildSearchBar(),
              ],
            )
          else
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mis tickets',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Consulta y da seguimiento a todos tus tickets registrados',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),

          if (!isDesktop) ...[const SizedBox(height: 16), _buildSearchBar()],

          const SizedBox(height: 20),

          _buildTicketsList(isDesktop),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return SizedBox(
      width: 280,
      height: 38,
      child: TextField(
        style: const TextStyle(color: Colors.white, fontSize: 12),
        decoration: InputDecoration(
          hintText: 'Buscar folio, título o fecha...',
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Colors.grey,
            size: 18,
          ),
          filled: true,
          fillColor: const Color(0xFF060A17),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 0,
            horizontal: 12,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.white12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF2563EB)),
          ),
        ),
      ),
    );
  }

  Widget _buildTicketsList(bool isDesktop) {
    final List<Map<String, dynamic>> tickets = [
      {
        'folio': 'TKT-2026-00031',
        'titulo': 'sadasd',
        'subtitulo': 'asdasdas',
        'estado': 'Pendiente',
        'estadoTipo': 'pendiente',
        'fecha': '19 Aug 2026',
        'hora': '02:15 PM',
      },
      {
        'folio': 'TKT-2026-00030',
        'titulo': 'No jala nada',
        'subtitulo': 'nadaa',
        'estado': 'Pendiente',
        'estadoTipo': 'pendiente',
        'fecha': '19 Aug 2026',
        'hora': '02:15 PM',
      },
      {
        'folio': 'TKT-2026-00029',
        'titulo': 'No jala nada',
        'subtitulo': 'nadaa',
        'estado': 'Pendiente',
        'estadoTipo': 'pendiente',
        'fecha': '19 Aug 2026',
        'hora': '02:13 PM',
      },
      {
        'folio': 'TKT-2026-00008',
        'titulo': 'La computadora no enciende',
        'subtitulo':
            'La computadora no enciende al presionar el botón de encendido.',
        'estado': 'Solucionado',
        'estadoTipo': 'solucionado',
        'fecha': '18 Aug 2026',
        'hora': '04:25 PM',
      },
      {
        'folio': 'TKT-2026-00027',
        'titulo': 'Acceso a sistema bloqueado',
        'subtitulo':
            'El usuario no puede acceder a uno de los sistemas utilizados para trabajar.',
        'estado': 'En proceso',
        'estadoTipo': 'proceso',
        'fecha': '18 Aug 2026',
        'hora': '04:25 PM',
      },
    ];

    if (!isDesktop) {
      return Column(
        children: tickets
            .map((ticket) => _buildMobileTicketItem(ticket))
            .toList(),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: 1000,
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(1.5),
            1: FlexColumnWidth(3.0),
            2: FlexColumnWidth(1.5),
            3: FlexColumnWidth(1.5),
            4: FlexColumnWidth(1.0),
          },
          children: [
            TableRow(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.white10)),
              ),
              children: [
                _tableHeaderCell('Folio'),
                _tableHeaderCell('Título del ticket'),
                _tableHeaderCell('Estado'),
                _tableHeaderCell('Fecha de creación'),
                _tableHeaderCell('Acciones', alignRight: true),
              ],
            ),

            ...tickets.map((ticket) {
              return TableRow(
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.white10)),
                ),
                children: [
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        ticket['folio'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),

                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ticket['titulo'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            ticket['subtitulo'],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: _statusBadge(
                          ticket['estado'],
                          ticket['estadoTipo'],
                        ),
                      ),
                    ),
                  ),

                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ticket['fecha'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            ticket['hora'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 4,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.visibility_outlined,
                              size: 18,
                              color: Colors.grey,
                            ),
                            onPressed: () {},
                            tooltip: 'Ver detalle',
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(
                              minWidth: 30,
                              minHeight: 30,
                            ),
                          ),

                          IconButton(
                            icon: Icon(
                              Icons.front_hand_outlined,
                              size: 18,
                              color: ticket['estadoTipo'] == 'solucionado'
                                  ? const Color(0xFF10B981)
                                  : Colors.grey,
                            ),
                            onPressed: () {},
                            tooltip: 'Tomar ticket',
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(
                              minWidth: 30,
                              minHeight: 30,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _tableHeaderCell(String title, {bool alignRight = false}) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: _tableHeader(title, alignRight: alignRight),
    );
  }

  Widget _tableHeader(String title, {bool alignRight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        textAlign: alignRight ? TextAlign.right : TextAlign.left,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _statusBadge(String text, String tipo) {
    Color bg;
    Color color;
    IconData icon;

    switch (tipo) {
      case 'pendiente':
        bg = const Color(0xFF3A2E07);
        color = const Color(0xFFEAB308);
        icon = Icons.circle;
        break;

      case 'solucionado':
        bg = const Color(0xFF064E3B);
        color = const Color(0xFF10B981);
        icon = Icons.check;
        break;

      case 'proceso':
      default:
        bg = const Color(0xFF1E3A8A);
        color = const Color(0xFF3B82F6);
        icon = Icons.circle;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileTicketItem(Map<String, dynamic> ticket) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1427),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  ticket['folio'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),

              const SizedBox(width: 8),
              _statusBadge(ticket['estado'], ticket['estadoTipo']),
            ],
          ),

          const SizedBox(height: 8),
          Text(
            ticket['titulo'],
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 3),
          Text(
            ticket['subtitulo'],
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.grey, fontSize: 11),
          ),

          const SizedBox(height: 12),
          _buildMobileActions(ticket),
        ],
      ),
    );
  }

  Widget _buildMobileActions(Map<String, dynamic> ticket) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            '${ticket['fecha']} - ${ticket['hora']}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.grey, fontSize: 10),
          ),
        ),

        const SizedBox(width: 4),
        SizedBox(
          width: 32,
          height: 32,
          child: IconButton(
            icon: const Icon(
              Icons.visibility_outlined,
              size: 17,
              color: Colors.grey,
            ),
            onPressed: () {},
            tooltip: 'Ver ticket',
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          ),
        ),

        const SizedBox(width: 2),
        SizedBox(
          width: 32,
          height: 32,
          child: IconButton(
            icon: Icon(
              Icons.front_hand_outlined,
              size: 17,
              color: ticket['estadoTipo'] == 'solucionado'
                  ? const Color(0xFF10B981)
                  : Colors.grey,
            ),
            onPressed: () {},
            tooltip: 'Tomar ticket',
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          ),
        ),
      ],
    );
  }
}

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

class AppNavigationDrawer extends StatelessWidget {
  final String activeRoute;

  const AppNavigationDrawer({super.key, this.activeRoute = 'Mis tickets'});

  static const String defaultAvatar = 'assets/images/user.png';

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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF2563EB),
                      width: 2,
                    ),
                  ),
                  child: const CircleAvatar(
                    radius: 20,
                    backgroundImage: AssetImage(defaultAvatar),
                  ),
                ),

                const SizedBox(width: 12),

                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Juan Pérez',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Administración',
                        maxLines: 1,
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
              onTap: () {
                if (activeRoute == 'Inicio') {
                  return;
                }

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                );
              },
            ),

            _drawerItem(
              icon: Icons.confirmation_number_outlined,
              title: 'Mis tickets',
              isActive: activeRoute == 'Mis tickets',
              onTap: () {
                if (activeRoute == 'Mis tickets') {
                  return;
                }

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const MisticketsScreen()),
                );
              },
            ),

            _drawerItem(
              icon: Icons.build_outlined,
              title: 'Crear ticket',
              isActive: activeRoute == 'Crear ticket',
              onTap: () {
                if (activeRoute == 'Crear ticket') {
                  return;
                }

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const CrearticketsScreen()),
                );
              },
            ),

            _drawerItem(
              icon: Icons.warning_amber_rounded,
              title: 'Avisos',
              isActive: activeRoute == 'Avisos',
              onTap: () {
                if (activeRoute == 'Avisos') {
                  return;
                }

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const AvisosScreen()),
                );
              },
            ),

            _drawerItem(
              icon: Icons.person_outline_rounded,
              title: 'Mi perfil',
              isActive: activeRoute == 'Mi perfil',
              onTap: () {
                if (activeRoute == 'Mi perfil') {
                  return;
                }

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const MiPerfilScreen()),
                );
              },
            ),

            const Spacer(),
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
    final Color itemColor = color ?? (isActive ? Colors.white : Colors.grey);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: isActive ? const Color(0xFF2563EB) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          dense: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          leading: Icon(icon, color: itemColor),
          title: Text(
            title,
            style: TextStyle(
              color: itemColor,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
