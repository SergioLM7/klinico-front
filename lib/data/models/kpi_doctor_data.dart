import 'kpi_month_value.dart';

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

  factory KpiDoctorData.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'] as List<dynamic>;
    return KpiDoctorData(
      doctorId: json['doctorId'] as String,
      doctorName: json['doctorName'] as String,
      doctorSurname: json['doctorSurname'] as String,
      data: rawData.map((e) => KpiMonthValue.fromJson(e)).toList(),
    );
  }

  String get fullName => 'Dr. $doctorName $doctorSurname';
}
