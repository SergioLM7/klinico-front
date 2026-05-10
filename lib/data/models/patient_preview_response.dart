/// DTO resumido de paciente embebido dentro de [AdmissionResponse].
///
/// Contiene solo los datos básicos necesarios para mostrar al paciente
/// en listados de ingresos sin realizar una consulta adicional.
class PatientPreviewResponse {
  final String patientId;
  final String name;
  final String surname;
  final DateTime birthdate;
  final String sex;

  PatientPreviewResponse({
    required this.patientId,
    required this.name,
    required this.surname,
    required this.birthdate,
    required this.sex,
  });

  /// Crea una instancia a partir del sub-objeto `patient` del JSON de ingreso.
  factory PatientPreviewResponse.fromJson(Map<String, dynamic> json) {
    return PatientPreviewResponse(
      patientId: json['patientId'] as String,
      name: json['name'] as String,
      surname: json['surname'] as String,
      birthdate: DateTime.parse(json['birthdate'] as String),
      sex: json['sex'].toString(),
    );
  }

  /// Calcula la edad actual del paciente a partir de [birthdate],
  /// ajustando si aún no ha cumplido años en el año en curso.
  int get age {
    final today = DateTime.now();
    int age = today.year - birthdate.year;
    if (today.month < birthdate.month ||
        (today.month == birthdate.month && today.day < birthdate.day)) {
      age--;
    }
    return age;
  }
}
