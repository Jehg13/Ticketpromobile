import 'dart:convert';

import 'package:http/http.dart' as http;

import '../api_service.dart';

class UsersService {
  // ============================================================
  // OBTENER USUARIOS
  // ============================================================
  //
  // GET /api/usuarios
  //
  // Parámetros:
  //   estado
  //   departamento
  //   buscar
  //   page
  //
  // Respuesta:
  //   data.usuarios
  //   data.pagination
  //   data.estadisticas
  //   data.departamentos
  //   data.notificaciones
  //
  // ============================================================

  static Future<Map<String, dynamic>> obtenerUsuarios({
    String estado = 'todos',
    String departamento = '',
    String buscar = '',
    int pagina = 1,
  }) async {
    final token = await ApiService.getToken();

    if (token == null || token.isEmpty) {
      return {
        'statusCode': 401,
        'success': false,
        'message': 'No hay una sesión activa.',
        'usuarios': <Map<String, dynamic>>[],
        'pagination': <String, dynamic>{},
        'estadisticas': <String, dynamic>{},
        'departamentos': <Map<String, dynamic>>[],
        'notificaciones': <Map<String, dynamic>>[],
        'notificaciones_no_leidas': 0,
      };
    }

    try {
      final queryParameters = <String, String>{'page': pagina.toString()};

      if (estado.trim().isNotEmpty && estado.trim().toLowerCase() != 'todos') {
        queryParameters['estado'] = estado.trim().toLowerCase();
      }

      if (departamento.trim().isNotEmpty) {
        queryParameters['departamento'] = departamento.trim();
      }

      if (buscar.trim().isNotEmpty) {
        queryParameters['buscar'] = buscar.trim();
      }

      final uri = Uri.parse(
        '${ApiService.baseUrl}/usuarios',
      ).replace(queryParameters: queryParameters);

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = _decodeResponse(response);

      if (response.statusCode == 401) {
        await ApiService.clearSession();
      }

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          responseData['success'] == true) {
        // ======================================================
        // EL CONTROLADOR DEVUELVE:
        //
        // {
        //   success: true,
        //   data: {
        //      usuarios: [],
        //      pagination: {},
        //      estadisticas: {},
        //      departamentos: [],
        //      notificaciones: [],
        //      ...
        //   }
        // }
        // ======================================================

        final data = responseData['data'];

        final dataMap = data is Map
            ? Map<String, dynamic>.from(data)
            : <String, dynamic>{};

        // ------------------------------------------------------
        // USUARIOS
        // ------------------------------------------------------

        final usuariosData = dataMap['usuarios'];

        final usuarios = usuariosData is List
            ? usuariosData
                  .whereType<Map>()
                  .map((item) => Map<String, dynamic>.from(item))
                  .toList()
            : <Map<String, dynamic>>[];

        // ------------------------------------------------------
        // PAGINACIÓN
        // ------------------------------------------------------

        final paginationData = dataMap['pagination'];

        final pagination = paginationData is Map
            ? Map<String, dynamic>.from(paginationData)
            : <String, dynamic>{};

        // ------------------------------------------------------
        // ESTADÍSTICAS
        // ------------------------------------------------------

        final estadisticasData = dataMap['estadisticas'];

        final estadisticas = estadisticasData is Map
            ? Map<String, dynamic>.from(estadisticasData)
            : <String, dynamic>{};

        // ------------------------------------------------------
        // DEPARTAMENTOS
        // ------------------------------------------------------

        final departamentosData = dataMap['departamentos'];

        final departamentos = departamentosData is List
            ? departamentosData
                  .whereType<Map>()
                  .map((item) => Map<String, dynamic>.from(item))
                  .toList()
            : <Map<String, dynamic>>[];

        // ------------------------------------------------------
        // NOTIFICACIONES
        // ------------------------------------------------------

        final notificacionesData = dataMap['notificaciones'];

        final notificaciones = notificacionesData is List
            ? notificacionesData
                  .whereType<Map>()
                  .map((item) => Map<String, dynamic>.from(item))
                  .toList()
            : <Map<String, dynamic>>[];

        final notificacionesNoLeidas = _toInt(
          dataMap['notificaciones_no_leidas'],
        );

        return {
          'statusCode': response.statusCode,
          'success': true,
          'message': responseData['message']?.toString() ?? '',
          'usuarios': usuarios,
          'pagination': pagination,
          'estadisticas': estadisticas,
          'departamentos': departamentos,
          'notificaciones': notificaciones,
          'notificaciones_no_leidas': notificacionesNoLeidas,

          // Conservamos la respuesta completa
          // por si alguna pantalla necesita
          // acceder a otro dato.
          'data': responseData,
        };
      }

      return {
        'statusCode': response.statusCode,
        'success': false,
        'message': _mensajeError(
          responseData,
          'No se pudieron obtener los usuarios.',
        ),
        'usuarios': <Map<String, dynamic>>[],
        'pagination': <String, dynamic>{},
        'estadisticas': <String, dynamic>{},
        'departamentos': <Map<String, dynamic>>[],
        'notificaciones': <Map<String, dynamic>>[],
        'notificaciones_no_leidas': 0,
        'data': responseData,
      };
    } catch (e) {
      return {
        'statusCode': 0,
        'success': false,
        'message': 'No se pudo conectar con el servidor.',
        'error': e.toString(),
        'usuarios': <Map<String, dynamic>>[],
        'pagination': <String, dynamic>{},
        'estadisticas': <String, dynamic>{},
        'departamentos': <Map<String, dynamic>>[],
        'notificaciones': <Map<String, dynamic>>[],
        'notificaciones_no_leidas': 0,
      };
    }
  }

  // ============================================================
  // OBTENER DETALLE DE UN USUARIO
  // ============================================================
  //
  // GET /api/usuarios/{login}
  //
  // Devuelve:
  //   data.usuario
  //   data.empresas
  //   data.oficinas
  //   data.departamentos
  //
  // ============================================================

  static Future<Map<String, dynamic>> obtenerUsuario(String login) async {
    final token = await ApiService.getToken();

    if (token == null || token.isEmpty) {
      return {
        'statusCode': 401,
        'success': false,
        'message': 'No hay una sesión activa.',
        'usuario': null,
        'empresas': <Map<String, dynamic>>[],
        'oficinas': <Map<String, dynamic>>[],
        'departamentos': <Map<String, dynamic>>[],
      };
    }

    final loginLimpio = login.trim();

    if (loginLimpio.isEmpty) {
      return {
        'statusCode': 422,
        'success': false,
        'message': 'El login del usuario es obligatorio.',
        'usuario': null,
        'empresas': <Map<String, dynamic>>[],
        'oficinas': <Map<String, dynamic>>[],
        'departamentos': <Map<String, dynamic>>[],
      };
    }

    try {
      final uri = Uri.parse(
        '${ApiService.baseUrl}/usuarios/${Uri.encodeComponent(loginLimpio)}',
      );

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = _decodeResponse(response);

      if (response.statusCode == 401) {
        await ApiService.clearSession();
      }

      final data = responseData['data'];

      final dataMap = data is Map
          ? Map<String, dynamic>.from(data)
          : <String, dynamic>{};

      // ------------------------------------------------------
      // USUARIO
      // ------------------------------------------------------

      Map<String, dynamic>? usuario;

      if (dataMap['usuario'] is Map) {
        usuario = Map<String, dynamic>.from(dataMap['usuario']);
      }

      // ------------------------------------------------------
      // EMPRESAS
      // ------------------------------------------------------

      final empresasData = dataMap['empresas'];

      final empresas = empresasData is List
          ? empresasData
                .whereType<Map>()
                .map((item) => Map<String, dynamic>.from(item))
                .toList()
          : <Map<String, dynamic>>[];

      // ------------------------------------------------------
      // OFICINAS
      // ------------------------------------------------------

      final oficinasData = dataMap['oficinas'];

      final oficinas = oficinasData is List
          ? oficinasData
                .whereType<Map>()
                .map((item) => Map<String, dynamic>.from(item))
                .toList()
          : <Map<String, dynamic>>[];

      // ------------------------------------------------------
      // DEPARTAMENTOS
      // ------------------------------------------------------

      final departamentosData = dataMap['departamentos'];

      final departamentos = departamentosData is List
          ? departamentosData
                .whereType<Map>()
                .map((item) => Map<String, dynamic>.from(item))
                .toList()
          : <Map<String, dynamic>>[];

      return {
        'statusCode': response.statusCode,
        'success':
            response.statusCode >= 200 &&
            response.statusCode < 300 &&
            responseData['success'] == true,
        'message': responseData['message']?.toString() ?? '',
        'usuario': usuario,
        'empresas': empresas,
        'oficinas': oficinas,
        'departamentos': departamentos,
        'data': responseData,
      };
    } catch (e) {
      return {
        'statusCode': 0,
        'success': false,
        'message': 'No se pudo conectar con el servidor.',
        'usuario': null,
        'empresas': <Map<String, dynamic>>[],
        'oficinas': <Map<String, dynamic>>[],
        'departamentos': <Map<String, dynamic>>[],
        'error': e.toString(),
      };
    }
  }

  // ============================================================
  // ACTUALIZAR USUARIO
  // ============================================================
  //
  // PUT /api/usuarios/{login}
  //
  // password:
  //   Es la NUEVA contraseña del usuario.
  //
  // IMPORTANTE:
  //   La columna de la base de datos se llama "pswd".
  //
  //   Flutter envía "password".
  //   Laravel se encarga de guardar ese valor
  //   en users.pswd utilizando Hash::make().
  //
  // ============================================================

  static String _normalizarEstadoApi(String valor) {
    final limpio = valor.trim().toUpperCase();

    if (limpio == 'Y' || limpio == 'ACTIVA' || limpio == 'ACTIVO') {
      return 'Y';
    }

    if (limpio == 'N' || limpio == 'INACTIVA' || limpio == 'INACTIVO') {
      return 'N';
    }

    return limpio == 'SI' || limpio == 'SÍ' ? 'Y' : 'N';
  }

  static Future<Map<String, dynamic>> actualizarUsuario({
    required String login,
    required String nombre,
    required String email,
    String? phone,
    String? password,
    String? currentPassword,
    required String numeroEmpleado,
    required String role,
    required String active,
    required String privAdmin,
    required int oficinaId,
    String? departamento,
  }) async {
    final token = await ApiService.getToken();

    if (token == null || token.isEmpty) {
      return {
        'statusCode': 401,
        'success': false,
        'message': 'No hay una sesión activa.',
      };
    }

    final loginLimpio = login.trim();

    if (loginLimpio.isEmpty) {
      return {
        'statusCode': 422,
        'success': false,
        'message': 'El login del usuario es obligatorio.',
      };
    }

    try {
      final uri = Uri.parse(
        '${ApiService.baseUrl}/usuarios/${Uri.encodeComponent(loginLimpio)}',
      );

      final body = <String, dynamic>{
        'name': nombre.trim(),
        'email': email.trim(),
        'phone': phone?.trim(),
        'numero_empleado': numeroEmpleado.trim(),
        'role': role.trim(),
        'active': _normalizarEstadoApi(active),
        'priv_admin': _normalizarEstadoApi(privAdmin),
        'oficina_id': oficinaId,
        'departamento': departamento?.trim() ?? '',
        'current_password': currentPassword?.trim() ?? '',
      };

      if (password != null && password.trim().isNotEmpty) {
        body['password'] = password.trim();
      }

      final response = await http.put(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      final responseData = _decodeResponse(response);

      if (response.statusCode == 401) {
        await ApiService.clearSession();
      }

      final data = responseData['data'];

      final dataMap = data is Map
          ? Map<String, dynamic>.from(data)
          : <String, dynamic>{};

      Map<String, dynamic>? usuario;

      if (dataMap['usuario'] is Map) {
        usuario = Map<String, dynamic>.from(dataMap['usuario']);
      }

      return {
        'statusCode': response.statusCode,
        'success':
            response.statusCode >= 200 &&
            response.statusCode < 300 &&
            responseData['success'] == true,
        'message':
            responseData['message']?.toString() ??
            'No se pudo actualizar el usuario.',
        'usuario': usuario,
        'errors': responseData['errors'],
        'data': responseData,
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

  // ============================================================
  // ELIMINAR USUARIO
  // ============================================================
  //
  // DELETE /api/usuarios/{login}
  //
  // password:
  //   Contraseña del administrador actualmente
  //   autenticado.
  //
  // Laravel la comprueba contra:
  //
  //   users.pswd
  //
  // ============================================================

  static Future<Map<String, dynamic>> eliminarUsuario({
    required String login,
    required String password,
  }) async {
    final token = await ApiService.getToken();

    if (token == null || token.isEmpty) {
      return {
        'statusCode': 401,
        'success': false,
        'message': 'No hay una sesión activa.',
      };
    }

    final loginLimpio = login.trim();

    if (loginLimpio.isEmpty) {
      return {
        'statusCode': 422,
        'success': false,
        'message': 'El login del usuario es obligatorio.',
      };
    }

    if (password.trim().isEmpty) {
      return {
        'statusCode': 422,
        'success': false,
        'message': 'Debes proporcionar tu contraseña.',
      };
    }

    try {
      final uri = Uri.parse(
        '${ApiService.baseUrl}/usuarios/${Uri.encodeComponent(loginLimpio)}',
      );

      final response = await http.delete(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'password': password.trim()}),
      );

      final responseData = _decodeResponse(response);

      if (response.statusCode == 401) {
        await ApiService.clearSession();
      }

      return {
        'statusCode': response.statusCode,
        'success':
            response.statusCode >= 200 &&
            response.statusCode < 300 &&
            responseData['success'] == true,
        'message':
            responseData['message']?.toString() ??
            'No se pudo eliminar el usuario.',
        'errors': responseData['errors'],
        'data': responseData,
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

  // ============================================================
  // OBTENER EMPRESAS
  // ============================================================
  //
  // GET /api/usuarios/empresas
  //
  // ============================================================

  static Future<Map<String, dynamic>> obtenerEmpresas() async {
    final token = await ApiService.getToken();

    if (token == null || token.isEmpty) {
      return {
        'statusCode': 401,
        'success': false,
        'message': 'No hay una sesión activa.',
        'empresas': <Map<String, dynamic>>[],
      };
    }

    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/usuarios/empresas'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = _decodeResponse(response);

      if (response.statusCode == 401) {
        await ApiService.clearSession();
      }

      final data = responseData['data'];

      final dataMap = data is Map
          ? Map<String, dynamic>.from(data)
          : <String, dynamic>{};

      final empresasData = dataMap['empresas'] ?? responseData['empresas'];

      final empresas = empresasData is List
          ? empresasData
                .whereType<Map>()
                .map((item) => Map<String, dynamic>.from(item))
                .toList()
          : <Map<String, dynamic>>[];

      return {
        'statusCode': response.statusCode,
        'success':
            response.statusCode >= 200 &&
            response.statusCode < 300 &&
            responseData['success'] == true,
        'message': responseData['message']?.toString() ?? '',
        'empresas': empresas,
        'data': responseData,
      };
    } catch (e) {
      return {
        'statusCode': 0,
        'success': false,
        'message': 'No se pudo conectar con el servidor.',
        'empresas': <Map<String, dynamic>>[],
        'error': e.toString(),
      };
    }
  }

  // ============================================================
  // OBTENER OFICINAS POR EMPRESA
  // ============================================================
  //
  // GET /api/usuarios/empresas/{empresaId}/oficinas
  //
  // ============================================================

  static Future<Map<String, dynamic>> obtenerOficinasPorEmpresa(
    int empresaId,
  ) async {
    final token = await ApiService.getToken();

    if (token == null || token.isEmpty) {
      return {
        'statusCode': 401,
        'success': false,
        'message': 'No hay una sesión activa.',
        'oficinas': <Map<String, dynamic>>[],
      };
    }

    try {
      final response = await http.get(
        Uri.parse(
          '${ApiService.baseUrl}/usuarios/empresas/$empresaId/oficinas',
        ),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = _decodeResponse(response);

      if (response.statusCode == 401) {
        await ApiService.clearSession();
      }

      final data = responseData['data'];

      final dataMap = data is Map
          ? Map<String, dynamic>.from(data)
          : <String, dynamic>{};

      final oficinasData = dataMap['oficinas'] ?? responseData['oficinas'];

      final oficinas = oficinasData is List
          ? oficinasData
                .whereType<Map>()
                .map((item) => Map<String, dynamic>.from(item))
                .toList()
          : <Map<String, dynamic>>[];

      return {
        'statusCode': response.statusCode,
        'success':
            response.statusCode >= 200 &&
            response.statusCode < 300 &&
            responseData['success'] == true,
        'message': responseData['message']?.toString() ?? '',
        'oficinas': oficinas,
        'data': responseData,
      };
    } catch (e) {
      return {
        'statusCode': 0,
        'success': false,
        'message': 'No se pudo conectar con el servidor.',
        'oficinas': <Map<String, dynamic>>[],
        'error': e.toString(),
      };
    }
  }

  // ============================================================
  // OBTENER DEPARTAMENTOS POR OFICINA
  // ============================================================
  //
  // GET /api/usuarios/oficinas/{oficinaId}/departamentos
  //
  // ============================================================

  static Future<Map<String, dynamic>> obtenerDepartamentosPorOficina(
    int oficinaId,
  ) async {
    final token = await ApiService.getToken();

    if (token == null || token.isEmpty) {
      return {
        'statusCode': 401,
        'success': false,
        'message': 'No hay una sesión activa.',
        'departamentos': <Map<String, dynamic>>[],
      };
    }

    try {
      final response = await http.get(
        Uri.parse(
          '${ApiService.baseUrl}/usuarios/oficinas/$oficinaId/departamentos',
        ),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = _decodeResponse(response);

      if (response.statusCode == 401) {
        await ApiService.clearSession();
      }

      final data = responseData['data'];

      final dataMap = data is Map
          ? Map<String, dynamic>.from(data)
          : <String, dynamic>{};

      final departamentosData =
          dataMap['departamentos'] ?? responseData['departamentos'];

      final departamentos = departamentosData is List
          ? departamentosData
                .whereType<Map>()
                .map((item) => Map<String, dynamic>.from(item))
                .toList()
          : <Map<String, dynamic>>[];

      return {
        'statusCode': response.statusCode,
        'success':
            response.statusCode >= 200 &&
            response.statusCode < 300 &&
            responseData['success'] == true,
        'message': responseData['message']?.toString() ?? '',
        'departamentos': departamentos,
        'data': responseData,
      };
    } catch (e) {
      return {
        'statusCode': 0,
        'success': false,
        'message': 'No se pudo conectar con el servidor.',
        'departamentos': <Map<String, dynamic>>[],
        'error': e.toString(),
      };
    }
  }

  // ============================================================
  // ESTADÍSTICAS
  // ============================================================
  //
  // Recibe la respuesta que devuelve obtenerUsuarios().
  //
  // ============================================================

  static Map<String, dynamic> obtenerEstadisticas(
    Map<String, dynamic> respuesta,
  ) {
    final estadisticasData = respuesta['estadisticas'];

    if (estadisticasData is Map) {
      final estadisticas = Map<String, dynamic>.from(estadisticasData);

      return {
        'totalUsuarios': _toInt(estadisticas['total']),
        'usuariosActivos': _toInt(estadisticas['activos']),
        'usuariosInactivos': _toInt(estadisticas['inactivos']),
        'administradores': _toInt(estadisticas['administradores']),
      };
    }

    return {
      'totalUsuarios': 0,
      'usuariosActivos': 0,
      'usuariosInactivos': 0,
      'administradores': 0,
    };
  }

  // ============================================================
  // DECODIFICAR RESPUESTA
  // ============================================================

  static Map<String, dynamic> _decodeResponse(http.Response response) {
    if (response.body.trim().isEmpty) {
      return {
        'success': false,
        'message': 'El servidor devolvió una respuesta vacía.',
      };
    }

    try {
      final decoded = jsonDecode(response.body);

      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }

      return {
        'success': false,
        'message': 'La respuesta del servidor no es válida.',
      };
    } catch (_) {
      return {
        'success': false,
        'message': 'El servidor devolvió una respuesta no válida.',
        'raw': response.body,
      };
    }
  }

  // ============================================================
  // MENSAJE DE ERROR
  // ============================================================

  static String _mensajeError(Map<String, dynamic> data, String defecto) {
    final message = data['message'];

    if (message != null && message.toString().trim().isNotEmpty) {
      return message.toString();
    }

    return defecto;
  }

  // ============================================================
  // CONVERTIR A INT
  // ============================================================

  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
