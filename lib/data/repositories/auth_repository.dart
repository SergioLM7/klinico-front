import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:klinico_front/data/models/auth_response.dart';
import '../../data/services/auth_service.dart';

class AuthRepository {
  final AuthService _authService;
  final FlutterSecureStorage _storage;

  static const String _keyToken = 'token';
  static const String _keyRole = 'role';

  AuthRepository({
    required AuthService authService,
    required FlutterSecureStorage storage,
  }) : _authService = authService,
       _storage = storage;

  Future<AuthResponse> signIn(String email, String password) async {
    try {
      final response = await _authService.login(email, password);

      await _storage.write(key: _keyToken, value: response.token);
      await _storage.write(key: _keyRole, value: response.role);

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> getToken() async => await _storage.read(key: _keyToken);

  Future<String?> getRole() async => await _storage.read(key: _keyRole);

  Future<void> logout() async => await _storage.deleteAll();
}
