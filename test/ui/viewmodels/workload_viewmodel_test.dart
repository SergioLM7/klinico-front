import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:klinico_front/core/exceptions/auth_exception.dart';
import 'package:klinico_front/data/models/workload_response.dart';
import 'package:klinico_front/data/repositories/user_repository.dart';
import 'package:klinico_front/ui/viewmodels/workload_viewmodel.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late WorkloadViewmodel viewModel;
  late MockUserRepository mockRepository;

  final fakeWorkload = WorkloadResponse(
    name: 'Pepe',
    surname: 'Jiménez',
    admissionsAssigned: 5,
  );

  setUp(() {
    mockRepository = MockUserRepository();
    viewModel = WorkloadViewmodel(repository: mockRepository);
  });

  group('WorkloadViewmodel - getServiceWorkload', () {
    test('Debe cargar la carga de trabajo y actualizar el estado', () async {
      when(
        () => mockRepository.getServiceWorkload(),
      ).thenAnswer((_) async => [fakeWorkload]);

      final loadingStates = <bool>[];
      viewModel.addListener(() => loadingStates.add(viewModel.isLoading));

      await viewModel.getServiceWorkload();

      expect(viewModel.workload.length, 1);
      expect(viewModel.workload.first.name, 'Pepe');
      expect(viewModel.workload.first.admissionsAssigned, 5);
      expect(viewModel.errorMessage, isNull);

      verify(() => mockRepository.getServiceWorkload()).called(1);
      expect(loadingStates, [true, false]);
    });

    test('Debe capturar error si falla la carga de datos', () async {
      when(
        () => mockRepository.getServiceWorkload(),
      ).thenThrow(AuthException('No se pudo obtener la carga de trabajo'));

      await viewModel.getServiceWorkload();

      expect(viewModel.workload, isEmpty);
      expect(viewModel.errorMessage, 'No se pudo obtener la carga de trabajo');
      expect(viewModel.isLoading, isFalse);
    });
  });
}
