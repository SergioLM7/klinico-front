import 'package:flutter/material.dart';
import '../../core/exceptions/auth_exception.dart';
import '../../data/repositories/auth_repository.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  bool _isLoading = false;
  String? _errorMessage;
  String? _userRole;
  String? _userName;
  String? _serviceId;

  LoginViewModel({required AuthRepository authRepository})
    : _authRepository = authRepository;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get userRole => _userRole;
  String? get userName => _userName;
  String? get serviceId => _serviceId;

  Future<bool> signIn(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _authRepository.signIn(email, password);

      _userRole = response.role;
      _userName = response.name;
      _serviceId = response.serviceId;

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

  /// Llamar al arrancar la app. Decodifica el JWT localmente, comprueba
  /// que no haya caducado y carga en memoria los claims disponibles.
  ///
  /// Devuelve [true] si la sesión sigue activa, [false] si ha caducado
  /// o no existe token (en cuyo caso el storage ya ha sido limpiado).
  ///
  /// Claims disponibles del JWT de Spring Boot:
  ///   role      → rol del usuario
  ///   surname   → apellido (usado como nombre de display al reiniciar)
  ///   serviceId → id del servicio asignado
  Future<bool> initialize() async {
    final claims = await _authRepository.initializeSession();
    if (claims == null) {
      _userRole = null;
      _userName = null;
      _serviceId = null;
      notifyListeners();
      return false;
    }

    _userRole = claims['role'] as String?;
    // En el JWT solo está el apellido; se usa como nombre de display
    // hasta que el usuario haga un login completo que devuelva 'name'
    _userName = claims['surname'] as String?;
    _serviceId = claims['serviceId']?.toString();

    notifyListeners();
    return true;
  }

  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _authRepository.logout();

      _userRole = null;
      _userName = null;
      _serviceId = null;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = "Error al cerrar sesión";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
