import 'package:flutter/material.dart';

class MiPerfilScreen extends StatelessWidget {
  const MiPerfilScreen({super.key});

  // ============================================================
  // COLORES
  // ============================================================

  static const Color backgroundColor = Color(0xFF060A17);
  static const Color cardColor = Color(0xFF0B1021);
  static const Color secondaryColor = Color(0xFF0D1427);
  static const Color primaryColor = Color(0xFF2563EB);

  // ============================================================
  // INFORMACIÓN DEL USUARIO
  // ============================================================

  static const String nombreUsuario = 'Juan Perez';
  static const String departamento = 'Administración';

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth >= 1024;

    return Scaffold(
      backgroundColor: backgroundColor,

      // ==========================================================
      // APP BAR MÓVIL
      // ==========================================================

      appBar: isDesktop
          ? null
          : AppBar(
              backgroundColor: cardColor,
              elevation: 0,
              iconTheme: const IconThemeData(
                color: Colors.white,
              ),
              title: const AppLogo(
                fontSize: 20,
              ),
              actions: [
                const Icon(
                  Icons.notifications_none_rounded,
                  color: Colors.white,
                ),

                const SizedBox(width: 12),

                const UserAvatar(
                  name: nombreUsuario,
                  radius: 14,
                ),

                const SizedBox(width: 16),
              ],
            ),

      // ==========================================================
      // DRAWER MÓVIL
      // ==========================================================

      drawer: isDesktop
          ? null
          : const AppNavigationDrawer(
              activeRoute: 'Mi perfil',
            ),

      // ==========================================================
      // BODY
      // ==========================================================

      body: Row(
        children: [
          if (isDesktop)
            const SizedBox(
              width: 260,
              child: AppNavigationDrawer(
                activeRoute: 'Mi perfil',
              ),
            ),

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

                    const SizedBox(height: 24),

                    _buildMainLayout(
                      isDesktop,
                      screenWidth,
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

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader(bool isDesktop) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mi perfil',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              SizedBox(height: 4),

              Text(
                'Consulta de tu información personal y de tu cuenta.',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),

        if (isDesktop) ...[
          Container(
            decoration: BoxDecoration(
              color: secondaryColor,
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

          const Row(
            children: [
              UserAvatar(
                name: nombreUsuario,
                radius: 18,
              ),

              SizedBox(width: 10),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nombreUsuario,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),

                  Text(
                    departamento,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),

              SizedBox(width: 4),

              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.grey,
                size: 18,
              ),
            ],
          ),
        ],
      ],
    );
  }

  // ============================================================
  // ESTRUCTURA PRINCIPAL
  // ============================================================

  Widget _buildMainLayout(
    bool isDesktop,
    double screenWidth,
  ) {
    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 7,
            child: Column(
              children: [
                _buildInfoPersonalCard(),

                const SizedBox(height: 16),

                _buildBannerSolicitarCambio(),

                const SizedBox(height: 16),

                _buildSeguridadCuentaCard(),
              ],
            ),
          ),

          const SizedBox(width: 20),

          Expanded(
            flex: 4,
            child: Column(
              children: [
                _buildFotoPerfilCard(),

                const SizedBox(height: 16),

                _buildInfoCuentaCard(),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        _buildFotoPerfilCard(),

        const SizedBox(height: 16),

        _buildInfoPersonalCard(),

        const SizedBox(height: 16),

        _buildBannerSolicitarCambio(),

        const SizedBox(height: 16),

        _buildSeguridadCuentaCard(),

        const SizedBox(height: 16),

        _buildInfoCuentaCard(),
      ],
    );
  }

  // ============================================================
  // INFORMACIÓN PERSONAL
  // ============================================================

  Widget _buildInfoPersonalCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.withOpacity(0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.person_outline_rounded,
                color: Colors.white,
                size: 20,
              ),

              SizedBox(width: 8),

              Text(
                'Información personal y laboral',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          const Text(
            'Esta información es proporcionada por la empresa',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 20),

          LayoutBuilder(
            builder: (context, constraints) {
              final double cardWidth = constraints.maxWidth > 500
                  ? (constraints.maxWidth - 12) / 2
                  : constraints.maxWidth;

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _infoTile(
                    'Nombre completo',
                    'Juan Perez',
                    Icons.person_outline,
                    cardWidth,
                  ),

                  _infoTile(
                    'Empresa',
                    'Cymez',
                    Icons.apartment_outlined,
                    cardWidth,
                  ),

                  _infoTile(
                    'Correo electrónico',
                    'administracion@cymez.com',
                    Icons.email_outlined,
                    cardWidth,
                  ),

                  _infoTile(
                    'Oficina / Sucursal',
                    'Reynosa',
                    Icons.desktop_windows_outlined,
                    cardWidth,
                  ),

                  _infoTile(
                    'Departamento',
                    'administracion',
                    Icons.account_tree_outlined,
                    cardWidth,
                  ),

                  _infoTile(
                    'Ubicación',
                    'Edificio A, piso 2',
                    Icons.location_on_outlined,
                    cardWidth,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INFO TILE
  // ============================================================

  Widget _infoTile(
    String label,
    String value,
    IconData icon,
    double width,
  ) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: secondaryColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              color: Colors.white70,
              size: 18,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
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

  // ============================================================
  // BANNER SOLICITAR CAMBIO
  // ============================================================

  Widget _buildBannerSolicitarCambio() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.withOpacity(0.12),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Text(
              'i',
              style: TextStyle(
                color: backgroundColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),

          const SizedBox(width: 12),

          const Expanded(
            child: Text(
              'Si alguna de tu información es incorrecta o requiere actualización, solicita un cambio a través del botón solicitar cambio.',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
                height: 1.3,
              ),
            ),
          ),

          const SizedBox(width: 12),

          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              backgroundColor: secondaryColor,
              side: const BorderSide(
                color: Colors.white12,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {},
            icon: const Icon(
              Icons.edit_note_rounded,
              color: Colors.white,
              size: 16,
            ),
            label: const Text(
              'Solicitar cambio',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SEGURIDAD
  // ============================================================

  Widget _buildSeguridadCuentaCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.withOpacity(0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.shield_outlined,
                color: Colors.white,
                size: 20,
              ),

              SizedBox(width: 8),

              Text(
                'Seguridad de tu cuenta',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          const Text(
            'Administra tu información relacionada con la seguridad de tu cuenta',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.white.withOpacity(0.05),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: secondaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.lock_outline_rounded,
                    color: Colors.white70,
                    size: 20,
                  ),
                ),

                const SizedBox(width: 14),

                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contraseña',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 2),

                    Text(
                      'Última actualización: No registrada',
                      style: TextStyle(
                        color: Colors.grey,
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
    );
  }

  // ============================================================
  // FOTO DE PERFIL
  // ============================================================

  Widget _buildFotoPerfilCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.withOpacity(0.12),
        ),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(
                Icons.camera_alt_outlined,
                color: Colors.white,
                size: 20,
              ),

              SizedBox(width: 8),

              Text(
                'Foto de perfil',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Actualización del perfil',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ),

          const SizedBox(height: 20),

          Stack(
            children: [
              const UserAvatar(
                name: nombreUsuario,
                radius: 65,
                fontSize: 38,
              ),

              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    size: 16,
                    color: backgroundColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          const Text(
            'Formatos permitidos: JPG, PNG',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 11,
            ),
          ),

          const Text(
            'Tamaño máximo: 2 MB',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 11,
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {},
              child: const Text(
                'Actualizar foto',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                backgroundColor: backgroundColor,
                side: const BorderSide(
                  color: Colors.white12,
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {},
              child: const Text(
                'Eliminar foto',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INFORMACIÓN DE LA CUENTA
  // ============================================================

  Widget _buildInfoCuentaCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.withOpacity(0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: Colors.white,
                size: 20,
              ),

              SizedBox(width: 8),

              Text(
                'Información de la cuenta',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          const Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fecha de creación',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                      ),
                    ),

                    SizedBox(height: 4),

                    Text(
                      '2026-08-10 19:58:58',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: 20),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rol en el sistema',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                      ),
                    ),

                    SizedBox(height: 4),

                    Text(
                      'usuario',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          const Text(
            'Estado de la cuenta',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 11,
            ),
          ),

          const SizedBox(height: 6),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF064E3B).withOpacity(0.4),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: const Color(0xFF10B981).withOpacity(0.4),
              ),
            ),
            child: const Text(
              'Activa',
              style: TextStyle(
                color: Color(0xFF10B981),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.white.withOpacity(0.05),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.sync_rounded,
                  color: Colors.grey,
                  size: 20,
                ),

                SizedBox(width: 10),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mantén tu información actualizada',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 2),

                      Text(
                        'Una información correcta nos ayuda a darte un mejor soporte y atención.',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                          height: 1.3,
                        ),
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
}

// ==================================================================
// AVATAR SIN DEPENDENCIA DE INTERNET
// ==================================================================

class UserAvatar extends StatelessWidget {
  final String name;
  final double radius;
  final double fontSize;

  const UserAvatar({
    super.key,
    required this.name,
    this.radius = 20,
    this.fontSize = 14,
  });

  String _getInitials(String name) {
    final String cleanName = name.trim();

    if (cleanName.isEmpty) {
      return 'U';
    }

    final List<String> parts = cleanName
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.length == 1) {
      return parts.first.substring(
            0,
            1,
          ).toUpperCase();
    }

    return (
      parts.first.substring(0, 1) +
      parts.last.substring(0, 1)
    ).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFF2563EB),
      child: Text(
        _getInitials(name),
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: fontSize,
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
    this.activeRoute = 'Mi perfil',
  });

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppLogo(
              fontSize: 26,
            ),

            const SizedBox(height: 24),

            const Row(
              children: [
                UserAvatar(
                  name: 'Juan Pérez',
                  radius: 20,
                ),

                SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Juan Pérez',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      Text(
                        'Administración',
                        overflow: TextOverflow.ellipsis,
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

            _drawerItem(
              icon: Icons.home_rounded,
              title: 'Inicio',
              isActive: activeRoute == 'Inicio',
              onTap: () {},
            ),

            _drawerItem(
              icon: Icons.confirmation_number_outlined,
              title: 'Mis tickets',
              isActive: activeRoute == 'Mis tickets',
              onTap: () {},
            ),

            _drawerItem(
              icon: Icons.build_outlined,
              title: 'Crear ticket',
              isActive: activeRoute == 'Crear ticket',
              onTap: () {},
            ),

            _drawerItem(
              icon: Icons.warning_amber_rounded,
              title: 'Avisos',
              isActive: activeRoute == 'Avisos',
              onTap: () {},
            ),

            _drawerItem(
              icon: Icons.person_outline_rounded,
              title: 'Mi perfil',
              isActive: activeRoute == 'Mi perfil',
              onTap: () {},
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
    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: 4,
      ),
      decoration: isActive
          ? BoxDecoration(
              color: const Color(0xFF2563EB),
              borderRadius: BorderRadius.circular(10),
            )
          : null,
      child: ListTile(
        leading: Icon(
          icon,
          color: color ??
              (isActive
                  ? Colors.white
                  : Colors.grey),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: color ??
                (isActive
                    ? Colors.white
                    : Colors.grey),
            fontWeight: isActive
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        dense: true,
        onTap: onTap,
      ),
    );
  }
}