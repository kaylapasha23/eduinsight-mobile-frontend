import 'package:shared_preferences/shared_preferences.dart';

const _tokenKey = 'access_token';

// Simpan token — pakai SharedPreferences agar persist setelah hard refresh di Flutter Web
Future<void> saveToken(String token) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_tokenKey, token);
}

// Baca token
Future<String?> readToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(_tokenKey);
}

// Hapus token saat logout
Future<void> clearToken() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(_tokenKey);
}
