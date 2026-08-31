import 'package:flutter/material.dart';

import 'avisosadmin_screen.dart';
import 'backup_screen.dart';
import 'cambios_screen.dart';
import 'dispositivos_screen.dart';
import 'home_screen.dart';
import 'perfiladmin_screen.dart';
import 'users_screen.dart';
class TicketsScreen extends StatefulWidget {
  const TicketsScreen({super.key});

  @override
  State<TicketsScreen> createState() => _TicketsScreenState();
}

class _TicketsScreenState extends State<TicketsScreen> {
  static const Color background = Color(0xFF070B18);
  static const Color cardBg = Color(0xFF0F172A);
  static const Color sidebarBg = Color(0xFF0D1630);
  static const Color primaryBlue = Color(0xFF4F46E5);
  static const Color accentBlue = Color(0xFF3B82F6);
  static const Color cyanAccent = Color(0xFF06B6D4);
  static const Color greenAccent = Color(0xFF10B981);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textWhite = Colors.white;

  String selectedFilter = 'Todos';

  final List<TicketItem> tickets = [
    TicketItem(
      folio: 'TKT-2026-00018',
      title: 'Ticket de prueba flutter',
      type: 'hardware',
      priority: 'Crítica',
      status: 'Pendiente',
      assignedTo: 'Sin asignar',
      assignedRole: '',
      date: '29 Aug 2026',
      time: '11:51 PM',
    ),
    TicketItem(
      folio: 'TKT-2026-00017',
      title: 'Ticket de prueba numero 20',
      type: 'Servidor',
      priority: 'Media',
      status: 'Solucionado',
      assignedTo: 'Jesus Hinojosa',
      assignedRole: 'Tecnologías',
      date: '25 Aug 2026',
      time: '08:32 AM',
    ),
    TicketItem(
      folio: 'TKT-2026-00016',
      title: 'Ticket de prueba numero 15',
      type: 'Equipo',
      priority: 'Crítica',
      status: 'Solucionado',
      assignedTo: 'Jesus Hinojosa',
      assignedRole: 'Tecnologías',
      date: '25 Aug 2026',
      time: '07:15 AM',
    ),
    TicketItem(
      folio: 'TKT-2026-00015',
      title: 'Ticket de prueba numero 6',
      type: 'Redes',
      priority: 'Crítica',
      status: 'Solucionado',
      assignedTo: 'Jesus Hinojosa',
      assignedRole: 'Tecnologías',
      date: '24 Aug 2026',
      time: '03:58 PM',
    ),
    TicketItem(
      folio: 'TKT-2026-00014',
      title: 'Ticket de prueba numero 5',
      type: 'Equipo',
      priority: 'Crítica',
      status: 'Solucionado',
      assignedTo: 'Jesus Hinojosa',
      assignedRole: 'Tecnologías',
      date: '24 Aug 2026',
      time: '03:10 PM',
    ),
    TicketItem(
      folio: 'TKT-2026-00013',
      title: 'Ticket de prueba numero 3',
      type: 'Equipo',
      priority: 'Crítica',
      status: 'Solucionado',
      assignedTo: 'Jesus Hinojosa',
      assignedRole: 'Tecnologías',
      date: '24 Aug 2026',
      time: '02:03 PM',
    ),
    TicketItem(
      folio: 'TKT-2026-00012',
      title: 'Ticket de prueba numero 2',
      type: 'Equipo',
      priority: 'Crítica',
      status: 'Cancelado',
      assignedTo: 'Jesus Hinojosa',
      assignedRole: 'Tecnologías',
      date: '24 Aug 2026',
      time: '10:40 AM',
    ),
    TicketItem(
      folio: 'TKT-2026-00011',
      title: 'Ticket de prueba numero',
      type: 'Equipo',
      priority: 'Crítica',
      status: 'Solucionado',
      assignedTo: 'Jesus Hinojosa',
      assignedRole: 'Tecnologías',
      date: '24 Aug 2026',
      time: '10:39 AM',
    ),
  ];

  @override
  Widget build(BuildContext context) {
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
                  color: Colors.white,
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
                      color: primaryBlue,
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
            backgroundColor: primaryBlue,
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
      drawer: const CustomSidebar(activeMenu: 'Tickets'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tickets',
              style: TextStyle(
                color: textWhite,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Consulta y da seguimiento a todos los tickets que se han creado',
              style: TextStyle(
                color: textMuted,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: const [
                  KPIStatCard(
                    title: 'Total de tickets',
                    count: '18',
                    subtitle: 'Este mes',
                    icon: Icons.confirmation_number_outlined,
                    iconColor: accentBlue,
                  ),
                  SizedBox(width: 10),
                  KPIStatCard(
                    title: 'Pendientes',
                    count: '1',
                    subtitle: 'Este mes',
                    icon: Icons.access_time_rounded,
                    iconColor: Colors.amber,
                  ),
                  SizedBox(width: 10),
                  KPIStatCard(
                    title: 'En proceso',
                    count: '0',
                    subtitle: 'Este mes',
                    icon: Icons.sync,
                    iconColor: cyanAccent,
                  ),
                  SizedBox(width: 10),
                  KPIStatCard(
                    title: 'Solucionados',
                    count: '15',
                    subtitle: 'Este mes',
                    icon: Icons.check_circle_outline,
                    iconColor: greenAccent,
                  ),
                  SizedBox(width: 10),
                  KPIStatCard(
                    title: 'Cancelados',
                    count: '2',
                    subtitle: 'Este mes',
                    icon: Icons.cancel_outlined,
                    iconColor: Colors.redAccent,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Todos'),
                  _buildFilterChip('Mis tickets'),
                  _buildFilterChip('Pendientes'),
                  _buildFilterChip('En proceso'),
                  _buildFilterChip('Solucionados'),
                  _buildFilterChip('Cancelados'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 42,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.search,
                          color: textMuted,
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            style: TextStyle(
                              color: textWhite,
                              fontSize: 13,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Buscar...',
                              hintStyle: TextStyle(
                                color: textMuted,
                                fontSize: 13,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  height: 42,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        color: textMuted,
                        size: 16,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Este mes',
                        style: TextStyle(
                          color: textWhite,
                          fontSize: 12,
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: textMuted,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tickets.length,
              itemBuilder: (context, index) {
                final ticket = tickets[index];
                return TicketCard(ticket: ticket);
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
              child: Column(
                children: [
                  const Text(
                    'Mostrando 1 a 10 de 18 tickets',
                    style: TextStyle(
                      color: textMuted,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildPageBtn(
                        icon: Icons.chevron_left,
                        disabled: true,
                      ),
                      const SizedBox(width: 6),
                      _buildPageBtn(
                        text: '1',
                        selected: true,
                      ),
                      const SizedBox(width: 6),
                      _buildPageBtn(text: '2'),
                      const SizedBox(width: 6),
                      _buildPageBtn(
                        icon: Icons.chevron_right,
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

  Widget _buildFilterChip(String label) {
    final bool isSelected = selectedFilter == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = label;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? primaryBlue : cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? primaryBlue : Colors.white10,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? textWhite : textMuted,
            fontSize: 12,
            fontWeight: isSelected
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildPageBtn({
    String? text,
    IconData? icon,
    bool selected = false,
    bool disabled = false,
  }) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: selected
            ? primaryBlue
            : (disabled
                ? Colors.white.withValues(alpha: 0.02)
                : cardBg),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: selected ? primaryBlue : Colors.white10,
        ),
      ),
      child: Center(
        child: icon != null
            ? Icon(
                icon,
                color: disabled ? Colors.white24 : textWhite,
                size: 18,
              )
            : Text(
                text!,
                style: TextStyle(
                  color: selected ? textWhite : textMuted,
                  fontSize: 12,
                  fontWeight: selected
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
      ),
    );
  }
}

class TicketItem {
  final String folio;
  final String title;
  final String type;
  final String priority;
  final String status;
  final String assignedTo;
  final String assignedRole;
  final String date;
  final String time;

  TicketItem({
    required this.folio,
    required this.title,
    required this.type,
    required this.priority,
    required this.status,
    required this.assignedTo,
    required this.assignedRole,
    required this.date,
    required this.time,
  });
}

class TicketCard extends StatelessWidget {
  final TicketItem ticket;

  const TicketCard({
    super.key,
    required this.ticket,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                ticket.folio,
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  _buildPriorityBadge(ticket.priority),
                  const SizedBox(width: 6),
                  _buildStatusBadge(ticket.status),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            ticket.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(
            color: Colors.white10,
            height: 1,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.memory,
                size: 14,
                color: Color(0xFF94A3B8),
              ),
              const SizedBox(width: 4),
              Text(
                ticket.type,
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.access_time,
                size: 14,
                color: Color(0xFF94A3B8),
              ),
              const SizedBox(width: 4),
              Text(
                '${ticket.date} • ${ticket.time}',
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 10,
                    backgroundColor: Color(0xFF3B82F6),
                    child: Text(
                      'US',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ticket.assignedTo,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (ticket.assignedRole.isNotEmpty)
                        Text(
                          ticket.assignedRole,
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 9,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      child: const Icon(
                        Icons.remove_red_eye_outlined,
                        color: Color(0xFF94A3B8),
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      child: const Icon(
                        Icons.front_hand_outlined,
                        color: Color(0xFF10B981),
                        size: 19,
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

  Widget _buildPriorityBadge(String priority) {
    Color bg = Colors.red.withValues(alpha: 0.15);
    Color text = Colors.redAccent;
    IconData icon = Icons.error_outline;

    if (priority == 'Media') {
      bg = Colors.amber.withValues(alpha: 0.15);
      text = Colors.amber;
      icon = Icons.keyboard_arrow_up;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: text.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: text,
            size: 11,
          ),
          const SizedBox(width: 3),
          Text(
            priority,
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

  Widget _buildStatusBadge(String status) {
    Color bg = Colors.amber.withValues(alpha: 0.15);
    Color text = Colors.amber;
    String prefix = '• ';

    if (status == 'Solucionado') {
      bg = const Color(0xFF10B981).withValues(alpha: 0.15);
      text = const Color(0xFF10B981);
      prefix = '✓ ';
    } else if (status == 'Cancelado') {
      bg = Colors.red.withValues(alpha: 0.15);
      text = Colors.redAccent;
      prefix = '✕ ';
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$prefix$status',
        style: TextStyle(
          color: text,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class KPIStatCard extends StatelessWidget {
  final String title;
  final String count;
  final String subtitle;
  final IconData icon;
  final Color iconColor;

  const KPIStatCard({
    super.key,
    required this.title,
    required this.count,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 125,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: iconColor,
                size: 15,
              ),
              const SizedBox(width: 4),
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
            ],
          ),
          Text(
            count,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}

class CustomSidebar extends StatelessWidget {
  final String activeMenu;

  const CustomSidebar({
    super.key,
    this.activeMenu = 'Inicio',
  });

  @override
  Widget build(BuildContext context) {
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
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const AvisosadminScreen(),
                ),
              );
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
            Icons.logout,
            'Cerrar sesión',
            isExit: true,
            onTap: () {
              Navigator.pop(context);
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
          color: isExit
              ? Colors.redAccent
              : (selected
                  ? Colors.white
                  : const Color(0xFF94A3B8)),
          size: 20,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isExit
                ? Colors.redAccent
                : (selected
                    ? Colors.white
                    : const Color(0xFF94A3B8)),
            fontSize: 14,
            fontWeight:
                selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
