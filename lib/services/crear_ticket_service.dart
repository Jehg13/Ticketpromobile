import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'api_service.dart';
import 'session_service.dart';

class CrearTicketService {
  static Future<List<Map<String, dynamic>>> obtenerEquipos() async {
    final token = await SessionService.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Sesión no válida');
    }

    final uri = Uri.parse('${ApiService.baseUrl}/equipos');

    debugPrint('====================================================');
    debugPrint('CrearTicketService.obtenerEquipos()');
    debugPrint('====================================================');
    debugPrint('URL: $uri');

    try {
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('Status: ${response.statusCode}');
      debugPrint('Body: ${response.body}');

      final decoded = _decodificarRespuesta(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (decoded['success'] != true) {
          throw Exception(
            decoded['message']?.toString() ??
                'No se pudieron obtener los equipos',
          );
        }

        final dynamic equiposData = decoded['equipos'];

        if (equiposData == null || equiposData is! List) {
          return <Map<String, dynamic>>[];
        }

        return equiposData
            .whereType<Map>()
            .map(
              (equipo) => Map<String, dynamic>.from(equipo),
            )
            .toList();
      }

      if (response.statusCode == 401) {
        await SessionService.clearSession();
        throw Exception('Sesión expirada');
      }

      if (response.statusCode == 403) {
        throw Exception(
          decoded['message']?.toString() ??
              'No tienes permiso para consultar tus equipos',
        );
      }

      if (response.statusCode == 404) {
        throw Exception(
          decoded['message']?.toString() ??
              'Ruta para consultar equipos no encontrada',
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
            'No se pudieron obtener los equipos',
      );
    } on Exception {
      rethrow;
    } catch (e) {
      debugPrint('Error obteniendo equipos: $e');
      throw Exception('No se pudo conectar con el servidor');
    }
  }

  static Future<Map<String, dynamic>> crearTicket({
    required String titulo,
    required String tipoFalla,
    String? equipo,
    required String prioridad,
    required String descripcion,
    required bool afectaOtros,
    required bool esRecurrente,
    String? comentarios,
    List<PlatformFile>? evidencias,
  }) async {
    final token = await SessionService.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Sesión no válida');
    }

    final uri = Uri.parse('${ApiService.baseUrl}/ticketscrear');

    debugPrint('====================================================');
    debugPrint('CrearTicketService.crearTicket()');
    debugPrint('====================================================');
    debugPrint('URL: $uri');
    debugPrint('Título: $titulo');
    debugPrint('Tipo de falla: $tipoFalla');
    debugPrint('Equipo: $equipo');
    debugPrint('Prioridad: $prioridad');
    debugPrint('Evidencias: ${evidencias?.length ?? 0}');

    try {
      final request = http.MultipartRequest(
        'POST',
        uri,
      );

      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      request.fields['titulo'] = titulo.trim();
      request.fields['tipo_falla'] = tipoFalla.trim();
      request.fields['prioridad'] = prioridad.trim();
      request.fields['descripcion'] = descripcion.trim();
      request.fields['afecta_otros'] = afectaOtros ? '1' : '0';
      request.fields['es_recurrente'] = esRecurrente ? '1' : '0';

      if (tipoFalla.trim().toLowerCase() == 'hardware' &&
          equipo != null &&
          equipo.trim().isNotEmpty) {
        request.fields['equipo'] = equipo.trim();
      }

      if (comentarios != null && comentarios.trim().isNotEmpty) {
        request.fields['comentarios'] = comentarios.trim();
      }

      if (evidencias != null && evidencias.isNotEmpty) {
        for (final file in evidencias) {
          try {
            final bytes = await file.readAsBytes();

            if (bytes.isEmpty) {
              debugPrint(
                'Archivo vacío: ${file.name}',
              );
              continue;
            }

            debugPrint(
              'Adjuntando: ${file.name} (${bytes.length} bytes)',
            );

            final archivo = http.MultipartFile.fromBytes(
              'evidencia[]',
              bytes,
              filename: file.name,
            );

            request.files.add(archivo);
          } catch (e) {
            debugPrint(
              'Error leyendo ${file.name}: $e',
            );

            throw Exception(
              'No se pudo leer el archivo ${file.name}',
            );
          }
        }
      }

      debugPrint(
        'Archivos agregados al request: ${request.files.length}',
      );

      debugPrint('Enviando ticket...');

      final streamedResponse = await request.send();

      final response = await http.Response.fromStream(
        streamedResponse,
      );

      debugPrint('Status: ${response.statusCode}');
      debugPrint('Body: ${response.body}');

      final decoded = _decodificarRespuesta(
        response.body,
      );

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        if (decoded['success'] == true) {
          debugPrint('Ticket creado correctamente');
          return decoded;
        }

        throw Exception(
          decoded['message']?.toString() ??
              'No se pudo crear el ticket',
        );
      }

      if (response.statusCode == 401) {
        await SessionService.clearSession();
        throw Exception('Sesión expirada');
      }

      if (response.statusCode == 403) {
        throw Exception(
          decoded['message']?.toString() ??
              'No tienes permiso para crear tickets',
        );
      }

      if (response.statusCode == 422) {
        final dynamic errores = decoded['errors'];

        if (errores is Map) {
          final mensajes = <String>[];

          errores.forEach((campo, valor) {
            if (valor is List) {
              for (final mensaje in valor) {
                mensajes.add(
                  mensaje.toString(),
                );
              }
            } else {
              mensajes.add(
                valor.toString(),
              );
            }
          });

          if (mensajes.isNotEmpty) {
            throw Exception(
              mensajes.join('\n'),
            );
          }
        }

        throw Exception(
          decoded['message']?.toString() ??
              'Los datos enviados no son válidos',
        );
      }

      if (response.statusCode == 404) {
        throw Exception(
          decoded['message']?.toString() ??
              'Ruta para crear tickets no encontrada',
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
            'No se pudo crear el ticket (${response.statusCode})',
      );
    } on Exception {
      rethrow;
    } catch (e) {
      debugPrint('Error de conexión: $e');

      throw Exception(
        'No se pudo conectar con el servidor',
      );
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

      throw Exception(
        'Respuesta inválida del servidor',
      );
    } on FormatException {
      throw Exception(
        'Respuesta inválida del servidor',
      );
    }
  }
}
