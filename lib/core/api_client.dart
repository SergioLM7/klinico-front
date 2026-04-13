import 'package:dio/dio.dart';

import 'exceptions/auth_exception.dart';

class ApiClient {
  late final Dio _dio;
  final Future<String?> Function()? getToken;

  /// [onUnauthorized]: callback que se invoca cuando la API devuelve 401
  /// durante una sesión activa (token caducado en mitad del uso).
  /// Se usa desde main.dart para limpiar el estado y redirigir al Login.
  ApiClient({this.getToken, void Function()? onUnauthorized}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'http://localhost:8080/api/v1',
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 3),
        contentType: 'application/json',
      ),
    );

    // Capa 2: interceptor de sesión — captura 401 durante el uso de la app
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (getToken != null) {
            final token = await getToken!();
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          handler.next(options);
        },
        onError: (DioException error, ErrorInterceptorHandler handler) {
          // Solo interceptamos el 401 si hay sesión activa (token caducado).
          // Si no hay callback, dejamos pasar el error para que _handleError
          // lo procese con el mensaje correcto (ej.: credenciales incorrectas).
          if (error.response?.statusCode == 401 &&
              onUnauthorized != null &&
              !(error.requestOptions.path.contains('/auth/login'))) {
            onUnauthorized();
          }
          handler.next(error);
        },
      ),
    );
  }

  Future<Response> post(String path, {dynamic data}) async {
    try {
      final response = await _dio.post(path, data: data);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParams}) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParams);
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
        error.response?.data['message'] ??
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
