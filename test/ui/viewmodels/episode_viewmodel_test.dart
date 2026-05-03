import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:klinico_front/core/exceptions/auth_exception.dart';
import 'package:klinico_front/data/models/episode_response.dart';
import 'package:klinico_front/data/repositories/episode_repository.dart';
import 'package:klinico_front/ui/viewmodels/episode_viewmodel.dart';

class MockEpisodeRepository extends Mock implements EpisodeRepository {}

void main() {
  late EpisodeViewModel viewModel;
  late MockEpisodeRepository mockRepository;

  final fakeEpisode = EpisodeResponse(
    episodeId: 'epi-1',
    admissionId: 'adm-1',
    doctorId: 'doc-1',
    clinicalProgress: 'El paciente evoluciona favorablemente',
    diagnosis: 'Neumonía leve',
    bradenScore: 12,
    createdAt: DateTime.now(),
    createdBy: 'doc-1',
    createdByName: 'Dr. Pepe Jiménez',
  );

  setUp(() {
    mockRepository = MockEpisodeRepository();
    viewModel = EpisodeViewModel(repository: mockRepository);
  });

  group('EpisodeViewModel - loadEpisodes', () {
    test('Debe cargar la lista de episodios y actualizar el estado', () async {
      when(
        () => mockRepository.getEpisodesByAdmission(
          admissionId: any(named: 'admissionId'),
        ),
      ).thenAnswer((_) async => [fakeEpisode]);

      final loadingStates = <bool>[];
      viewModel.addListener(() => loadingStates.add(viewModel.isLoading));

      await viewModel.loadEpisodes('adm-1');

      expect(viewModel.episodes.length, 1);
      expect(viewModel.episodes.first.episodeId, 'epi-1');
      expect(viewModel.episodes.first.createdByName, 'Dr. Pepe Jiménez');
      expect(viewModel.errorMessage, isNull);

      verify(
        () => mockRepository.getEpisodesByAdmission(admissionId: 'adm-1'),
      ).called(1);
      expect(loadingStates, [true, false]);
    });

    test(
      'Debe limpiar la lista y setear errorMessage si ocurre un error',
      () async {
        when(
          () => mockRepository.getEpisodesByAdmission(
            admissionId: any(named: 'admissionId'),
          ),
        ).thenThrow(AuthException('No se encontraron episodios'));

        await viewModel.loadEpisodes('adm-1');

        expect(viewModel.episodes, isEmpty);
        expect(viewModel.errorMessage, 'No se encontraron episodios');
        expect(viewModel.isLoading, isFalse);
      },
    );
  });

  group('EpisodeViewModel - createEpisode', () {
    test('Debe retornar true si el episodio se crea con éxito', () async {
      when(
        () => mockRepository.createEpisode(
          admissionId: any(named: 'admissionId'),
          doctorId: any(named: 'doctorId'),
          clinicalProgress: any(named: 'clinicalProgress'),
          diagnosis: any(named: 'diagnosis'),
        ),
      ).thenAnswer((_) async => {"success": true});

      final success = await viewModel.createEpisode(
        admissionId: 'adm-1',
        doctorId: 'doc-1',
        clinicalProgress: 'Nueva evaluación',
        diagnosis: 'Estable',
      );

      expect(success, isTrue);
      expect(viewModel.errorMessage, isNull);

      verify(
        () => mockRepository.createEpisode(
          admissionId: 'adm-1',
          doctorId: 'doc-1',
          clinicalProgress: 'Nueva evaluación',
          diagnosis: 'Estable',
        ),
      ).called(1);
    });

    test(
      'Debe capturar AuthException y retornar false si falla la creación',
      () async {
        when(
          () => mockRepository.createEpisode(
            admissionId: any(named: 'admissionId'),
            doctorId: any(named: 'doctorId'),
            clinicalProgress: any(named: 'clinicalProgress'),
            diagnosis: any(named: 'diagnosis'),
          ),
        ).thenThrow(
          AuthException('No tienes permisos para crear este episodio'),
        );

        final success = await viewModel.createEpisode(
          admissionId: 'adm-1',
          doctorId: 'doc-1',
          clinicalProgress: 'Intento de edición',
          diagnosis: 'Sigue igual',
        );

        expect(success, isFalse);
        expect(
          viewModel.errorMessage,
          'No tienes permisos para crear este episodio',
        );

        verify(
          () => mockRepository.createEpisode(
            admissionId: 'adm-1',
            doctorId: 'doc-1',
            clinicalProgress: 'Intento de edición',
            diagnosis: 'Sigue igual',
          ),
        ).called(1);
      },
    );
  });

  group('EpisodeViewModel - updateEpisode', () {
    test('Debe retornar true si el episodio se actualiza con éxito', () async {
      when(
        () => mockRepository.updateEpisode(
          episodeId: any(named: 'episodeId'),
          clinicalProgress: any(named: 'clinicalProgress'),
          diagnosis: any(named: 'diagnosis'),
        ),
      ).thenAnswer((_) async => {"success": true});

      final success = await viewModel.updateEpisode(
        episodeId: 'adm-1',
        clinicalProgress: 'Nueva evaluación',
        diagnosis: 'Estable',
      );

      expect(success, isTrue);
      expect(viewModel.errorMessage, isNull);

      verify(
        () => mockRepository.updateEpisode(
          episodeId: 'adm-1',
          clinicalProgress: 'Nueva evaluación',
          diagnosis: 'Estable',
        ),
      ).called(1);
    });

    test(
      'Debe capturar AuthException y retornar false si falla la actualización',
      () async {
        when(
          () => mockRepository.updateEpisode(
            episodeId: any(named: 'episodeId'),
            clinicalProgress: any(named: 'clinicalProgress'),
            diagnosis: any(named: 'diagnosis'),
          ),
        ).thenThrow(
          AuthException('No tienes permisos para editar este episodio'),
        );

        final success = await viewModel.updateEpisode(
          episodeId: 'epi-1',
          clinicalProgress: 'Intento de edición',
          diagnosis: 'Sigue igual',
        );

        expect(success, isFalse);
        expect(
          viewModel.errorMessage,
          'No tienes permisos para editar este episodio',
        );

        verify(
          () => mockRepository.updateEpisode(
            episodeId: 'epi-1',
            clinicalProgress: 'Intento de edición',
            diagnosis: 'Sigue igual',
          ),
        ).called(1);
      },
    );
  });
}
