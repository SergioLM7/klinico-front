import '../../core/api_client.dart';
import '../models/kpi_month_value.dart';
import '../models/kpi_doctor_data.dart';

class KpisRepository {
  final ApiClient _apiClient;

  KpisRepository(this._apiClient);

  Map<String, dynamic> _buildParams(int year, {int? month}) {
    final params = <String, dynamic>{'year': year};
    if (month != null) params['month'] = month;
    return params;
  }

  List<KpiMonthValue> _parseMonthValueList(dynamic payload) {
    Iterable raw;
    if (payload is List) {
      raw = payload;
    } else if (payload is Map && payload.containsKey('data')) {
      raw = payload['data'];
    } else {
      throw Exception('Estructura de respuesta no soportada: $payload');
    }
    return raw.map((e) => KpiMonthValue.fromJson(e)).toList();
  }

  List<KpiDoctorData> _parseDoctorDataList(dynamic payload) {
    Iterable raw;
    if (payload is List) {
      raw = payload;
    } else if (payload is Map && payload.containsKey('data')) {
      raw = payload['data'];
    } else {
      throw Exception('Estructura de respuesta no soportada: $payload');
    }
    return raw.map((e) => KpiDoctorData.fromJson(e)).toList();
  }

  Future<List<KpiMonthValue>> getAdmissionsByService(
    int year, {
    int? month,
  }) async {
    final response = await _apiClient.get(
      '/kpis/admissions-by-service',
      queryParams: _buildParams(year, month: month),
    );
    return _parseMonthValueList(response.data);
  }

  Future<List<KpiDoctorData>> getAdmissionsByDoctor(
    int year, {
    int? month,
  }) async {
    final response = await _apiClient.get(
      '/kpis/admissions-by-doctor',
      queryParams: _buildParams(year, month: month),
    );
    return _parseDoctorDataList(response.data);
  }

  Future<List<KpiMonthValue>> getExitus(int year, {int? month}) async {
    final response = await _apiClient.get(
      '/kpis/exitus',
      queryParams: _buildParams(year, month: month),
    );
    return _parseMonthValueList(response.data);
  }

  Future<List<KpiMonthValue>> getAvgStay(int year, {int? month}) async {
    final response = await _apiClient.get(
      '/kpis/avg-stay',
      queryParams: _buildParams(year, month: month),
    );
    return _parseMonthValueList(response.data);
  }

  Future<List<KpiDoctorData>> getAvgStayByDoctor(int year, {int? month}) async {
    final response = await _apiClient.get(
      '/kpis/avg-stay-by-doctor',
      queryParams: _buildParams(year, month: month),
    );
    return _parseDoctorDataList(response.data);
  }
}
