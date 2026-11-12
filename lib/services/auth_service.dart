import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/token_store.dart' as store;

class AuthService {
  // Daftar URL backend dengan port 5001 (utama) dan 3000 (cadangan)
  // Mendukung Android Emulator (10.0.2.2), Web/Desktop (localhost & 127.0.0.1), dan HP Fisik Wi-Fi (192.168.100.24)
  static const List<String> _candidateBaseUrls = [
    'http://10.0.2.2:5001/api/auth',
    'http://localhost:5001/api/auth',
    'http://127.0.0.1:5001/api/auth',
    'http://192.168.100.24:5001/api/auth',
    'http://10.0.2.2:3000/api/auth',
    'http://localhost:3000/api/auth',
    'http://192.168.100.24:3000/api/auth',
  ];

  static String? _cachedWorkingUrl;

  static const String _tokenKey = 'auth_token'; // hanya untuk membersihkan token lama
  static const String _userKey = 'auth_user';

  // ─────────────────────────────────────────
  // TOKEN (wrapper ke token_store.dart)
  // ─────────────────────────────────────────
  static Future<String?> getToken() => store.getToken();
  static Future<void> saveToken(String token) => store.saveToken(token);
  static Future<void> clearToken() => store.clearToken();

  /// Helper untuk POST dengan mencoba semua kandidat URL otomatis
  static Future<http.Response> _postWithFallback(
    String endpoint, {
    required Map<String, dynamic> body,
    Map<String, String>? headers,
  }) async {
    final mergedHeaders = {
      'Content-Type': 'application/json',
      ...?headers,
    };
    final encodedBody = jsonEncode(body);

    if (_cachedWorkingUrl != null) {
      try {
        final res = await http
            .post(
              Uri.parse('$_cachedWorkingUrl/$endpoint'),
              headers: mergedHeaders,
              body: encodedBody,
            )
            .timeout(const Duration(seconds: 4));
        return res;
      } catch (e) {
        debugPrint('Gagal di $_cachedWorkingUrl: $e');
        _cachedWorkingUrl = null;
      }
    }

    for (final base in _candidateBaseUrls) {
      try {
        final res = await http
            .post(
              Uri.parse('$base/$endpoint'),
              headers: mergedHeaders,
              body: encodedBody,
            )
            .timeout(const Duration(seconds: 3));
        _cachedWorkingUrl = base;
        return res;
      } catch (e) {
        debugPrint('Gagal di $base: $e');
        // coba kandidat berikutnya
      }
    }

    throw Exception(
      'Tidak dapat terhubung ke server backend di port 5001 maupun 3000. Pastikan node server.js sedang berjalan.',
    );
  }

  /// Helper untuk GET dengan mencoba semua kandidat URL otomatis
  static Future<http.Response> _getWithFallback(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    if (_cachedWorkingUrl != null) {
      try {
        final res = await http
            .get(
              Uri.parse('$_cachedWorkingUrl/$endpoint'),
              headers: headers,
            )
            .timeout(const Duration(seconds: 4));
        return res;
      } catch (e) {
        debugPrint('Gagal di $_cachedWorkingUrl: $e');
        _cachedWorkingUrl = null;
      }
    }

    for (final base in _candidateBaseUrls) {
      try {
        final res = await http
            .get(
              Uri.parse('$base/$endpoint'),
              headers: headers,
            )
            .timeout(const Duration(seconds: 3));
        _cachedWorkingUrl = base;
        return res;
      } catch (e) {
        debugPrint('Gagal di $base: $e');
        // coba kandidat berikutnya
      }
    }

    throw Exception('Tidak dapat terhubung ke backend.');
  }

  // ─────────────────────────────────────────
  // LOGIN
  // ─────────────────────────────────────────
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _postWithFallback(
        'login',
        body: {
          'email': email.trim(),
          'password': password,
        },
      );

      final decoded = jsonDecode(response.body);
      final Map<String, dynamic> data =
          decoded is Map<String, dynamic> ? decoded : {};

      if (response.statusCode == 200 && data['success'] == true) {
        // Dukung 2 bentuk: {data:{token,user}} atau {token,user} di level atas
        final payload = (data['data'] is Map<String, dynamic>)
            ? data['data'] as Map<String, dynamic>
            : data;

        final token = payload['token']?.toString();
        final user = payload['user'];

        if (token == null || token.isEmpty) {
          return {
            'success': false,
            'message': 'Server tidak mengirim token. Respons: ${response.body}',
          };
        }

        await _saveToken(token);
        if (user is Map<String, dynamic>) {
          await _saveUser(user);
        }

        // Seragamkan bentuk supaya AuthProvider tetap membaca result['data']
        return {
          'success': true,
          'message': data['message'],
          'data': {'token': token, 'user': user},
        };
      }

      return data.isNotEmpty
          ? data
          : {'success': false, 'message': 'Respons server tidak valid.'};
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
      final response = await _postWithFallback(
        'reset-password',
        body: {
          'email': email.trim(),
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        },
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

      final response = await _postWithFallback(
        'logout',
        body: {},
        headers: {
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

      final response = await _getWithFallback(
        'profile',
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

  /// Simpan JWT token lewat token_store (SharedPreferences)
  static Future<void> _saveToken(String token) async {
    await saveToken(token);
  }

  /// Simpan user data ke SharedPreferences
  static Future<void> _saveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user));
  }

  /// Ambil user data dari SharedPreferences
  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString(_userKey);
    if (userString == null) return null;
    try {
      return jsonDecode(userString);
    } catch (_) {
      return null;
    }
  }

  /// Alias dari getUser (dipakai oleh AuthProvider)
  static Future<Map<String, dynamic>?> getSavedUser() => getUser();

  /// Bersihkan session (logout)
  static Future<void> _clearSession() async {
    await clearToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove(_tokenKey); // bersihkan jika ada token lama
  }

  /// Cek apakah user sedang login
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}