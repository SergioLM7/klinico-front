import 'package:flutter_test/flutter_test.dart';
import 'package:klinico_front/data/models/patient_preview_response.dart';

void main() {
  group('PatientPreviewResponse - age getter', () {
    test(
      'Debe calcular la edad correctamente si ya ha cumplido años este año',
      () {
        final birthdate = DateTime(1990, 1, 1);
        final patient = PatientPreviewResponse(
          patientId: '1',
          name: 'Test',
          surname: 'User',
          birthdate: birthdate,
          sex: 'M',
        );

        final expectedAge = DateTime.now().year - 1990;
        expect(patient.age, expectedAge);
      },
    );

    test(
      'Debe calcular la edad correctamente si aún no ha cumplido años este año',
      () {
        final today = DateTime.now();
        final birthdate = DateTime(today.year - 20, today.month + 1, today.day);

        final patient = PatientPreviewResponse(
          patientId: '1',
          name: 'Test',
          surname: 'User',
          birthdate: birthdate,
          sex: 'M',
        );

        expect(patient.age, 19);
      },
    );
  });
}
