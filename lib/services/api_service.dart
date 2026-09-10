import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // ============================================================
  // URLS
  // ============================================================

  static const String serverUrl = 'https://tickets.cymezapi.com';
  static const String baseUrl = '$serverUrl/api';

  // Todos los archivos que están dentro de storage/app/public
  // serán servidos mediante:
  //
  // https://tickets.cymezapi.com/archivo/ruta/del/archivo
  //
  static const String fileUrl = '$serverUrl/archivo';

  static const FlutterSecureStorage storage = FlutterSecureStorage();
  static final http.Client client = http.Client();

  // ============================================================
  // ARCHIVOS / IMÁGENES
  // ============================================================

  /// Genera la URL para cualquier archivo almacenado
  /// en storage/app/public.
  ///
  /// Ejemplos:
  ///
  /// profile-photos/usuario.jpg
  /// firmas/firma_123.png
  /// comentarios_tickets/documento.pdf
  /// tickets/evidencia.jpg
  ///
  /// Resultado:
  ///
  /// https://tickets.cymezapi.com/archivo/profile-photos/usuario.jpg
  ///
  static String storageFileUrl(String? path) {
    if (path == null || path.trim().isEmpty) {
      return '';
    }

    String cleanPath = path.trim();

    if (cleanPath.startsWith('http://localhost') ||
        cleanPath.startsWith('https://localhost')) {
      cleanPath = cleanPath
          .replaceFirst('http://localhost', 'https://tickets.cymezapi.com')
          .replaceFirst('https://localhost', 'https://tickets.cymezapi.com');
    }

    // Si Laravel ya devuelve una URL completa,
    // no hacemos ninguna modificación.
    if (cleanPath.startsWith('http://') || cleanPath.startsWith('https://')) {
      final uri = Uri.tryParse(cleanPath);
      if (uri != null && uri.path.contains('/storage/')) {
        cleanPath = uri.path.substring(uri.path.indexOf('/storage/') + 9);
      } else {
        return cleanPath;
      }
    }

    // Elimina / iniciales.
    cleanPath = cleanPath.replaceFirst(RegExp(r'^/+'), '');

    // Si por alguna razón viene como:
    // storage/profile-photos/foto.jpg
    //
    // lo convertimos a:
    // profile-photos/foto.jpg
    if (cleanPath.startsWith('storage/')) {
      cleanPath = cleanPath.substring('storage/'.length);
    }

    // Si viene como:
    // api/profile-photos/foto.jpg
    //
    // eliminamos api/.
    if (cleanPath.startsWith('api/')) {
      cleanPath = cleanPath.substring('api/'.length);
    }

    return '$fileUrl/$cleanPath';
  }

  static Future<Map<String, dynamic>> verifyMfa({
    required String challenge,
    required String codigo,
  }) async {
    final response = await client.post(
      Uri.parse('$baseUrl/login/mfa/verify'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'challenge': challenge, 'codigo': codigo}),
    );
    final data = _decodeJsonBody(response.body);
    return {
      'statusCode': response.statusCode,
      'success':
          response.statusCode >= 200 &&
          response.statusCode < 300 &&
          data['success'] == true,
      'message':
          data['message']?.toString() ?? 'No se pudo verificar el código.',
      'retry_after': _retryAfterSeconds(response, data),
      'token': data['token'],
      'user': data['user'],
    };
  }

  static Future<Map<String, dynamic>> disableMfa({
    required String codigo,
  }) async {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      return {
        'statusCode': 401,
        'success': false,
        'message': 'Tu sesión expiró. Inicia sesión nuevamente.',
      };
    }

    final response = await client.post(
      Uri.parse('$baseUrl/perfil/mfa/desactivar'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'codigo': codigo}),
    );
    final data = _decodeJsonBody(response.body);
    return {
      'statusCode': response.statusCode,
      'success':
          response.statusCode >= 200 &&
          response.statusCode < 300 &&
          data['success'] == true,
      'message':
          data['message']?.toString() ??
          'No se pudo desactivar la verificación en dos pasos.',
    };
  }

  // ============================================================
  // IMÁGENES DE PERFIL
  // ============================================================

  static String profileImageUrl(String? path) {
    if (path == null || path.trim().isEmpty) {
      return '';
    }

    return storageFileUrl(path);
  }

  // ============================================================
  // IMAGEN GENÉRICA
  // ============================================================

  static String imagenUrl(String? path) {
    if (path == null || path.trim().isEmpty) {
      return '';
    }

    return storageFileUrl(path);
  }

  // ============================================================
  // FIRMA
  // ============================================================

  static String firmaUrl(String? path) {
    if (path == null || path.trim().isEmpty) {
      return '';
    }

    return storageFileUrl(path);
  }

  static String resolveNotificationUrl(dynamic rawValue) {
    if (rawValue == null) {
      return '';
    }

    final value = rawValue.toString().trim();
    if (value.isEmpty) {
      return '';
    }

    if (value.startsWith('{') || value.startsWith('[')) {
      try {
        final decoded = jsonDecode(value);
        if (decoded is Map) {
          final selected = kIsWeb
              ? (decoded['web'] ?? decoded['url'])
              : (decoded['mobile'] ?? decoded['url'] ?? decoded['web']);

          final url = selected?.toString().trim();
          if (url != null && url.isNotEmpty) {
            return url;
          }
        }
      } catch (_) {
        return value;
      }
    }

    return value;
  }

  // ============================================================
  // LOGIN
  // ============================================================

  static Map<String, dynamic> _decodeJsonBody(String body) {
    if (body.trim().isEmpty) {
      return {};
    }

    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry(key.toString(), value));
      }

      return {'raw': decoded};
    } catch (_) {
      return {};
    }
  }

  static String sanitizeUserFacingMessage(
    dynamic value, {
    String fallback = 'Ocurrió un error al procesar la solicitud.',
  }) {
    final text = _messageText(value);
    if (text.isEmpty) {
      return fallback;
    }

    if (_isTechnicalMessage(text)) {
      return fallback;
    }

    return text;
  }

  static String _messageText(dynamic value) {
    if (value == null) return '';

    if (value is Map) {
      for (final key in const ['message', 'error', 'exception', 'detail']) {
        final nested = _messageText(value[key]);
        if (nested.isNotEmpty) {
          return nested;
        }
      }
      return '';
    }

    if (value is List) {
      return value
          .map(_messageText)
          .where((item) => item.isNotEmpty)
          .join('\n');
    }

    final text = value.toString().trim();
    if (text.startsWith('Exception: ')) {
      return text.replaceFirst('Exception: ', '');
    }
    if (text.startsWith('Error: ')) {
      return text.replaceFirst('Error: ', '');
    }

    return text;
  }

  static bool _isTechnicalMessage(String text) {
    final lower = text.toLowerCase();
    return lower.contains('sqlstate') ||
        lower.contains('pdoexception') ||
        lower.contains('queryexception') ||
        lower.contains('integrity constraint') ||
        lower.contains('syntax error') ||
        lower.contains('unknown column') ||
        (lower.contains('table ') && lower.contains("doesn't exist")) ||
        lower.contains('could not find driver') ||
        lower.contains('connection refused') ||
        lower.contains('stack trace') ||
        lower.contains('exception trace') ||
        lower.contains('connection: mysql') ||
        lower.contains('laravel\\');
  }

  static Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    final cleanEmail = email.trim();

    if (cleanEmail.isEmpty) {
      return {
        'statusCode': 400,
        'success': false,
        'message': 'Ingresa tu correo electrónico.',
      };
    }

    try {
      final response = await client.post(
        Uri.parse('$baseUrl/password/forgot'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
        },
        body: jsonEncode({'email': cleanEmail}),
      );

      final payload = _decodeJsonBody(response.body);
      final bool success =
          response.statusCode >= 200 &&
          response.statusCode < 300 &&
          payload['success'] == true;

      return {
        'statusCode': response.statusCode,
        'success': success,
        'message':
            payload['message']?.toString() ??
            'No se pudo enviar el enlace de recuperación.',
        'data': payload,
      };
    } catch (e) {
      return {
        'statusCode': 0,
        'success': false,
        'message': 'No se pudo conectar con el servidor.',
        'error': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> getMobileMaintenance() async {
    final token = await getToken();
    if (token == null || token.isEmpty) {
      return {'enabled': false, 'message': ''};
    }

    final response = await client.get(
      Uri.parse('$baseUrl/maintenance?platform=mobile'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('No se pudo consultar el estado de mantenimiento.');
    }

    return _decodeJsonBody(response.body);
  }

  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    final cleanEmail = email.trim();
    final cleanToken = token.trim();
    final cleanPassword = password.trim();
    final cleanConfirmation = passwordConfirmation.trim();

    if (cleanEmail.isEmpty) {
      return {
        'statusCode': 400,
        'success': false,
        'message': 'Ingresa tu correo electrónico.',
      };
    }

    if (cleanToken.isEmpty) {
      return {
        'statusCode': 400,
        'success': false,
        'message': 'Pega el token recibido en tu correo para continuar.',
      };
    }

    if (cleanPassword.isEmpty) {
      return {
        'statusCode': 400,
        'success': false,
        'message': 'Ingresa una nueva contraseña.',
      };
    }

    if (cleanPassword.length < 8) {
      return {
        'statusCode': 400,
        'success': false,
        'message': 'La contraseña debe tener al menos 8 caracteres.',
      };
    }

    if (!RegExp(
      r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$',
    ).hasMatch(cleanPassword)) {
      return {
        'statusCode': 400,
        'success': false,
        'message':
            'La contraseña debe incluir mayúscula, minúscula, número y símbolo.',
      };
    }

    if (cleanPassword != cleanConfirmation) {
      return {
        'statusCode': 400,
        'success': false,
        'message': 'Las contraseñas no coinciden.',
      };
    }

    try {
      final response = await client.post(
        Uri.parse('$baseUrl/password/reset'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
        },
        body: jsonEncode({
          'email': cleanEmail,
          'token': cleanToken,
          'password': cleanPassword,
          'password_confirmation': cleanConfirmation,
        }),
      );

      final payload = _decodeJsonBody(response.body);
      final bool success =
          response.statusCode >= 200 &&
          response.statusCode < 300 &&
          payload['success'] == true;

      return {
        'statusCode': response.statusCode,
        'success': success,
        'message':
            payload['message']?.toString() ??
            'No se pudo restablecer la contraseña.',
        'data': payload,
      };
    } catch (e) {
      return {
        'statusCode': 0,
        'success': false,
        'message': 'No se pudo conectar con el servidor.',
        'error': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> login({
    required String usuario,
    required String password,
    bool remember = false,
  }) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'usuario': usuario.trim(),
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
          await storage.write(key: 'auth_token', value: token);
        }

        final user = data['user'] ?? data['usuario'];

        if (user is Map<String, dynamic>) {
          await _guardarUsuario(user);
        }
      }

      return {
        'statusCode': response.statusCode,
        'success': data['success'] == true,
        'mfa_required': data['mfa_required'] == true,
        'message': data['message']?.toString() ?? '',
        'token': data['token'],
        'user': data['user'] ?? data['usuario'],
        'login': data['login'],
        'mfa_challenge': data['mfa_challenge'],
        'retry_after': _retryAfterSeconds(response, data),
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

  static int _retryAfterSeconds(
    http.Response response,
    Map<String, dynamic> data,
  ) {
    final payloadValue = data['retry_after'];
    final headerValue = response.headers['retry-after'];
    return int.tryParse(payloadValue?.toString() ?? '') ??
        int.tryParse(headerValue ?? '') ??
        0;
  }

  // ============================================================
  // GUARDAR USUARIO
  // ============================================================

  static Future<void> _guardarUsuario(Map<String, dynamic> user) async {
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
      value: (user['role'] ?? user['rol'])?.toString() ?? '',
    );

    await storage.write(
      key: 'user_priv_admin',
      value: user['priv_admin']?.toString() ?? 'N',
    );

    await storage.write(
      key: 'user_active',
      value: user['active']?.toString() ?? 'N',
    );

    await storage.write(key: 'user_mfa', value: user['mfa']?.toString() ?? 'N');

    await storage.write(
      key: 'user_empresa',
      value: user['empresa']?.toString() ?? '',
    );

    await storage.write(
      key: 'user_departamento',
      value: user['departamento']?.toString() ?? '',
    );

    await storage.write(
      key: 'user_oficina',
      value: user['oficina']?.toString() ?? '',
    );

    await storage.write(
      key: 'user_numero_empleado',
      value: user['numero_empleado']?.toString() ?? '',
    );
    final picture =
        (user['picture'] ?? user['foto'] ?? user['foto_perfil'])?.toString() ??
        '';
    final storedPicture = await storage.read(key: 'user_picture');
    final normalizedPicture = picture.trim().toLowerCase();
    final isDefaultPicture =
        normalizedPicture.isEmpty ||
        normalizedPicture == 'user.png' ||
        normalizedPicture.endsWith('/user.png') ||
        normalizedPicture.contains('profile-photos/user.png');
    final normalizedStored = storedPicture?.trim().toLowerCase() ?? '';
    final hasStoredCustomPicture =
        normalizedStored.isNotEmpty &&
        normalizedStored != 'user.png' &&
        !normalizedStored.endsWith('/user.png') &&
        !normalizedStored.contains('profile-photos/user.png');

    if (!isDefaultPicture || !hasStoredCustomPicture) {
      await storage.write(key: 'user_picture', value: picture);
    }
  }

  // ============================================================
  // TOKEN
  // ============================================================

  static Future<String?> getToken() async {
    return await storage.read(key: 'auth_token');
  }

  // ============================================================
  // USUARIO GUARDADO
  // ============================================================

  static Future<Map<String, dynamic>?> getStoredUser() async {
    final login = await storage.read(key: 'user_login');
    final email = await storage.read(key: 'user_email');
    final name = await storage.read(key: 'user_name');
    final role = await storage.read(key: 'user_role');
    final privAdmin = await storage.read(key: 'user_priv_admin');
    final active = await storage.read(key: 'user_active');
    final mfa = await storage.read(key: 'user_mfa');
    final empresa = await storage.read(key: 'user_empresa');
    final departamento = await storage.read(key: 'user_departamento');
    final oficina = await storage.read(key: 'user_oficina');
    final numeroEmpleado = await storage.read(key: 'user_numero_empleado');
    final picture = await storage.read(key: 'user_picture');

    if (login == null &&
        email == null &&
        name == null &&
        role == null &&
        empresa == null &&
        departamento == null &&
        oficina == null &&
        numeroEmpleado == null) {
      return null;
    }

    return {
      'login': login ?? '',
      'email': email ?? '',
      'name': name ?? '',
      'role': role ?? '',
      'priv_admin': privAdmin ?? 'N',
      'active': active ?? 'N',
      'mfa': mfa ?? '',
      'empresa': empresa ?? '',
      'departamento': departamento ?? '',
      'oficina': oficina ?? '',
      'numero_empleado': numeroEmpleado ?? '',
      'picture': picture ?? '',
    };
  }

  // ============================================================
  // ADMIN
  // ============================================================

  static Future<bool> isAdmin() async {
    final role = await storage.read(key: 'user_role');

    final privAdmin = await storage.read(key: 'user_priv_admin');

    final rolNormalizado = role
        ?.trim()
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u');

    final bool rolPermitido =
        rolNormalizado == 'gerente ti' || rolNormalizado == 'soporte tecnico';

    return rolPermitido && privAdmin?.trim().toUpperCase() == 'Y';
  }

  // ============================================================
  // PERMISOS
  // ============================================================

  static Future<bool> puedeAccederTecnologias() async {
    return await isAdmin();
  }

  static Future<bool> esUsuarioNormal() async {
    final admin = await isAdmin();

    return !admin;
  }

  // ============================================================
  // DATOS DEL USUARIO
  // ============================================================

  static Future<String?> getLogin() async {
    return await storage.read(key: 'user_login');
  }

  static Future<String?> getEmail() async {
    return await storage.read(key: 'user_email');
  }

  static Future<String?> getNombre() async {
    return await storage.read(key: 'user_name');
  }

  static Future<String?> getRol() async {
    return await storage.read(key: 'user_role');
  }

  static Future<String?> getPrivAdmin() async {
    return await storage.read(key: 'user_priv_admin');
  }

  static Future<String?> getEmpresa() async {
    return await storage.read(key: 'user_empresa');
  }

  static Future<String?> getDepartamento() async {
    return await storage.read(key: 'user_departamento');
  }

  static Future<String?> getOficina() async {
    return await storage.read(key: 'user_oficina');
  }

  static Future<String?> getNumeroEmpleado() async {
    return await storage.read(key: 'user_numero_empleado');
  }

  // ============================================================
  // OBTENER USUARIO DESDE API
  // ============================================================

  static Future<Map<String, dynamic>> getUser() async {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      return {
        'statusCode': 401,
        'success': false,
        'message': 'No hay una sesión activa.',
        'data': {'success': false, 'message': 'No hay una sesión activa.'},
      };
    }

    try {
      final response = await client.get(
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

        await _guardarUsuario(user);
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

  // ============================================================
  // LOGOUT
  // ============================================================

  static Future<Map<String, dynamic>> logout() async {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      await clearSession();

      return {
        'statusCode': 401,
        'success': false,
        'message': 'No hay una sesión activa.',
        'data': {'success': false, 'message': 'No hay una sesión activa.'},
      };
    }

    try {
      final response = await client.post(
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

  // ============================================================
  // LIMPIAR SESIÓN
  // ============================================================

  static Future<void> clearSession() async {
    await storage.deleteAll();
  }

  // ============================================================
  // COMPROBAR SESIÓN
  // ============================================================

  static Future<bool> hasSession() async {
    final token = await getToken();

    return token != null && token.isNotEmpty;
  }
}
