import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isLoggedIn = false;
  String? _errorMessage;
  Map<String, dynamic>? _user;
  String? _token;

  // Getters
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get user => _user;
  String? get token => _token;
  String get userName => _user?['name'] ?? 'Pengguna';
  String get userEmail => _user?['email'] ?? '';
  String get userRole => _user?['role'] ?? '';

  /// Inisialisasi — cek apakah sudah ada token tersimpan
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    final loggedIn = await AuthService.isLoggedIn();
    if (loggedIn) {
      _isLoggedIn = true;
      _user = await AuthService.getSavedUser();
      _token = await AuthService.getToken();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Login
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await AuthService.login(
      email: email,
      password: password,
    );

    _isLoading = false;

    if (result['success'] == true) {
      _isLoggedIn = true;
      _user = result['data']['user'];
      _token = result['data']['token'];
      _errorMessage = null;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'] ?? 'Login gagal.';
      notifyListeners();
      return false;
    }
  }

  /// Register
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String role = 'mahasiswa',
    String? nim,
    String? fakultas,
    String? prodi,
    String? angkatan,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await AuthService.register(
      name: name,
      email: email,
      password: password,
      role: role,
      nim: nim,
      fakultas: fakultas,
      prodi: prodi,
      angkatan: angkatan,
    );

    _isLoading = false;

    if (result['success'] == true) {
      _isLoggedIn = true;
      _user = result['data']['user'];
      _token = result['data']['token'];
      _errorMessage = null;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'] ?? 'Registrasi gagal.';
      notifyListeners();
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await AuthService.logout();

    _isLoggedIn = false;
    _user = null;
    _token = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
