import 'kpi_month_value.dart';

/// DTO de datos KPI desglosados por médico.
///
/// Contiene la identificación del profesional y su serie temporal de
/// [KpiMonthValue], usada para renderizar gráficas comparativas
/// entre médicos en el dashboard.
class KpiDoctorData {
  final String doctorId;
  final String doctorName;
  final String doctorSurname;
  final List<KpiMonthValue> data;

  KpiDoctorData({
    required this.doctorId,
    required this.doctorName,
    required this.doctorSurname,
    required this.data,
  });

  /// Parsea el JSON del backend incluyendo la lista anidada de [KpiMonthValue].
  factory KpiDoctorData.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'] as List<dynamic>;
    return KpiDoctorData(
      doctorId: json['doctorId'] as String,
      doctorName: json['doctorName'] as String,
      doctorSurname: json['doctorSurname'] as String,
      data: rawData.map((e) => KpiMonthValue.fromJson(e)).toList(),
    );
  }

  /// Nombre completo formateado con el prefijo «Dr.» para mostrar en la UI.
  String get fullName => 'Dr. $doctorName $doctorSurname';
}
