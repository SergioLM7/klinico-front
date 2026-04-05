import 'package:flutter/material.dart';
import '../../data/repositories/admission_repository.dart';
import '../../data/models/admission_response.dart';

class AdmissionViewModel extends ChangeNotifier {
  final AdmissionRepository _repository;

  bool _isLoading = false;
  String? _errorMessage;
  List<AdmissionResponse> _admissions = [];

  AdmissionViewModel({required AdmissionRepository repository})
    : _repository = repository;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<AdmissionResponse> get admissions => _admissions;

  Future<void> getUserAdmissions(String doctorId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _admissions = await _repository.getMyAdmissions(doctorId: doctorId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
