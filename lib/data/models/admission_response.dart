import '../../core/models/admission.dart';
import 'patient_preview_response.dart';

/// DTO de respuesta de la API para un ingreso hospitalario.
///
/// Incluye el paciente embebido como [PatientPreviewResponse].
/// Las fechas se reciben como cadenas ISO-8601 generadas por
/// `LocalDateTime` de Spring Boot y se parsean a [DateTime].
class AdmissionResponse {
  final String admissionId;
  final PatientPreviewResponse patient;
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
  final DateTime? lastModifiedAt;
  final String? lastModifiedBy;

  AdmissionResponse({
    required this.admissionId,
    required this.patient,
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

  /// Parsea el JSON de la API incluyendo el sub-objeto `patient` y las
  /// fechas ISO-8601 opcionales (`dischargeDate`, `lastModifiedAt`).
  factory AdmissionResponse.fromJson(Map<String, dynamic> json) {
    return AdmissionResponse(
      admissionId: json['admissionId'] as String,
      patient: PatientPreviewResponse.fromJson(json['patient'] as Map<String, dynamic>),
      serviceId: json['serviceId'] as String,
      assignedDoctorId: json['assignedDoctorId'] as String,

      // LocalDateTime handling (ISO-8601 strings from Spring Boot LocalDateTime)
      dischargeDate: json['dischargeDate'] != null
          ? DateTime.parse(json['dischargeDate'] as String)
          : null,
      hospitalizationLength: json['hospitalizationLength'] as int?,

      principalDiagnosis: json['principalDiagnosis'] as String?,
      medicalHistory: json['medicalHistory'] as String?,
      allergies: json['allergies'] as String?,
      chronicTreatment: json['chronicTreatment'] as String?,
      basalBarthel: json['basalBarthel'] as int?,
      roomNumber: json['roomNumber'] as int?,

      createdAt: DateTime.parse(json['createdAt'] as String),
      createdBy: json['createdBy'] as String,
      lastModifiedAt: json['lastModifiedAt'] != null
          ? DateTime.parse(json['lastModifiedAt'] as String)
          : null,
      lastModifiedBy: json['lastModifiedBy'] as String?,
    );
  }

  /// Convierte este DTO en la entidad de dominio [Admission],
  /// extrayendo el `patientId` del objeto [patient] embebido.
  Admission toDomain() {
    return Admission(
      admissionId: admissionId,
      patientId: patient.patientId,
      serviceId: serviceId,
      assignedDoctorId: assignedDoctorId,
      dischargeDate: dischargeDate,
      hospitalizationLength: hospitalizationLength,
      principalDiagnosis: principalDiagnosis,
      medicalHistory: medicalHistory,
      allergies: allergies,
      chronicTreatment: chronicTreatment,
      basalBarthel: basalBarthel,
      roomNumber: roomNumber,
      createdAt: createdAt,
      createdBy: createdBy,
      lastModifiedAt: lastModifiedAt,
      lastModifiedBy: lastModifiedBy,
    );
  }
}
