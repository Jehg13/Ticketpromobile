import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/session_service.dart';
import 'admin_only_drawer_item.dart';

class AdminNavigationDrawerItem {
  final IconData icon;
  final String title;
  final bool selected;
  final VoidCallback? onTap;

  const AdminNavigationDrawerItem({
    required this.icon,
    required this.title,
    this.selected = false,
    this.onTap,
  });
}

class AdminNavigationDrawer extends StatelessWidget {
  final List<AdminNavigationDrawerItem> items;
  final VoidCallback onLogout;

  const AdminNavigationDrawer({
    super.key,
    required this.items,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF0B1021),
      child: SafeArea(
        child: Container(
          color: const Color(0xFF0B1021),
          padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _AdminDrawerLogo(),
              const SizedBox(height: 24),
              const _AdminDrawerUser(),
              const SizedBox(height: 20),
              const Divider(color: Colors.white12, height: 1),
              const SizedBox(height: 20),
              ...items.map(_buildItem),
              const Spacer(),
              const Divider(color: Colors.white12, height: 1),
              _buildItem(
                const AdminNavigationDrawerItem(
                  icon: Icons.logout_rounded,
                  title: 'Cerrar sesión',
                ),
                isLogout: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItem(
    AdminNavigationDrawerItem item, {
    bool isLogout = false,
  }) {
    final color = isLogout
        ? Colors.white70
        : item.selected
        ? Colors.white
        : const Color(0xFF94A3B8);

    final tile = Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: item.selected ? const Color(0xFF2563EB) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          leading: Icon(item.icon, color: color),
          title: Text(
            item.title,
            style: TextStyle(
              color: color,
              fontWeight: item.selected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          onTap: isLogout ? onLogout : item.onTap,
        ),
      ),
    );

    if (item.title == 'Cambios' || item.title == 'Usuarios') {
      return AdminOnlyDrawerItem(child: tile);
    }
    return tile;
  }
}

class _AdminDrawerLogo extends StatelessWidget {
  const _AdminDrawerLogo();

  @override
  Widget build(BuildContext context) {
    return const Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'Ticket',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text: 'Pro',
            style: TextStyle(
              color: Color(0xFF2563EB),
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminDrawerUser extends StatelessWidget {
  const _AdminDrawerUser();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: SessionService.getUser(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        final picture = user?['picture']?.toString().trim() ?? '';
        final hasPicture = picture.isNotEmpty &&
            !SessionService.isDefaultProfilePicture(picture);
        final imageUrl = hasPicture ? ApiService.profileImageUrl(picture) : '';

        return Row(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF2563EB), width: 2),
              ),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFF1E3A8A),
                backgroundImage: imageUrl.isEmpty
                    ? const AssetImage('assets/images/user.png')
                    : NetworkImage(
                        '$imageUrl?profile_refresh=${picture.hashCode}',
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    SessionService.displayName(user),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    SessionService.displayRole(user),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
