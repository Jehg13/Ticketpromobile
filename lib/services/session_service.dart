import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SessionService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static const String tokenKey = 'auth_token';

  static const String loginKey = 'user_login';
  static const String emailKey = 'user_email';
  static const String nameKey = 'user_name';
  static const String roleKey = 'user_role';
  static const String privAdminKey = 'user_priv_admin';
  static const String activeKey = 'user_active';
  static const String mfaKey = 'user_mfa';

  static const String empresaKey = 'user_empresa';
  static const String departamentoKey = 'user_departamento';
  static const String oficinaKey = 'user_oficina';

  static const String phoneKey = 'user_phone';
  static const String numeroEmpleadoKey = 'user_numero_empleado';
  static const String pictureKey = 'user_picture';

  static Future<void> saveSession({
    required String token,
    required Map<String, dynamic> user,
  }) async {
    await _storage.write(key: tokenKey, value: _toString(token));

    await _storage.write(key: loginKey, value: _toString(user['login']));

    await _storage.write(key: emailKey, value: _toString(user['email']));

    await _storage.write(key: nameKey, value: _toString(user['name']));

    await _storage.write(
      key: roleKey,
      value: _toString(user['role'] ?? user['rol']),
    );

    await _storage.write(
      key: privAdminKey,
      value: _toString(user['priv_admin']),
    );

    await _storage.write(key: activeKey, value: _toString(user['active']));

    await _storage.write(key: mfaKey, value: _toString(user['mfa']));

    await _storage.write(key: empresaKey, value: _toString(user['empresa']));

    await _storage.write(
      key: departamentoKey,
      value: _toString(user['departamento']),
    );

    await _storage.write(key: oficinaKey, value: _toString(user['oficina']));

    await _storage.write(
      key: phoneKey,
      value: _toString(user['phone']),
    );

    await _storage.write(
      key: numeroEmpleadoKey,
      value: _toString(user['numero_empleado']),
    );
    final picture = _toString(
      user['picture'] ?? user['foto'] ?? user['foto_perfil'],
    );
    final storedPicture = await _storage.read(key: pictureKey);
    final finalPicture = picture.isNotEmpty ? picture : (storedPicture ?? '');
    final normalizedPicture = finalPicture.toLowerCase();
    final isDefaultPicture =
        normalizedPicture.isEmpty ||
        normalizedPicture == 'user.png' ||
        normalizedPicture.endsWith('/user.png') ||
        normalizedPicture.contains('profile-photos/user.png');
    final normalizedStored = finalPicture.trim().toLowerCase();
    final hasStoredCustomPicture =
        normalizedStored.isNotEmpty &&
        normalizedStored != 'user.png' &&
        !normalizedStored.endsWith('/user.png') &&
        !normalizedStored.contains('profile-photos/user.png');

    if (!isDefaultPicture || !hasStoredCustomPicture) {
      await _storage.write(key: pictureKey, value: finalPicture);
    }
  }

  static String _toString(dynamic value) {
    if (value == null) {
      return '';
    }

    return value.toString().trim();
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: tokenKey);
  }

  static Future<String?> getLogin() async {
    return await _storage.read(key: loginKey);
  }

  static Future<String?> getEmail() async {
    return await _storage.read(key: emailKey);
  }

  static Future<String?> getName() async {
    return await _storage.read(key: nameKey);
  }

  static Future<String?> getRole() async {
    return await _storage.read(key: roleKey);
  }

  static Future<String?> getPrivAdmin() async {
    return await _storage.read(key: privAdminKey);
  }

  static Future<String?> getActive() async {
    return await _storage.read(key: activeKey);
  }

  static Future<String?> getMfa() async {
    return await _storage.read(key: mfaKey);
  }

  static Future<String?> getEmpresa() async {
    return await _storage.read(key: empresaKey);
  }

  static Future<String?> getDepartamento() async {
    return await _storage.read(key: departamentoKey);
  }

  static Future<String?> getOficina() async {
    return await _storage.read(key: oficinaKey);
  }

  static Future<String?> getPhone() async {
    return await _storage.read(key: phoneKey);
  }

  static Future<String?> getNumeroEmpleado() async {
    return await _storage.read(key: numeroEmpleadoKey);
  }

  static Future<String?> getPicture() async {
    return await _storage.read(key: pictureKey);
  }

  static Future<bool> canManageUsersAndChanges() async {
    final role = (await getRole() ?? '').trim().toLowerCase();
    final privAdmin = (await getPrivAdmin() ?? '').trim().toLowerCase();
    final hasAdminPermission =
        privAdmin == 'y' || privAdmin == 'yes' || privAdmin == 'true' ||
        privAdmin == '1';

    return role == 'gerente ti' && hasAdminPermission;
  }

  static Future<void> updatePicture(String picture) async {
    await _storage.write(key: pictureKey, value: picture.trim());
  }

  static bool isDefaultProfilePicture(String? picture) {
    final normalized = (picture ?? '').trim().toLowerCase();
    return normalized.isEmpty ||
        normalized == 'user.png' ||
        normalized.endsWith('/user.png') ||
        normalized.contains('profile-photos/user.png');
  }

  static Future<Map<String, dynamic>?> getUser() async {
    final token = await getToken();

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
    final phone = await getPhone();
    final numeroEmpleado = await getNumeroEmpleado();
    final picture = await getPicture();

    return {
      'login': login ?? '',
      'email': email ?? '',
      'name': name ?? '',
      'phone': phone ?? '',
      'role': role ?? '',
      'rol': role ?? '',
      'priv_admin': privAdmin ?? '',
      'active': active ?? '',
      'mfa': mfa ?? '',
      'empresa': empresa ?? '',
      'departamento': departamento ?? '',
      'oficina': oficina ?? '',
      'numero_empleado': numeroEmpleado ?? '',
      'picture': picture ?? '',
    };
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();

    return token != null && token.isNotEmpty;
  }

  static Future<void> clearSession() async {
    await _storage.deleteAll();
  }
}
