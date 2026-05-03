import '../../core/api_client.dart';
import '../models/service_response.dart';

class ServiceRepository {
  final ApiClient _apiClient;

  ServiceRepository(this._apiClient);

  Future<List<ServiceResponse>> searchByName(
    String name, {
    int page = 0,
    int size = 5,
  }) async {
    try {
      final response = await _apiClient.get(
        "/services/search",
        queryParams: {"name": name, "page": page, "size": size},
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

      return content.map((json) => ServiceResponse.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }
}
