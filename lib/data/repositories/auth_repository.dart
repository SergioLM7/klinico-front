import '../../core/api_client.dart';
import '../models/auth_response.dart';

/// Repositorio de autenticación.
///
/// Gestiona la comunicación con el endpoint REST de login
/// y devuelve la respuesta tipada [AuthResponse] con el JWT y los datos del usuario.
class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository(this._apiClient);

  /// Autentica al usuario contra `POST /auth/login`.
  ///
  /// Lanza una excepción si las credenciales son incorrectas o el servidor no responde.
  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await _apiClient.post(
        "/auth/login",
        data: {"email": email, "password": password},
      );

      return AuthResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
