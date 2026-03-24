import 'package:flutter/material.dart';
import '../../core/exceptions/auth_exception.dart';
import '../../data/repositories/auth_repository.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  bool _isLoading = false;
  String? _errorMessage;
  String? _userRole;
  String? _userName;

  LoginViewModel({required AuthRepository authRepository})
    : _authRepository = authRepository;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get userRole => _userRole;
  String? get userName => _userName;

  Future<bool> signIn(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _authRepository.signIn(email, password);

      _userRole = response.role;
      _userName = response.name;

      return true;
    } catch (e) {
      if (e is AuthException) {
        _errorMessage = e.message;
      } else {
        _errorMessage = "Error de conexión inesperado";
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
