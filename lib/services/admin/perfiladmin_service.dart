import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

import '../api_service.dart';
import '../session_service.dart';

class PerfiladminService {
  static Future<Map<String, dynamic>> obtenerPerfil() {
    return _request(
      (token) => http.get(
        Uri.parse('${ApiService.baseUrl}/perfil'),
        headers: _headers(token),
      ),
    );
  }

  static Future<Map<String, dynamic>> actualizarPassword({
    required String passwordActual,
    required String password,
    required String confirmPassword,
  }) {
    return _request(
      (token) => http.put(
        Uri.parse('${ApiService.baseUrl}/perfil/password'),
        headers: {..._headers(token), 'Content-Type': 'application/json'},
        body: jsonEncode({
          'password_actual': passwordActual,
          'password': password,
          'password_confirmation': confirmPassword,
        }),
      ),
    );
  }

  static Future<Map<String, dynamic>> actualizarFoto(
    PlatformFile archivo,
  ) async {
    final token = await SessionService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Sesión no válida.');
    }

    final bytes = await archivo.readAsBytes();
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiService.baseUrl}/perfil/foto'),
    )..headers.addAll(_headers(token));
    request.files.add(
      http.MultipartFile.fromBytes('picture', bytes, filename: archivo.name),
    );

    final response = await http.Response.fromStream(await request.send());
    return _decodeResponse(response);
  }

  static Future<Map<String, dynamic>> eliminarFoto() {
    return _request(
      (token) => http.delete(
        Uri.parse('${ApiService.baseUrl}/perfil/foto'),
        headers: _headers(token),
      ),
    );
  }

  static Future<Map<String, dynamic>> _request(
    Future<http.Response> Function(String token) request,
  ) async {
    final token = await SessionService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Sesión no válida.');
    }
    return _decodeResponse(await request(token));
  }

  static Future<Map<String, dynamic>> _decodeResponse(
    http.Response response,
  ) async {
    final decoded = jsonDecode(response.body);
    final data = decoded is Map<String, dynamic>
        ? decoded
        : <String, dynamic>{};
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        data['message']?.toString() ?? 'No se pudo completar la solicitud.',
      );
    }
    if (data['success'] == false) {
      throw Exception(
        data['message']?.toString() ?? 'No se pudo completar la solicitud.',
      );
    }
    return data;
  }

  static Map<String, String> _headers(String token) => {
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };
}
