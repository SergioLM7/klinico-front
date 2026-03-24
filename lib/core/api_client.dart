import 'package:dio/dio.dart';

import 'exceptions/auth_exception.dart';

class ApiClient {
  late final Dio _dio;

  /// Configure Dio options.
  ///
  /// This method sets Dio's options to the following:
  ///
  /// - Base URL:
  /// iOS: http://localhost:8080/api/v1
  /// Android: http://10.0.2.2:8080/api/v1
  /// - Connect timeout: 5 seconds
  /// - Receive timeout: 3 seconds
  /// - Content type: application/json
  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'http://localhost:8080/api/v1',
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 3),
        contentType: 'application/json',
      ),
    );
    // 💡 Aquí es donde en el futuro añadiremos los INTERCEPTORES
    // para meter el token JWT automáticamente en la cabecera 'Authorization'
  }

  // 3. Método genérico para peticiones POST
  Future<Response> post(String path, {dynamic data}) async {
    try {
      final response = await _dio.post(path, data: data);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Never _handleError(DioException error) {
    if (error.response?.statusCode == 401) {
      throw AuthException(
        "Credenciales incorrectas. Revisa tu email o contraseña.",
      );
    } else if (error.response?.statusCode == 403) {
      throw AuthException(
        "Acceso denegado. El usuario no tiene permisos suficientes",
      );
    } else if (error.response?.statusCode == 400) {
      throw AuthException(
        "Email o contraseña con formato incorrecto. Revisa los datos enviados.",
      );
    } else if (error.response?.statusCode == 500) {
      throw AuthException("Error en el servidor. Inténtalo más tarde.");
    } else if (error.type == DioExceptionType.connectionTimeout) {
      throw AuthException(
        "El servidor no responde. Revisa tu conexión a internet",
      );
    } else {
      throw AuthException("Error inesperado: ${error.message}");
    }
  }
}
