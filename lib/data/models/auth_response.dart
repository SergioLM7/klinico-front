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