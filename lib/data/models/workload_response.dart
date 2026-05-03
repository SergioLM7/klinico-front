class WorkloadResponse {
  final String name;
  final String surname;
  final int admissionsAssigned;

  WorkloadResponse({
    required this.name,
    required this.surname,
    required this.admissionsAssigned,
  });

  factory WorkloadResponse.fromJson(Map<String, dynamic> json) {
    return WorkloadResponse(
      name: json['name'] as String,
      surname: json['surname'] as String,
      admissionsAssigned: json['admissionsAssigned'] as int,
    );
  }
}
