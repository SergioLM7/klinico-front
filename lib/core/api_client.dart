import 'dart:io';
import 'package:dio/dio.dart';

import 'exceptions/auth_exception.dart';

class ApiClient {
  late final Dio _dio;
  final Future<String?> Function()? getToken;

  /// [onUnauthorized]: callback que se invoca cuando la API devuelve 401
  /// durante una sesión activa (token caducado en mitad del uso).
  /// Se usa desde main.dart para limpiar el estado y redirigir al Login.
  /// [dio] es opcional y se utiliza para inyectar mocks durante los tests.
  ApiClient({this.getToken, void Function()? onUnauthorized, Dio? dio}) {
    _dio =
        dio ??
        Dio(
          BaseOptions(
            baseUrl: Platform.isAndroid
                ? 'http://10.0.2.2:8080/api/v1'
                : 'http://localhost:8080/api/v1',
            connectTimeout: const Duration(seconds: 5),
            receiveTimeout: const Duration(seconds: 15),
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

  Future<Response> put(String path, {dynamic data}) async {
    try {
      final response = await _dio.put(path, data: data);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> patch(String path, {dynamic data}) async {
    try {
      final response = await _dio.patch(path, data: data);
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
    } else if (error.response?.statusCode == 500 ||
        error.response?.statusCode == 503) {
      throw AuthException(
        error.response?.statusCode == 503
            ? "Servicio temporalmente no disponible. Inténtalo más tarde o contacta con el servicio técnico."
            : "Error interno en el servidor. Inténtalo más tarde o contacta con el servicio técnico.",
      );
    } else if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.connectionError) {
      throw AuthException(
        "No se pudo conectar con el servidor. Contacta con el servicio técnico",
      );
    } else if (error.response == null) {
      throw AuthException(
        "No se recibió respuesta del servidor. Contacta con el servicio técnico",
      );
    } else {
      throw AuthException(
        "Error inesperado: ${error.message}. Contacta con el servicio técnico",
      );
    }
  }
}
