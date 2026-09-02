import 'package:flutter/material.dart';

import '../services/session_service.dart';

class AdminOnlyDrawerItem extends StatelessWidget {
  final Widget child;

  const AdminOnlyDrawerItem({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: SessionService.canManageUsersAndChanges(),
      builder: (context, snapshot) {
        if (snapshot.data != true) {
          return const SizedBox.shrink();
        }
        return child;
      },
    );
  }
}
