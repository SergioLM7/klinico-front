import '../../core/models/episode.dart';

class EpisodeResponse {
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
  final String? createdByName;
  final DateTime? lastModifiedAt;
  final String? lastModifiedBy;

  EpisodeResponse({
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
    this.createdByName,
    this.lastModifiedAt,
    this.lastModifiedBy,
  });

  factory EpisodeResponse.fromJson(Map<String, dynamic> json) {
    return EpisodeResponse(
      episodeId: json['episodeId'] as String,
      admissionId: json['admissionId'] as String,
      doctorId: json['doctorId'] as String,
      clinicalProgress: json['clinicalProgress'] as String,
      diagnosis: json['diagnosis'] as String,
      bradenScore: json['bradenScore'] as int?,
      camScore: json['camScore'] as bool?,
      chads2Score: json['chads2Score'] as int?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      createdBy: json['createdBy'] as String,
      createdByName: json['createdByName'] as String?,
      lastModifiedAt: json['lastModifiedAt'] != null
          ? DateTime.parse(json['lastModifiedAt'] as String)
          : null,
      lastModifiedBy: json['lastModifiedBy'] as String?,
    );
  }

  Episode toDomain() {
    return Episode(
      episodeId: episodeId,
      admissionId: admissionId,
      doctorId: doctorId,
      clinicalProgress: clinicalProgress,
      diagnosis: diagnosis,
      bradenScore: bradenScore,
      camScore: camScore,
      chads2Score: chads2Score,
      createdAt: createdAt,
      createdBy: createdBy,
      createdByName: createdByName,
      lastModifiedAt: lastModifiedAt,
      lastModifiedBy: lastModifiedBy,
    );
  }
}
