/// Excepción de autenticación y autorización utilizada en toda la aplicación.
///
/// Encapsula errores HTTP relacionados con credenciales (401), permisos (403),
/// validaciones (400) y errores de servidor (500/503), proporcionando
/// mensajes legibles en español listos para mostrar al usuario.
class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}
