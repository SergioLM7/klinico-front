import 'package:flutter/material.dart';

import '../../data/models/kpi_doctor_data.dart';
import '../../data/models/kpi_month_value.dart';
import '../../data/repositories/kpis_repository.dart';

class KpisViewModel extends ChangeNotifier {
  final KpisRepository _repository;

  KpisViewModel({required KpisRepository repository})
    : _repository = repository;

  int _selectedYear = DateTime.now().year;
  int? _selectedMonth;

  int get selectedYear => _selectedYear;
  int? get selectedMonth => _selectedMonth;
  bool get isMonthlyView => _selectedMonth != null;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<KpiMonthValue> _admissionsByService = [];
  List<KpiDoctorData> _admissionsByDoctor = [];
  List<KpiMonthValue> _exitus = [];
  List<KpiMonthValue> _avgStay = [];
  List<KpiDoctorData> _avgStayByDoctor = [];

  List<KpiMonthValue> get admissionsByService => _admissionsByService;
  List<KpiDoctorData> get admissionsByDoctor => _admissionsByDoctor;
  List<KpiMonthValue> get exitus => _exitus;
  List<KpiMonthValue> get avgStay => _avgStay;
  List<KpiDoctorData> get avgStayByDoctor => _avgStayByDoctor;

  //Carga inicial de todos los KPIs
  Future<void> loadAll() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.getAdmissionsByService(
          _selectedYear,
          month: _selectedMonth,
        ),
        _repository.getAdmissionsByDoctor(_selectedYear, month: _selectedMonth),
        _repository.getExitus(_selectedYear, month: _selectedMonth),
        _repository.getAvgStay(_selectedYear, month: _selectedMonth),
        _repository.getAvgStayByDoctor(_selectedYear, month: _selectedMonth),
      ]);

      _admissionsByService = results[0] as List<KpiMonthValue>;
      _admissionsByDoctor = results[1] as List<KpiDoctorData>;
      _exitus = results[2] as List<KpiMonthValue>;
      _avgStay = results[3] as List<KpiMonthValue>;
      _avgStayByDoctor = results[4] as List<KpiDoctorData>;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> changeFilters({required int year, int? month}) async {
    _selectedYear = year;
    _selectedMonth = month;
    await loadAll();
  }

  // --- Helpers para fl_chart ---

  /// Total acumulado de un List<KpiMonthValue> (útil para KPI cards mensuales).
  double totalValue(List<KpiMonthValue> data) =>
      data.fold(0.0, (sum, e) => sum + e.value);

  /// Valor único de un mes concreto (vista mensual).
  double singleValue(List<KpiMonthValue> data) =>
      data.isNotEmpty ? data.first.value : 0.0;

  /// Para médico en vista mensual: suma de sus values del único mes devuelto.
  double doctorSingleValue(KpiDoctorData doc) =>
      doc.data.isNotEmpty ? doc.data.first.value : 0.0;
}
