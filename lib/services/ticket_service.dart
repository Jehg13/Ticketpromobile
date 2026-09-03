import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_service.dart';
import 'session_service.dart';

class TicketService {
  static Future<Map<String, dynamic>> obtenerTickets() async {





    final token = await SessionService.getToken();

    if (token == null || token.isEmpty) {

      throw Exception('Sesión no válida');
    }

    final url = '${ApiService.baseUrl}/tickets';



    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );




      if (response.statusCode == 200) {
        final decoded = _decodificarRespuesta(response.body);

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



      throw Exception(
        'No se pudo conectar con el servidor',
      );
    }
  }

  static Future<Map<String, dynamic>> obtenerTicket(
    int id,
  ) async {





    final token = await SessionService.getToken();

    if (token == null || token.isEmpty) {


      throw Exception(
        'Sesión no válida',
      );
    }

    final url = '${ApiService.baseUrl}/tickets/$id';



    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
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



      throw Exception(
        'No se pudo conectar con el servidor',
      );
    }
  }

  static Future<List<Map<String, dynamic>>>
      obtenerNotificaciones() async {





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



      return false;
    } catch (e) {

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



      return false;
    } catch (e) {

      return false;
    }
  }

  static Future<int>
      obtenerNotificacionesNoLeidas() async {





    final respuesta = await obtenerTickets();

    final valor =
        respuesta['notificaciones_no_leidas'];

    final cantidad = _enteroSeguro(valor);



    return cantidad;
  }

  static Future<List<Map<String, dynamic>>>
      obtenerActividad() async {





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



    return actividad;
  }

  static Future<List<Map<String, dynamic>>>
      obtenerAvisos() async {





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

}