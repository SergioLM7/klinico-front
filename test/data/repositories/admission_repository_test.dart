import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klinico_front/core/api_client.dart';
import 'package:klinico_front/core/exceptions/auth_exception.dart';
import 'package:klinico_front/data/models/admission_response.dart';
import 'package:klinico_front/data/repositories/admission_repository.dart';
import 'package:klinico_front/data/models/patient_preview_response.dart';
import 'package:mocktail/mocktail.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late AdmissionRepository admissionRepository;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    admissionRepository = AdmissionRepository(mockApiClient);
  });

  final fakePatientJson = {
    'patientId': 'pat-1',
    'name': 'Sergio',
    'surname': 'Garcia',
    'birthdate': '2003-05-05',
    'sex': 'MALE',
  };

  final fakePatientPreview = PatientPreviewResponse.fromJson(fakePatientJson);

  final fakeAdmissionJson = {
    'admissionId': 'adm-1',
    'patient': fakePatientJson,
    'serviceId': 'ser-1',
    'assignedDoctorId': 'doc-1',
    'dischargeDate': null,
    'hospitalizationLength': null,
    'principalDiagnosis': 'Dx',
    'medicalHistory': 'Hx',
    'allergies': 'Allergies',
    'chronicTreatment': 'Tx',
    'basalBarthel': 100,
    'roomNumber': null,
    'createdAt': '2023-10-25T10:00:00',
    'createdBy': 'user-1',
    'lastModifiedAt': null,
    'lastModifiedBy': null,
  };

  final fakeAdmissionUpdateJson = {
    'admissionId': 'adm-1',
    'serviceId': 'ser-1',
    'assignedDoctorId': 'doc-1',
    'dischargeDate': null,
    'hospitalizationLength': null,
    'principalDiagnosis': 'Dx',
    'medicalHistory': 'Hx',
    'allergies': 'Allergies',
    'chronicTreatment': 'Tx',
    'basalBarthel': 100,
    'roomNumber': null,
    'createdAt': '2023-10-25T10:00:00',
    'createdBy': 'user-1',
    'lastModifiedAt': null,
    'lastModifiedBy': null,
  };

  group('AdmissionRepository - getMyAdmissions', () {
    test('Debe retornar lista de Admission cuando payload es List', () async {
      when(
        () => mockApiClient.get(any(), queryParams: any(named: 'queryParams')),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          data: [fakeAdmissionJson],
        ),
      );

      final admission = await admissionRepository.getMyAdmissions(
        doctorId: 'doc-1',
      );
      expect(admission.length, 1);
      expect(admission.first.admissionId, 'adm-1');
    });

    test(
      'Debe retornar lista de Admission cuando payload tiene "data"',
      () async {
        when(
          () =>
              mockApiClient.get(any(), queryParams: any(named: 'queryParams')),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: {
              'data': [fakeAdmissionJson],
            },
          ),
        );

        final admission = await admissionRepository.getMyAdmissions(
          doctorId: 'doc-1',
        );
        expect(admission.length, 1);
      },
    );

    test(
      'Debe retornar lista de Admission cuando payload tiene "content"',
      () async {
        when(
          () =>
              mockApiClient.get(any(), queryParams: any(named: 'queryParams')),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: {
              'content': [fakeAdmissionJson],
            },
          ),
        );

        final admission = await admissionRepository.getMyAdmissions(
          doctorId: 'doc-1',
        );
        expect(admission.length, 1);
      },
    );

    test('Debe lanzar Exception si map no tiene data ni content', () async {
      when(
        () => mockApiClient.get(any(), queryParams: any(named: 'queryParams')),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          data: {'fakeContent': []},
        ),
      );

      expect(
        () => admissionRepository.getMyAdmissions(doctorId: 'doc-1'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains(
              "Estructura de respuesta no soportada (sin 'data' o 'content')",
            ),
          ),
        ),
      );
    });

    test('Debe lanzar Exception si payload no es Map ni List', () async {
      when(
        () => mockApiClient.get(any(), queryParams: any(named: 'queryParams')),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          data: 'fake_string',
        ),
      );

      expect(
        () => admissionRepository.getMyAdmissions(doctorId: 'doc-1'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains("Estructura de respuesta no soportada"),
          ),
        ),
      );
    });

    test('Debe propagar error de ApiClient', () async {
      when(
        () => mockApiClient.get(any(), queryParams: any(named: 'queryParams')),
      ).thenThrow(AuthException('No hay conexión'));

      expect(
        () => admissionRepository.getMyAdmissions(doctorId: 'doc-1'),
        throwsA(isA<AuthException>()),
      );
    });
  });

  group('AdmissionRepository - searchBySurname', () {
    test('Debe retornar PaginatedAdmissionResult con "data"', () async {
      when(
        () => mockApiClient.get(any(), queryParams: any(named: 'queryParams')),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          data: {
            'data': [fakeAdmissionJson],
            'totalPages': 1,
            'totalElements': 1,
            'last': true,
          },
        ),
      );

      final result = await admissionRepository.searchBySurname(
        surname: 'Garcia',
      );
      expect(result.content.length, 1);
      expect(result.content.first, isA<AdmissionResponse>());
    });

    test('Debe retornar PaginatedAdmissionResult con "content"', () async {
      when(
        () => mockApiClient.get(any(), queryParams: any(named: 'queryParams')),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          data: {
            'content': [fakeAdmissionJson],
            'totalPages': 1,
            'totalElements': 1,
            'last': true,
          },
        ),
      );

      final result = await admissionRepository.searchBySurname(
        surname: 'Garcia',
      );
      expect(result.content.length, 1);
      expect(result.content.first, isA<AdmissionResponse>());
    });

    test('Debe lanzar Exception si payload no es Map', () async {
      when(
        () => mockApiClient.get(any(), queryParams: any(named: 'queryParams')),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          data: [fakeAdmissionJson],
        ),
      );

      expect(
        () => admissionRepository.searchBySurname(surname: 'Garcia'),
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
        () => admissionRepository.searchBySurname(surname: 'Garcia'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains(
              "Estructura de respuesta no soportada (sin 'data' o 'content')",
            ),
          ),
        ),
      );
    });

    test('Debe propagar error de ApiClient', () async {
      when(
        () => mockApiClient.get(any(), queryParams: any(named: 'queryParams')),
      ).thenThrow(Exception('Error'));

      expect(
        () => admissionRepository.searchBySurname(surname: 'Garcia'),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('AdmissionRepository - createAdmission', () {
    test('Debe retornar true si statusCode es 201', () async {
      when(
        () => mockApiClient.post(any(), data: any(named: 'data')),
      ).thenAnswer(
        (_) async =>
            Response(requestOptions: RequestOptions(path: ''), statusCode: 201),
      );

      final result = await admissionRepository.createAdmission(
        patientId: 'pat-1',
        serviceId: 'ser-1',
        principalDiagnosis: 'Dx',
        medicalHistory: 'Hx',
        allergies: 'Allergies',
        chronicTreatment: 'Tx',
        basalBarthel: 100,
      );

      expect(result, true);
    });

    test('Debe retornar false si statusCode no es 201', () async {
      when(
        () => mockApiClient.post(any(), data: any(named: 'data')),
      ).thenAnswer(
        (_) async =>
            Response(requestOptions: RequestOptions(path: ''), statusCode: 400),
      );

      final result = await admissionRepository.createAdmission(
        patientId: 'pat-1',
        serviceId: 'ser-1',
        principalDiagnosis: 'Dx',
        medicalHistory: 'Hx',
      );

      expect(result, false);
    });

    test('Debe manejar Excepción y relanzar Exception', () async {
      when(
        () => mockApiClient.post(any(), data: any(named: 'data')),
      ).thenThrow(Exception('Http Error'));

      expect(
        () => admissionRepository.createAdmission(
          patientId: 'pat-1',
          serviceId: 'ser-1',
          principalDiagnosis: 'Dx',
          medicalHistory: 'Hx',
        ),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains("Error creando ingreso"),
          ),
        ),
      );
    });
  });

  group('AdmissionRepository - dischargeAdmission', () {
    test('Debe retornar true si statusCode es 200', () async {
      when(() => mockApiClient.patch(any())).thenAnswer(
        (_) async =>
            Response(requestOptions: RequestOptions(path: ''), statusCode: 200),
      );

      final result = await admissionRepository.dischargeAdmission('adm-1');
      expect(result, true);
    });

    test('Debe retornar false si statusCode no es 200', () async {
      when(() => mockApiClient.patch(any())).thenAnswer(
        (_) async =>
            Response(requestOptions: RequestOptions(path: ''), statusCode: 400),
      );

      final result = await admissionRepository.dischargeAdmission('adm-1');
      expect(result, false);
    });

    test('Debe propagar error de ApiClient', () async {
      when(() => mockApiClient.patch(any())).thenThrow(Exception('Http Error'));

      expect(
        () => admissionRepository.dischargeAdmission('adm-1'),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('AdmissionRepository - clinicalUpdate', () {
    test(
      'Debe actualizar y retornar AdmissionResponse cuando payload tiene "data"',
      () async {
        when(
          () => mockApiClient.put(any(), data: any(named: 'data')),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: {'data': fakeAdmissionUpdateJson},
          ),
        );

        final result = await admissionRepository.clinicalUpdate(
          admissionId: 'adm-1',
          principalDiagnosis: 'Dx',
          medicalHistory: 'Hx',
          patient: fakePatientPreview,
        );

        expect(result.admissionId, 'adm-1');
        expect(result.patient.patientId, 'pat-1');
      },
    );

    test(
      'Debe actualizar y retornar AdmissionResponse cuando payload NO tiene "data"',
      () async {
        when(
          () => mockApiClient.put(any(), data: any(named: 'data')),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: fakeAdmissionUpdateJson,
          ),
        );

        final result = await admissionRepository.clinicalUpdate(
          admissionId: 'adm-1',
          principalDiagnosis: 'Dx',
          medicalHistory: 'Hx',
          patient: fakePatientPreview,
        );

        expect(result.admissionId, 'adm-1');
        expect(result.patient.patientId, 'pat-1');
      },
    );

    test('Debe propagar error de ApiClient', () async {
      when(
        () => mockApiClient.put(any(), data: any(named: 'data')),
      ).thenThrow(Exception('Http Error'));

      expect(
        () => admissionRepository.clinicalUpdate(
          admissionId: 'adm-1',
          principalDiagnosis: 'Dx',
          medicalHistory: 'Hx',
          patient: fakePatientPreview,
        ),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('AdmissionRepository - assignDoctor', () {
    test(
      'Debe retornar AdmissionResponse cuando payload tiene "patient"',
      () async {
        when(() => mockApiClient.patch(any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: fakeAdmissionJson, // ya incluye 'patient'
          ),
        );

        final result = await admissionRepository.assignDoctor(
          admissionId: 'adm-1',
          doctorId: 'doc-1',
          patient: fakePatientPreview,
        );

        expect(result.admissionId, 'adm-1');
        expect(result.patient.patientId, 'pat-1');
      },
    );

    test(
      'Debe retornar AdmissionResponse cuando payload NO tiene "patient"',
      () async {
        when(() => mockApiClient.patch(any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: fakeAdmissionUpdateJson, // NO incluye 'patient'
          ),
        );

        final result = await admissionRepository.assignDoctor(
          admissionId: 'adm-1',
          doctorId: 'doc-1',
          patient: fakePatientPreview,
        );

        expect(result.admissionId, 'adm-1');
        expect(result.patient.patientId, 'pat-1');
      },
    );

    test(
      'Debe retornar AdmissionResponse cuando payload está anidado en "data"',
      () async {
        when(() => mockApiClient.patch(any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: {'data': fakeAdmissionJson},
          ),
        );

        final result = await admissionRepository.assignDoctor(
          admissionId: 'adm-1',
          doctorId: 'doc-1',
          patient: fakePatientPreview,
        );

        expect(result.admissionId, 'adm-1');
        expect(result.patient.patientId, 'pat-1');
      },
    );

    test('Debe propagar error de ApiClient', () async {
      when(() => mockApiClient.patch(any())).thenThrow(Exception('Http Error'));

      expect(
        () => admissionRepository.assignDoctor(
          admissionId: 'adm-1',
          doctorId: 'doc-1',
          patient: fakePatientPreview,
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
