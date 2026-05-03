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

  factory PatientPreviewResponse.fromJson(Map<String, dynamic> json) {
    return PatientPreviewResponse(
      patientId: json['patientId'] as String,
      name: json['name'] as String,
      surname: json['surname'] as String,
      birthdate: DateTime.parse(json['birthdate'] as String),
      sex: json['sex'].toString(),
    );
  }

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
