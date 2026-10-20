import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const storage = FlutterSecureStorage();

// Simpan token setelah login berhasil
Future<void> saveToken(String token) =>
    storage.write(key: 'access_token', value: token);

// Baca token saat dibutuhkan
Future<String?> readToken() => storage.read(key: 'access_token');

// Hapus semua saat logout
Future<void> clearToken() => storage.deleteAll();