import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'api_service.dart';
import 'session_service.dart';

class MisTicketsUsuarioService {
  static Future<Map<String, dynamic>> obtenerTickets({
    String buscar = '',
    String estado = 'todos',
    int pagina = 1,
  }) async {
    final token = await SessionService.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Sesión no válida');
    }

    final queryParameters = <String, String>{
      'page': pagina.toString(),
      'estado': estado.trim().toLowerCase(),
    };

    if (buscar.trim().isNotEmpty) {
      queryParameters['buscar'] = buscar.trim();
    }

    final uri = Uri.parse(
      '${ApiService.baseUrl}/mis-tickets',
    ).replace(
      queryParameters: queryParameters,
    );

    debugPrint('====================================================');
    debugPrint('🎫 MisTicketsUsuarioService.obtenerTickets()');
    debugPrint('====================================================');
    debugPrint('🌐 URL: $uri');

    try {
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('📥 Status: ${response.statusCode}');
      debugPrint('📦 Body: ${response.body}');

      final decoded = _decodificarRespuesta(response.body);

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        if (decoded['success'] != true) {
          throw Exception(
            decoded['message']?.toString() ??
                'No se pudieron obtener los tickets',
          );
        }

        return decoded;
      }

      if (response.statusCode == 401) {
        await SessionService.clearSession();
        throw Exception('Sesión expirada');
      }

      if (response.statusCode == 403) {
        throw Exception(
          decoded['message']?.toString() ??
              'No tienes permiso para consultar tus tickets',
        );
      }

      if (response.statusCode == 404) {
        throw Exception(
          decoded['message']?.toString() ??
              'Ruta de mis tickets no encontrada',
        );
      }

      if (response.statusCode >= 500) {
        throw Exception(
          decoded['message']?.toString() ??
              'Error interno del servidor',
        );
      }

      throw Exception(
        decoded['message']?.toString() ??
            'No se pudieron obtener los tickets',
      );
    } on Exception {
      rethrow;
    } catch (e) {
      debugPrint('❌ Error obteniendo mis tickets: $e');
      throw Exception('No se pudo conectar con el servidor');
    }
  }

  static Future<Map<String, dynamic>> obtenerTicket(
    int id,
  ) async {
    final token = await SessionService.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Sesión no válida');
    }

    final uri = Uri.parse(
      '${ApiService.baseUrl}/mis-tickets/$id',
    );

    debugPrint('====================================================');
    debugPrint('🎫 MisTicketsUsuarioService.obtenerTicket()');
    debugPrint('====================================================');
    debugPrint('🌐 URL: $uri');
    debugPrint('🆔 Ticket ID: $id');

    try {
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('📥 Status: ${response.statusCode}');
      debugPrint('📦 Body: ${response.body}');

      final decoded = _decodificarRespuesta(response.body);

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        if (decoded['success'] != true) {
          throw Exception(
            decoded['message']?.toString() ??
                'No se pudo obtener el ticket',
          );
        }

        return decoded;
      }

      if (response.statusCode == 401) {
        await SessionService.clearSession();
        throw Exception('Sesión expirada');
      }

      if (response.statusCode == 403) {
        throw Exception(
          decoded['message']?.toString() ??
              'No tienes permiso para consultar este ticket',
        );
      }

      if (response.statusCode == 404) {
        throw Exception(
          decoded['message']?.toString() ??
              'Ticket no encontrado o no tienes permiso para consultarlo',
        );
      }

      if (response.statusCode >= 500) {
        throw Exception(
          decoded['message']?.toString() ??
              'Error interno del servidor',
        );
      }

      throw Exception(
        decoded['message']?.toString() ??
            'No se pudo obtener el ticket',
      );
    } on Exception {
      rethrow;
    } catch (e) {
      debugPrint('❌ Error obteniendo ticket: $e');
      throw Exception('No se pudo conectar con el servidor');
    }
  }

  static Future<Map<String, dynamic>> obtenerResumen() async {
    final token = await SessionService.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Sesión no válida');
    }

    final uri = Uri.parse(
      '${ApiService.baseUrl}/mis-tickets-resumen',
    );

    debugPrint('====================================================');
    debugPrint('📊 MisTicketsUsuarioService.obtenerResumen()');
    debugPrint('====================================================');
    debugPrint('🌐 URL: $uri');

    try {
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('📥 Status: ${response.statusCode}');
      debugPrint('📦 Body: ${response.body}');

      final decoded = _decodificarRespuesta(response.body);

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        if (decoded['success'] != true) {
          throw Exception(
            decoded['message']?.toString() ??
                'No se pudo obtener el resumen',
          );
        }

        return decoded;
      }

      if (response.statusCode == 401) {
        await SessionService.clearSession();
        throw Exception('Sesión expirada');
      }

      if (response.statusCode == 403) {
        throw Exception(
          decoded['message']?.toString() ??
              'No tienes permiso para consultar el resumen',
        );
      }

      if (response.statusCode == 404) {
        throw Exception(
          decoded['message']?.toString() ??
              'Ruta del resumen no encontrada',
        );
      }

      if (response.statusCode >= 500) {
        throw Exception(
          decoded['message']?.toString() ??
              'Error interno del servidor',
        );
      }

      throw Exception(
        decoded['message']?.toString() ??
            'No se pudo obtener el resumen',
      );
    } on Exception {
      rethrow;
    } catch (e) {
      debugPrint('❌ Error obteniendo resumen: $e');
      throw Exception('No se pudo conectar con el servidor');
    }
  }

  static Map<String, dynamic> _decodificarRespuesta(
    String body,
  ) {
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
