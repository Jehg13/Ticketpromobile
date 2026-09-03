import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_service.dart';
import 'session_service.dart';

class AvisosusuarioService {
  static Future<Map<String, dynamic>> obtenerAvisos({
    String buscar = '',
    String tipo = 'todos',
  }) async {
    final token = await SessionService.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Sesión no válida');
    }

    final parametros = <String, String>{
      'tipo': tipo.trim().isEmpty ? 'todos' : tipo.trim(),
    };

    if (buscar.trim().isNotEmpty) {
      parametros['buscar'] = buscar.trim();
    }

    final uri = Uri.parse(
      '${ApiService.baseUrl}/avisos',
    ).replace(
      queryParameters: parametros,
    );

    try {
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
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
                'No se pudieron obtener los avisos',
          );
        }

        final avisos = decoded['avisos'];

        if (avisos is List) {


          for (final item in avisos) {
            if (item is Map) {







            }
          }
        }

        return decoded;
      }

      if (response.statusCode == 401) {
        await SessionService.clearSession();

        throw Exception('Sesión expirada');
      }

      if (response.statusCode == 403) {
        throw Exception(
          'No tienes permiso para consultar los avisos',
        );
      }

      if (response.statusCode == 404) {
        throw Exception(
          'Ruta de avisos no encontrada',
        );
      }

      if (response.statusCode >= 500) {
        throw Exception(
          'Error interno del servidor (${response.statusCode})',
        );
      }

      throw _obtenerMensajeError(
        response.body,
        response.statusCode,
      );
    } on Exception {
      rethrow;
    } catch (e) {


      throw Exception(
        'No se pudo conectar con el servidor',
      );
    }
  }

  static Future<Map<String, dynamic>> obtenerAviso(
    int id,
  ) async {
    final token = await SessionService.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Sesión no válida');
    }

    final uri = Uri.parse(
      '${ApiService.baseUrl}/avisos/$id',
    );

    try {
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
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
                'No se pudo obtener el aviso',
          );
        }

        final aviso = decoded['aviso'];

        if (aviso is Map) {









        }

        return decoded;
      }

      if (response.statusCode == 401) {
        await SessionService.clearSession();

        throw Exception('Sesión expirada');
      }

      if (response.statusCode == 403) {
        throw Exception(
          'No tienes permiso para consultar este aviso',
        );
      }

      if (response.statusCode == 404) {
        throw Exception(
          'Aviso no encontrado',
        );
      }

      if (response.statusCode >= 500) {
        throw Exception(
          'Error interno del servidor',
        );
      }

      throw _obtenerMensajeError(
        response.body,
        response.statusCode,
      );
    } on Exception {
      rethrow;
    } catch (e) {


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

  static Exception _obtenerMensajeError(
    String body,
    int statusCode,
  ) {
    try {
      final decoded = jsonDecode(body);

      if (decoded is Map &&
          decoded['message'] != null) {
        return Exception(
          decoded['message'].toString(),
        );
      }
    } catch (_) {}

    return Exception(
      'No se pudieron obtener los avisos ($statusCode)',
    );
  }

  static String? obtenerArchivoUrl(
    Map<String, dynamic> aviso,
  ) {
    final valor = aviso['archivo_url'];

    if (valor == null) {
      return null;
    }

    final url = valor.toString().trim();

    if (url.isEmpty) {
      return null;
    }

    return ApiService.storageFileUrl(url);
  }

  static String? obtenerArchivoNombre(
    Map<String, dynamic> aviso,
  ) {
    final valor = aviso['archivo_nombre'];

    if (valor == null) {
      return null;
    }

    final nombre = valor.toString().trim();

    if (nombre.isEmpty) {
      return null;
    }

    return nombre;
  }

  static String? obtenerArchivoTipo(
    Map<String, dynamic> aviso,
  ) {
    final valor = aviso['archivo_tipo'];

    if (valor == null) {
      return null;
    }

    final tipo = valor.toString().trim();

    if (tipo.isEmpty) {
      return null;
    }

    return tipo;
  }

  static bool tieneArchivo(
    Map<String, dynamic> aviso,
  ) {
    final url = obtenerArchivoUrl(aviso);

    return url != null && url.isNotEmpty;
  }

  static bool esImagen(
    Map<String, dynamic> aviso,
  ) {
    final tipo = obtenerArchivoTipo(aviso);

    if (tipo != null) {
      return tipo.startsWith('image/');
    }

    final url = obtenerArchivoUrl(aviso);

    if (url == null) {
      return false;
    }

    final extension = _obtenerExtension(url);

    return [
      'jpg',
      'jpeg',
      'png',
      'gif',
      'webp',
      'bmp',
      'svg',
    ].contains(extension);
  }

  static bool esVideo(
    Map<String, dynamic> aviso,
  ) {
    final tipo = obtenerArchivoTipo(aviso);

    if (tipo != null) {
      return tipo.startsWith('video/');
    }

    final url = obtenerArchivoUrl(aviso);

    if (url == null) {
      return false;
    }

    final extension = _obtenerExtension(url);

    return [
      'mp4',
      'webm',
      'mov',
      'avi',
      'mkv',
      'm4v',
    ].contains(extension);
  }

  static bool esPdf(
    Map<String, dynamic> aviso,
  ) {
    final tipo = obtenerArchivoTipo(aviso);

    if (tipo != null) {
      return tipo == 'application/pdf';
    }

    final url = obtenerArchivoUrl(aviso);

    if (url == null) {
      return false;
    }

    return _obtenerExtension(url) == 'pdf';
  }

  static bool esDocumento(
    Map<String, dynamic> aviso,
  ) {
    final tipo = obtenerArchivoTipo(aviso);

    if (tipo != null) {
      return tipo.contains('word') ||
          tipo.contains('document') ||
          tipo.contains('msword') ||
          tipo.contains('officedocument');
    }

    final url = obtenerArchivoUrl(aviso);

    if (url == null) {
      return false;
    }

    return [
      'doc',
      'docx',
      'xls',
      'xlsx',
      'ppt',
      'pptx',
      'txt',
      'csv',
    ].contains(
      _obtenerExtension(url),
    );
  }

  static String _obtenerExtension(
    String url,
  ) {
    try {
      final uri = Uri.parse(url);
      final path = uri.path;

      if (path.isEmpty) {
        return '';
      }

      final ultimoPunto = path.lastIndexOf('.');

      if (ultimoPunto == -1) {
        return '';
      }

      return path
          .substring(ultimoPunto + 1)
          .toLowerCase();
    } catch (_) {
      return '';
    }
  }
}