import 'package:flutter/material.dart';
import '../../data/repositories/episode_repository.dart';
import '../../data/models/episode_response.dart';

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
}
