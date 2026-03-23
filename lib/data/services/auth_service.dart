import '../../core/api_client.dart';
import '../models/auth_response.dart';

class AuthService {

  final ApiClient _apiClient;

  AuthService(this._apiClient);

  Future<AuthResponse> login(String email, String password) async {

    try {
      final response = await _apiClient.post("/auth/login", data: {
          "email": email,
          "password": password
        });

      return AuthResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }

  }
  
}