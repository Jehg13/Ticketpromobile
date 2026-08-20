import 'package:flutter/material.dart';

import 'creartickets_screen.dart';
import 'home_screen.dart';
import 'mistickets_screen.dart';
import 'perfil_screen.dart';

class AvisosScreen extends StatefulWidget {
  const AvisosScreen({super.key});

  @override
  State<AvisosScreen> createState() => _AvisosScreenState();
}

class _AvisosScreenState extends State<AvisosScreen> {
  // ================================================================
  // CONFIGURACIÓN
  // ================================================================

  static const String defaultAvatar = 'assets/images/user.png';

  // ================================================================
  // ESTADO
  // ================================================================

  String selectedFilter = 'Todos';
  int currentPage = 1;

  // ================================================================
  // AVISOS
  // ================================================================

  final List<Map<String, dynamic>> avisos = List.generate(
    5,
    (index) => {
      'categoria': 'MANTENIMIENTO',
      'titulo': index == 0
          ? 'ACTUALIZACIÓN DE EQUIPOS DE CÓMPUTO'
          : 'MANTENIMIENTO PROGRAMADO DEL SISTEMA',
      'descripcion':
          'Se realizará un mantenimiento programado en los sistemas internos de la empresa. Durante este periodo algunos servicios podrían presentar intermitencias.',
      'afecta': 'Toda la empresa',
      'prioridad': 'Alta',
      'fecha': '19 ago 2026, 08:48 p.m.',
      'icon': Icons.settings_outlined,
      'colorCategory': const Color(0xFFD97706),
    },
  );

  // ================================================================
  // BUILD
  // ================================================================

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth >= 1024;

    return Scaffold(
      backgroundColor: const Color(0xFF060A17),

      // ============================================================
      // APP BAR
      // ============================================================

      appBar: isDesktop
          ? null
          : AppBar(
              backgroundColor: const Color(0xFF0B1021),
              elevation: 0,
              iconTheme: const IconThemeData(
                color: Colors.white,
              ),
              title: const AppLogo(
                fontSize: 20,
              ),
              actions: const [
                Icon(
                  Icons.notifications_none_rounded,
                  color: Colors.white,
                ),
                SizedBox(width: 12),
                CircleAvatar(
                  radius: 14,
                  backgroundImage: AssetImage(
                    defaultAvatar,
                  ),
                ),
                SizedBox(width: 16),
              ],
            ),

      // ============================================================
      // DRAWER MOBILE
      // ============================================================

      drawer: isDesktop
          ? null
          : const AppNavigationDrawer(
              activeRoute: 'Avisos',
            ),

      // ============================================================
      // BODY
      // ============================================================

      body: Row(
        children: [
          // ========================================================
          // SIDEBAR DESKTOP
          // ========================================================

          if (isDesktop)
            const SizedBox(
              width: 260,
              child: AppNavigationDrawer(
                activeRoute: 'Avisos',
              ),
            ),

          // ========================================================
          // CONTENIDO
          // ========================================================

          Expanded(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 32.0 : 16.0,
                  vertical: 24.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(isDesktop),

                    const SizedBox(height: 20),

                    _buildFilterAndSearch(isDesktop),

                    const SizedBox(height: 20),

                    _buildAvisosContainer(screenWidth),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // HEADER
  // ================================================================

  Widget _buildHeader(bool isDesktop) {
    if (!isDesktop) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Avisos',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Mantente informado sobre mantenimientos, fallas y actualizaciones',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 13,
            ),
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ==========================================================
        // TITULO
        // ==========================================================

        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Avisos',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Mantente informado sobre mantenimientos, fallas y actualizaciones',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 20),

        // ==========================================================
        // ACCIONES + USUARIO
        // ==========================================================

        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0D1427),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () {},
              ),
            ),

            const SizedBox(width: 16),

            // ======================================================
            // USUARIO
            // ======================================================

            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(
                  radius: 18,
                  backgroundImage: AssetImage(
                    defaultAvatar,
                  ),
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
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                      ),
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

  // ================================================================
  // FILTROS Y BÚSQUEDA
  // ================================================================

  Widget _buildFilterAndSearch(bool isDesktop) {
    final filters = [
      {
        'label': 'Todos',
        'activeColor': const Color(0xFF2563EB),
        'textColor': Colors.white,
      },
      {
        'label': 'Mantenimiento',
        'activeColor': const Color(0xFF38240D),
        'textColor': const Color(0xFFF59E0B),
      },
      {
        'label': 'Falla / Incidente',
        'activeColor': const Color(0xFF3B1219),
        'textColor': const Color(0xFFEF4444),
      },
      {
        'label': 'Informativo',
        'activeColor': const Color(0xFF0C2A3A),
        'textColor': const Color(0xFF06B6D4),
      },
      {
        'label': 'General',
        'activeColor': const Color(0xFF1E293B),
        'textColor': Colors.grey,
      },
    ];

    // ==============================================================
    // FILTROS
    // ==============================================================

    Widget filterList = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final String label = f['label'] as String;
          final Color activeColor = f['activeColor'] as Color;
          final Color textColor = f['textColor'] as Color;

          final bool isSelected = selectedFilter == label;

          return Padding(
            padding: const EdgeInsets.only(
              right: 8,
            ),
            child: InkWell(
              onTap: () {
                setState(() {
                  selectedFilter = label;
                  currentPage = 1;
                });
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? activeColor
                      : const Color(0xFF0B1021),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? textColor.withOpacity(0.5)
                        : Colors.white12,
                  ),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected
                        ? textColor
                        : Colors.grey,
                    fontSize: 12,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );

    // ==============================================================
    // BUSCADOR
    // ==============================================================

    Widget searchInput = TextField(
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12,
      ),
      decoration: InputDecoration(
        hintText: 'Buscar aviso...',
        hintStyle: const TextStyle(
          color: Colors.grey,
          fontSize: 12,
        ),
        filled: true,
        fillColor: const Color(0xFF060A17),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        suffixIcon: const Icon(
          Icons.search_rounded,
          color: Colors.grey,
          size: 18,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Colors.white12,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Color(0xFF2563EB),
          ),
        ),
      ),
    );

    // ==============================================================
    // DESKTOP
    // ==============================================================

    if (isDesktop) {
      return Row(
        children: [
          Expanded(
            child: filterList,
          ),

          const SizedBox(width: 16),

          SizedBox(
            width: 240,
            child: searchInput,
          ),
        ],
      );
    }

    // ==============================================================
    // MOBILE
    // ==============================================================

    return Column(
      children: [
        filterList,

        const SizedBox(height: 12),

        SizedBox(
          width: double.infinity,
          child: searchInput,
        ),
      ],
    );
  }

  // ================================================================
  // CONTENEDOR DE AVISOS
  // ================================================================

  Widget _buildAvisosContainer(double screenWidth) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        screenWidth < 600 ? 12 : 20,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1021),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.withOpacity(0.12),
        ),
      ),
      child: Column(
        children: [
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: avisos.length,
            separatorBuilder: (_, __) {
              return const SizedBox(height: 14);
            },
            itemBuilder: (context, index) {
              return _buildAvisoCard(
                avisos[index],
                screenWidth,
              );
            },
          ),

          const SizedBox(height: 20),

          _buildPagination(screenWidth),
        ],
      ),
    );
  }

  // ================================================================
  // TARJETA DE AVISO
  // ================================================================

  Widget _buildAvisoCard(
    Map<String, dynamic> item,
    double screenWidth,
  ) {
    final bool isMobile = screenWidth < 768;

    // ==============================================================
    // BADGE CATEGORIA
    // ==============================================================

    Widget headerBadge = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF38240D),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        item['categoria'],
        style: const TextStyle(
          color: Color(0xFFF59E0B),
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    // ==============================================================
    // BADGE PRIORIDAD
    // ==============================================================

    Widget priorityBadge = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF381B13),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: const Color(0xFFF97316).withOpacity(0.5),
        ),
      ),
      child: Text(
        item['prioridad'],
        style: const TextStyle(
          color: Color(0xFFF97316),
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    // ==============================================================
    // FECHA + VER MÁS
    // ==============================================================

    Widget dateAndLink = Wrap(
      alignment: isMobile
          ? WrapAlignment.spaceBetween
          : WrapAlignment.end,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 12,
      runSpacing: 8,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 12,
              color: Colors.grey,
            ),

            const SizedBox(width: 4),

            Text(
              item['fecha'],
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 11,
              ),
            ),

            const SizedBox(width: 4),

            const Icon(
              Icons.access_time_rounded,
              size: 12,
              color: Colors.grey,
            ),
          ],
        ),

        InkWell(
          onTap: () {},
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Ver más',
                style: TextStyle(
                  color: Color(0xFF3B82F6),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF3B82F6),
                size: 16,
              ),
            ],
          ),
        ),
      ],
    );

    // ==============================================================
    // CARD
    // ==============================================================

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF060A17),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white.withOpacity(0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ========================================================
          // ICONO + TITULO
          // ========================================================

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF2B1C08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  item['icon'] as IconData,
                  color: item['colorCategory'] as Color,
                  size: 20,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isMobile)
                      headerBadge
                    else
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          headerBadge,
                          priorityBadge,
                        ],
                      ),

                    const SizedBox(height: 6),

                    Text(
                      item['titulo'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ========================================================
          // PRIORIDAD MOBILE
          // ========================================================

          if (isMobile) ...[
            const SizedBox(height: 8),
            priorityBadge,
          ],

          const SizedBox(height: 10),

          // ========================================================
          // DESCRIPCIÓN
          // ========================================================

          Text(
            item['descripcion'],
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 10),

          // ========================================================
          // AFECTA
          // ========================================================

          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 11,
              ),
              children: [
                const TextSpan(
                  text: 'Afecta a: ',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                TextSpan(
                  text: item['afecta'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          const Divider(
            color: Colors.white10,
            height: 1,
          ),

          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            child: dateAndLink,
          ),
        ],
      ),
    );
  }

  // ================================================================
  // PAGINACIÓN
  // ================================================================

  Widget _buildPagination(double screenWidth) {
    final bool isSmall = screenWidth < 500;

    const Widget pageInfo = Text(
      'Mostrando 1 a 5 de 16 avisos',
      style: TextStyle(
        color: Colors.grey,
        fontSize: 12,
      ),
    );

    Widget pageControls = FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _pageBtn(
            icon: Icons.chevron_left_rounded,
            disabled: currentPage == 1,
            onTap: () {
              if (currentPage > 1) {
                setState(() {
                  currentPage--;
                });
              }
            },
          ),

          const SizedBox(width: 4),

          _pageNumberBtn(1),

          const SizedBox(width: 4),

          _pageNumberBtn(2),

          const SizedBox(width: 4),

          _pageNumberBtn(3),

          const SizedBox(width: 4),

          _pageNumberBtn(4),

          const SizedBox(width: 4),

          _pageBtn(
            icon: Icons.chevron_right_rounded,
            disabled: currentPage == 4,
            onTap: () {
              if (currentPage < 4) {
                setState(() {
                  currentPage++;
                });
              }
            },
          ),
        ],
      ),
    );

    // ==============================================================
    // MOBILE
    // ==============================================================

    if (isSmall) {
      return Column(
        children: [
          pageInfo,

          const SizedBox(height: 12),

          pageControls,
        ],
      );
    }

    // ==============================================================
    // DESKTOP
    // ==============================================================

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        pageInfo,
        pageControls,
      ],
    );
  }

  // ================================================================
  // BOTÓN PAGINACIÓN
  // ================================================================

  Widget _pageBtn({
    required IconData icon,
    bool disabled = false,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: const Color(0xFF060A17),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Colors.white12,
        ),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(
          icon,
          size: 18,
          color: disabled
              ? Colors.white24
              : Colors.grey,
        ),
        onPressed: disabled ? null : onTap,
      ),
    );
  }

  // ================================================================
  // NÚMERO DE PÁGINA
  // ================================================================

  Widget _pageNumberBtn(int page) {
    final bool isSelected = currentPage == page;

    return InkWell(
      onTap: () {
        setState(() {
          currentPage = page;
        });
      },
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF2563EB)
              : const Color(0xFF060A17),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF2563EB)
                : Colors.white12,
          ),
        ),
        child: Text(
          '$page',
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : Colors.grey,
            fontSize: 12,
            fontWeight: isSelected
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

// ==================================================================
// LOGO
// ==================================================================

class AppLogo extends StatelessWidget {
  final double fontSize;

  const AppLogo({
    super.key,
    this.fontSize = 26,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
        children: const [
          TextSpan(
            text: 'Ticket',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          TextSpan(
            text: 'Pro',
            style: TextStyle(
              color: Color(0xFF2563EB),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// DRAWER
// ==================================================================

class AppNavigationDrawer extends StatelessWidget {
  final String activeRoute;

  const AppNavigationDrawer({
    super.key,
    this.activeRoute = 'Avisos',
  });

  // ================================================================
  // AVATAR LOCAL
  // ================================================================

  static const String defaultAvatar =
      'assets/images/user.png';

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: const Color(0xFF0B1021),
        padding: const EdgeInsets.symmetric(
          vertical: 36,
          horizontal: 16,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // ======================================================
            // LOGO
            // ======================================================

            const AppLogo(
              fontSize: 26,
            ),

            const SizedBox(height: 24),

            // ======================================================
            // USUARIO
            // ======================================================

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
                    backgroundImage: AssetImage(
                      defaultAvatar,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                const Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Juan Pérez',
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Administración',
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            const Divider(
              color: Colors.white12,
              height: 1,
            ),

            const SizedBox(height: 20),

            // ======================================================
            // INICIO
            // ======================================================

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
                  MaterialPageRoute(
                    builder: (_) =>
                        const HomeScreen(),
                  ),
                );
              },
            ),

            // ======================================================
            // MIS TICKETS
            // ======================================================

            _drawerItem(
              icon:
                  Icons.confirmation_number_outlined,
              title: 'Mis tickets',
              isActive:
                  activeRoute == 'Mis tickets',
              onTap: () {
                if (activeRoute == 'Mis tickets') {
                  return;
                }

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const MisticketsScreen(),
                  ),
                );
              },
            ),

            // ======================================================
            // CREAR TICKET
            // ======================================================

            _drawerItem(
              icon: Icons.build_outlined,
              title: 'Crear ticket',
              isActive:
                  activeRoute == 'Crear ticket',
              onTap: () {
                if (activeRoute == 'Crear ticket') {
                  return;
                }

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const CrearticketsScreen(),
                  ),
                );
              },
            ),

            // ======================================================
            // AVISOS
            // ======================================================

            _drawerItem(
              icon:
                  Icons.warning_amber_rounded,
              title: 'Avisos',
              isActive:
                  activeRoute == 'Avisos',
              onTap: () {
                if (activeRoute == 'Avisos') {
                  return;
                }

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const AvisosScreen(),
                  ),
                );
              },
            ),

            // ======================================================
            // MI PERFIL
            // ======================================================

            _drawerItem(
              icon:
                  Icons.person_outline_rounded,
              title: 'Mi perfil',
              isActive:
                  activeRoute == 'Mi perfil',
              onTap: () {
                if (activeRoute == 'Mi perfil') {
                  return;
                }

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const MiPerfilScreen(),
                  ),
                );
              },
            ),

            const Spacer(),

            // ======================================================
            // CERRAR SESIÓN
            // ======================================================

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

  // ================================================================
  // ITEM DEL DRAWER
  // ================================================================

  Widget _drawerItem({
    required IconData icon,
    required String title,
    bool isActive = false,
    Color? color,
    required VoidCallback onTap,
  }) {
    final Color itemColor =
        color ??
        (isActive
            ? Colors.white
            : Colors.grey);

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 4,
      ),
      child: Material(
        color: isActive
            ? const Color(0xFF2563EB)
            : Colors.transparent,
        borderRadius:
            BorderRadius.circular(10),
        clipBehavior:
            Clip.antiAlias,
        child: ListTile(
          dense: true,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(10),
          ),
          leading: Icon(
            icon,
            color: itemColor,
          ),
          title: Text(
            title,
            style: TextStyle(
              color: itemColor,
              fontWeight: isActive
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}