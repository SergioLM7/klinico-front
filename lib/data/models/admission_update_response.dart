import 'admission_response.dart';
import 'patient_preview_response.dart';

/// DTO parcial devuelto por `PUT /admissions/clinical-update` y
/// `PATCH /admissions/assign-doctor`.
///
/// A diferencia de [AdmissionResponse], no incluye el objeto paciente
/// embebido. Usa [toFullResponse] para reconstruir un [AdmissionResponse]
/// completo inyectando el [PatientPreviewResponse] disponible en caché.
class AdmissionUpdateResponse {
  final String admissionId;
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

  AdmissionUpdateResponse({
    required this.admissionId,
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

  /// Parsea el JSON parcial de la API (sin objeto `patient`).
  factory AdmissionUpdateResponse.fromJson(Map<String, dynamic> json) {
    return AdmissionUpdateResponse(
      admissionId: json['admissionId'] as String,
      serviceId: json['serviceId'] as String,
      assignedDoctorId: json['assignedDoctorId'] as String,
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

  /// Convierte este DTO parcial en un [AdmissionResponse] completo
  /// inyectando el [patient] que la API no incluye en esta respuesta.
  AdmissionResponse toFullResponse(PatientPreviewResponse patient) {
    return AdmissionResponse(
      admissionId: admissionId,
      patient: patient,
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
