import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:klinico_front/data/models/auth_response.dart';
import 'package:klinico_front/data/repositories/auth_repository.dart';
import 'package:klinico_front/data/services/auth_service.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late AuthService authService;
  late MockAuthRepository mockAuthRepository;
  late MockFlutterSecureStorage mockStorage;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockStorage = MockFlutterSecureStorage();
    authService = AuthService(
      authRepository: mockAuthRepository,
      storage: mockStorage,
    );
  });

  group('AuthService - signIn & logout', () {
    test('signIn debe llamar al repositorio y guardar el token', () async {
      final fakeResponse = AuthResponse(
        token: 'fake_jwt_token',
        userId: '123',
        email: 'test@test.com',
        name: 'Dr. Pepe',
        role: 'MEDICO',
      );

      when(
        () => mockAuthRepository.login('test@test.com', '1234'),
      ).thenAnswer((_) async => fakeResponse);
      when(
        () => mockStorage.write(key: 'token', value: 'fake_jwt_token'),
      ).thenAnswer((_) async => {});

      final result = await authService.signIn('test@test.com', '1234');

      expect(result.token, 'fake_jwt_token');
      expect(result.name, 'Dr. Pepe');

      verify(() => mockAuthRepository.login('test@test.com', '1234')).called(1);
      verify(
        () => mockStorage.write(key: 'token', value: 'fake_jwt_token'),
      ).called(1);
    });

    test('getToken debe leer el storage', () async {
      when(
        () => mockStorage.read(key: 'token'),
      ).thenAnswer((_) async => 'mi_token_guardado');

      final token = await authService.getToken();

      expect(token, 'mi_token_guardado');
      verify(() => mockStorage.read(key: 'token')).called(1);
    });

    test('logout debe borrar el storage por completo', () async {
      when(() => mockStorage.deleteAll()).thenAnswer((_) async => {});

      await authService.logout();

      verify(() => mockStorage.deleteAll()).called(1);
    });
  });

  group('AuthService - JWT Decoding (initializeSession & isTokenValid)', () {
    // Cabecera base64 genérica: {"alg":"HS256","typ":"JWT"}
    const header = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9';
    const signature = 'fake_signature';

    test('initializeSession retorna los claims si el token es válido', () async {
      // Payload: {"sub":"123","role":"MEDICO","exp":9999999999} -> Año 2286, no caducado
      const validPayload =
          'eyJzdWIiOiIxMjMiLCJyb2xlIjoiTUVESUNPIiwiZXhwIjo5OTk5OTk5OTk5fQ';
      const validToken = '$header.$validPayload.$signature';

      when(
        () => mockStorage.read(key: 'token'),
      ).thenAnswer((_) async => validToken);

      final claims = await authService.initializeSession();

      expect(claims, isNotNull);
      expect(claims!['sub'], '123');
      expect(claims['role'], 'MEDICO');

      verifyNever(() => mockStorage.deleteAll());
    });

    test(
      'initializeSession limpia el storage y devuelve null si el token caducó',
      () async {
        // Payload: {"sub":"123","role":"MEDICO","exp":1000000000} -> Año 2001, muy caducado
        const expiredPayload =
            'eyJzdWIiOiIxMjMiLCJyb2xlIjoiTUVESUNPIiwiZXhwIjoxMDAwMDAwMDAwfQ';
        const expiredToken = '$header.$expiredPayload.$signature';

        when(
          () => mockStorage.read(key: 'token'),
        ).thenAnswer((_) async => expiredToken);
        when(() => mockStorage.deleteAll()).thenAnswer((_) async => {});

        final claims = await authService.initializeSession();

        expect(claims, isNull);

        verify(() => mockStorage.deleteAll()).called(1);
      },
    );

    test('initializeSession hace logout si el claim exp es null', () async {
      // Payload: {"sub":"123","role":"MEDICO","exp":null}
      const validPayload =
          'eyJzdWIiOiIxMjMiLCJyb2xlIjoiTUVESUNPIiwibWFpbCI6Im1lZ2FAbWVkaWNvLmNvbSJ9';
      const validToken = '$header.$validPayload.$signature';

      when(
        () => mockStorage.read(key: 'token'),
      ).thenAnswer((_) async => validToken);
      when(() => mockStorage.deleteAll()).thenAnswer((_) async => {});

      final claims = await authService.initializeSession();

      expect(claims, isNull);

      verify(() => mockStorage.deleteAll()).called(1);
    });

    test(
      'initializeSession limpia el storage si el token tiene mal formato',
      () async {
        when(
          () => mockStorage.read(key: 'token'),
        ).thenAnswer((_) async => 'token_invalido_sin_puntos');
        when(() => mockStorage.deleteAll()).thenAnswer((_) async => {});

        final claims = await authService.initializeSession();

        expect(claims, isNull);
        verify(() => mockStorage.deleteAll()).called(1);
      },
    );

    test('isTokenValid retorna true si el token está activo', () async {
      const validPayload =
          'eyJzdWIiOiIxMjMiLCJyb2xlIjoiTUVESUNPIiwiZXhwIjo5OTk5OTk5OTk5fQ';
      const validToken = '$header.$validPayload.$signature';

      when(
        () => mockStorage.read(key: 'token'),
      ).thenAnswer((_) async => validToken);

      final isValid = await authService.isTokenValid();
      expect(isValid, isTrue);
    });

    test('isTokenValid retorna false si el token caducó', () async {
      const expiredPayload =
          'eyJzdWIiOiIxMjMiLCJyb2xlIjoiTUVESUNPIiwiZXhwIjoxMDAwMDAwMDAwfQ';
      const expiredToken = '$header.$expiredPayload.$signature';

      when(
        () => mockStorage.read(key: 'token'),
      ).thenAnswer((_) async => expiredToken);

      final isValid = await authService.isTokenValid();
      expect(isValid, isFalse);
    });

    test('isTokenValid retorna false si el claim exp es null', () async {
      const noExpPayload =
          'eyJzdWIiOiIxMjMiLCJyb2xlIjoiTUVESUNPIiwibWFpbCI6Im1lZ2FAbWVkaWNvLmNvbSJ9';
      const noExpToken = '$header.$noExpPayload.$signature';

      when(
        () => mockStorage.read(key: 'token'),
      ).thenAnswer((_) async => noExpToken);

      final isValid = await authService.isTokenValid();
      expect(isValid, isFalse);
    });

    test('isTokenValid retorna false si el token es null', () async {
      when(() => mockStorage.read(key: 'token')).thenAnswer((_) async => null);

      final isValid = await authService.isTokenValid();
      expect(isValid, isFalse);
    });
  });
}
