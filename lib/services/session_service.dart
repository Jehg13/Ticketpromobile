import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SessionService {
  static const FlutterSecureStorage _storage =
      FlutterSecureStorage();

  // ============================================================
  // CLAVES DE ALMACENAMIENTO
  // ============================================================

  static const String _tokenKey = 'auth_token';

  static const String _loginKey = 'user_login';
  static const String _emailKey = 'user_email';
  static const String _nameKey = 'user_name';
  static const String _roleKey = 'user_role';
  static const String _privAdminKey = 'user_priv_admin';
  static const String _activeKey = 'user_active';
  static const String _mfaKey = 'user_mfa';

  static const String _empresaKey = 'user_empresa';
  static const String _departamentoKey = 'user_departamento';
  static const String _oficinaKey = 'user_oficina';
  static const String _ubicacionKey = 'user_ubicacion';
  static const String _numeroEmpleadoKey =
      'user_numero_empleado';
  static const String _fechaIngresoKey =
      'user_fecha_ingreso';

  // ============================================================
  // GUARDAR SESIÓN COMPLETA
  // ============================================================

  static Future<void> saveSession({
    required String token,
    required Map<String, dynamic> user,
  }) async {
    // ----------------------------------------------------------
    // TOKEN
    // ----------------------------------------------------------

    await _storage.write(
      key: _tokenKey,
      value: token,
    );

    // ----------------------------------------------------------
    // DATOS BÁSICOS
    // ----------------------------------------------------------

    await _storage.write(
      key: _loginKey,
      value: _value(user['login']),
    );

    await _storage.write(
      key: _emailKey,
      value: _value(user['email']),
    );

    await _storage.write(
      key: _nameKey,
      value: _value(user['name']),
    );

    await _storage.write(
      key: _roleKey,
      value: _value(user['role']),
    );

    await _storage.write(
      key: _privAdminKey,
      value: _value(user['priv_admin']),
    );

    await _storage.write(
      key: _activeKey,
      value: _value(user['active']),
    );

    await _storage.write(
      key: _mfaKey,
      value: _value(user['mfa']),
    );

    // ----------------------------------------------------------
    // DATOS DEL PERFIL
    // ----------------------------------------------------------

    await _storage.write(
      key: _empresaKey,
      value: _value(user['empresa']),
    );

    await _storage.write(
      key: _departamentoKey,
      value: _value(user['departamento']),
    );

    await _storage.write(
      key: _oficinaKey,
      value: _value(user['oficina']),
    );

    await _storage.write(
      key: _ubicacionKey,
      value: _value(user['ubicacion']),
    );

    await _storage.write(
      key: _numeroEmpleadoKey,
      value: _value(user['numero_empleado']),
    );

    await _storage.write(
      key: _fechaIngresoKey,
      value: _value(user['fecha_ingreso']),
    );
  }

  // ============================================================
  // CONVERTIR VALORES A STRING
  // ============================================================

  static String _value(dynamic value) {
    if (value == null) {
      return '';
    }

    return value.toString();
  }

  // ============================================================
  // TOKEN
  // ============================================================

  static Future<String?> getToken() async {
    return await _storage.read(
      key: _tokenKey,
    );
  }

  // ============================================================
  // DATOS DEL USUARIO
  // ============================================================

  static Future<String?> getLogin() async {
    return await _storage.read(
      key: _loginKey,
    );
  }

  static Future<String?> getEmail() async {
    return await _storage.read(
      key: _emailKey,
    );
  }

  static Future<String?> getName() async {
    return await _storage.read(
      key: _nameKey,
    );
  }

  static Future<String?> getRole() async {
    return await _storage.read(
      key: _roleKey,
    );
  }

  static Future<String?> getPrivAdmin() async {
    return await _storage.read(
      key: _privAdminKey,
    );
  }

  static Future<String?> getActive() async {
    return await _storage.read(
      key: _activeKey,
    );
  }

  static Future<String?> getMfa() async {
    return await _storage.read(
      key: _mfaKey,
    );
  }

  // ============================================================
  // DATOS DE EMPRESA / UBICACIÓN
  // ============================================================

  static Future<String?> getEmpresa() async {
    return await _storage.read(
      key: _empresaKey,
    );
  }

  static Future<String?> getDepartamento() async {
    return await _storage.read(
      key: _departamentoKey,
    );
  }

  static Future<String?> getOficina() async {
    return await _storage.read(
      key: _oficinaKey,
    );
  }

  static Future<String?> getUbicacion() async {
    return await _storage.read(
      key: _ubicacionKey,
    );
  }

  static Future<String?> getNumeroEmpleado() async {
    return await _storage.read(
      key: _numeroEmpleadoKey,
    );
  }

  static Future<String?> getFechaIngreso() async {
    return await _storage.read(
      key: _fechaIngresoKey,
    );
  }

  // ============================================================
  // OBTENER USUARIO COMPLETO
  // ============================================================

  static Future<Map<String, dynamic>?> getUser() async {
    final token = await getToken();

    // Si no existe token, no existe una sesión válida.
    if (token == null || token.isEmpty) {
      return null;
    }

    final login = await getLogin();
    final email = await getEmail();
    final name = await getName();
    final role = await getRole();
    final privAdmin = await getPrivAdmin();
    final active = await getActive();
    final mfa = await getMfa();

    final empresa = await getEmpresa();
    final departamento = await getDepartamento();
    final oficina = await getOficina();
    final ubicacion = await getUbicacion();
    final numeroEmpleado = await getNumeroEmpleado();
    final fechaIngreso = await getFechaIngreso();

    return {
      'login': login ?? '',
      'email': email ?? '',
      'name': name ?? '',
      'role': role ?? '',
      'priv_admin': privAdmin ?? '',
      'active': active ?? '',
      'mfa': mfa ?? '',

      'empresa': empresa ?? '',
      'departamento': departamento ?? '',
      'oficina': oficina ?? '',
      'ubicacion': ubicacion ?? '',
      'numero_empleado': numeroEmpleado ?? '',
      'fecha_ingreso': fechaIngreso ?? '',
    };
  }

  // ============================================================
  // COMPROBAR SESIÓN
  // ============================================================

  static Future<bool> isLoggedIn() async {
    final token = await getToken();

    return token != null && token.isNotEmpty;
  }

  // ============================================================
  // CERRAR SESIÓN
  // ============================================================

  static Future<void> clearSession() async {
    await _storage.deleteAll();
  }
}