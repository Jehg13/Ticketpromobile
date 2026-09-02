import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';

import '../screens/resetpassword_screen.dart';

class DeepLinkService {
  DeepLinkService(this.navigatorKey);

  final GlobalKey<NavigatorState> navigatorKey;
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri?>? _subscription;

  Future<void> initialize() async {
    final initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) {
      _handleDeepLink(initialUri);
    }

    _subscription = _appLinks.uriLinkStream.listen(_handleDeepLink);
  }

  void _handleDeepLink(Uri uri) {
    final scheme = uri.scheme.toLowerCase();
    if (scheme != 'ticketpro') {
      return;
    }

    final host = uri.host.toLowerCase();
    final path = uri.path.toLowerCase();
    final isResetLink = host == 'reset-password' ||
        path == '/reset-password' ||
        path == 'reset-password';

    if (!isResetLink) {
      return;
    }

    final token = uri.queryParameters['token']?.trim() ?? '';
    final email = uri.queryParameters['email']?.trim() ?? '';

    if (token.isEmpty || email.isEmpty) {
      return;
    }

    final navigator = navigatorKey.currentState;
    if (navigator == null) {
      return;
    }

    final currentRoute = ModalRoute.of(navigator.context);
    if (currentRoute != null && currentRoute.settings.name == '/reset-password') {
      return;
    }

    navigator.pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => ResetPasswordScreen(
          email: email,
          token: token,
        ),
      ),
      (route) => false,
    );
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
  }
}
