import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:klinico_front/core/exceptions/auth_exception.dart';
import 'package:klinico_front/data/models/kpi_doctor_data.dart';
import 'package:klinico_front/data/models/kpi_month_value.dart';
import 'package:klinico_front/data/repositories/kpis_repository.dart';
import 'package:klinico_front/ui/viewmodels/kpis_viewmodel.dart';

class MockKpisRepository extends Mock implements KpisRepository {}

void main() {
  late KpisViewModel viewModel;
  late MockKpisRepository mockRepository;

  final fakeMonthValue = [KpiMonthValue(month: 1, value: 42.0)];
  final fakeDoctorData = [
    KpiDoctorData(
      doctorId: 'doc-1',
      doctorName: 'Pepe',
      doctorSurname: 'Jiménez',
      data: fakeMonthValue,
    ),
  ];

  setUp(() {
    mockRepository = MockKpisRepository();
    viewModel = KpisViewModel(repository: mockRepository);
  });

  group('KpisViewModel - loadAll', () {
    test(
      'Debe cargar todos los KPIs exitosamente y actualizar el estado',
      () async {
        when(
          () => mockRepository.getAdmissionsByService(
            any(),
            month: any(named: 'month'),
          ),
        ).thenAnswer((_) async => fakeMonthValue);
        when(
          () => mockRepository.getAdmissionsByDoctor(
            any(),
            month: any(named: 'month'),
          ),
        ).thenAnswer((_) async => fakeDoctorData);
        when(
          () => mockRepository.getExitus(any(), month: any(named: 'month')),
        ).thenAnswer((_) async => fakeMonthValue);
        when(
          () => mockRepository.getAvgStay(any(), month: any(named: 'month')),
        ).thenAnswer((_) async => fakeMonthValue);
        when(
          () => mockRepository.getAvgStayByDoctor(
            any(),
            month: any(named: 'month'),
          ),
        ).thenAnswer((_) async => fakeDoctorData);

        final loadingStates = <bool>[];
        viewModel.addListener(() => loadingStates.add(viewModel.isLoading));

        await viewModel.loadAll();

        expect(viewModel.admissionsByService, fakeMonthValue);
        expect(viewModel.admissionsByDoctor, fakeDoctorData);
        expect(viewModel.exitus, fakeMonthValue);
        expect(viewModel.avgStay, fakeMonthValue);
        expect(viewModel.avgStayByDoctor, fakeDoctorData);
        expect(viewModel.errorMessage, isNull);

        verify(
          () => mockRepository.getAdmissionsByService(
            any(),
            month: any(named: 'month'),
          ),
        ).called(1);
        expect(loadingStates, [true, false]);
      },
    );

    test('Debe capturar error si falla alguna petición de KPIs', () async {
      when(
        () => mockRepository.getAdmissionsByService(
          any(),
          month: any(named: 'month'),
        ),
      ).thenThrow(AuthException('Error al cargar KPIs de admisiones'));
      when(
        () => mockRepository.getAdmissionsByDoctor(
          any(),
          month: any(named: 'month'),
        ),
      ).thenAnswer((_) async => fakeDoctorData);
      when(
        () => mockRepository.getExitus(any(), month: any(named: 'month')),
      ).thenAnswer((_) async => fakeMonthValue);
      when(
        () => mockRepository.getAvgStay(any(), month: any(named: 'month')),
      ).thenAnswer((_) async => fakeMonthValue);
      when(
        () => mockRepository.getAvgStayByDoctor(
          any(),
          month: any(named: 'month'),
        ),
      ).thenAnswer((_) async => fakeDoctorData);

      await viewModel.loadAll();

      expect(viewModel.admissionsByService, isEmpty);
      expect(viewModel.errorMessage, 'Error al cargar KPIs de admisiones');
      expect(viewModel.isLoading, isFalse);
    });
  });

  group('KpisViewModel - changeFilters', () {
    test('Debe cambiar los filtros y recargar los datos', () async {
      when(
        () => mockRepository.getAdmissionsByService(
          any(),
          month: any(named: 'month'),
        ),
      ).thenAnswer((_) async => fakeMonthValue);
      when(
        () => mockRepository.getAdmissionsByDoctor(
          any(),
          month: any(named: 'month'),
        ),
      ).thenAnswer((_) async => fakeDoctorData);
      when(
        () => mockRepository.getExitus(any(), month: any(named: 'month')),
      ).thenAnswer((_) async => fakeMonthValue);
      when(
        () => mockRepository.getAvgStay(any(), month: any(named: 'month')),
      ).thenAnswer((_) async => fakeMonthValue);
      when(
        () => mockRepository.getAvgStayByDoctor(
          any(),
          month: any(named: 'month'),
        ),
      ).thenAnswer((_) async => fakeDoctorData);

      await viewModel.changeFilters(year: 2023, month: 5);

      expect(viewModel.selectedYear, 2023);
      expect(viewModel.selectedMonth, 5);
      expect(viewModel.isMonthlyView, isTrue);

      verify(
        () => mockRepository.getAdmissionsByService(2023, month: 5),
      ).called(1);
    });
  });

  group('KpisViewModel - helpers', () {
    test('totalValue debe sumar correctamente', () {
      final data = [
        KpiMonthValue(month: 1, value: 10),
        KpiMonthValue(month: 2, value: 15),
      ];
      expect(viewModel.totalValue(data), 25.0);
    });

    test('singleValue debe retornar el primer valor', () {
      final data = [KpiMonthValue(month: 1, value: 42.0)];
      expect(viewModel.singleValue(data), 42.0);
      expect(viewModel.singleValue([]), 0.0);
    });

    test('doctorSingleValue debe retornar el valor del doctor', () {
      final doctor = KpiDoctorData(
        doctorId: 'doc-1',
        doctorName: 'Pepe',
        doctorSurname: 'Jiménez',
        data: [KpiMonthValue(month: 1, value: 100)],
      );
      expect(viewModel.doctorSingleValue(doctor), 100.0);
    });
  });
}
