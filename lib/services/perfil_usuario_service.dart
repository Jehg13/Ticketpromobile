import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'api_service.dart';
import 'session_service.dart';

class PerfilUsuarioService {
  static Future<Map<String, dynamic>> obtenerPerfil() async {
    final token = await SessionService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Sesión no válida');
    }

    final uri = Uri.parse('${ApiService.baseUrl}/perfil');

    try {
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );





      final decoded = _decodificarRespuesta(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (decoded['success'] != true) {
          throw Exception(
            decoded['message']?.toString() ?? 'No se pudo cargar el perfil',
          );
        }
        return decoded;
      }

      await _manejarError(response.statusCode, decoded);
      throw Exception('No se pudo cargar el perfil');
    } on Exception {
      rethrow;
    } catch (e) {

      throw Exception('No se pudo conectar con el servidor');
    }
  }

  static Future<Map<String, dynamic>> actualizarPassword({
    required String passwordActual,
    required String password,
    required String confirmPassword,
  }) async {
    final token = await SessionService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Sesión no válida');
    }

    final nuevaPassword = password.trim();
    if (nuevaPassword.length < 8) {
      throw Exception('La nueva contraseña debe tener al menos 8 caracteres.');
    }

    final regex = RegExp(r'^(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$');
    if (!regex.hasMatch(nuevaPassword)) {
      throw Exception(
        'La contraseña debe incluir mayúsculas, números y símbolos.',
      );
    }

    if (nuevaPassword != confirmPassword.trim()) {
      throw Exception('La confirmación de contraseña no coincide.');
    }

    final uri = Uri.parse('${ApiService.baseUrl}/perfil/password');

    try {
      final response = await http.put(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'password_actual': passwordActual,
          'password': nuevaPassword,
          'password_confirmation': confirmPassword.trim(),
        }),
      );





      final decoded = _decodificarRespuesta(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (decoded['success'] != true) {
          throw Exception(
            decoded['message']?.toString() ??
                'No se pudo actualizar la contraseña',
          );
        }
        return decoded;
      }

      await _manejarError(response.statusCode, decoded);
      throw Exception('No se pudo actualizar la contraseña');
    } on Exception {
      rethrow;
    } catch (e) {

      throw Exception('No se pudo conectar con el servidor');
    }
  }

  static Future<Map<String, dynamic>> solicitarCambio({
    required String campo,
    required String nuevoValor,
    required String motivo,
  }) async {
    final token = await SessionService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Sesión no válida');
    }

    final uri = Uri.parse('${ApiService.baseUrl}/perfil/solicitud-cambio');

    try {
      final response = await http.post(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'campo': campo,
          'nuevo_valor': nuevoValor.trim(),
          'motivo': motivo.trim(),
        }),
      );





      final decoded = _decodificarRespuesta(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (decoded['success'] != true) {
          throw Exception(
            decoded['message']?.toString() ??
                'No se pudo enviar la solicitud de cambio',
          );
        }
        return decoded;
      }

      await _manejarError(response.statusCode, decoded);
      throw Exception('No se pudo enviar la solicitud de cambio');
    } on Exception {
      rethrow;
    } catch (e) {

      throw Exception('No se pudo conectar con el servidor');
    }
  }

  static Future<Map<String, dynamic>> actualizarFoto({
    String? path,
    Uint8List? bytes,
    String? fileName,
  }) async {
    final token = await SessionService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Sesión no válida');
    }

    if ((path == null || path.isEmpty) && (bytes == null || bytes.isEmpty)) {
      throw Exception('Selecciona una imagen para continuar.');
    }

    final uri = Uri.parse('${ApiService.baseUrl}/perfil/foto');

    try {
      final request = http.MultipartRequest('POST', uri)
        ..headers['Accept'] = 'application/json'
        ..headers['Authorization'] = 'Bearer $token';

      if (path != null && path.isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath('picture', path));
      } else {
        request.files.add(
          http.MultipartFile.fromBytes(
            'picture',
            bytes!,
            filename: fileName ?? 'profile-photo.png',
          ),
        );
      }

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);





      final decoded = _decodificarRespuesta(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (decoded['success'] != true) {
          throw Exception(
            decoded['message']?.toString() ?? 'No se pudo actualizar la foto',
          );
        }
        return decoded;
      }

      await _manejarError(response.statusCode, decoded);
      throw Exception('No se pudo actualizar la foto');
    } on Exception {
      rethrow;
    } catch (e) {

      throw Exception('No se pudo conectar con el servidor');
    }
  }

  static Future<Map<String, dynamic>> eliminarFoto() async {
    final token = await SessionService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Sesión no válida');
    }

    final uri = Uri.parse('${ApiService.baseUrl}/perfil/foto');

    try {
      final response = await http.delete(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );





      final decoded = _decodificarRespuesta(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (decoded['success'] != true) {
          throw Exception(
            decoded['message']?.toString() ?? 'No se pudo eliminar la foto',
          );
        }
        return decoded;
      }

      await _manejarError(response.statusCode, decoded);
      throw Exception('No se pudo eliminar la foto');
    } on Exception {
      rethrow;
    } catch (e) {

      throw Exception('No se pudo conectar con el servidor');
    }
  }

  static Future<void> _manejarError(
    int statusCode,
    Map<String, dynamic> decoded,
  ) async {
    if (statusCode == 401) {
      await SessionService.clearSession();
      throw Exception(decoded['message']?.toString() ?? 'Sesión expirada');
    }
    if (statusCode == 403) {
      throw Exception(
        decoded['message']?.toString() ??
            'No tienes permiso para realizar esta acción',
      );
    }
    if (statusCode == 404) {
      throw Exception(
        decoded['message']?.toString() ?? 'Recurso no encontrado',
      );
    }
    if (statusCode >= 500) {
      throw Exception(
        decoded['message']?.toString() ?? 'Error interno del servidor',
      );
    }
    throw Exception(
      decoded['message']?.toString() ?? 'No se pudo completar la solicitud',
    );
  }

  static Map<String, dynamic> _decodificarRespuesta(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
      throw Exception('Respuesta inválida del servidor');
    } on FormatException {
      throw Exception('Respuesta inválida del servidor');
    }
  }
}
