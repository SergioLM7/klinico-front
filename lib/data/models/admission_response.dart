import '../../core/models/admission.dart';
import 'patient_preview_response.dart';

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
  final DateTime lastModifiedAt;
  final String lastModifiedBy;

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
    required this.lastModifiedAt,
    required this.lastModifiedBy,
  });

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
      lastModifiedAt: DateTime.parse(json['lastModifiedAt'] as String),
      lastModifiedBy: json['lastModifiedBy'] as String,
    );
  }

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
