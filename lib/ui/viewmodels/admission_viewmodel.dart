import 'package:flutter/material.dart';
import '../../core/exceptions/auth_exception.dart';
import '../../data/repositories/admission_repository.dart';
import '../../data/models/admission_response.dart';
import '../../data/models/patient_preview_response.dart';

/// ViewModel de ingresos hospitalarios.
///
/// Gestiona el ciclo de vida de los ingresos del médico autenticado:
/// carga, creación, alta, actualización clínica y reasignación de médico.
/// Mantiene en memoria la lista [admissions] y la actualiza tras cada operación.
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

  /// Carga los ingresos activos asignados al médico [doctorId].
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

  /// Crea un nuevo ingreso y devuelve `true` si el servidor confirma la creación.
  Future<bool> createAdmission({
    required String patientId,
    required String serviceId,
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
        serviceId: serviceId,
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

  /// Tramita el alta hospitalaria del ingreso [admissionId].
  Future<bool> dischargeAdmission(String admissionId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _repository.dischargeAdmission(admissionId);
      return success;
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

  /// Actualiza los datos clínicos de un ingreso (diagnóstico, historial, escalas).
  ///
  /// Devuelve el [AdmissionResponse] actualizado o `null` si falla.
  Future<AdmissionResponse?> clinicalUpdate({
    required String admissionId,
    required String principalDiagnosis,
    required String medicalHistory,
    required PatientPreviewResponse patient,
    String? allergies,
    String? chronicTreatment,
    int? basalBarthel,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _repository.clinicalUpdate(
        admissionId: admissionId,
        principalDiagnosis: principalDiagnosis,
        medicalHistory: medicalHistory,
        patient: patient,
        allergies: allergies,
        chronicTreatment: chronicTreatment,
        basalBarthel: basalBarthel,
      );
      return updated;
    } catch (e) {
      if (e is AuthException) {
        _errorMessage = e.message;
      } else {
        _errorMessage = "Error inesperado de conexión";
      }
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Reasigna un ingreso a otro médico y actualiza la lista local en memoria.
  Future<bool> assignDoctor(
    String admissionId,
    String doctorId,
    PatientPreviewResponse patient,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _repository.assignDoctor(
        admissionId: admissionId,
        doctorId: doctorId,
        patient: patient,
      );

      // Usar _admissions local para actualizar la tabla
      final index = _admissions.indexWhere((a) => a.admissionId == admissionId);
      if (index != -1) {
        _admissions[index] = updated;
      }

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
