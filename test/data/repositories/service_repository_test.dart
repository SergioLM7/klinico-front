import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klinico_front/core/api_client.dart';
import 'package:klinico_front/data/models/service_response.dart';
import 'package:klinico_front/data/repositories/service_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late ServiceRepository serviceRepository;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    serviceRepository = ServiceRepository(mockApiClient);
  });

  group('ServiceRepository - searchByName', () {
    final fakeServiceJson = {
      'serviceId': 'ser-1',
      'name': 'Traumatología',
      'active': true,
    };

    test(
      'Debe retornar una lista de Service cuando la API responde con una lista de Service',
      () async {
        when(
          () =>
              mockApiClient.get(any(), queryParams: any(named: 'queryParams')),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: [fakeServiceJson],
          ),
        );

        final services = await serviceRepository.searchByName('Traumatología');
        expect(services.length, 1);
        expect(services.first.serviceId, 'ser-1');
        expect(services.first.name, 'Traumatología');
        expect(services.first.active, true);

        verify(
          () => mockApiClient.get(
            '/services/search',
            queryParams: {'name': 'Traumatología', 'page': 0, 'size': 5},
          ),
        ).called(1);
      },
    );

    test(
      'Debe retornar una lista de Service cuando la API responde con "content"',
      () async {
        when(
          () =>
              mockApiClient.get(any(), queryParams: any(named: 'queryParams')),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: {
              'content': [fakeServiceJson],
              'totalPages': 1,
              'totalElements': 1,
              'last': true,
            },
          ),
        );

        final result = await serviceRepository.searchByName('Traumatología');
        expect(result.length, 1);
        expect(result.first, isA<ServiceResponse>());
      },
    );

    test(
      'Debe retornar una lista de Service cuando la API responde con "data"',
      () async {
        when(
          () =>
              mockApiClient.get(any(), queryParams: any(named: 'queryParams')),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: {
              'data': [fakeServiceJson],
              'totalPages': 1,
              'totalElements': 1,
              'last': true,
            },
          ),
        );

        final result = await serviceRepository.searchByName('Traumatología');
        expect(result.length, 1);
        expect(result.first, isA<ServiceResponse>());
      },
    );

    test('Debe lanzar Exception si no es Map ni List', () async {
      when(
        () => mockApiClient.get(any(), queryParams: any(named: 'queryParams')),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          data: 'fake_string',
        ),
      );

      expect(
        () => serviceRepository.searchByName('Traumatología'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains("Estructura de respuesta no soportada"),
          ),
        ),
      );
    });

    test('Debe lanzar Exception si Map no tiene data ni content', () async {
      when(
        () => mockApiClient.get(any(), queryParams: any(named: 'queryParams')),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          data: {'fake': []},
        ),
      );

      expect(
        () => serviceRepository.searchByName('Traumatología'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains("Estructura de respuesta no soportada"),
          ),
        ),
      );
    });
  });
}
