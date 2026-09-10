import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../api_service.dart';
import '../session_service.dart';

class AvisosAdminService {
static String get baseUrl => '${ApiService.serverUrl}/api';

static Future<Map<String, String>> _headers() async {
final token = await SessionService.getToken();


if (token == null || token.isEmpty) {
  throw Exception('No hay una sesiÃ³n autenticada.');
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

if (body is Map<String, dynamic>) {
  final parts = <String>[];

  for (final key in const ['message', 'error', 'exception']) {
    final value = body[key];
    if (value != null) {
      final text = ApiService.sanitizeUserFacingMessage(
        value,
        fallback: '',
      ).trim();
      if (text.isNotEmpty) {
        parts.add(text);
      }
    }
  }

  if (body['errors'] is Map) {
    final errors = body['errors'] as Map;

    for (final entry in errors.entries) {
      final campo = entry.key.toString();
      final value = entry.value;

      if (value is List) {
        for (final error in value) {
          final text = ApiService.sanitizeUserFacingMessage(
            error,
            fallback: '',
          ).trim();
          if (text.isNotEmpty) {
            parts.add('$campo: $text');
          }
        }
      } else {
        final text = ApiService.sanitizeUserFacingMessage(
          value,
          fallback: '',
        ).trim();
        if (text.isNotEmpty) {
          parts.add('$campo: $text');
        }
      }
    }
  }

  if (parts.isNotEmpty) {
    throw Exception(parts.join('\n\n'));
  }
}

throw Exception(
  'Ocurrió un error en el servidor. Código: ${response.statusCode}',
);
}

static String _errorFromResponse(http.Response response, dynamic decoded) {
if (decoded is Map<String, dynamic>) {
  final parts = <String>[];

  for (final key in const ['message', 'error', 'exception']) {
    final value = decoded[key];
    if (value != null) {
      final text = ApiService.sanitizeUserFacingMessage(
        value,
        fallback: '',
      ).trim();
      if (text.isNotEmpty) {
        parts.add(text);
      }
    }
  }

  if (decoded['errors'] is Map) {
    final errors = decoded['errors'] as Map;
    for (final entry in errors.entries) {
      final field = entry.key.toString();
      final value = entry.value;
      if (value is List) {
        for (final error in value) {
          final text = ApiService.sanitizeUserFacingMessage(
            error,
            fallback: '',
          ).trim();
          if (text.isNotEmpty) {
            parts.add('$field: $text');
          }
        }
      } else {
        final text = ApiService.sanitizeUserFacingMessage(
          value,
          fallback: '',
        ).trim();
        if (text.isNotEmpty) {
          parts.add('$field: $text');
        }
      }
    }
  }

  if (parts.isNotEmpty) {
    return parts.join('\n\n');
  }
}

final body = response.body.trim();
if (body.isNotEmpty) {
  return ApiService.sanitizeUserFacingMessage(
    body,
    fallback: 'La solicitud falló.',
  );
}

return 'La solicitud fallÃ³ con cÃ³digo ${response.statusCode}.';
}

static Future<Map<String, dynamic>> obtenerDatos() async {
final headers = await _headers();


final response = await http.get(
  Uri.parse('$baseUrl/admin/avisos'),
  headers: headers,
);

final decoded = _decodeResponse(response);

if (decoded is! Map<String, dynamic>) {
  throw Exception(
    'La respuesta de avisos no tiene un formato vÃ¡lido.',
  );
}

final data = decoded['data'];

if (data is! Map) {
  throw Exception(
    'La respuesta no contiene la informaciÃ³n de avisos.',
  );
}

return Map<String, dynamic>.from(data);


}

static Future<List<Map<String, dynamic>>> obtenerAvisos() async {
final data = await obtenerDatos();


final avisosData = data['avisos'];

if (avisosData is! List) {
  return [];
}

return avisosData
    .whereType<Map>()
    .map(
      (item) => Map<String, dynamic>.from(item),
    )
    .toList();


}

static Future<List<Map<String, dynamic>>> obtenerDepartamentos() async {
final data = await obtenerDatos();


final lista = data['departamentos'];

if (lista is! List) {
  return [];
}

return lista
    .whereType<Map>()
    .map(
      (item) => Map<String, dynamic>.from(item),
    )
    .toList();


}

static Future<List<Map<String, dynamic>>> obtenerOficinas() async {
final data = await obtenerDatos();


final lista = data['oficinas'];

if (lista is! List) {
  return [];
}

return lista
    .whereType<Map>()
    .map(
      (item) => Map<String, dynamic>.from(item),
    )
    .toList();


}

static Future<List<Map<String, dynamic>>> obtenerUsuarios() async {
final data = await obtenerDatos();


final lista = data['usuarios'];

if (lista is! List) {
  return [];
}

return lista
    .whereType<Map>()
    .map(
      (item) => Map<String, dynamic>.from(item),
    )
    .toList();


}

static Future<List<Map<String, dynamic>>> obtenerNotificaciones() async {
final data = await obtenerDatos();


final lista = data['notificaciones'];

if (lista is! List) {
  return [];
}

return lista
    .whereType<Map>()
    .map(
      (item) => Map<String, dynamic>.from(item),
    )
    .toList();


}

static Future<int> obtenerNotificacionesNoLeidas() async {
final data = await obtenerDatos();


final cantidad = data['notificaciones_no_leidas'];

if (cantidad is int) {
  return cantidad;
}

return int.tryParse(cantidad?.toString() ?? '') ?? 0;


}

static Future<bool> marcarNotificacionComoLeida(dynamic id) async {
final token = await SessionService.getToken();

if (token == null || token.isEmpty) {
  return false;
}

final notificationId = int.tryParse(id?.toString() ?? '');
if (notificationId == null) {
  return false;
}

final response = await http.patch(
  Uri.parse('${ApiService.baseUrl}/mis-tickets-notificaciones/$notificationId/leida'),
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
}

static Future<bool> marcarTodasNotificacionesLeidas() async {
final token = await SessionService.getToken();

if (token == null || token.isEmpty) {
  return false;
}

final response = await http.patch(
  Uri.parse('${ApiService.baseUrl}/mis-tickets-notificaciones-leer-todas'),
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
}

static Future<Map<String, dynamic>> obtenerAviso(int id) async {
final headers = await _headers();


final response = await http.get(
  Uri.parse('$baseUrl/admin/avisos/$id'),
  headers: headers,
);

final decoded = _decodeResponse(response);

if (decoded is! Map<String, dynamic>) {
  throw Exception(
    'La respuesta del aviso no tiene un formato vÃ¡lido.',
  );
}

final data = decoded['data'];

if (data is! Map) {
  throw Exception(
    'No se encontrÃ³ la informaciÃ³n del aviso.',
  );
}

final aviso = data['aviso'];

if (aviso is! Map) {
  throw Exception(
    'El aviso recibido no tiene un formato vÃ¡lido.',
  );
}

return Map<String, dynamic>.from(aviso);


}

static Future<Map<String, dynamic>> crearAviso({
required String titulo,
required String tipo,
required String importancia,
required String fechaInicio,
required String horaInicio,
required String aplicaA,
required dynamic afectaA,
required String descripcion,
required bool mostrarNotificaciones,
required bool fijado,
dynamic archivo,
}) async {
final token = await SessionService.getToken();


if (token == null || token.isEmpty) {
  throw Exception('No hay una sesiÃ³n autenticada.');
}

final request = http.MultipartRequest(
  'POST',
  Uri.parse('$baseUrl/admin/avisos'),
);

request.headers.addAll({
  'Accept': 'application/json',
  'Authorization': 'Bearer $token',
});

request.fields['titulo'] = titulo.trim();
request.fields['tipo'] = tipo.trim().toLowerCase();
request.fields['importancia'] = importancia.trim().toLowerCase();
request.fields['fecha_inicio'] = fechaInicio.trim();
request.fields['hora_inicio'] = horaInicio.trim();
request.fields['aplica_a'] = aplicaA.trim().toLowerCase();
request.fields['descripcion'] = descripcion.trim();
request.fields['mostrar_notificaciones'] =
    mostrarNotificaciones ? '1' : '0';
request.fields['fijado'] = fijado ? '1' : '0';
request.fields['estado'] = 'activo';

_agregarAfectados(
  request,
  aplicaA.trim().toLowerCase(),
  afectaA,
);

await _agregarArchivo(request, archivo);








final streamedResponse = await request.send();

final response = await http.Response.fromStream(
  streamedResponse,
);

final decoded = _decodeResponse(response);

if (response.statusCode < 200 || response.statusCode >= 300) {
  throw Exception(_errorFromResponse(response, decoded));
}

if (decoded is! Map<String, dynamic>) {
  throw Exception(
    'La respuesta al crear el aviso no es vÃ¡lida.',
  );
}

final data = decoded['data'];

if (data is! Map) {
  throw Exception(
    'El servidor no devolviÃ³ el aviso creado.',
  );
}

final aviso = data['aviso'];

if (aviso is! Map) {
  throw Exception(
    'El aviso creado no tiene un formato vÃ¡lido.',
  );
}

return Map<String, dynamic>.from(aviso);


}

static Future<Map<String, dynamic>> actualizarAviso({
required int id,
required String titulo,
required String tipo,
required String importancia,
required String fechaInicio,
required String horaInicio,
required String aplicaA,
required dynamic afectaA,
required String descripcion,
required bool mostrarNotificaciones,
required bool fijado,
required String estado,
dynamic archivo,
}) async {
final token = await SessionService.getToken();


if (token == null || token.isEmpty) {
  throw Exception('No hay una sesiÃ³n autenticada.');
}

final request = http.MultipartRequest(
  'POST',
  Uri.parse('$baseUrl/admin/avisos/$id'),
);

request.headers.addAll({
  'Accept': 'application/json',
  'Authorization': 'Bearer $token',
});

request.fields['_method'] = 'PUT';
request.fields['titulo'] = titulo.trim();
request.fields['tipo'] = tipo.trim().toLowerCase();
request.fields['importancia'] = importancia.trim().toLowerCase();
request.fields['fecha_inicio'] = fechaInicio.trim();
request.fields['hora_inicio'] = horaInicio.trim();
request.fields['aplica_a'] = aplicaA.trim().toLowerCase();
request.fields['descripcion'] = descripcion.trim();
request.fields['mostrar_notificaciones'] =
    mostrarNotificaciones ? '1' : '0';
request.fields['fijado'] = fijado ? '1' : '0';
request.fields['estado'] = estado.trim().toLowerCase();

_agregarAfectados(
  request,
  aplicaA.trim().toLowerCase(),
  afectaA,
);

await _agregarArchivo(request, archivo);








final streamedResponse = await request.send();

final response = await http.Response.fromStream(
  streamedResponse,
);

final decoded = _decodeResponse(response);

if (response.statusCode < 200 || response.statusCode >= 300) {
  throw Exception(_errorFromResponse(response, decoded));
}

if (decoded is! Map<String, dynamic>) {
  throw Exception(
    'La respuesta al actualizar el aviso no es vÃ¡lida.',
  );
}

final data = decoded['data'];

if (data is! Map) {
  throw Exception(
    'El servidor no devolviÃ³ el aviso actualizado.',
  );
}

final aviso = data['aviso'];

if (aviso is! Map) {
  throw Exception(
    'El aviso actualizado no tiene un formato vÃ¡lido.',
  );
}

return Map<String, dynamic>.from(aviso);


}

static Future<String> eliminarAviso(int id) async {
final headers = await _headers();


final response = await http.delete(
  Uri.parse('$baseUrl/admin/avisos/$id'),
  headers: headers,
);

final decoded = _decodeResponse(response);

if (response.statusCode < 200 || response.statusCode >= 300) {
  throw Exception(_errorFromResponse(response, decoded));
}

if (decoded is Map<String, dynamic>) {
  return decoded['message']?.toString() ??
      'Aviso eliminado correctamente.';
}

return 'Aviso eliminado correctamente.';


}

static Future<void> _agregarArchivo(
http.MultipartRequest request,
dynamic archivo,
) async {
if (archivo == null) return;

if (archivo is File) {
  final path = archivo.path;
  if (path.isEmpty) return;
  request.files.add(
    await http.MultipartFile.fromPath(
      'archivo',
      path,
      filename: path.split(RegExp(r'[\\/]')).last,
    ),
  );
  return;
}

if (archivo is PlatformFile) {
  final path = archivo.path;
  if (path != null && path.isNotEmpty) {
    request.files.add(
      await http.MultipartFile.fromPath(
        'archivo',
        path,
        filename: archivo.name,
      ),
    );
    return;
  }

  final bytes = await archivo.readAsBytes();
  if (bytes.isNotEmpty) {
    request.files.add(
      http.MultipartFile.fromBytes(
        'archivo',
        bytes,
        filename: archivo.name,
      ),
    );
  }
}
}

static void _agregarAfectados(
http.MultipartRequest request,
String aplicaA,
dynamic afectaA,
) {
if (aplicaA == 'todos') {
return;
}

final valores = <dynamic>[];

if (afectaA is List) {
  valores.addAll(afectaA);
} else if (afectaA is Map) {
  final ids = afectaA['ids'];
  final logins = afectaA['logins'];
  if (ids is List) {
    valores.addAll(ids);
  } else if (logins is List) {
    valores.addAll(logins);
  }
}

if (valores.isEmpty) {
  return;
}

for (int i = 0; i < valores.length; i++) {
  final valor = valores[i];

  final texto = valor?.toString().trim() ?? '';

  if (texto.isEmpty) {
    continue;
  }

  request.fields['afecta_a[$i]'] = texto;
}


}

static String formatearFecha(DateTime fecha) {
final year = fecha.year.toString().padLeft(4, '0');
final month = fecha.month.toString().padLeft(2, '0');
final day = fecha.day.toString().padLeft(2, '0');


return '$year-$month-$day';


}

static String formatearHora(TimeOfDay hora) {
final hour = hora.hour.toString().padLeft(2, '0');
final minute = hora.minute.toString().padLeft(2, '0');


return '$hour:$minute';


}
}
