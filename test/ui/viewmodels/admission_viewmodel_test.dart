import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:klinico_front/core/exceptions/auth_exception.dart';
import 'package:klinico_front/data/models/admission_response.dart';
import 'package:klinico_front/data/models/patient_preview_response.dart';
import 'package:klinico_front/data/repositories/admission_repository.dart';
import 'package:klinico_front/ui/viewmodels/admission_viewmodel.dart';

class MockAdmissionRepository extends Mock implements AdmissionRepository {}

void main() {
  late AdmissionViewModel viewModel;
  late MockAdmissionRepository mockRepository;

  final fakePatient = PatientPreviewResponse(
    patientId: 'pat-1',
    name: 'María',
    surname: 'García',
    birthdate: DateTime(1980, 5, 20),
    sex: 'F',
  );

  final fakeAdmission = AdmissionResponse(
    admissionId: 'adm-1',
    patient: fakePatient,
    serviceId: '2',
    assignedDoctorId: '423523',
    principalDiagnosis: 'Neumonía',
    createdAt: DateTime.now(),
    createdBy: '423523',
  );

  setUp(() {
    mockRepository = MockAdmissionRepository();
    viewModel = AdmissionViewModel(repository: mockRepository);
  });

  group('AdmissionViewModel - getUserAdmissions', () {
    test('Debe cargar la lista de admisiones y actualizar el estado', () async {
      when(
        () => mockRepository.getMyAdmissions(doctorId: '423523'),
      ).thenAnswer((_) async => [fakeAdmission]);

      final loadingStates = <bool>[];
      viewModel.addListener(() => loadingStates.add(viewModel.isLoading));

      await viewModel.getUserAdmissions('423523');

      expect(viewModel.admissions.length, 1);
      expect(viewModel.admissions.first.admissionId, 'adm-1');
      expect(viewModel.errorMessage, isNull);

      verify(
        () => mockRepository.getMyAdmissions(doctorId: '423523'),
      ).called(1);
      expect(loadingStates, [true, false]);
    });

    test('Debe capturar errores si falla la carga', () async {
      when(
        () => mockRepository.getMyAdmissions(doctorId: any(named: 'doctorId')),
      ).thenThrow(AuthException('Error de conexión a base de datos'));

      await viewModel.getUserAdmissions('doc-1');

      expect(viewModel.admissions, isEmpty);
      expect(viewModel.errorMessage, 'Error de conexión a base de datos');
      expect(viewModel.isLoading, isFalse);
    });
  });

  group('AdmissionViewModel - createAdmission', () {
    test('Debe retornar true si se crea exitosamente', () async {
      when(
        () => mockRepository.createAdmission(
          patientId: any(named: 'patientId'),
          serviceId: any(named: 'serviceId'),
          principalDiagnosis: any(named: 'principalDiagnosis'),
          medicalHistory: any(named: 'medicalHistory'),
        ),
      ).thenAnswer((_) async => true);

      final success = await viewModel.createAdmission(
        patientId: 'pat-1',
        serviceId: '10',
        principalDiagnosis: 'Gripe',
        medicalHistory: 'Sin antecedentes',
      );

      expect(success, isTrue);
      expect(viewModel.errorMessage, isNull);
      verify(
        () => mockRepository.createAdmission(
          patientId: 'pat-1',
          serviceId: '10',
          principalDiagnosis: 'Gripe',
          medicalHistory: 'Sin antecedentes',
        ),
      ).called(1);
    });

    test('Debe capturar errores si falla la creación', () async {
      when(
        () => mockRepository.createAdmission(
          patientId: any(named: 'patientId'),
          serviceId: any(named: 'serviceId'),
          principalDiagnosis: any(named: 'principalDiagnosis'),
          medicalHistory: any(named: 'medicalHistory'),
        ),
      ).thenThrow(
        AuthException(
          'Servicio temporalmente no disponible. Inténtalo más tarde o contacta con el servicio técnico.',
        ),
      );

      await viewModel.createAdmission(
        patientId: 'pat-1',
        serviceId: '10',
        principalDiagnosis: 'Gripe',
        medicalHistory: 'Sin antecedentes',
      );

      expect(viewModel.admissions, isEmpty);
      expect(
        viewModel.errorMessage,
        'Servicio temporalmente no disponible. Inténtalo más tarde o contacta con el servicio técnico.',
      );
      expect(viewModel.isLoading, isFalse);
    });
  });

  group('AdmissionViewModel - dischargeAdmission', () {
    test('Debe retornar true si se da de alta exitosamente', () async {
      when(
        () => mockRepository.dischargeAdmission('pat-1'),
      ).thenAnswer((_) async => true);

      final success = await viewModel.dischargeAdmission('pat-1');

      expect(success, isTrue);
      expect(viewModel.errorMessage, isNull);
      verify(() => mockRepository.dischargeAdmission('pat-1')).called(1);
    });

    test('Debe capturar la excepción y setear errorMessage si falla', () async {
      when(
        () => mockRepository.dischargeAdmission(any()),
      ).thenThrow(AuthException('Servidor no disponible'));

      // 2. Act
      final success = await viewModel.dischargeAdmission('adm-1');

      expect(success, isFalse);
      expect(viewModel.errorMessage, 'Servidor no disponible');
      verify(() => mockRepository.dischargeAdmission('adm-1')).called(1);
    });
  });

  group('AdmissionViewModel - clinicalUpdate', () {
    test(
      'Debe retornar una AdmissionResponse si modifica la admisión exitosamente',
      () async {
        when(
          () => mockRepository.clinicalUpdate(
            admissionId: 'pat-1',
            principalDiagnosis: 'Neumonía',
            medicalHistory: 'Sin antecedentes',
            patient: fakePatient,
          ),
        ).thenAnswer((_) async => fakeAdmission);

        final response = await viewModel.clinicalUpdate(
          admissionId: 'pat-1',
          principalDiagnosis: 'Neumonía',
          medicalHistory: 'Sin antecedentes',
          patient: fakePatient,
        );

        expect(response, isInstanceOf<AdmissionResponse>());
        expect(viewModel.errorMessage, isNull);
        verify(
          () => mockRepository.clinicalUpdate(
            admissionId: 'pat-1',
            principalDiagnosis: 'Neumonía',
            medicalHistory: 'Sin antecedentes',
            patient: fakePatient,
          ),
        ).called(1);
      },
    );
    test('Debe capturar la excepción y setear errorMessage si falla', () async {
      when(
        () => mockRepository.clinicalUpdate(
          admissionId: 'pat-1',
          principalDiagnosis: 'Neumonía',
          medicalHistory: 'Sin antecedentes',
          patient: fakePatient,
        ),
      ).thenThrow(AuthException('Error inesperado de conexión'));

      final response = await viewModel.clinicalUpdate(
        admissionId: 'pat-1',
        principalDiagnosis: 'Neumonía',
        medicalHistory: 'Sin antecedentes',
        patient: fakePatient,
      );

      expect(response, isNull);
      expect(viewModel.errorMessage, 'Error inesperado de conexión');
      verify(
        () => mockRepository.clinicalUpdate(
          admissionId: 'pat-1',
          principalDiagnosis: 'Neumonía',
          medicalHistory: 'Sin antecedentes',
          patient: fakePatient,
        ),
      ).called(1);
    });
  });

  group('AdmissionViewModel - assignDoctor', () {
    test(
      'Debe retornar una AdmissionResponse si modifica la asignación exitosamente',
      () async {
        when(
          () => mockRepository.assignDoctor(
            admissionId: 'pat-1',
            doctorId: 'doc-1',
            patient: fakePatient,
          ),
        ).thenAnswer((_) async => fakeAdmission);

        final response = await viewModel.assignDoctor(
          'pat-1',
          'doc-1',
          fakePatient,
        );

        expect(response, isTrue);
        expect(viewModel.errorMessage, isNull);
        verify(
          () => mockRepository.assignDoctor(
            admissionId: 'pat-1',
            doctorId: 'doc-1',
            patient: fakePatient,
          ),
        ).called(1);
      },
    );
    test('Debe capturar la excepción y setear errorMessage si falla', () async {
      when(
        () => mockRepository.assignDoctor(
          admissionId: 'pat-1',
          doctorId: 'doc-1',
          patient: fakePatient,
        ),
      ).thenThrow(AuthException('Servidor no disponible'));

      final success = await viewModel.assignDoctor(
        'adm-1',
        'doc-1',
        fakePatient,
      );

      expect(success, isFalse);
      expect(viewModel.errorMessage, 'Error inesperado de conexión');
      verify(
        () => mockRepository.assignDoctor(
          admissionId: 'adm-1',
          doctorId: 'doc-1',
          patient: fakePatient,
        ),
      ).called(1);
    });
  });
}
