class Episode {
  final String episodeId;
  final String admissionId;
  final String doctorId;
  final String clinicalProgress;
  final String diagnosis;
  final int? bradenScore;
  final bool? camScore;
  final int? chads2Score;
  final DateTime createdAt;
  final String createdBy;
  final DateTime? lastModifiedAt;
  final String? lastModifiedBy;

  Episode({
    required this.episodeId,
    required this.admissionId,
    required this.doctorId,
    required this.clinicalProgress,
    required this.diagnosis,
    this.bradenScore,
    this.camScore,
    this.chads2Score,
    required this.createdAt,
    required this.createdBy,
    this.lastModifiedAt,
    this.lastModifiedBy,
  });
}
