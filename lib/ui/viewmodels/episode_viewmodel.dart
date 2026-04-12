import 'package:flutter/material.dart';
import '../../core/exceptions/auth_exception.dart';
import '../../data/models/episode_response.dart';
import '../../data/repositories/episode_repository.dart';

class EpisodeViewModel extends ChangeNotifier {
  final EpisodeRepository _repository;

  bool _isLoading = false;
  String? _errorMessage;
  List<EpisodeResponse> _episodes = [];

  EpisodeViewModel({required EpisodeRepository repository})
    : _repository = repository;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<EpisodeResponse> get episodes => _episodes;

  Future<void> loadEpisodes(String admissionId) async {
    _isLoading = true;
    _errorMessage = null;
    _episodes = [];
    notifyListeners();

    try {
      _episodes = await _repository.getEpisodesByAdmission(
        admissionId: admissionId,
      );
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createEpisode({
    required String admissionId,
    required String doctorId,
    required String clinicalProgress,
    required String diagnosis,
    int? bradenScore,
    int? chads2Score,
    bool? camScore,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.createEpisode(
        admissionId: admissionId,
        doctorId: doctorId,
        clinicalProgress: clinicalProgress,
        diagnosis: diagnosis,
        bradenScore: bradenScore,
        chads2Score: chads2Score,
        camScore: camScore,
      );
      return true;
    } catch (e) {
      if (e is AuthException) {
        _errorMessage = e.message;
      } else {
        _errorMessage = "Error inesperado de conexión";
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
