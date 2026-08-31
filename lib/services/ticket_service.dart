import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'api_service.dart';
import 'session_service.dart';

class TicketService {
  static Future<Map<String, dynamic>> obtenerTickets() async {
    debugPrint('');
    debugPrint('====================================================');
    debugPrint('🎫 TicketService.obtenerTickets()');
    debugPrint('====================================================');

    final token = await SessionService.getToken();

    if (token == null || token.isEmpty) {
      debugPrint('❌ NO HAY TOKEN');
      throw Exception('Sesión no válida');
    }

    final url = '${ApiService.baseUrl}/tickets';

    debugPrint('🌐 URL: $url');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('📥 Status: ${response.statusCode}');
      debugPrint('📦 Body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = _decodificarRespuesta(response.body);

        if (decoded['success'] != true) {
          throw Exception(
            decoded['message']?.toString() ??
                'No se pudieron obtener los tickets',
          );
        }

        _mostrarInformacionRespuesta(decoded);

        return decoded;
      }

      if (response.statusCode == 401) {
        debugPrint('🔴 Sesión expirada');

        await SessionService.clearSession();

        throw Exception('Sesión expirada');
      }

      if (response.statusCode == 403) {
        throw Exception(
          'No tienes permiso para consultar los tickets',
        );
      }

      if (response.statusCode == 404) {
        throw Exception(
          'Ruta de tickets no encontrada',
        );
      }

      if (response.statusCode >= 500) {
        throw Exception(
          'Error interno del servidor (${response.statusCode})',
        );
      }

      final mensaje = _obtenerMensajeError(
        response.body,
      );

      throw Exception(
        mensaje.isNotEmpty
            ? mensaje
            : 'No se pudieron obtener los tickets (${response.statusCode})',
      );
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }

      debugPrint('❌ Error de conexión: $e');

      throw Exception(
        'No se pudo conectar con el servidor',
      );
    }
  }

  static Future<Map<String, dynamic>> obtenerTicket(
    int id,
  ) async {
    debugPrint('');
    debugPrint('====================================================');
    debugPrint(
      '🎫 TicketService.obtenerTicket($id)',
    );
    debugPrint('====================================================');

    final token = await SessionService.getToken();

    if (token == null || token.isEmpty) {
      debugPrint('❌ NO HAY TOKEN');

      throw Exception(
        'Sesión no válida',
      );
    }

    final url = '${ApiService.baseUrl}/tickets/$id';

    debugPrint('🌐 URL: $url');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint(
        '📥 Status: ${response.statusCode}',
      );

      debugPrint(
        '📦 Body: ${response.body}',
      );

      if (response.statusCode == 200) {
        final decoded = _decodificarRespuesta(
          response.body,
        );

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

        throw Exception(
          'Sesión expirada',
        );
      }

      if (response.statusCode == 403) {
        throw Exception(
          'No tienes permiso para consultar este ticket',
        );
      }

      if (response.statusCode == 404) {
        throw Exception(
          'Ticket no encontrado',
        );
      }

      if (response.statusCode >= 500) {
        throw Exception(
          'Error interno del servidor',
        );
      }

      final mensaje = _obtenerMensajeError(
        response.body,
      );

      throw Exception(
        mensaje.isNotEmpty
            ? mensaje
            : 'No se pudo obtener el ticket (${response.statusCode})',
      );
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }

      debugPrint(
        '❌ Error de conexión: $e',
      );

      throw Exception(
        'No se pudo conectar con el servidor',
      );
    }
  }

  static Future<List<Map<String, dynamic>>>
      obtenerNotificaciones() async {
    debugPrint('');
    debugPrint(
      '====================================================',
    );
    debugPrint(
      '🔔 TicketService.obtenerNotificaciones()',
    );
    debugPrint(
      '====================================================',
    );

    final respuesta = await obtenerTickets();

    final raw = respuesta['notificaciones'];

    if (raw is! List) {
      return [];
    }

    final notificaciones =
        <Map<String, dynamic>>[];

    for (final item in raw) {
      if (item is Map) {
        notificaciones.add(
          Map<String, dynamic>.from(item),
        );
      }
    }

    debugPrint(
      '🔔 Notificaciones obtenidas: ${notificaciones.length}',
    );

    return notificaciones;
  }

  static Future<bool> marcarNotificacionComoLeida(
    dynamic id,
  ) async {
    final token = await SessionService.getToken();

    if (token == null || token.isEmpty) {
      return false;
    }

    final notificationId = int.tryParse(id?.toString() ?? '');

    if (notificationId == null) {
      return false;
    }

    final url =
        '${ApiService.baseUrl}/mis-tickets-notificaciones/$notificationId/leida';

    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        return decoded is Map && decoded['success'] == true;
      }

      debugPrint(
        '⚠️ Error al marcar notificación como leída: ${response.statusCode} ${response.body}',
      );

      return false;
    } catch (e) {
      debugPrint('❌ Excepción al marcar notificación como leída: $e');
      return false;
    }
  }

  static Future<bool> marcarTodasNotificacionesLeidas() async {
    final token = await SessionService.getToken();

    if (token == null || token.isEmpty) {
      return false;
    }

    final url =
        '${ApiService.baseUrl}/mis-tickets-notificaciones-leer-todas';

    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        return decoded is Map && decoded['success'] == true;
      }

      debugPrint(
        '⚠️ Error al marcar todas las notificaciones como leídas: ${response.statusCode} ${response.body}',
      );

      return false;
    } catch (e) {
      debugPrint('❌ Excepción al marcar todas las notificaciones: $e');
      return false;
    }
  }

  static Future<int>
      obtenerNotificacionesNoLeidas() async {
    debugPrint('');
    debugPrint(
      '====================================================',
    );
    debugPrint(
      '🔔 TicketService.obtenerNotificacionesNoLeidas()',
    );
    debugPrint(
      '====================================================',
    );

    final respuesta = await obtenerTickets();

    final valor =
        respuesta['notificaciones_no_leidas'];

    final cantidad = _enteroSeguro(valor);

    debugPrint(
      '🔔 No leídas: $cantidad',
    );

    return cantidad;
  }

  static Future<List<Map<String, dynamic>>>
      obtenerActividad() async {
    debugPrint('');
    debugPrint(
      '====================================================',
    );
    debugPrint(
      '📋 TicketService.obtenerActividad()',
    );
    debugPrint(
      '====================================================',
    );

    final respuesta = await obtenerTickets();

    final raw = respuesta['actividad'];

    if (raw is! List) {
      return [];
    }

    final actividad =
        <Map<String, dynamic>>[];

    for (final item in raw) {
      if (item is Map) {
        actividad.add(
          Map<String, dynamic>.from(item),
        );
      }
    }

    debugPrint(
      '📋 Actividad obtenida: ${actividad.length}',
    );

    return actividad;
  }

  static Future<List<Map<String, dynamic>>>
      obtenerAvisos() async {
    debugPrint('');
    debugPrint(
      '====================================================',
    );
    debugPrint(
      '📢 TicketService.obtenerAvisos()',
    );
    debugPrint(
      '====================================================',
    );

    final respuesta = await obtenerTickets();

    final raw = respuesta['avisos'];

    if (raw is! List) {
      return [];
    }

    final avisos =
        <Map<String, dynamic>>[];

    for (final item in raw) {
      if (item is Map) {
        avisos.add(
          Map<String, dynamic>.from(item),
        );
      }
    }

    debugPrint(
      '📢 Avisos obtenidos: ${avisos.length}',
    );

    return avisos;
  }

  static Map<String, dynamic>
      _decodificarRespuesta(
    String body,
  ) {
    try {
      final decoded = jsonDecode(body);

      if (decoded is! Map<String, dynamic>) {
        throw Exception(
          'Respuesta inválida del servidor',
        );
      }

      return decoded;
    } on FormatException {
      debugPrint(
        '❌ La respuesta no es JSON válido',
      );

      throw Exception(
        'Respuesta inválida del servidor',
      );
    }
  }

  static String _obtenerMensajeError(
    String body,
  ) {
    try {
      final decoded = jsonDecode(body);

      if (decoded is Map) {
        final mensaje = decoded['message'];

        if (mensaje != null) {
          return mensaje.toString().trim();
        }

        final error = decoded['error'];

        if (error != null) {
          return error.toString().trim();
        }
      }
    } catch (_) {}

    return '';
  }

  static int _enteroSeguro(
    dynamic valor,
  ) {
    if (valor == null) {
      return 0;
    }

    if (valor is int) {
      return valor;
    }

    if (valor is num) {
      return valor.toInt();
    }

    if (valor is String) {
      return int.tryParse(
            valor.trim(),
          ) ??
          0;
    }

    return 0;
  }

  static void _mostrarInformacionRespuesta(
    Map<String, dynamic> decoded,
  ) {
    final resumen = decoded['resumen'];

    if (resumen is Map) {
      debugPrint(
        '📊 Resumen: $resumen',
      );
    }

    final ticketsRecientes =
        decoded['tickets_recientes'];

    if (ticketsRecientes is List) {
      debugPrint(
        '🎫 Tickets recientes: ${ticketsRecientes.length}',
      );
    }

    final ultimoTicket =
        decoded['ultimo_ticket'];

    debugPrint(
      '🏆 Último ticket: $ultimoTicket',
    );

    final actividad = decoded['actividad'];

    if (actividad is List) {
      debugPrint(
        '📋 Actividad: ${actividad.length}',
      );
    }

    final avisos = decoded['avisos'];

    if (avisos is List) {
      debugPrint(
        '📢 Avisos: ${avisos.length}',
      );
    }

    final notificaciones =
        decoded['notificaciones'];

    if (notificaciones is List) {
      debugPrint(
        '🔔 Notificaciones: ${notificaciones.length}',
      );
    }

    final noLeidas =
        decoded['notificaciones_no_leidas'];

    debugPrint(
      '🔔 Notificaciones no leídas: $noLeidas',
    );
  }
}