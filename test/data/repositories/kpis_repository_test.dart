import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klinico_front/core/api_client.dart';
import 'package:klinico_front/data/repositories/kpis_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late KpisRepository kpisRepository;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    kpisRepository = KpisRepository(mockApiClient);
  });

  final fakeMonthValueJson = {'month': 1, 'value': 10.5};

  final fakeDoctorDataJson = {
    'doctorId': 'd1',
    'doctorName': 'John',
    'doctorSurname': 'Doe',
    'data': [fakeMonthValueJson]
  };

  group('KpisRepository - _parseMonthValueList (vía getAdmissionsByService)', () {
    test('Debe retornar List<KpiMonthValue> cuando payload es List', () async {
      when(() => mockApiClient.get(any(), queryParams: any(named: 'queryParams')))
          .thenAnswer((_) async => Response(
                requestOptions: RequestOptions(path: ''),
                data: [fakeMonthValueJson],
              ));

      final result = await kpisRepository.getAdmissionsByService(2023);
      expect(result.length, 1);
      expect(result.first.month, 1);
      expect(result.first.value, 10.5);
    });

    test('Debe retornar List<KpiMonthValue> cuando payload es Map con data', () async {
      when(() => mockApiClient.get(any(), queryParams: any(named: 'queryParams')))
          .thenAnswer((_) async => Response(
                requestOptions: RequestOptions(path: ''),
                data: {'data': [fakeMonthValueJson]},
              ));

      final result = await kpisRepository.getAdmissionsByService(2023, month: 5);
      expect(result.length, 1);
    });

    test('Debe lanzar Exception cuando la estructura no es soportada', () async {
      when(() => mockApiClient.get(any(), queryParams: any(named: 'queryParams')))
          .thenAnswer((_) async => Response(
                requestOptions: RequestOptions(path: ''),
                data: 'invalid_string',
              ));

      expect(
        () => kpisRepository.getAdmissionsByService(2023),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('Estructura de respuesta no soportada'))),
      );
    });
  });

  group('KpisRepository - _parseDoctorDataList (vía getAdmissionsByDoctor)', () {
    test('Debe retornar List<KpiDoctorData> cuando payload es List', () async {
      when(() => mockApiClient.get(any(), queryParams: any(named: 'queryParams')))
          .thenAnswer((_) async => Response(
                requestOptions: RequestOptions(path: ''),
                data: [fakeDoctorDataJson],
              ));

      final result = await kpisRepository.getAdmissionsByDoctor(2023);
      expect(result.length, 1);
      expect(result.first.doctorId, 'd1');
    });

    test('Debe retornar List<KpiDoctorData> cuando payload es Map con data', () async {
      when(() => mockApiClient.get(any(), queryParams: any(named: 'queryParams')))
          .thenAnswer((_) async => Response(
                requestOptions: RequestOptions(path: ''),
                data: {'data': [fakeDoctorDataJson]},
              ));

      final result = await kpisRepository.getAdmissionsByDoctor(2023, month: 5);
      expect(result.length, 1);
    });

    test('Debe lanzar Exception cuando la estructura no es soportada', () async {
      when(() => mockApiClient.get(any(), queryParams: any(named: 'queryParams')))
          .thenAnswer((_) async => Response(
                requestOptions: RequestOptions(path: ''),
                data: 'invalid_string',
              ));

      expect(
        () => kpisRepository.getAdmissionsByDoctor(2023),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('Estructura de respuesta no soportada'))),
      );
    });
  });

  group('KpisRepository - Resto de endpoints', () {
    test('getExitus debe retornar List<KpiMonthValue>', () async {
      when(() => mockApiClient.get(any(), queryParams: any(named: 'queryParams')))
          .thenAnswer((_) async => Response(
                requestOptions: RequestOptions(path: ''),
                data: [fakeMonthValueJson],
              ));

      final result = await kpisRepository.getExitus(2023);
      expect(result.length, 1);
      verify(() => mockApiClient.get('/kpis/exitus', queryParams: {'year': 2023})).called(1);
    });

    test('getAvgStay debe retornar List<KpiMonthValue>', () async {
      when(() => mockApiClient.get(any(), queryParams: any(named: 'queryParams')))
          .thenAnswer((_) async => Response(
                requestOptions: RequestOptions(path: ''),
                data: [fakeMonthValueJson],
              ));

      final result = await kpisRepository.getAvgStay(2023);
      expect(result.length, 1);
      verify(() => mockApiClient.get('/kpis/avg-stay', queryParams: {'year': 2023})).called(1);
    });

    test('getAvgStayByDoctor debe retornar List<KpiDoctorData>', () async {
      when(() => mockApiClient.get(any(), queryParams: any(named: 'queryParams')))
          .thenAnswer((_) async => Response(
                requestOptions: RequestOptions(path: ''),
                data: [fakeDoctorDataJson],
              ));

      final result = await kpisRepository.getAvgStayByDoctor(2023);
      expect(result.length, 1);
      verify(() => mockApiClient.get('/kpis/avg-stay-by-doctor', queryParams: {'year': 2023})).called(1);
    });
  });
}
