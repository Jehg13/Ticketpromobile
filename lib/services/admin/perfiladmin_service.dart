import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

import '../api_service.dart';
import '../session_service.dart';

class PerfiladminService {
  static Future<Map<String, dynamic>> obtenerPerfil() {
    return _request(
      (token) =>
          http.get(Uri.parse(ApiService.baseUrl), headers: _headers(token)),
    );
  }

  static Future<Map<String, dynamic>> actualizarPassword({
    required String passwordActual,
    required String password,
    required String confirmacion,
  }) {
    return _request(
      (token) => http.put(
        Uri.parse('${ApiService.baseUrl}/password'),
        headers: {..._headers(token), 'Content-Type': 'application/json'},
        body: jsonEncode({
          'password_actual': passwordActual,
          'password': password,
          'password_confirmation': confirmacion,
        }),
      ),
    );
  }

  static Future<Map<String, dynamic>> actualizarFoto(
    PlatformFile archivo,
  ) async {
    final bytes = await archivo.readAsBytes();
    final token = await SessionService.getToken();
    if (token == null || token.isEmpty) {
      return {'success': false, 'message': 'No hay una sesión activa.'};
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiService.baseUrl}/foto'),
    )..headers.addAll(_headers(token));
    request.files.add(
      http.MultipartFile.fromBytes('picture', bytes, filename: archivo.name),
    );
    return _decode(await http.Response.fromStream(await request.send()));
  }

  static Future<Map<String, dynamic>> eliminarFoto() {
    return _request(
      (token) => http.delete(
        Uri.parse('${ApiService.baseUrl}/foto'),
        headers: _headers(token),
      ),
    );
  }

  static Future<Map<String, dynamic>> _request(
    Future<http.Response> Function(String token) request,
  ) async {
    final token = await SessionService.getToken();
    if (token == null || token.isEmpty) {
      return {'success': false, 'message': 'No hay una sesión activa.'};
    }
    return _decode(await request(token));
  }

  static Map<String, String> _headers(String token) => {
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };

  static Future<Map<String, dynamic>> _decode(http.Response response) async {
    final decoded = jsonDecode(response.body);
    final data = decoded is Map<String, dynamic>
        ? Map<String, dynamic>.from(decoded)
        : <String, dynamic>{};
    final user = data['user'] ?? data['usuario'];
    final nested = data['data'];
    final picture =
        data['picture'] ??
        (user is Map ? user['picture'] : null) ??
        (nested is Map ? nested['picture'] : null);
    return {
      ...data,
      'success':
          response.statusCode >= 200 &&
          response.statusCode < 300 &&
          data['success'] == true,
      'usuario': user,
      'picture': data['picture'] ?? picture,
      'picture_url': data['picture_url'] ?? picture,
    };
  }
}
