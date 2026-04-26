import 'package:flutter/material.dart';

import '../../data/models/workload_response.dart';
import '../../data/repositories/user_repository.dart';

class WorkloadViewmodel extends ChangeNotifier {
  final UserRepository _repository;

  bool _isLoading = false;
  String? _errorMessage;
  List<WorkloadResponse> _workload = [];

  WorkloadViewmodel({required UserRepository repository})
    : _repository = repository;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<WorkloadResponse> get workload => _workload;

  Future<void> getServiceWorkload() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _workload = await _repository.getServiceWorkload();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
