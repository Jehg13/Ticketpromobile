import 'dart:convert';

import 'package:http/http.dart' as http;

import '../api_service.dart';

class CambiosService {
  static const String endpoint = '${ApiService.baseUrl}/cambios';

  static Future<Map<String, dynamic>> obtenerSolicitudes({
    String? estado,
    String? buscar,
    int pagina = 1,
    int porPagina = 10,
  }) async {
    final token = await ApiService.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('No hay una sesión activa.');
    }

    final params = <String, String>{
      'page': pagina.toString(),
      'por_pagina': porPagina.toString(),
    };

    if (estado != null &&
        estado.trim().isNotEmpty &&
        estado.toLowerCase() != 'todos') {
      params['estado'] = _normalizarEstadoParaApi(estado);
    }

    if (buscar != null && buscar.trim().isNotEmpty) {
      params['buscar'] = buscar.trim();
    }

    final uri = Uri.parse(endpoint).replace(
      queryParameters: params,
    );

    try {
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = _decodeResponse(response);

      if (response.statusCode == 401) {
        await ApiService.clearSession();
        throw Exception('La sesión ha expirado.');
      }

      if (response.statusCode < 200 ||
          response.statusCode >= 300 ||
          data['success'] != true) {
        throw Exception(
          data['message']?.toString() ??
              'No se pudieron obtener las solicitudes de cambio.',
        );
      }

      final dataResponse = data['data'];

      if (dataResponse is Map) {
        return Map<String, dynamic>.from(dataResponse);
      }

      return {
        'solicitudes': <Map<String, dynamic>>[],
        'pagination': {
          'current_page': pagina,
          'last_page': pagina,
          'per_page': porPagina,
          'total': 0,
          'from': null,
          'to': null,
        },
        'estadisticas': {
          'total': 0,
          'pendientes': 0,
          'aprobadas': 0,
          'rechazadas': 0,
        },
        'notificaciones': <dynamic>[],
        'notificaciones_no_leidas': 0,
      };
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }

      throw Exception(
        'No se pudo conectar con el servidor.',
      );
    }
  }

  static Future<Map<String, dynamic>> obtenerSolicitud(
    int id,
  ) async {
    final token = await ApiService.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('No hay una sesión activa.');
    }

    try {
      final response = await http.get(
        Uri.parse('$endpoint/$id'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = _decodeResponse(response);

      if (response.statusCode == 401) {
        await ApiService.clearSession();
        throw Exception('La sesión ha expirado.');
      }

      if (response.statusCode < 200 ||
          response.statusCode >= 300 ||
          data['success'] != true) {
        throw Exception(
          data['message']?.toString() ??
              'No se pudo obtener la solicitud.',
        );
      }

      final dataResponse = data['data'];

      if (dataResponse is Map) {
        return Map<String, dynamic>.from(dataResponse);
      }

      throw Exception(
        'La respuesta del servidor no contiene la solicitud.',
      );
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }

      throw Exception(
        'No se pudo conectar con el servidor.',
      );
    }
  }

  static Future<Map<String, dynamic>> aprobarSolicitud({
    required int id,
    String? comentarioAdmin,
  }) async {
    return _resolverSolicitud(
      id: id,
      accion: 'aprobar',
      comentarioAdmin: comentarioAdmin,
    );
  }

  static Future<Map<String, dynamic>> rechazarSolicitud({
    required int id,
    required String comentarioAdmin,
  }) async {
    return _resolverSolicitud(
      id: id,
      accion: 'rechazar',
      comentarioAdmin: comentarioAdmin,
    );
  }

  static Future<Map<String, dynamic>> _resolverSolicitud({
    required int id,
    required String accion,
    String? comentarioAdmin,
  }) async {
    final token = await ApiService.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('No hay una sesión activa.');
    }

    final body = <String, dynamic>{};

    if (comentarioAdmin != null) {
      body['comentario_admin'] = comentarioAdmin.trim();
    }

    try {
      final response = await http.patch(
        Uri.parse('$endpoint/$id/$accion'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      final data = _decodeResponse(response);

      if (response.statusCode == 401) {
        await ApiService.clearSession();
        throw Exception('La sesión ha expirado.');
      }

      if (response.statusCode == 403) {
        throw Exception(
          data['message']?.toString() ??
              'No tienes permisos para realizar esta acción.',
        );
      }

      if (response.statusCode == 422) {
        throw Exception(
          data['message']?.toString() ??
              'La solicitud no puede ser procesada.',
        );
      }

      if (response.statusCode < 200 ||
          response.statusCode >= 300 ||
          data['success'] != true) {
        throw Exception(
          data['message']?.toString() ??
              'No se pudo procesar la solicitud.',
        );
      }

      final dataResponse = data['data'];

      if (dataResponse is Map) {
        return Map<String, dynamic>.from(dataResponse);
      }

      return {
        'solicitud': null,
      };
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }

      throw Exception(
        'No se pudo conectar con el servidor.',
      );
    }
  }

  static Map<String, dynamic> _decodeResponse(
    http.Response response,
  ) {
    if (response.body.trim().isEmpty) {
      return {
        'success': false,
        'message': 'El servidor devolvió una respuesta vacía.',
      };
    }

    try {
      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

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
        'message':
            'El servidor devolvió una respuesta no válida.',
      };
    }
  }

  static String _normalizarEstadoParaApi(
    String estado,
  ) {
    final valor = estado.trim().toLowerCase();

    switch (valor) {
      case 'en revisión':
      case 'en revision':
      case 'pendiente':
        return 'pendiente';

      case 'aprobada':
      case 'aprobado':
        return 'aprobada';

      case 'rechazada':
      case 'rechazado':
        return 'rechazada';

      default:
        return estado.trim();
    }
  }
}
