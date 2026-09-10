import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/session_service.dart';

class AdminOnlyDrawerItem extends StatelessWidget {
  final Widget child;

  const AdminOnlyDrawerItem({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: SessionService.canViewGerenteTiSections(),
      builder: (context, snapshot) {
        if (snapshot.data != true) {
          return const SizedBox.shrink();
        }

        return child;
      },
    );
  }

}

class AdminDrawerRole extends StatelessWidget {
  const AdminDrawerRole({super.key, this.color = const Color(0xFF94A3B8)});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _loadUser(),
      builder: (context, snapshot) {
        final user = snapshot.data ?? {};
        final role = (user['role'] ?? user['rol'] ?? '').toString().trim();
        return Text(
          role.isNotEmpty ? role : 'Sin rol',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: color, fontSize: 11),
        );
      },
    );
  }

  Future<Map<String, dynamic>?> _loadUser() async {
    final response = await ApiService.getUser();
    if (response['success'] == true && response['user'] is Map) {
      return Map<String, dynamic>.from(response['user'] as Map);
    }
    return SessionService.getUser();
  }
}

class AdminDrawerUserName extends StatelessWidget {
  const AdminDrawerUserName({
    super.key,
    this.color = Colors.white,
    this.fallback = 'Usuario',
  });

  final Color color;
  final String fallback;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: SessionService.getUser(),
      builder: (context, snapshot) {
        final name = SessionService.displayName(
          snapshot.data,
          fallback: fallback,
        );
        return Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        );
      },
    );
  }
}
