/// DTO de usuario (médico) del sistema.
///
/// Devuelto por los endpoints de gestión de usuarios y utilizado
/// en selectores de médico y listados administrativos.
class UserResponse {
  final String id;
  final String name;
  final String surname;
  final String email;
  final String role;

  UserResponse({
    required this.id,
    required this.name,
    required this.surname,
    required this.email,
    required this.role,
  });

  /// Crea una instancia a partir del JSON devuelto por el backend.
  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      id: json['id'] as String,
      name: json['name'] as String,
      surname: json['surname'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
    );
  }
}
