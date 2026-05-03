import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klinico_front/core/api_client.dart';
import 'package:klinico_front/data/models/patient_response.dart';
import 'package:klinico_front/data/repositories/patient_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late PatientRepository patientRepository;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    patientRepository = PatientRepository(mockApiClient);
  });

  group('PatientRepository - searchBySurname', () {
    final fakePatientJson = {
      'patientId': 'pat-1',
      'name': 'John',
      'surname': 'Doe',
      'birthdate': '1991-07-20 20:18:04Z',
      'sex': 'Male',
      'address': '123 Main St',
      'contactNumber': '123456789',
      'relativeContactNumber': '123456789',
      'status': 'Active',
    };

    test(
      'Debe retornar una lista de Patient cuando la API responde con una lista de Patient',
      () async {
        when(
          () =>
              mockApiClient.get(any(), queryParams: any(named: 'queryParams')),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: [fakePatientJson],
          ),
        );

        final patients = await patientRepository.searchBySurname(
          'Doe',
          page: 0,
          size: 5,
        );
        expect(patients.length, 1);
        expect(patients.first.patientId, 'pat-1');
        expect(patients.first.name, 'John');
        expect(patients.first.surname, 'Doe');
        expect(
          patients.first.birthdate,
          DateTime.parse('1991-07-20T20:18:04Z'),
        );
        expect(patients.first.sex, 'Male');
        expect(patients.first.address, '123 Main St');
        expect(patients.first.contactNumber, '123456789');
        expect(patients.first.relativeContactNumber, '123456789');
        expect(patients.first.status, 'Active');

        verify(
          () => mockApiClient.get(
            '/patients/search',
            queryParams: {'surname': 'Doe', 'page': 0, 'size': 5},
          ),
        ).called(1);
      },
    );

    test(
      'Debe retornar una lista de Partient cuando la API responde con "content"',
      () async {
        when(
          () =>
              mockApiClient.get(any(), queryParams: any(named: 'queryParams')),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: {
              'content': [fakePatientJson],
              'totalPages': 1,
              'totalElements': 1,
              'last': true,
            },
          ),
        );

        final patients = await patientRepository.searchBySurname('Doe');
        expect(patients.length, 1);
        expect(patients.first, isA<PatientResponse>());
      },
    );

    test(
      'Debe retornar una lista de Patient cuando la API responde con "data"',
      () async {
        when(
          () =>
              mockApiClient.get(any(), queryParams: any(named: 'queryParams')),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: {
              'data': [fakePatientJson],
              'totalPages': 1,
              'totalElements': 1,
              'last': true,
            },
          ),
        );

        final patients = await patientRepository.searchBySurname('Doe');
        expect(patients.length, 1);
        expect(patients.first, isA<PatientResponse>());
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
        () => patientRepository.searchBySurname('Rodriguez'),
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
        () => patientRepository.searchBySurname('Dominguez'),
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
