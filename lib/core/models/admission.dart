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
  final int? basalBarthel;
  final int? roomNumber;

  final DateTime createdAt;
  final String createdBy;
  final DateTime lastModifiedAt;
  final String lastModifiedBy;

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
    required this.lastModifiedAt,
    required this.lastModifiedBy,
  });
}
