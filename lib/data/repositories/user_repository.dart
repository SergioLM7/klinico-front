import 'package:klinico_front/data/models/workload_response.dart';

import '../../core/api_client.dart';
import '../models/user_response.dart';

class UserRepository {
  final ApiClient _apiClient;

  UserRepository(this._apiClient);

  Future<List<UserResponse>> searchBySurname(
    String surname, {
    int page = 0,
    int size = 10,
  }) async {
    try {
      final response = await _apiClient.get(
        "/users/search",
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

      return content.map((json) => UserResponse.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<WorkloadResponse>> getServiceWorkload({
    int page = 0,
    int size = 10,
  }) async {
    try {
      final response = await _apiClient.get(
        "/users/service-workload",
        queryParams: {"page": page, "size": size},
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

      return content.map((json) => WorkloadResponse.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }
}
