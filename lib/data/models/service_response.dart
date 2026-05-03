class ServiceResponse {
  final String serviceId;
  final String name;
  final bool active;

  ServiceResponse({
    required this.serviceId,
    required this.name,
    required this.active,
  });

  factory ServiceResponse.fromJson(Map<String, dynamic> json) {
    return ServiceResponse(
      serviceId: json['serviceId'] as String,
      name: json['name'] as String,
      active: json['active'] as bool,
    );
  }
}
