/// DTO que asocia un valor KPI numérico a un mes concreto.
///
/// Utilizado en las gráficas de evolución mensual del dashboard
/// (ingresos, éxitus, estancia media, etc.).
class KpiMonthValue {
  final int month;
  final double value;

  KpiMonthValue({required this.month, required this.value});

  /// Crea una instancia a partir del JSON devuelto por el backend.
  /// El campo `value` se normaliza a [double] para soportar decimales.
  factory KpiMonthValue.fromJson(Map<String, dynamic> json) {
    return KpiMonthValue(
      month: json['month'] as int,
      value: (json['value'] as num).toDouble(),
    );
  }
}
