import '../../core/api_client.dart';
import '../models/episode_response.dart';

/// Repositorio de episodios clínicos.
///
/// Cada ingreso hospitalario puede contener múltiples episodios (evoluciones diarias).
/// Este repositorio gestiona la lectura, creación y actualización de episodios
/// contra los endpoints REST `/episodes/*`.
class EpisodeRepository {
  final ApiClient _apiClient;

  EpisodeRepository(this._apiClient);

  /// Obtiene los episodios asociados a un ingreso vía `GET /episodes/{admissionId}`.
  Future<List<EpisodeResponse>> getEpisodesByAdmission({
    required String admissionId,
    int page = 0,
  }) async {
    try {
      final response = await _apiClient.get(
        "/episodes/$admissionId",
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
          throw Exception("Estructura de respuesta no soportada: $payload");
        }
      } else {
        throw Exception("Estructura de respuesta no soportada: $payload");
      }

      return content.map((json) => EpisodeResponse.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Actualiza un episodio existente vía `PUT /episodes/update/{id}`.
  ///
  /// Permite modificar la evolución clínica, diagnóstico y escalas de valoración.
  Future<Map<String, dynamic>> updateEpisode({
    required String episodeId,
    required String clinicalProgress,
    required String diagnosis,
    int? bradenScore,
    int? chads2Score,
    bool? camScore,
  }) async {
    try {
      final response = await _apiClient.put(
        "/episodes/update/$episodeId",
        data: {
          "clinicalProgress": clinicalProgress,
          "diagnosis": diagnosis,
          "bradenScore": bradenScore,
          "chads2Score": chads2Score,
          "camScore": camScore,
        },
      );

      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Crea un nuevo episodio clínico vía `POST /episodes/create`.
  ///
  /// Vincula el episodio al ingreso [admissionId] y al médico [doctorId].
  Future<Map<String, dynamic>> createEpisode({
    required String admissionId,
    required String doctorId,
    required String clinicalProgress,
    required String diagnosis,
    int? bradenScore,
    int? chads2Score,
    bool? camScore,
  }) async {
    try {
      final response = await _apiClient.post(
        "/episodes/create",
        data: {
          "admissionId": admissionId,
          "doctorId": doctorId,
          "clinicalProgress": clinicalProgress,
          "diagnosis": diagnosis,
          "bradenScore": bradenScore,
          "chads2Score": chads2Score,
          "camScore": camScore,
        },
      );

      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }
}
