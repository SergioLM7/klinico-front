/// Entidad de dominio pura que representa un episodio clínico (evolución)
/// asociado a un ingreso hospitalario.
///
/// No depende de la capa de datos ni de DTOs de la API.
/// Es el modelo que manejan los providers y la UI.
class Episode {
  final String episodeId;
  final String admissionId;
  final String doctorId;
  final String clinicalProgress;
  final String diagnosis;

  /// Escala de Braden: valora el riesgo de úlceras por presión (UPP).
  /// Rango 6–23; valores más bajos indican mayor riesgo.
  final int? bradenScore;

  /// Resultado del test CAM (Confusion Assessment Method): indica si el
  /// paciente presenta delirium (`true`) o no (`false`).
  final bool? camScore;

  /// Puntuación CHA₂DS₂-VASc: estima el riesgo tromboembólico en
  /// pacientes con fibrilación auricular. Rango 0–9.
  final int? chads2Score;
  final DateTime createdAt;
  final String createdBy;
  final String? createdByName;
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
    this.createdByName,
    this.lastModifiedAt,
    this.lastModifiedBy,
  });
}
