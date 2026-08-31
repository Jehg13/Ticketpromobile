import 'dart:convert';
import 'package:http/http.dart' as http;

import '../api_service.dart';
import '../session_service.dart';

class DispositivosService {
  static String get baseUrl => '${ApiService.serverUrl}/api';

  static Future<Map<String, String>> _headers() async {
    final token = await SessionService.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('No hay una sesión autenticada.');
    }

    return {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static dynamic _decodeResponse(http.Response response) {
    dynamic body;

    try {
      body = jsonDecode(response.body);
    } catch (_) {
      throw Exception(
        'El servidor devolvió una respuesta no válida.',
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    String mensaje = 'Ocurrió un error en el servidor.';

    if (body is Map<String, dynamic>) {
      if (body['message'] != null) {
        mensaje = body['message'].toString();
      }

      if (body['errors'] is Map) {
        final errors = body['errors'] as Map;
        final mensajes = <String>[];

        for (final entry in errors.entries) {
          final value = entry.value;

          if (value is List) {
            mensajes.addAll(
              value.map((e) => e.toString()),
            );
          } else {
            mensajes.add(value.toString());
          }
        }

        if (mensajes.isNotEmpty) {
          mensaje = mensajes.join('\n');
        }
      }
    }

    throw Exception(mensaje);
  }

  static Future<Map<String, dynamic>> obtenerDatos({
    String buscar = '',
    String estado = '',
    int pagina = 1,
    int porPagina = 10,
  }) async {
    final headers = await _headers();

    final queryParameters = <String, String>{
      'page': pagina.toString(),
      'por_pagina': porPagina.toString(),
    };

    if (buscar.trim().isNotEmpty) {
      queryParameters['buscar'] = buscar.trim();
    }

    if (estado.trim().isNotEmpty) {
      queryParameters['estado'] = estado.trim();
    }

    final uri = Uri.parse(
      '$baseUrl/dispositivos',
    ).replace(
      queryParameters: queryParameters,
    );

    final response = await http.get(
      uri,
      headers: headers,
    );

    final decoded = _decodeResponse(response);

    if (decoded is! Map<String, dynamic>) {
      throw Exception(
        'La respuesta de dispositivos no tiene un formato válido.',
      );
    }

    final data = decoded['data'];

    if (data is! Map) {
      throw Exception(
        'La respuesta no contiene la información de dispositivos.',
      );
    }

    return Map<String, dynamic>.from(data);
  }

  static Future<List<Map<String, dynamic>>> obtenerTodosLosUsuarios({
    String buscar = '',
  }) async {
    final todosLosUsuarios = <Map<String, dynamic>>[];

    int pagina = 1;
    int ultimaPagina = 1;

    do {
      final data = await obtenerDatos(
        buscar: buscar,
        pagina: pagina,
        porPagina: 100,
      );

      final usuariosData = data['usuarios'];

      if (usuariosData is List) {
        for (final item in usuariosData) {
          if (item is Map) {
            todosLosUsuarios.add(
              Map<String, dynamic>.from(item),
            );
          }
        }
      }

      final pagination = data['usuarios_pagination'] ??
          data['usuariosPagination'] ??
          data['pagination_usuarios'];

      if (pagination is Map) {
        final lastPageValue =
            pagination['last_page'] ??
            pagination['lastPage'];

        ultimaPagina =
            int.tryParse(lastPageValue?.toString() ?? '') ?? pagina;
      } else {
        final dispositivosPagination = data['pagination'];

        if (dispositivosPagination is Map &&
            data['usuarios'] is List) {
          final lastPageValue =
              dispositivosPagination['last_page'] ??
              dispositivosPagination['lastPage'];

          final posibleUltimaPagina =
              int.tryParse(lastPageValue?.toString() ?? '');

          if (posibleUltimaPagina != null &&
              posibleUltimaPagina > ultimaPagina) {
            ultimaPagina = posibleUltimaPagina;
          }
        }
      }

      pagina++;
    } while (pagina <= ultimaPagina);

    final usuariosUnicos = <String, Map<String, dynamic>>{};

    for (final usuario in todosLosUsuarios) {
      final login = _obtenerLoginUsuario(usuario);

      if (login.isNotEmpty) {
        usuariosUnicos[login.toLowerCase()] = usuario;
      }
    }

    return usuariosUnicos.values.toList();
  }

  static String _obtenerLoginUsuario(
    Map<String, dynamic> usuario,
  ) {
    return usuario['login']?.toString().trim() ??
        usuario['username']?.toString().trim() ??
        usuario['usuario']?.toString().trim() ??
        '';
  }

  static Future<List<Map<String, dynamic>>> obtenerDispositivos({
    String buscar = '',
    String estado = '',
    int pagina = 1,
    int porPagina = 10,
  }) async {
    final data = await obtenerDatos(
      buscar: buscar,
      estado: estado,
      pagina: pagina,
      porPagina: porPagina,
    );

    final dispositivosData = data['dispositivos'];

    if (dispositivosData is! List) {
      return [];
    }

    return dispositivosData
        .whereType<Map>()
        .map(
          (item) => Map<String, dynamic>.from(item),
        )
        .toList();
  }

  static Future<Map<String, dynamic>> obtenerPaginacion({
    String buscar = '',
    String estado = '',
    int pagina = 1,
    int porPagina = 10,
  }) async {
    final data = await obtenerDatos(
      buscar: buscar,
      estado: estado,
      pagina: pagina,
      porPagina: porPagina,
    );

    final pagination = data['pagination'];

    if (pagination is! Map) {
      return {
        'current_page': pagina,
        'last_page': pagina,
        'per_page': porPagina,
        'total': 0,
        'from': null,
        'to': null,
      };
    }

    return Map<String, dynamic>.from(pagination);
  }

  static Future<List<Map<String, dynamic>>> obtenerUsuarios({
    String buscar = '',
    String estado = '',
    int pagina = 1,
    int porPagina = 10,
  }) async {
    final data = await obtenerDatos(
      buscar: buscar,
      estado: estado,
      pagina: pagina,
      porPagina: porPagina,
    );

    final usuariosData = data['usuarios'];

    if (usuariosData is! List) {
      return [];
    }

    return usuariosData
        .whereType<Map>()
        .map(
          (item) => Map<String, dynamic>.from(item),
        )
        .toList();
  }

  static Future<List<Map<String, dynamic>>> obtenerNotificaciones({
    String buscar = '',
    String estado = '',
    int pagina = 1,
    int porPagina = 10,
  }) async {
    final data = await obtenerDatos(
      buscar: buscar,
      estado: estado,
      pagina: pagina,
      porPagina: porPagina,
    );

    final notificacionesData = data['notificaciones'];

    if (notificacionesData is! List) {
      return [];
    }

    return notificacionesData
        .whereType<Map>()
        .map(
          (item) => Map<String, dynamic>.from(item),
        )
        .toList();
  }

  static Future<int> obtenerNotificacionesNoLeidas({
    String buscar = '',
    String estado = '',
    int pagina = 1,
    int porPagina = 10,
  }) async {
    final data = await obtenerDatos(
      buscar: buscar,
      estado: estado,
      pagina: pagina,
      porPagina: porPagina,
    );

    final cantidad = data['notificaciones_no_leidas'];

    if (cantidad is int) {
      return cantidad;
    }

    return int.tryParse(
          cantidad?.toString() ?? '',
        ) ??
        0;
  }

  static Future<Map<String, dynamic>> obtenerDispositivo(
    int id,
  ) async {
    final headers = await _headers();

    final response = await http.get(
      Uri.parse('$baseUrl/dispositivos/$id'),
      headers: headers,
    );

    final decoded = _decodeResponse(response);

    if (decoded is! Map<String, dynamic>) {
      throw Exception(
        'La respuesta del dispositivo no tiene un formato válido.',
      );
    }

    final data = decoded['data'];

    if (data is! Map) {
      throw Exception(
        'No se encontró la información del dispositivo.',
      );
    }

    final dispositivo = data['dispositivo'];

    if (dispositivo is! Map) {
      throw Exception(
        'El dispositivo recibido no tiene un formato válido.',
      );
    }

    return Map<String, dynamic>.from(dispositivo);
  }

  static Future<Map<String, dynamic>> crearDispositivo({
    required String login,
    required String nombreEquipo,
    required String idEquipo,
    String estado = 'vinculado',
  }) async {
    final headers = await _headers();

    final response = await http.post(
      Uri.parse('$baseUrl/dispositivos'),
      headers: {
        ...headers,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'login': login,
        'nombre_equipo': nombreEquipo,
        'id_equipo': idEquipo,
        'estado': estado,
      }),
    );

    final decoded = _decodeResponse(response);

    if (decoded is! Map<String, dynamic>) {
      throw Exception(
        'La respuesta al crear el dispositivo no es válida.',
      );
    }

    final data = decoded['data'];

    if (data is! Map) {
      throw Exception(
        'El servidor no devolvió el dispositivo creado.',
      );
    }

    final dispositivo = data['dispositivo'];

    if (dispositivo is! Map) {
      throw Exception(
        'El dispositivo creado no tiene un formato válido.',
      );
    }

    return Map<String, dynamic>.from(dispositivo);
  }

  static Future<Map<String, dynamic>> actualizarDispositivo({
    required int id,
    required String login,
    required String nombreEquipo,
    required String idEquipo,
    required String estado,
  }) async {
    final headers = await _headers();

    final response = await http.put(
      Uri.parse('$baseUrl/dispositivos/$id'),
      headers: {
        ...headers,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'login': login,
        'nombre_equipo': nombreEquipo,
        'id_equipo': idEquipo,
        'estado': estado,
      }),
    );

    final decoded = _decodeResponse(response);

    if (decoded is! Map<String, dynamic>) {
      throw Exception(
        'La respuesta al actualizar el dispositivo no es válida.',
      );
    }

    final data = decoded['data'];

    if (data is! Map) {
      throw Exception(
        'El servidor no devolvió el dispositivo actualizado.',
      );
    }

    final dispositivo = data['dispositivo'];

    if (dispositivo is! Map) {
      throw Exception(
        'El dispositivo actualizado no tiene un formato válido.',
      );
    }

    return Map<String, dynamic>.from(dispositivo);
  }

  static Future<Map<String, dynamic>> cambiarEstado(
    int id,
  ) async {
    final headers = await _headers();

    final response = await http.patch(
      Uri.parse('$baseUrl/dispositivos/$id/estado'),
      headers: headers,
    );

    final decoded = _decodeResponse(response);

    if (decoded is! Map<String, dynamic>) {
      throw Exception(
        'La respuesta al cambiar el estado no es válida.',
      );
    }

    final data = decoded['data'];

    if (data is! Map) {
      throw Exception(
        'El servidor no devolvió el dispositivo actualizado.',
      );
    }

    final dispositivo = data['dispositivo'];

    if (dispositivo is! Map) {
      throw Exception(
        'El dispositivo actualizado no tiene un formato válido.',
      );
    }

    return Map<String, dynamic>.from(dispositivo);
  }

  static Future<String> eliminarDispositivo(
    int id,
  ) async {
    final headers = await _headers();

    final response = await http.delete(
      Uri.parse('$baseUrl/dispositivos/$id'),
      headers: headers,
    );

    final decoded = _decodeResponse(response);

    if (decoded is Map<String, dynamic>) {
      return decoded['message']?.toString() ??
          'Dispositivo eliminado correctamente.';
    }

    return 'Dispositivo eliminado correctamente.';
  }

  static Future<List<Map<String, dynamic>>> buscarDispositivos(
    String texto,
  ) async {
    return obtenerDispositivos(
      buscar: texto,
      pagina: 1,
    );
  }

  static Future<List<Map<String, dynamic>>> obtenerDispositivosVinculados({
    int pagina = 1,
    int porPagina = 10,
  }) async {
    return obtenerDispositivos(
      estado: 'vinculado',
      pagina: pagina,
      porPagina: porPagina,
    );
  }

  static Future<List<Map<String, dynamic>>> obtenerDispositivosDesvinculados({
    int pagina = 1,
    int porPagina = 10,
  }) async {
    return obtenerDispositivos(
      estado: 'desvinculado',
      pagina: pagina,
      porPagina: porPagina,
    );
  }

  static int obtenerIdDispositivo(
    Map<String, dynamic> dispositivo,
  ) {
    final id = dispositivo['id'];

    if (id is int) {
      return id;
    }

    return int.tryParse(
          id?.toString() ?? '',
        ) ??
        0;
  }

  static String obtenerLogin(
    Map<String, dynamic> dispositivo,
  ) {
    return dispositivo['login']?.toString() ?? '';
  }

  static String obtenerNombreEquipo(
    Map<String, dynamic> dispositivo,
  ) {
    return dispositivo['nombre_equipo']?.toString() ?? '';
  }

  static String obtenerIdEquipo(
    Map<String, dynamic> dispositivo,
  ) {
    return dispositivo['id_equipo']?.toString() ?? '';
  }

  static String obtenerEstado(
    Map<String, dynamic> dispositivo,
  ) {
    return dispositivo['estado']?.toString() ?? '';
  }

  static String obtenerNombreUsuario(
    Map<String, dynamic> dispositivo,
  ) {
    final usuario = dispositivo['usuario'];

    if (usuario is Map) {
      return usuario['name']?.toString() ?? '';
    }

    return '';
  }

  static String obtenerCorreoUsuario(
    Map<String, dynamic> dispositivo,
  ) {
    final usuario = dispositivo['usuario'];

    if (usuario is Map) {
      return usuario['email']?.toString() ?? '';
    }

    return '';
  }

  static bool estaVinculado(
    Map<String, dynamic> dispositivo,
  ) {
    return obtenerEstado(dispositivo).toLowerCase() == 'vinculado';
  }

  static bool estaDesvinculado(
    Map<String, dynamic> dispositivo,
  ) {
    return obtenerEstado(dispositivo).toLowerCase() == 'desvinculado';
  }
}
