class PaginatedAdmissionResult {
  final List<dynamic> content;
  final int totalElements;
  final int totalPages;
  final int currentPage;
  final bool isLast;

  PaginatedAdmissionResult({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.currentPage,
    required this.isLast,
  });

  factory PaginatedAdmissionResult.fromJson(Map<String, dynamic> json, List<dynamic> parsedContent) {
    return PaginatedAdmissionResult(
      content: parsedContent,
      totalElements: json['totalElements'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 0,
      currentPage: json['currentPage'] as int? ?? 0,
      isLast: json['isLast'] as bool? ?? true,
    );
  }
}
