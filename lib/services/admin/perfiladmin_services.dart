import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../api_service.dart';

class PerfilAdminService {
  static const String _baseUrl = ApiService.baseUrl;

  static Future<Map<String, String>> _headers() async {
    final token = await ApiService.getToken();

    return {
      'Accept': 'application/json',
      'Authorization': 'Bearer ${token ?? ''}',
    };
  }

  static Future<Map<String, dynamic>> obtenerPerfil() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/perfil'),
        headers: await _headers(),
      );

      final data = _decode(response);

      if (response.statusCode == 401) {
        await ApiService.clearSession();
      }

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          data['user'] is Map<String, dynamic>) {
        final user = Map<String, dynamic>.from(
          data['user'],
        );

        await _guardarUsuarioLocal(user);
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

  static Future<Map<String, dynamic>> actualizarFoto(
    File archivo,
  ) async {
    try {
      final token = await ApiService.getToken();

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/perfil/foto'),
      );

      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer ${token ?? ''}',
      });

      request.files.add(
        await http.MultipartFile.fromPath(
          'picture',
          archivo.path,
        ),
      );

      final streamedResponse = await request.send();

      final response =
          await http.Response.fromStream(
        streamedResponse,
      );

      final data = _decode(response);

      if (response.statusCode == 401) {
        await ApiService.clearSession();
      }

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          data['user'] is Map<String, dynamic>) {
        final user = Map<String, dynamic>.from(
          data['user'],
        );

        await _guardarUsuarioLocal(user);
      } else if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          data['picture'] != null) {
        await ApiService.storage.write(
          key: 'user_picture',
          value: data['picture'].toString(),
        );
      }

      return {
        'statusCode': response.statusCode,
        'success': data['success'] == true,
        'message': data['message']?.toString() ?? '',
        'user': data['user'],
        'picture': data['picture'],
        'data': data,
      };
    } catch (e) {
      return {
        'statusCode': 0,
        'success': false,
        'message': 'No se pudo subir la foto de perfil.',
        'error': e.toString(),
        'data': null,
      };
    }
  }

  static Future<Map<String, dynamic>> eliminarFoto() async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/perfil/foto'),
        headers: await _headers(),
      );

      final data = _decode(response);

      if (response.statusCode == 401) {
        await ApiService.clearSession();
      }

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        if (data['user'] is Map<String, dynamic>) {
          final user = Map<String, dynamic>.from(
            data['user'],
          );

          await _guardarUsuarioLocal(user);
        } else {
          await ApiService.storage.write(
            key: 'user_picture',
            value: 'profile-photos/user.png',
          );
        }
      }

      return {
        'statusCode': response.statusCode,
        'success': data['success'] == true,
        'message': data['message']?.toString() ?? '',
        'user': data['user'],
        'picture': data['picture'],
        'data': data,
      };
    } catch (e) {
      return {
        'statusCode': 0,
        'success': false,
        'message': 'No se pudo eliminar la foto de perfil.',
        'error': e.toString(),
        'data': null,
      };
    }
  }

  static Future<Map<String, dynamic>> actualizarTecnologias({
    required String login,
    required String nombre,
    required String email,
    required String phone,
    required String password,
    required String numeroEmpleado,
    required String role,
    required String active,
    required String privAdmin,
    required int? oficinaId,
    required String departamento,
    required String passwordConfirmacion,
  }) async {
    try {
      final token = await ApiService.getToken();

      final response = await http.put(
        Uri.parse('$_baseUrl/perfil/tecnologias'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${token ?? ''}',
        },
        body: jsonEncode({
          'login': login.trim(),
          'name': nombre.trim(),
          'email': email.trim(),
          'phone': phone.trim(),
          'password': password,
          'numero_empleado': numeroEmpleado.trim(),
          'role': role,
          'active': active,
          'priv_admin': privAdmin,
          'oficina_id': oficinaId,
          'departamento': departamento.trim(),
          'password_confirmation': passwordConfirmacion,
        }),
      );

      final data = _decode(response);

      if (response.statusCode == 401) {
        await ApiService.clearSession();
      }

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          data['user'] is Map<String, dynamic>) {
        final user = Map<String, dynamic>.from(
          data['user'],
        );

        await _guardarUsuarioLocal(user);
      }

      return {
        'statusCode': response.statusCode,
        'success': data['success'] == true,
        'message': data['message']?.toString() ?? '',
        'user': data['user'],
        'errors': data['errors'],
        'data': data,
      };
    } catch (e) {
      return {
        'statusCode': 0,
        'success': false,
        'message': 'No se pudo actualizar el perfil.',
        'error': e.toString(),
        'data': null,
      };
    }
  }

  static Future<Map<String, dynamic>> actualizarPassword({
    required String passwordActual,
    required String password,
    required String passwordConfirmacion,
  }) async {
    try {
      final token = await ApiService.getToken();

      final response = await http.put(
        Uri.parse('$_baseUrl/perfil/password'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${token ?? ''}',
        },
        body: jsonEncode({
          'password_actual': passwordActual,
          'password': password,
          'password_confirmation': passwordConfirmacion,
        }),
      );

      final data = _decode(response);

      if (response.statusCode == 401) {
        await ApiService.clearSession();
      }

      return {
        'statusCode': response.statusCode,
        'success': data['success'] == true,
        'message': data['message']?.toString() ?? '',
        'errors': data['errors'],
        'data': data,
      };
    } catch (e) {
      return {
        'statusCode': 0,
        'success': false,
        'message': 'No se pudo actualizar la contraseña.',
        'error': e.toString(),
        'data': null,
      };
    }
  }

  static Future<void> _guardarUsuarioLocal(
    Map<String, dynamic> user,
  ) async {
    await ApiService.storage.write(
      key: 'user_login',
      value: user['login']?.toString() ?? '',
    );

    await ApiService.storage.write(
      key: 'user_email',
      value: user['email']?.toString() ?? '',
    );

    await ApiService.storage.write(
      key: 'user_name',
      value: user['name']?.toString() ?? '',
    );

    await ApiService.storage.write(
      key: 'user_role',
      value: user['role']?.toString() ?? '',
    );

    await ApiService.storage.write(
      key: 'user_priv_admin',
      value: user['priv_admin']?.toString() ?? 'N',
    );

    await ApiService.storage.write(
      key: 'user_active',
      value: user['active']?.toString() ?? 'N',
    );

    await ApiService.storage.write(
      key: 'user_mfa',
      value: user['mfa']?.toString() ?? 'N',
    );

    await ApiService.storage.write(
      key: 'user_empresa',
      value: user['empresa']?.toString() ?? '',
    );

    await ApiService.storage.write(
      key: 'user_departamento',
      value: user['departamento']?.toString() ?? '',
    );

    await ApiService.storage.write(
      key: 'user_oficina',
      value: user['oficina']?.toString() ?? '',
    );

    await ApiService.storage.write(
      key: 'user_numero_empleado',
      value: user['numero_empleado']?.toString() ?? '',
    );

    await ApiService.storage.write(
      key: 'user_picture',
      value: (
        user['picture'] ??
        user['foto'] ??
        user['foto_perfil']
      )?.toString() ?? '',
    );
  }

  static Map<String, dynamic> _decode(
    http.Response response,
  ) {
    if (response.body.trim().isEmpty) {
      return {
        'success': false,
        'message': 'El servidor no devolvió información.',
      };
    }

    try {
      final decoded = jsonDecode(
        response.body,
      );

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      return {
        'success': false,
        'message': 'Respuesta inválida del servidor.',
      };
    } catch (_) {
      return {
        'success': false,
        'message': response.body.isNotEmpty
            ? response.body
            : 'Respuesta inválida del servidor.',
      };
    }
  }
}
