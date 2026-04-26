import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klinico_front/core/api_client.dart';
import 'package:klinico_front/data/repositories/auth_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late AuthRepository authRepository;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    authRepository = AuthRepository(mockApiClient);
  });

  group('AuthRepository - login', () {
    final fakeAuthJson = {
      'token': 'test-token',
      'userId': 'u1',
      'email': 'test@test.com',
      'name': 'Sergio',
      'role': 'MEDICO',
      'serviceId': 's1',
    };

    test('Debe retornar AuthResponse si login es exitoso', () async {
      when(() => mockApiClient.post(any(), data: any(named: 'data')))
          .thenAnswer((_) async => Response(
                requestOptions: RequestOptions(path: ''),
                data: fakeAuthJson,
              ));

      final response = await authRepository.login('test@test.com', 'password123');
      expect(response.token, 'test-token');
      expect(response.userId, 'u1');
      expect(response.email, 'test@test.com');
      expect(response.name, 'Sergio');
      expect(response.role, 'MEDICO');
      expect(response.serviceId, 's1');
    });

    test('Debe propagar error de ApiClient', () async {
      when(() => mockApiClient.post(any(), data: any(named: 'data')))
          .thenThrow(Exception('Error de red'));

      expect(
        () => authRepository.login('test@test.com', 'password123'),
        throwsA(isA<Exception>()),
      );
    });
  });
}
