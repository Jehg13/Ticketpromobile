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
    'El servidor devolvió una respuesta no válida. '
    'Código: ${response.statusCode}',
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
      final campo = entry.key.toString();
      final value = entry.value;

      if (value is List) {
        for (final error in value) {
          mensajes.add('$campo: ${error.toString()}');
        }
      } else {
        mensajes.add('$campo: ${value.toString()}');
      }
    }

    if (mensajes.isNotEmpty) {
      mensaje = mensajes.join('\n');
    }
  }

  if (body['error'] != null &&
      body['error'].toString().trim().isNotEmpty) {

  }
}

throw Exception(mensaje);


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
    'La respuesta de avisos no tiene un formato válido.',
  );
}

final data = decoded['data'];

if (data is! Map) {
  throw Exception(
    'La respuesta no contiene la información de avisos.',
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
    'La respuesta del aviso no tiene un formato válido.',
  );
}

final data = decoded['data'];

if (data is! Map) {
  throw Exception(
    'No se encontró la información del aviso.',
  );
}

final aviso = data['aviso'];

if (aviso is! Map) {
  throw Exception(
    'El aviso recibido no tiene un formato válido.',
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
  throw Exception('No hay una sesión autenticada.');
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

if (decoded is! Map<String, dynamic>) {
  throw Exception(
    'La respuesta al crear el aviso no es válida.',
  );
}

final data = decoded['data'];

if (data is! Map) {
  throw Exception(
    'El servidor no devolvió el aviso creado.',
  );
}

final aviso = data['aviso'];

if (aviso is! Map) {
  throw Exception(
    'El aviso creado no tiene un formato válido.',
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
  throw Exception('No hay una sesión autenticada.');
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

if (decoded is! Map<String, dynamic>) {
  throw Exception(
    'La respuesta al actualizar el aviso no es válida.',
  );
}

final data = decoded['data'];

if (data is! Map) {
  throw Exception(
    'El servidor no devolvió el aviso actualizado.',
  );
}

final aviso = data['aviso'];

if (aviso is! Map) {
  throw Exception(
    'El aviso actualizado no tiene un formato válido.',
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


if (afectaA is! List || afectaA.isEmpty) {
  return;
}

for (int i = 0; i < afectaA.length; i++) {
  final valor = afectaA[i];

  if (valor == null) {
    continue;
  }

  final texto = valor.toString().trim();

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
