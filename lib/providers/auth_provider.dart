import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'token_store.dart';

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
  String get userName => _user?['name'] as String? ?? 'Pengguna';
  String get userEmail => _user?['email'] as String? ?? '';
  String get userRole => _user?['role'] as String? ?? '';
  String get userNim => _user?['nim'] as String? ?? '-';
  String get userProdi => _user?['prodi'] as String? ?? 'Teknik Informatika';
  String get userFakultas => _user?['fakultas'] as String? ?? 'Ilmu Komputer';
  String get userAngkatan => _user?['angkatan'] as String? ?? '-';

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
      await saveToken(result['data']['token']);
      debugPrint('token tersimpan: ${await readToken()}');
      _errorMessage = null;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'] ?? 'Login gagal.';
      notifyListeners();
      return false;
    }
  }

  /// Reset Password
  Future<bool> resetPassword({
    required String email,
    required String newPassword,
    required String confirmPassword,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await AuthService.resetPassword(
      email: email,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );

    _isLoading = false;

    if (result['success'] == true) {
      _errorMessage = null;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'] ?? 'Gagal menyetel ulang password.';
      notifyListeners();
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await AuthService.logout();
    await clearToken();

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
