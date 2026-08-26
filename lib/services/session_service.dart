import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SessionService {
  static const FlutterSecureStorage _storage =
      FlutterSecureStorage();

  static const String _tokenKey = 'auth_token';
  static const String _loginKey = 'user_login';
  static const String _emailKey = 'user_email';
  static const String _nameKey = 'user_name';
  static const String _roleKey = 'user_role';
  static const String _privAdminKey = 'user_priv_admin';
  static const String _activeKey = 'user_active';
  static const String _mfaKey = 'user_mfa';

  static Future<void> saveSession({
    required String token,
    required Map<String, dynamic> user,
  }) async {
    await _storage.write(
      key: _tokenKey,
      value: token,
    );

    await _storage.write(
      key: _loginKey,
      value: user['login']?.toString() ?? '',
    );

    await _storage.write(
      key: _emailKey,
      value: user['email']?.toString() ?? '',
    );

    await _storage.write(
      key: _nameKey,
      value: user['name']?.toString() ?? '',
    );

    await _storage.write(
      key: _roleKey,
      value: user['role']?.toString() ?? '',
    );

    await _storage.write(
      key: _privAdminKey,
      value: user['priv_admin']?.toString() ?? '',
    );

    await _storage.write(
      key: _activeKey,
      value: user['active']?.toString() ?? '',
    );

    await _storage.write(
      key: _mfaKey,
      value: user['mfa']?.toString() ?? '',
    );
  }

  static Future<String?> getToken() async {
    return await _storage.read(
      key: _tokenKey,
    );
  }

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

  static Future<bool> isLoggedIn() async {
    final token = await getToken();

    return token != null && token.isNotEmpty;
  }

  static Future<void> clearSession() async {
    await _storage.deleteAll();
  }
}