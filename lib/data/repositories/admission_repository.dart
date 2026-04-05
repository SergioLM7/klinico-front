import '../../core/api_client.dart';
import '../models/admission_response.dart';

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
          throw Exception("Estructura de respuesta no soportada (sin 'data' o 'content'): $payload");
        }
      } else {
        throw Exception("Estructura de respuesta no soportada: $payload");
      }

      return content.map((json) => AdmissionResponse.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }
}
