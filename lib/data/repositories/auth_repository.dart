import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:klinico_front/data/models/auth_response.dart';
import '../../data/services/auth_service.dart';

class AuthRepository {
  final AuthService _authService;
  final FlutterSecureStorage _storage;

  static const String _keyToken = 'token';

  AuthRepository({
    required AuthService authService,
    required FlutterSecureStorage storage,
  }) : _authService = authService,
       _storage = storage;

  Future<AuthResponse> signIn(String email, String password) async {
    try {
      final response = await _authService.login(email, password);
      // Solo guardamos el token: el rol y demás claims ya van dentro del JWT
      await _storage.write(key: _keyToken, value: response.token);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> getToken() async => await _storage.read(key: _keyToken);

  Future<void> logout() async => await _storage.deleteAll();

  // ---------------------------------------------------------------------------
  // Decodificación del JWT (sin llamada a red)
  // ---------------------------------------------------------------------------

  /// Decodifica el payload del JWT y devuelve los claims como [Map].
  /// Devuelve [null] si el token es nulo, tiene formato incorrecto o falla.
  Future<Map<String, dynamic>?> _decodePayload() async {
    final token = await getToken();
    if (token == null) return null;

    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      String payload = parts[1];
      // Base64 requiere longitud múltiplo de 4
      switch (payload.length % 4) {
        case 2:
          payload += '==';
          break;
        case 3:
          payload += '=';
          break;
      }

      final decoded = utf8.decode(base64Url.decode(payload));
      return jsonDecode(decoded) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// Comprueba si el token en storage existe y no ha caducado.
  /// No realiza ninguna llamada a la API.
  Future<bool> isTokenValid() async {
    final claims = await _decodePayload();
    if (claims == null) return false;

    final exp = claims['exp'] as int?;
    if (exp == null) return false;

    final expiry = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
    return DateTime.now().isBefore(expiry);
  }

  /// Inicializa la sesión al arrancar la app:
  /// - Si el token no existe o ha caducado → limpia el storage → devuelve null.
  /// - Si es válido → devuelve los claims del JWT para que el ViewModel
  ///   pueda extraer rol, apellido, serviceId, etc. directamente del token.
  ///
  /// Claims del JWT generados por Spring Boot:
  ///   sub       → userId  (String)
  ///   role      → nombre del rol (MEDICO, JEFESERVICIO…)
  ///   surname   → apellido del usuario
  ///   serviceId → id del servicio asignado
  ///   exp       → expiración (Unix timestamp en segundos)
  Future<Map<String, dynamic>?> initializeSession() async {
    final claims = await _decodePayload();
    if (claims == null) {
      await logout();
      return null;
    }

    final exp = claims['exp'] as int?;
    if (exp == null) {
      await logout();
      return null;
    }

    final expiry = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
    if (DateTime.now().isAfter(expiry)) {
      await logout();
      return null;
    }

    return claims;
  }
}
