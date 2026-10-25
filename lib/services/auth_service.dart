import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/token_store.dart'; // flutter_secure_storage untuk token

class AuthService {
  // Gunakan 10.0.2.2 untuk Android emulator, localhost untuk Web/Desktop
  // Ubah ke IP lokal jika testing di device fisik
  static const String _baseUrl = 'http://10.0.2.2:3000/api/auth';
  static const String _baseUrlWeb = 'http://localhost:3000/api/auth';

  static const String _tokenKey = 'auth_token'; // hanya untuk membersihkan token lama
  static const String _userKey = 'auth_user';

  /// Deteksi base URL berdasarkan platform
  static String get baseUrl {
    // Untuk Flutter Web, gunakan localhost
    // Untuk Android emulator, gunakan 10.0.2.2
    // Bisa diubah sesuai kebutuhan
    return const bool.fromEnvironment('dart.library.js_util')
        ? _baseUrlWeb
        : _baseUrl;
  }

  // ─────────────────────────────────────────
  // LOGIN
  // ─────────────────────────────────────────
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email.trim(),
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        // Token -> secure storage, data user -> SharedPreferences
        await _saveToken(data['data']['token']);
        await _saveUser(data['data']['user']);
      }

      return data;
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal terhubung ke server. Pastikan backend berjalan.\n($e)',
      };
    }
  }

  // ─────────────────────────────────────────
  // RESET / LUPA PASSWORD
  // ─────────────────────────────────────────
  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email.trim(),
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        }),
      );

      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal terhubung ke server. Pastikan backend berjalan.\n($e)',
      };
    }
  }

  // ─────────────────────────────────────────
  // LOGOUT
  // ─────────────────────────────────────────
  static Future<Map<String, dynamic>> logout() async {
    try {
      final token = await getToken();
      if (token == null) {
        await _clearSession();
        return {'success': true, 'message': 'Sesi sudah berakhir.'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      // Selalu hapus session lokal, apapun response server
      await _clearSession();

      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      // Tetap hapus session lokal meskipun gagal hubungi server
      await _clearSession();
      return {
        'success': true,
        'message': 'Logout lokal berhasil (server tidak terjangkau).',
      };
    }
  }

  // ─────────────────────────────────────────
  // GET PROFILE
  // ─────────────────────────────────────────
  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'Token tidak ditemukan.'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal mengambil profil.\n($e)',
      };
    }
  }

  // ─────────────────────────────────────────
  // LOCAL TOKEN & USER MANAGEMENT
  // ─────────────────────────────────────────

  /// Simpan JWT token ke SECURE STORAGE (terenkripsi), bukan SharedPreferences
  static Future<void> _saveToken(String token) async {
    await saveToken(token);
  }

  /// Simpan user data ke SharedPreferences
  static Future<void> _saveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user));
  }

  /// Ambil JWT token dari secure storage
  static Future<String?> getToken() async {
    return await readToken();
  }

  /// Ambil user data yang tersimpan
  static Future<Map<String, dynamic>?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString(_userKey);
    if (userStr == null) return null;
    return jsonDecode(userStr);
  }

  /// Cek apakah user sudah login (ada token tersimpan)
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Hapus session lokal (token + user data)
  static Future<void> _clearSession() async {
    await clearToken(); // hapus token di secure storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey); // bersihkan sisa token lama (versi sebelumnya)
    await prefs.remove(_userKey);
  }
}
