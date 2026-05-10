/// DTO de respuesta del endpoint `POST /auth/login`.
///
/// Contiene el token JWT y los datos básicos del usuario autenticado
/// necesarios para inicializar la sesión en la app.
class AuthResponse {
  final String token;
  final String userId;
  final String email;
  final String name;
  final String role;
  final String? serviceId;

  AuthResponse({
    required this.token,
    required this.userId,
    required this.email,
    required this.name,
    required this.role,
    this.serviceId,
  });

  /// Crea una instancia a partir del JSON devuelto por el backend.
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String,
      userId: json['userId'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      serviceId: json['serviceId'] as String?,
    );
  }
}