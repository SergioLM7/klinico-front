import '../../core/api_client.dart';
import '../models/admission_response.dart';
import '../models/admission_update_response.dart';
import '../models/paginated_admission_result.dart';
import '../models/patient_preview_response.dart';

class AdmissionRepository {
  final ApiClient _apiClient;

  AdmissionRepository(this._apiClient);

  Future<List<AdmissionResponse>> getMyAdmissions({
    required String doctorId,
    int page = 0,
  }) async {
    try {
      // El Interceptor ya añadirá el Token automáticamente
      final response = await _apiClient.get(
        "/admissions/doctor/$doctorId",
        queryParams: {"page": page},
      );
      final payload = response.data;
      Iterable content;
      if (payload is List) {
        content = payload;
      } else if (payload is Map) {
        if (payload.containsKey('data')) {
          content = payload['data'];
        } else if (payload.containsKey('content')) {
          content = payload['content'];
        } else {
          throw Exception(
            "Estructura de respuesta no soportada (sin 'data' o 'content'): $payload",
          );
        }
      } else {
        throw Exception("Estructura de respuesta no soportada: $payload");
      }

      return content.map((json) => AdmissionResponse.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<PaginatedAdmissionResult> searchBySurname({
    required String surname,
    int page = 0,
  }) async {
    try {
      final response = await _apiClient.get(
        "/admissions/search",
        queryParams: {"surname": surname, "page": page},
      );
      final payload = response.data;

      if (payload is! Map) {
        throw Exception("Estructura de respuesta no soportada: $payload");
      }

      Iterable rawContent;
      if (payload.containsKey('data')) {
        rawContent = payload['data'];
      } else if (payload.containsKey('content')) {
        rawContent = payload['content'];
      } else {
        throw Exception(
          "Estructura de respuesta no soportada (sin 'data' o 'content'): $payload",
        );
      }

      final parsedList = rawContent
          .map((json) => AdmissionResponse.fromJson(json))
          .toList();

      return PaginatedAdmissionResult.fromJson(
        Map<String, dynamic>.from(payload),
        parsedList,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> createAdmission({
    required String patientId,
    required String serviceId,
    required String principalDiagnosis,
    required String medicalHistory,
    String? allergies,
    String? chronicTreatment,
    int? basalBarthel,
  }) async {
    try {
      final body = {
        "patientId": patientId,
        "serviceId": serviceId,
        "principalDiagnosis": principalDiagnosis,
        "medicalHistory": medicalHistory,
        if (allergies != null && allergies.isNotEmpty) "allergies": allergies,
        if (chronicTreatment != null && chronicTreatment.isNotEmpty)
          "chronicTreatment": chronicTreatment,
        "basalBarthel": ?basalBarthel,
      };

      final response = await _apiClient.post("/admissions/create", data: body);

      return response.statusCode != null && response.statusCode == 201;
    } catch (e) {
      throw Exception("Error creando ingreso: $e");
    }
  }

  Future<bool> dischargeAdmission(String admissionId) async {
    try {
      final response = await _apiClient.put(
        "/admissions/discharge/$admissionId",
      );
      return response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }

  Future<AdmissionResponse> clinicalUpdate({
    required String admissionId,
    required String principalDiagnosis,
    required String medicalHistory,
    required PatientPreviewResponse patient,
    String? allergies,
    String? chronicTreatment,
    int? basalBarthel,
  }) async {
    try {
      final response = await _apiClient.put(
        "/admissions/clinical-update/$admissionId",
        data: {
          "principalDiagnosis": principalDiagnosis,
          "medicalHistory": medicalHistory,
          "allergies": allergies,
          "chronicTreatment": chronicTreatment,
          "basalBarthel": basalBarthel,
        },
      );

      final payload = response.data;
      Map<String, dynamic> jsonData;

      if (payload is Map<String, dynamic> && payload.containsKey('data')) {
        jsonData = payload['data'] as Map<String, dynamic>;
      } else {
        jsonData = payload as Map<String, dynamic>;
      }

      final update = AdmissionUpdateResponse.fromJson(jsonData);
      return update.toFullResponse(patient);
    } catch (e) {
      rethrow;
    }
  }

  Future<AdmissionResponse> assignDoctor({
    required String admissionId,
    required String doctorId,
    required PatientPreviewResponse patient,
  }) async {
    try {
      final response = await _apiClient.patch(
        "/admissions/assign-doctor/$admissionId?doctorId=$doctorId",
      );

      final payload = response.data;
      Map<String, dynamic> jsonData;

      if (payload is Map<String, dynamic> && payload.containsKey('data')) {
        jsonData = payload['data'] as Map<String, dynamic>;
      } else {
        jsonData = payload as Map<String, dynamic>;
      }

      // Si el endpoint devuelve el paciente o no, intentamos recuperarlo igual que en clinicalUpdate
      if (jsonData.containsKey('patient') && jsonData['patient'] != null) {
        return AdmissionResponse.fromJson(jsonData);
      } else {
        final update = AdmissionUpdateResponse.fromJson(jsonData);
        return update.toFullResponse(patient);
      }
    } catch (e) {
      rethrow;
    }
  }
}
