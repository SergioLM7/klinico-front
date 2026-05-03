import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:klinico_front/core/api_client.dart';
import 'package:klinico_front/core/exceptions/auth_exception.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late ApiClient apiClient;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();

    when(() => mockDio.interceptors).thenReturn(Interceptors());

    apiClient = ApiClient(dio: mockDio);
  });

  final baseRequestOptions = RequestOptions(path: '/test');

  group('ApiClient - Control de Errores', () {
    test('Debe devolver el Response si la llamada es exitosa', () async {
      final fakeResponse = Response(
        requestOptions: baseRequestOptions,
        data: {'success': true},
        statusCode: 200,
      );
      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenAnswer((_) async => fakeResponse);

      final result = await apiClient.get('/test');

      expect(result.statusCode, 200);
      expect(result.data['success'], true);
    });

    test(
      'Debe lanzar AuthException de credenciales incorrectas si el servidor devuelve 401',
      () async {
        final dioException = DioException(
          requestOptions: baseRequestOptions,
          response: Response(
            requestOptions: baseRequestOptions,
            statusCode: 401,
          ),
          type: DioExceptionType.badResponse,
        );

        when(() => mockDio.get(any())).thenThrow(dioException);

        expect(
          () => apiClient.get('/test'),
          throwsA(
            isA<AuthException>().having(
              (e) => e.message,
              'message',
              contains('Credenciales incorrectas'),
            ),
          ),
        );
      },
    );

    test(
      'Debe lanzar AuthException con mensaje de error interno del servidor si el servidor devuelve 500',
      () async {
        final dioException = DioException(
          requestOptions: baseRequestOptions,
          response: Response(
            requestOptions: baseRequestOptions,
            statusCode: 500,
            data: {'message': 'Internal server error'},
          ),
          type: DioExceptionType.badResponse,
        );

        when(() => mockDio.get(any())).thenThrow(dioException);

        expect(
          () => apiClient.get('/test'),
          throwsA(
            isA<AuthException>().having(
              (e) => e.message,
              'message',
              contains(
                'Error interno en el servidor. Inténtalo más tarde o contacta con el servicio técnico.',
              ),
            ),
          ),
        );
      },
    );

    test(
      'Debe lanzar AuthException de timeout genérico si hay un ConnectionTimeout',
      () async {
        final dioException = DioException(
          requestOptions: baseRequestOptions,
          type: DioExceptionType.connectionTimeout,
        );

        when(() => mockDio.get(any())).thenThrow(dioException);

        expect(
          () => apiClient.get('/test'),
          throwsA(
            isA<AuthException>().having(
              (e) => e.message,
              'message',
              contains('No se pudo conectar con el servidor'),
            ),
          ),
        );
      },
    );

    test(
      'Debe lanzar AuthException de servicio temporalmente no disponible si devuelve 503',
      () async {
        final dioException = DioException(
          requestOptions: baseRequestOptions,
          response: Response(
            requestOptions: baseRequestOptions,
            statusCode: 503,
            data: {'message': 'Server overload'},
          ),
          type: DioExceptionType.badResponse,
        );

        when(() => mockDio.get(any())).thenThrow(dioException);

        expect(
          () => apiClient.get('/test'),
          throwsA(
            isA<AuthException>().having(
              (e) => e.message,
              'message',
              contains('Servicio temporalmente no disponible'),
            ),
          ),
        );
      },
    );

    test(
      'Debe lanzar AuthException de acceso denegado si el servidor devuelve 403',
      () async {
        final dioException = DioException(
          requestOptions: baseRequestOptions,
          response: Response(
            requestOptions: baseRequestOptions,
            statusCode: 403,
            data: {'message': 'Forbidden'},
          ),
          type: DioExceptionType.badResponse,
        );

        when(() => mockDio.get(any())).thenThrow(dioException);

        expect(
          () => apiClient.get('/test'),
          throwsA(
            isA<AuthException>().having(
              (e) => e.message,
              'message',
              contains('Acceso denegado'),
            ),
          ),
        );
      },
    );

    test('Debe lanzar AuthException con mensaje específico de 400', () async {
      final dioException = DioException(
        requestOptions: baseRequestOptions,
        response: Response(
          requestOptions: baseRequestOptions,
          statusCode: 400,
          data: {'message': 'Los datos enviados no son válidos'},
        ),
        type: DioExceptionType.badResponse,
      );

      when(
        () => mockDio.post(any(), data: any(named: 'data')),
      ).thenThrow(dioException);

      expect(
        () => apiClient.post('/test'),
        throwsA(
          isA<AuthException>().having(
            (e) => e.message,
            'message',
            'Los datos enviados no son válidos',
          ),
        ),
      );
    });

    test(
      'Debe lanzar AuthException con mensaje específico de 400 con put',
      () async {
        final dioException = DioException(
          requestOptions: baseRequestOptions,
          response: Response(
            requestOptions: baseRequestOptions,
            statusCode: 400,
            data: {'message': 'Los datos enviados no son válidos'},
          ),
          type: DioExceptionType.badResponse,
        );

        when(
          () => mockDio.put(any(), data: any(named: 'data')),
        ).thenThrow(dioException);

        expect(
          () => apiClient.put('/test'),
          throwsA(
            isA<AuthException>().having(
              (e) => e.message,
              'message',
              'Los datos enviados no son válidos',
            ),
          ),
        );
      },
    );

    test(
      'Debe lanzar AuthException con mensaje específico de 400 con patch',
      () async {
        final dioException = DioException(
          requestOptions: baseRequestOptions,
          response: Response(
            requestOptions: baseRequestOptions,
            statusCode: 400,
            data: {'message': 'Los datos enviados no son válidos'},
          ),
          type: DioExceptionType.badResponse,
        );

        when(
          () => mockDio.patch(any(), data: any(named: 'data')),
        ).thenThrow(dioException);

        expect(
          () => apiClient.patch('/test'),
          throwsA(
            isA<AuthException>().having(
              (e) => e.message,
              'message',
              'Los datos enviados no son válidos',
            ),
          ),
        );
      },
    );

    test(
      'Debe lanzar AuthException con error inesperado si devuelve 404',
      () async {
        final dioException = DioException(
          requestOptions: baseRequestOptions,
          response: Response(
            requestOptions: baseRequestOptions,
            statusCode: 404,
          ),
          type: DioExceptionType.badResponse,
        );

        when(() => mockDio.get(any())).thenThrow(dioException);

        expect(
          () => apiClient.get('/test'),
          throwsA(
            isA<AuthException>().having(
              (e) => e.message,
              'message',
              contains('Error inesperado:'),
            ),
          ),
        );
      },
    );

    test('Debe lanzar AuthException si la response es null', () async {
      final dioException = DioException(
        requestOptions: baseRequestOptions,
        response: null,
        type: DioExceptionType.unknown,
      );

      when(() => mockDio.get(any())).thenThrow(dioException);

      expect(
        () => apiClient.get('/test'),
        throwsA(
          isA<AuthException>().having(
            (e) => e.message,
            'message',
            contains('No se recibió respuesta del servidor'),
          ),
        ),
      );
    });
  });
}
