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
