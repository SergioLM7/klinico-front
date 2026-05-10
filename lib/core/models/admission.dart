/// Entidad de dominio pura que representa un ingreso hospitalario.
///
/// No depende de la capa de datos ni de DTOs de la API.
/// Es el modelo que manejan los providers y la UI.
class Admission {
  final String admissionId;
  final String patientId;
  final String serviceId;
  final String assignedDoctorId;

  final DateTime? dischargeDate;
  final int? hospitalizationLength;

  final String? principalDiagnosis;
  final String? medicalHistory;
  final String? allergies;
  final String? chronicTreatment;

  /// Índice de Barthel basal: valoración funcional del paciente al ingreso
  /// (rango 0–100, donde 100 indica independencia total).
  final int? basalBarthel;
  final int? roomNumber;

  final DateTime createdAt;
  final String createdBy;
  final DateTime? lastModifiedAt;
  final String? lastModifiedBy;

  Admission({
    required this.admissionId,
    required this.patientId,
    required this.serviceId,
    required this.assignedDoctorId,
    this.dischargeDate,
    this.hospitalizationLength,
    this.principalDiagnosis,
    this.medicalHistory,
    this.allergies,
    this.chronicTreatment,
    this.basalBarthel,
    this.roomNumber,
    required this.createdAt,
    required this.createdBy,
    this.lastModifiedAt,
    this.lastModifiedBy,
  });
}
