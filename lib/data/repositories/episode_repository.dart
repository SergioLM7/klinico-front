import '../../core/api_client.dart';
import '../models/episode_response.dart';

class EpisodeRepository {
  final ApiClient _apiClient;

  EpisodeRepository(this._apiClient);

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
