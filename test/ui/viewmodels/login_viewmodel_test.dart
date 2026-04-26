import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:klinico_front/core/exceptions/auth_exception.dart';
import 'package:klinico_front/data/models/auth_response.dart';
import 'package:klinico_front/data/services/auth_service.dart';
import 'package:klinico_front/ui/viewmodels/login_viewmodel.dart';

class MockAuthService extends Mock implements AuthService {}

void main() {
  late LoginViewModel viewModel;
  late MockAuthService mockAuthService;

  setUp(() {
    mockAuthService = MockAuthService();
    viewModel = LoginViewModel(authService: mockAuthService);
  });

  group('LoginViewModel - signIn', () {
    test(
      'Debe retornar true y actualizar el estado cuando el login es exitoso',
      () async {
        final mockResponse = AuthResponse(
          token: 'fake_jwt_token',
          userId: '123',
          email: 'pepeJimenez@hospital.com',
          name: 'Dr. Pepe Jiménez',
          role: 'MEDICO',
          serviceId: '10',
        );

        when(
          () =>
              mockAuthService.signIn('pepeJimenez@hospital.com', 'password123'),
        ).thenAnswer((_) async => mockResponse);

        final loadingStates = <bool>[];
        viewModel.addListener(() {
          loadingStates.add(viewModel.isLoading);
        });

        final success = await viewModel.signIn(
          'pepeJimenez@hospital.com',
          'password123',
        );

        expect(success, isTrue);
        expect(viewModel.userName, 'Dr. Pepe Jiménez');
        expect(viewModel.userRole, 'MEDICO');
        expect(viewModel.errorMessage, isNull);

        verify(
          () =>
              mockAuthService.signIn('pepeJimenez@hospital.com', 'password123'),
        ).called(1);

        expect(loadingStates, [true, false]);
      },
    );

    test(
      'Debe retornar false y capturar el AuthException cuando el login falla',
      () async {
        final exception = AuthException('Credenciales incorrectas');

        when(() => mockAuthService.signIn(any(), any())).thenThrow(exception);

        final success = await viewModel.signIn(
          'dadadas@hospital.com',
          'asasr1r2',
        );

        expect(success, isFalse);
        expect(viewModel.errorMessage, 'Credenciales incorrectas');
        expect(viewModel.userName, isNull);
        expect(viewModel.isLoading, isFalse);
      },
    );

    test(
      'Debe retornar false y capturar la Exception cuando hay error inesperado',
      () async {
        when(
          () => mockAuthService.signIn(any(), any()),
        ).thenThrow(Exception('Error inesperado'));

        final success = await viewModel.signIn(
          'dadadas@hospital.com',
          'asasr1r2',
        );

        expect(success, isFalse);
        expect(viewModel.errorMessage, 'Error de conexión inesperado');
        expect(viewModel.userName, isNull);
        expect(viewModel.isLoading, isFalse);
      },
    );
  });

  group('LoginViewModel - signOut', () {
    test(
      'Debe realizar correctamente el signOut y limpiar el estado',
      () async {
        when(() => mockAuthService.logout()).thenAnswer((_) async {});

        final loadingStates = <bool>[];
        viewModel.addListener(() {
          loadingStates.add(viewModel.isLoading);
        });

        await viewModel.signOut();

        expect(viewModel.userName, isNull);
        expect(viewModel.userRole, isNull);
        expect(viewModel.errorMessage, isNull);

        verify(() => mockAuthService.logout()).called(1);

        expect(loadingStates, [true, false]);
      },
    );

    test('Debe capturar el error cuando el logout falla', () async {
      when(
        () => mockAuthService.logout(),
      ).thenThrow(Exception('Error inesperado'));

      await viewModel.signOut();

      expect(viewModel.errorMessage, 'Error al cerrar sesión');
      expect(viewModel.userName, isNull);
      expect(viewModel.isLoading, isFalse);
    });
  });

  group('LoginViewModel - initialize', () {
    test('Debe retornar true cuando el initialize es exitoso', () async {
      final mockClaims = {
        'sub': '123',
        'role': 'MEDICO',
        'surname': 'Jiménez',
        'serviceId': '10',
      };

      when(
        () => mockAuthService.initializeSession(),
      ).thenAnswer((_) async => mockClaims);

      final success = await viewModel.initialize();

      expect(success, isTrue);
      expect(viewModel.userName, 'Jiménez');
      expect(viewModel.userRole, 'MEDICO');
      expect(viewModel.serviceId, '10');
      expect(viewModel.userId, '123');
      expect(viewModel.errorMessage, isNull);

      verify(() => mockAuthService.initializeSession()).called(1);
    });

    test('Debe retornar false cuando no hay sesión iniciada', () async {
      when(
        () => mockAuthService.initializeSession(),
      ).thenAnswer((_) async => null);

      final success = await viewModel.initialize();

      expect(success, isFalse);
      expect(viewModel.userName, isNull);
      expect(viewModel.userRole, isNull);
      expect(viewModel.serviceId, isNull);
      expect(viewModel.userId, isNull);
      expect(viewModel.errorMessage, isNull);
    });
  });
}
