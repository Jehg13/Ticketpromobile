import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

import 'api_service.dart';
import 'session_service.dart';

/// Registers an FCM token once a Firebase Messaging integration provides one.
///
/// Firebase is intentionally not initialized here because this project does
/// not contain platform Firebase configuration files. Calling this service
/// with no token is a safe no-op and does not affect login or app startup.
class NotificationService {
  static bool _tokenListenerRegistered = false;
  static bool _firebaseReady = false;
  static String? _registeredToken;

  static Future<void> initialize() async {
    if (kIsWeb) {
      return;
    }

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
      final messaging = FirebaseMessaging.instance;
      if (!_firebaseReady) {
        await messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
        _firebaseReady = true;
      }

      if (!_tokenListenerRegistered) {
        _tokenListenerRegistered = true;
        messaging.onTokenRefresh.listen(
          registerDeviceToken,
          onError: (_, _) {},
        );
      }

      for (var attempt = 1; attempt <= 3; attempt++) {
        try {
          final token = await messaging.getToken();

          final result = await registerDeviceToken(token);
          if (result['success'] == true) {
            return;
          }

        } catch (_) {
        }

        if (attempt < 3) {
          await Future<void>.delayed(const Duration(seconds: 2));
        }
      }
    } on FirebaseException catch (_) {
    } catch (_) {
    }
  }

  static Future<Map<String, dynamic>> registerDeviceToken(
    String? token, {
    String? platform,
    String? deviceId,
    String? appVersion,
  }) async {
    final cleanToken = token?.trim() ?? '';

    if (cleanToken.isEmpty) {

      return {
        'statusCode': 400,
        'success': false,
        'message': 'No se proporcionó un token de notificaciones.',
      };
    }

    if (_registeredToken == cleanToken) {
      return {
        'statusCode': 200,
        'success': true,
        'message': 'Token ya registrado.',
      };
    }

    final authToken = await SessionService.getToken();

    if (authToken == null || authToken.isEmpty) {

      return {
        'statusCode': 401,
        'success': false,
        'message': 'Sesión no válida.',
      };
    }

    try {

      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/device-tokens'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'token': cleanToken,
          'platform': platform ?? _platformName(),
          if (deviceId != null && deviceId.trim().isNotEmpty)
            'device_id': deviceId.trim(),
          if (appVersion != null && appVersion.trim().isNotEmpty)
            'app_version': appVersion.trim(),
        }),
      );

      final data = _decodeBody(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        _registeredToken = cleanToken;
      }
      return {
        'statusCode': response.statusCode,
        'success': response.statusCode >= 200 &&
            response.statusCode < 300 &&
            data['success'] == true,
        'message': data['message']?.toString() ?? '',
        'data': data,
      };
    } catch (error) {

      return {
        'statusCode': 0,
        'success': false,
        'message': 'No se pudo registrar el token de notificaciones.',
        'error': error.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> unregisterDeviceToken(
    String? token,
  ) async {
    final cleanToken = token?.trim() ?? '';

    if (cleanToken.isEmpty) {
      return {
        'statusCode': 400,
        'success': false,
        'message': 'No se proporcionó un token de notificaciones.',
      };
    }

    final authToken = await SessionService.getToken();

    if (authToken == null || authToken.isEmpty) {
      return {
        'statusCode': 401,
        'success': false,
        'message': 'Sesión no válida.',
      };
    }

    try {
      final response = await http.delete(
        Uri.parse('${ApiService.baseUrl}/device-tokens'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({'token': cleanToken}),
      );
      final data = _decodeBody(response.body);

      return {
        'statusCode': response.statusCode,
        'success': response.statusCode >= 200 &&
            response.statusCode < 300 &&
            data['success'] == true,
        'message': data['message']?.toString() ?? '',
        'data': data,
      };
    } catch (error) {

      return {
        'statusCode': 0,
        'success': false,
        'message': 'No se pudo retirar el token de notificaciones.',
        'error': error.toString(),
      };
    }
  }

  static Map<String, dynamic> _decodeBody(String body) {
    if (body.trim().isEmpty) {
      return {};
    }

    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return decoded.map(
          (key, value) => MapEntry(key.toString(), value),
        );
      }
    } catch (_) {
      // The API may return a non-JSON error page; keep the hook non-fatal.
    }

    return {};
  }

  static String _platformName() {
    if (kIsWeb) {
      return 'web';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'android';
      case TargetPlatform.iOS:
        return 'ios';
      case TargetPlatform.windows:
        return 'windows';
      case TargetPlatform.macOS:
        return 'macos';
      case TargetPlatform.linux:
        return 'linux';
      case TargetPlatform.fuchsia:
        return 'fuchsia';
    }
  }
}
