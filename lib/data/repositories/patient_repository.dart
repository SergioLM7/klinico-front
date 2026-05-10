import '../../core/api_client.dart';
import '../models/patient_response.dart';

/// Repositorio de pacientes.
///
/// Permite buscar pacientes registrados en el sistema por apellido
/// a través del endpoint paginado `GET /patients/search`.
class PatientRepository {
  final ApiClient _apiClient;

  PatientRepository(this._apiClient);

  /// Busca pacientes cuyo apellido contenga [surname], con paginación.
  Future<List<PatientResponse>> searchBySurname(
    String surname, {
    int page = 0,
    int size = 10,
  }) async {
    try {
      final response = await _apiClient.get(
        "/patients/search",
        queryParams: {"surname": surname, "page": page, "size": size},
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
          throw Exception("Estructura de respuesta no soportada: $payload");
        }
      } else {
        throw Exception("Estructura de respuesta no soportada: $payload");
      }

      return content.map((json) => PatientResponse.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }
}
