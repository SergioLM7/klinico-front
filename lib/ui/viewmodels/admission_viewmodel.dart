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

  Future<bool> createAdmission({
    required String patientId,
    required String principalDiagnosis,
    required String medicalHistory,
    String? allergies,
    String? chronicTreatment,
    int? basalBarthel,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _repository.createAdmission(
        patientId: patientId,
        principalDiagnosis: principalDiagnosis,
        medicalHistory: medicalHistory,
        allergies: allergies,
        chronicTreatment: chronicTreatment,
        basalBarthel: basalBarthel,
      );
      return success;
    } catch (e) {
      _errorMessage = e.toString().replaceAll("Exception: ", "");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
