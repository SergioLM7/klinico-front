import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:klinico_front/core/api_client.dart';
import 'package:klinico_front/core/exceptions/auth_exception.dart';
import 'package:klinico_front/data/repositories/episode_repository.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late EpisodeRepository repository;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    repository = EpisodeRepository(mockApiClient);
  });

  group('EpisodeRepository - getEpisodesByAdmission', () {
    final fakeEpisodeJson = {
      'episodeId': 'epi-1',
      'admissionId': 'adm-1',
      'doctorId': 'doc-1',
      'clinicalProgress': 'Evolución estable',
      'diagnosis': 'Gripe',
      'createdAt': '2023-10-25T10:00:00',
      'createdBy': 'doc-1',
    };

    test('Debe parsear una lista directa', () async {
      when(
        () => mockApiClient.get(any(), queryParams: any(named: 'queryParams')),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          data: [fakeEpisodeJson],
        ),
      );

      final episodes = await repository.getEpisodesByAdmission(
        admissionId: 'adm-1',
      );

      expect(episodes.length, 1);
      expect(episodes.first.episodeId, 'epi-1');
    });

    test('Debe parsear un paginable con "content"', () async {
      when(
        () => mockApiClient.get(any(), queryParams: any(named: 'queryParams')),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          data: {
            'content': [fakeEpisodeJson],
          },
        ),
      );

      final episodes = await repository.getEpisodesByAdmission(
        admissionId: 'adm-1',
      );

      expect(episodes.length, 1);
    });

    test('Debe parsear un paginable con "data"', () async {
      when(
        () => mockApiClient.get(any(), queryParams: any(named: 'queryParams')),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          data: {
            'data': [fakeEpisodeJson],
          },
        ),
      );

      final episodes = await repository.getEpisodesByAdmission(
        admissionId: 'adm-1',
      );

      expect(episodes.length, 1);
    });

    test('Debe propagar error de ApiClient', () async {
      when(
        () => mockApiClient.get(any(), queryParams: any(named: 'queryParams')),
      ).thenThrow(AuthException('No hay conexión'));

      expect(
        () => repository.getEpisodesByAdmission(admissionId: 'adm-1'),
        throwsA(isA<AuthException>()),
      );
    });

    test('Debe lanzar Exception si no hay payload', () async {
      when(
        () => mockApiClient.get(any(), queryParams: any(named: 'queryParams')),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          data: 'fake',
        ),
      );

      expect(
        () => repository.getEpisodesByAdmission(admissionId: 'adm-1'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Estructura de respuesta no soportada'),
          ),
        ),
      );
    });

    test(
      'Debe lanzar Exception si el payload no contiene data o content',
      () async {
        when(
          () =>
              mockApiClient.get(any(), queryParams: any(named: 'queryParams')),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: {
              'fakeContent': [fakeEpisodeJson],
            },
          ),
        );

        expect(
          () => repository.getEpisodesByAdmission(admissionId: 'adm-1'),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Estructura de respuesta no soportada'),
            ),
          ),
        );
      },
    );
  });

  group('EpisodeRepository - createEpisode', () {
    test('Debe enviar los parámetros correctos en el body', () async {
      when(
        () => mockApiClient.post(any(), data: any(named: 'data')),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          data: {'success': true, 'episodeId': 'nuevo-epi'},
        ),
      );

      final result = await repository.createEpisode(
        admissionId: 'adm-1',
        doctorId: 'doc-1',
        clinicalProgress: 'Nueva evaluación',
        diagnosis: 'Asma',
        camScore: true,
      );

      expect(result['success'], true);
      expect(result['episodeId'], 'nuevo-epi');

      verify(
        () => mockApiClient.post(
          "/episodes/create",
          data: {
            "admissionId": 'adm-1',
            "doctorId": 'doc-1',
            "clinicalProgress": 'Nueva evaluación',
            "diagnosis": 'Asma',
            "bradenScore": null, // porque no lo pasamos
            "chads2Score": null,
            "camScore": true,
          },
        ),
      ).called(1);
    });

    test('Debe propagar error de ApiClient', () async {
      when(
        () => mockApiClient.post(any(), data: any(named: 'data')),
      ).thenThrow(AuthException('No hay conexión'));

      expect(
        () => repository.createEpisode(
          admissionId: 'adm-1',
          doctorId: 'doc-1',
          clinicalProgress: 'Nueva evaluación',
          diagnosis: 'Asma',
          camScore: true,
        ),
        throwsA(isA<AuthException>()),
      );
    });

    test(
      'Debe lanzar Exception de error inesperado si el payload es otro string',
      () async {
        when(
          () => mockApiClient.post(any(), data: any(named: 'data')),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: {'success': false},
          ),
        );

        final result = await repository.createEpisode(
          admissionId: 'adm-1',
          doctorId: 'doc-1',
          clinicalProgress: 'Nueva evaluación',
          diagnosis: 'Asma',
          camScore: true,
        );

        expect(result['success'], false);

        verify(
          () => mockApiClient.post(
            "/episodes/create",
            data: {
              "admissionId": 'adm-1',
              "doctorId": 'doc-1',
              "clinicalProgress": 'Nueva evaluación',
              "diagnosis": 'Asma',
              "bradenScore": null, // porque no lo pasamos
              "chads2Score": null,
              "camScore": true,
            },
          ),
        ).called(1);
      },
    );
  });

  group('EpisodeRepository - updateEpisode', () {
    test('Debe usar el verbo PUT y pasar el episodeId en la URL', () async {
      when(() => mockApiClient.put(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          data: {'updated': true},
        ),
      );

      final result = await repository.updateEpisode(
        episodeId: 'epi-1',
        clinicalProgress: 'Mejorando',
        diagnosis: 'Asma leve',
      );

      expect(result['updated'], true);

      verify(
        () => mockApiClient.put(
          "/episodes/update/epi-1",
          data: {
            "clinicalProgress": 'Mejorando',
            "diagnosis": 'Asma leve',
            "bradenScore": null,
            "chads2Score": null,
            "camScore": null,
          },
        ),
      ).called(1);
    });

    test('Debe propagar error de ApiClient', () async {
      when(
        () => mockApiClient.put(any(), data: any(named: 'data')),
      ).thenThrow(AuthException('No hay conexión'));

      expect(
        () => repository.updateEpisode(
          episodeId: 'epi-1',
          clinicalProgress: 'Mejorando',
          diagnosis: 'Asma leve',
        ),
        throwsA(isA<AuthException>()),
      );
    });
  });
}
