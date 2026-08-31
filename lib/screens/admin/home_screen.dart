import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../services/session_service.dart';
import 'avisosadmin_screen.dart';
import 'cambios_screen.dart';
import 'dispositivos_screen.dart';
import 'perfiladmin_screen.dart';
import 'tickets_screen.dart';
import 'users_screen.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});
  static const Color background = Color(0xFF070B18);
  static const Color cardBg = Color(0xFF0F172A);
  static const Color sidebarBg = Color(0xFF0D1630);
  static const Color primaryBlue = Color(0xFF4F46E5);
  static const Color accentBlue = Color(0xFF3B82F6);
  static const Color cyanAccent = Color(0xFF06B6D4);
  static const Color greenAccent = Color(0xFF10B981);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textWhite = Colors.white;
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
                const Icon(Icons.notifications_outlined, color: Colors.white),
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
                      style: TextStyle(color: Colors.white, fontSize: 9),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          const AdminAvatar(radius: 16),
          const SizedBox(width: 12),
        ],
      ),
      drawer: const CustomSidebar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tecnologías / Soporte',
              style: TextStyle(
                color: textWhite,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Dashboard de estadísticas y métricas del soporte técnico.',
              style: TextStyle(color: textMuted, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: textMuted,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Seleccionar fechas',
                        style: TextStyle(color: textWhite, fontSize: 13),
                      ),
                    ],
                  ),
                  Icon(Icons.keyboard_arrow_down, color: textMuted),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.35,
              children: const [
                KPICard(
                  icon: Icons.confirmation_number_outlined,
                  iconColor: accentBlue,
                  title: 'Tickets abiertos',
                  value: '0',
                  badgeText: '+57% vs semana pasada ↗',
                  badgeColor: greenAccent,
                ),
                KPICard(
                  icon: Icons.access_time_rounded,
                  iconColor: Colors.purpleAccent,
                  title: 'Tickets pendientes',
                  value: '1',
                  badgeText: '+57% vs semana pasada ↗',
                  badgeColor: greenAccent,
                ),
                KPICard(
                  icon: Icons.check_circle_outline,
                  iconColor: greenAccent,
                  title: 'Tickets resueltos',
                  value: '15',
                  badgeText: '+57% vs semana pasada ↗',
                  badgeColor: greenAccent,
                ),
                KPICard(
                  icon: Icons.timer_outlined,
                  iconColor: Colors.amber,
                  title: 'Tiempo promedio',
                  subtitle: 'de atención',
                  value: '0h 4m',
                  badgeText: '-100% vs semana pasada ↘',
                  badgeColor: cyanAccent,
                ),
              ],
            ),
            const SizedBox(height: 12),
            const KPICard(
              icon: Icons.bar_chart_rounded,
              iconColor: accentBlue,
              title: 'Tickets del mes',
              value: '18',
              badgeText: 'Este mes',
              badgeColor: cyanAccent,
              fullWidth: true,
            ),
            const SizedBox(height: 20),
            CardContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.amber,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Quejas recurrentes',
                        style: TextStyle(
                          color: textWhite,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Problemas más reportados por los usuarios.',
                    style: TextStyle(color: textMuted, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  const ProgressBarRow(
                    label: 'Equipo',
                    value: 15,
                    total: 15,
                    barColor: accentBlue,
                  ),
                  const ProgressBarRow(
                    label: 'Redes',
                    value: 1,
                    total: 15,
                    barColor: accentBlue,
                  ),
                  const ProgressBarRow(
                    label: 'Servidor',
                    value: 1,
                    total: 15,
                    barColor: accentBlue,
                  ),
                  const ProgressBarRow(
                    label: 'Hardware',
                    value: 1,
                    total: 15,
                    barColor: accentBlue,
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Ver todas las quejas >',
                        style: TextStyle(
                          color: textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            CardContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.laptop_chromebook,
                        color: accentBlue,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Equipo con más fallas',
                        style: TextStyle(
                          color: textWhite,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Equipos con mayor número de incidencias.',
                    style: TextStyle(color: textMuted, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            'Equipo',
                            style: TextStyle(color: textMuted, fontSize: 11),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Tipo',
                            style: TextStyle(color: textMuted, fontSize: 11),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            'Fallas',
                            style: TextStyle(color: textMuted, fontSize: 11),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Última incidencia',
                            style: TextStyle(color: textMuted, fontSize: 11),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Colors.white10),
                  const EquipmentRow(
                    name: 'Laptop - lenovo',
                    type: 'Equipo',
                    count: '11',
                    date: '25 Aug',
                  ),
                  const EquipmentRow(
                    name: 'Impresora',
                    type: 'Equipo',
                    count: '2',
                    date: '24 Aug',
                  ),
                  const EquipmentRow(
                    name: 'Pc - Hp',
                    type: 'Equipo',
                    count: '2',
                    date: '20 Aug',
                  ),
                  const EquipmentRow(
                    name: 'LAP-ADM-2',
                    type: 'Laptop',
                    count: '1',
                    date: '29 Aug',
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.amber.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.amber,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.amber,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Equipo con mayor recurrencia: ',
                                ),
                                TextSpan(
                                  text: 'Laptop - lenovo',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: accentBlue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const CardContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: accentBlue,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        '¿Dónde hay más tickets?',
                        style: TextStyle(
                          color: textWhite,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Tickets generados por ubicación / sucursal.',
                    style: TextStyle(color: textMuted, fontSize: 12),
                  ),
                  SizedBox(height: 16),
                  ProgressBarRow(
                    label: 'Reynosa',
                    value: 18,
                    total: 18,
                    barColor: cyanAccent,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            CardContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.show_chart, color: accentBlue, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Evolución de tickets',
                        style: TextStyle(
                          color: textWhite,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Comportamiento de tickets en el periodo seleccionado.',
                    style: TextStyle(color: textMuted, fontSize: 11),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: background,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildFilterTab('Hoy', false),
                        _buildFilterTab('Semana', true),
                        _buildFilterTab('Mes', false),
                        _buildFilterTab('Año', false),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 180,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: Colors.white.withValues(alpha: 0.05),
                            strokeWidth: 1,
                          ),
                        ),
                        titlesData: FlTitlesData(
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 20,
                              getTitlesWidget: (value, meta) => Text(
                                '${value.toInt()}',
                                style: const TextStyle(
                                  color: textMuted,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                const days = [
                                  '24 ago.',
                                  '25 ago.',
                                  '26 ago.',
                                  '27 ago.',
                                  '28 ago.',
                                  '29 ago.',
                                  '30 ago.',
                                ];
                                if (value.toInt() >= 0 &&
                                    value.toInt() < days.length) {
                                  return Text(
                                    days[value.toInt()],
                                    style: const TextStyle(
                                      color: textMuted,
                                      fontSize: 9,
                                    ),
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: const [
                              FlSpot(0, 7),
                              FlSpot(1, 2.2),
                              FlSpot(2, 1),
                              FlSpot(3, 1),
                              FlSpot(4, 1),
                              FlSpot(5, 1.8),
                              FlSpot(6, 1),
                            ],
                            isCurved: true,
                            color: accentBlue,
                            barWidth: 3,
                            dotData: const FlDotData(show: true),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      MiniStat(
                        title: 'Promedio',
                        value: '1.6',
                        icon: Icons.center_focus_weak,
                      ),
                      MiniStat(
                        title: 'Máximo',
                        value: '8',
                        icon: Icons.trending_up,
                      ),
                      MiniStat(
                        title: 'Mínimo',
                        value: '0',
                        icon: Icons.trending_down,
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

  static Widget _buildFilterTab(String text, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? primaryBlue : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isSelected ? textWhite : textMuted,
          fontSize: 11,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}

class CustomSidebar extends StatelessWidget {
  const CustomSidebar({super.key});
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AdminScreen.sidebarBg,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AdminScreen.sidebarBg),
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
          _drawerItem(Icons.dashboard_rounded, 'Inicio', selected: true),
          _drawerItem(
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
          _drawerItem(
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
          _drawerItem(
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
          _drawerItem(
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
          _drawerItem(
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
          _drawerItem(
            Icons.person_outline,
            'Mi perfil',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PerfiladminScreen(),
                ),
              );
            },
          ),
          const Divider(color: Colors.white10),
          _drawerItem(
            Icons.logout_rounded,
            'Cerrar sesión',
            onTap: () async {
              await SessionService.clearSession();
              if (!context.mounted) {
                return;
              }

              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: selected ? AdminScreen.primaryBlue : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isExit
              ? Colors.redAccent
              : (selected ? Colors.white : AdminScreen.textMuted),
          size: 20,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isExit
                ? Colors.redAccent
                : (selected ? Colors.white : AdminScreen.textMuted),
            fontSize: 14,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}

class AdminAvatar extends StatelessWidget {
  const AdminAvatar({super.key, this.radius = 16});

  final double radius;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: SessionService.getUser(),
      builder: (context, snapshot) {
        final picture = snapshot.data?['picture']?.toString().trim() ?? '';
        final imageUrl = ApiService.profileImageUrl(picture);
        return CircleAvatar(
          radius: radius,
          backgroundColor: const Color(0xFF4F46E5),
          child: ClipOval(
            child: imageUrl.isEmpty
                ? Image.asset(
                    'assets/images/user.png',
                    width: radius * 2,
                    height: radius * 2,
                    fit: BoxFit.cover,
                  )
                : Image.network(
                    '$imageUrl?profile_refresh=${picture.hashCode}',
                    width: radius * 2,
                    height: radius * 2,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Image.asset(
                      'assets/images/user.png',
                      width: radius * 2,
                      height: radius * 2,
                      fit: BoxFit.cover,
                    ),
                  ),
          ),
        );
      },
    );
  }
}

class CardContainer extends StatelessWidget {
  final Widget child;
  const CardContainer({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AdminScreen.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: child,
    );
  }
}

class KPICard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final String value;
  final String badgeText;
  final Color badgeColor;
  final bool fullWidth;
  const KPICard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    required this.value,
    required this.badgeText,
    required this.badgeColor,
    this.fullWidth = false,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AdminScreen.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AdminScreen.textMuted,
                        fontSize: 11,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          color: AdminScreen.textMuted,
                          fontSize: 10,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            badgeText,
            style: TextStyle(
              color: badgeColor,
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class ProgressBarRow extends StatelessWidget {
  final String label;
  final int value;
  final int total;
  final Color barColor;
  const ProgressBarRow({
    super.key,
    required this.label,
    required this.value,
    required this.total,
    required this.barColor,
  });
  @override
  Widget build(BuildContext context) {
    double factor = (value / total).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              Text(
                '$value',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Container(
                    height: 6,
                    width: constraints.maxWidth,
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  Container(
                    height: 6,
                    width: constraints.maxWidth * factor,
                    decoration: BoxDecoration(
                      color: barColor,
                      borderRadius: BorderRadius.circular(3),
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
}

class EquipmentRow extends StatelessWidget {
  final String name;
  final String type;
  final String count;
  final String date;
  const EquipmentRow({
    super.key,
    required this.name,
    required this.type,
    required this.count,
    required this.date,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                const Icon(
                  Icons.computer,
                  color: AdminScreen.textMuted,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              type,
              style: const TextStyle(
                color: AdminScreen.textMuted,
                fontSize: 11,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              count,
              style: const TextStyle(color: Colors.white, fontSize: 11),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              date,
              style: const TextStyle(
                color: AdminScreen.textMuted,
                fontSize: 11,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class MiniStat extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  const MiniStat({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AdminScreen.accentBlue, size: 18),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(color: AdminScreen.textMuted, fontSize: 10),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
