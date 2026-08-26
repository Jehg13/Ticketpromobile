import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  static const FlutterSecureStorage storage =
      FlutterSecureStorage();

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    bool remember = false,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
          'remember': remember,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          data['success'] == true) {
        final String? token = data['token']?.toString();

        if (token != null && token.isNotEmpty) {
          await storage.write(
            key: 'auth_token',
            value: token,
          );
        }

        final user = data['user'];

        if (user is Map<String, dynamic>) {
          await storage.write(
            key: 'user_login',
            value: user['login']?.toString() ?? '',
          );

          await storage.write(
            key: 'user_email',
            value: user['email']?.toString() ?? '',
          );

          await storage.write(
            key: 'user_name',
            value: user['name']?.toString() ?? '',
          );

          await storage.write(
            key: 'user_role',
            value: user['role']?.toString() ?? '',
          );

          await storage.write(
            key: 'user_priv_admin',
            value: user['priv_admin']?.toString() ?? 'N',
          );

          await storage.write(
            key: 'user_active',
            value: user['active']?.toString() ?? 'N',
          );

          await storage.write(
            key: 'user_mfa',
            value: user['mfa']?.toString() ?? 'N',
          );
        }
      }

      return {
        'statusCode': response.statusCode,
        'success': data['success'] == true,
        'mfa_required': data['mfa_required'] == true,
        'message': data['message']?.toString() ?? '',
        'token': data['token'],
        'user': data['user'],
        'data': data,
      };
    } catch (e) {
      return {
        'statusCode': 0,
        'success': false,
        'mfa_required': false,
        'message': 'No se pudo conectar con el servidor.',
        'error': e.toString(),
        'data': null,
      };
    }
  }

  static Future<String?> getToken() async {
    return await storage.read(
      key: 'auth_token',
    );
  }

  static Future<Map<String, dynamic>?> getStoredUser() async {
    final login = await storage.read(
      key: 'user_login',
    );

    final email = await storage.read(
      key: 'user_email',
    );

    final name = await storage.read(
      key: 'user_name',
    );

    final role = await storage.read(
      key: 'user_role',
    );

    final privAdmin = await storage.read(
      key: 'user_priv_admin',
    );

    final active = await storage.read(
      key: 'user_active',
    );

    final mfa = await storage.read(
      key: 'user_mfa',
    );

    if (login == null &&
        email == null &&
        name == null &&
        role == null) {
      return null;
    }

    return {
      'login': login,
      'email': email,
      'name': name,
      'role': role,
      'priv_admin': privAdmin ?? 'N',
      'active': active ?? 'N',
      'mfa': mfa ?? 'N',
    };
  }

  static Future<bool> isAdmin() async {
    final role = await storage.read(
      key: 'user_role',
    );

    final privAdmin = await storage.read(
      key: 'user_priv_admin',
    );

    final bool rolPermitido =
        role == 'Gerente Ti' ||
        role == 'Soporte Tecnico' ||
        role == 'Soporte técnico';

    return rolPermitido && privAdmin == 'Y';
  }

  static Future<Map<String, dynamic>> getUser() async {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      return {
        'statusCode': 401,
        'success': false,
        'message': 'No hay una sesión activa.',
        'data': {
          'success': false,
          'message': 'No hay una sesión activa.',
        },
      };
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 &&
          data['success'] == true &&
          data['user'] is Map<String, dynamic>) {
        final user = data['user'] as Map<String, dynamic>;

        await storage.write(
          key: 'user_login',
          value: user['login']?.toString() ?? '',
        );

        await storage.write(
          key: 'user_email',
          value: user['email']?.toString() ?? '',
        );

        await storage.write(
          key: 'user_name',
          value: user['name']?.toString() ?? '',
        );

        await storage.write(
          key: 'user_role',
          value: user['role']?.toString() ?? '',
        );

        await storage.write(
          key: 'user_priv_admin',
          value: user['priv_admin']?.toString() ?? 'N',
        );

        await storage.write(
          key: 'user_active',
          value: user['active']?.toString() ?? 'N',
        );

        await storage.write(
          key: 'user_mfa',
          value: user['mfa']?.toString() ?? 'N',
        );
      }

      if (response.statusCode == 401) {
        await clearSession();
      }

      return {
        'statusCode': response.statusCode,
        'success': data['success'] == true,
        'message': data['message']?.toString() ?? '',
        'user': data['user'],
        'data': data,
      };
    } catch (e) {
      return {
        'statusCode': 0,
        'success': false,
        'message': 'No se pudo conectar con el servidor.',
        'error': e.toString(),
        'data': null,
      };
    }
  }

  static Future<Map<String, dynamic>> logout() async {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      await clearSession();

      return {
        'statusCode': 401,
        'success': false,
        'message': 'No hay una sesión activa.',
        'data': {
          'success': false,
          'message': 'No hay una sesión activa.',
        },
      };
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      await clearSession();

      return {
        'statusCode': response.statusCode,
        'success': data['success'] == true,
        'message': data['message']?.toString() ?? '',
        'data': data,
      };
    } catch (e) {
      await clearSession();

      return {
        'statusCode': 0,
        'success': false,
        'message': 'No se pudo conectar con el servidor.',
        'error': e.toString(),
        'data': null,
      };
    }
  }

  static Future<void> clearSession() async {
    await storage.deleteAll();
  }

  static Future<bool> hasSession() async {
    final token = await getToken();

    return token != null && token.isNotEmpty;
  }
}