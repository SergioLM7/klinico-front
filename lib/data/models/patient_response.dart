class PatientResponse {
  final String patientId;
  final String name;
  final String surname;
  final DateTime birthdate;
  final String sex;
  final String? address;
  final String? contactNumber;
  final String? relativeContactNumber;
  final String status;

  PatientResponse({
    required this.patientId,
    required this.name,
    required this.surname,
    required this.birthdate,
    required this.sex,
    this.address,
    this.contactNumber,
    this.relativeContactNumber,
    required this.status,
  });

  factory PatientResponse.fromJson(Map<String, dynamic> json) {
    return PatientResponse(
      patientId: json['patientId'] as String,
      name: json['name'] as String,
      surname: json['surname'] as String,
      birthdate: DateTime.parse(json['birthdate'] as String),
      sex: json['sex'].toString(),
      address: json['address'] as String?,
      contactNumber: json['contactNumber'] as String?,
      relativeContactNumber: json['relativeContactNumber'] as String?,
      status: json['status'] as String,
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
