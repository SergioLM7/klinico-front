import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:klinico_front/core/api_client.dart';
import 'package:klinico_front/core/exceptions/auth_exception.dart';
import 'package:klinico_front/data/repositories/user_repository.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late UserRepository repository;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    repository = UserRepository(mockApiClient);
  });

  group('UserRepository - searchBySurname', () {
    final fakeUserJson = {
      'id': 'u1',
      'name': 'Pepe',
      'surname': 'Jiménez',
      'email': 'pepe@hospital.com',
      'role': 'MEDICO',
    };

    test(
      'Debe parsear correctamente si la API devuelve una Lista directa',
      () async {
        when(
          () => mockApiClient.get(
            '/users/search',
            queryParams: any(named: 'queryParams'),
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: [fakeUserJson],
          ),
        );

        final users = await repository.searchBySurname('Jiménez');

        expect(users.length, 1);
        expect(users.first.name, 'Pepe');
        expect(users.first.surname, 'Jiménez');
      },
    );

    test(
      'Debe parsear correctamente si la API devuelve un Map con "content" (Spring Boot)',
      () async {
        when(
          () => mockApiClient.get(
            '/users/search',
            queryParams: any(named: 'queryParams'),
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: {
              'content': [fakeUserJson],
              'pageable': {},
            },
          ),
        );

        final users = await repository.searchBySurname('Jiménez');

        expect(users.length, 1);
        expect(users.first.name, 'Pepe');
      },
    );

    test(
      'Debe parsear correctamente si la API devuelve un Map con "data"',
      () async {
        when(
          () => mockApiClient.get(
            '/users/search',
            queryParams: any(named: 'queryParams'),
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: {
              'data': [fakeUserJson],
            },
          ),
        );

        final users = await repository.searchBySurname('Jiménez');

        expect(users.length, 1);
      },
    );

    test('Debe lanzar Exception si la estructura no está soportada', () async {
      when(
        () => mockApiClient.get(
          '/users/search',
          queryParams: any(named: 'queryParams'),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          data: {
            'otra_clave': [fakeUserJson],
          },
        ),
      );

      expect(
        () => repository.searchBySurname('Jiménez'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Estructura de respuesta no soportada'),
          ),
        ),
      );
    });

    test('Debe propagar el error si el ApiClient lanza uno', () async {
      when(
        () => mockApiClient.get(
          '/users/search',
          queryParams: any(named: 'queryParams'),
        ),
      ).thenThrow(AuthException('Error de conexión'));

      expect(
        () => repository.searchBySurname('Jiménez'),
        throwsA(isA<AuthException>()),
      );
    });
  });

  group('UserRepository - getServiceWorkload', () {
    final fakeWorkloadJson = {
      'name': 'Pepe',
      'surname': 'Jiménez',
      'admissionsAssigned': 5,
    };

    test(
      'Debe parsear correctamente si la API devuelve un Map con "content"',
      () async {
        when(
          () => mockApiClient.get(
            '/users/service-workload',
            queryParams: any(named: 'queryParams'),
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: {
              'content': [fakeWorkloadJson],
            },
          ),
        );

        final workloads = await repository.getServiceWorkload();

        expect(workloads.length, 1);
        expect(workloads.first.name, 'Pepe');
        expect(workloads.first.admissionsAssigned, 5);

        verify(
          () => mockApiClient.get(
            '/users/service-workload',
            queryParams: {'page': 0, 'size': 10},
          ),
        ).called(1);
      },
    );

    test('Debe propagar el error si el ApiClient lanza uno', () async {
      when(
        () => mockApiClient.get(
          '/users/service-workload',
          queryParams: any(named: 'queryParams'),
        ),
      ).thenThrow(AuthException('Error de conexión'));

      expect(
        () => repository.getServiceWorkload(),
        throwsA(isA<AuthException>()),
      );
    });

    test('Debe lanzar Exception si la estructura no está soportada', () async {
      when(
        () => mockApiClient.get(
          '/users/service-workload',
          queryParams: any(named: 'queryParams'),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          data: {
            'otra_clave': [fakeWorkloadJson],
          },
        ),
      );

      expect(
        () => repository.getServiceWorkload(),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Estructura de respuesta no soportada'),
          ),
        ),
      );
    });

    test('Debe lanzar Exception si no hay payload', () async {
      when(
        () => mockApiClient.get(
          '/users/service-workload',
          queryParams: any(named: 'queryParams'),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          data: 'fake',
        ),
      );

      expect(
        () => repository.getServiceWorkload(),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Estructura de respuesta no soportada'),
          ),
        ),
      );
    });
  });
}
