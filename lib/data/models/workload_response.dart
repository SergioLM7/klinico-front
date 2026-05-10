/// DTO de carga de trabajo de un médico, devuelto por
/// `GET /users/service-workload`.
///
/// Se utiliza para visualizar la distribución de ingresos activos
/// asignados a cada médico del servicio.
class WorkloadResponse {
  final String name;
  final String surname;
  final int admissionsAssigned;

  WorkloadResponse({
    required this.name,
    required this.surname,
    required this.admissionsAssigned,
  });

  /// Crea una instancia a partir del JSON devuelto por el backend.
  factory WorkloadResponse.fromJson(Map<String, dynamic> json) {
    return WorkloadResponse(
      name: json['name'] as String,
      surname: json['surname'] as String,
      admissionsAssigned: json['admissionsAssigned'] as int,
    );
  }
}
