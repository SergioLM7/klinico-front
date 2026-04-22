class KpiMonthValue {
  final int month;
  final double value;

  KpiMonthValue({required this.month, required this.value});

  factory KpiMonthValue.fromJson(Map<String, dynamic> json) {
    return KpiMonthValue(
      month: json['month'] as int,
      value: (json['value'] as num).toDouble(),
    );
  }
}
