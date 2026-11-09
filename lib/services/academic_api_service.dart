import 'dart:convert';
import 'package:http/http.dart' as http;
import '../database/app_database.dart';

class AcademicApiService {
  // Mendukung Android Emulator (10.0.2.2), Windows / Desktop / Web (localhost & 127.0.0.1)
  // serta port 5001 dan port 3000
  static const List<String> _baseUrls = [
    'http://10.0.2.2:5001/api',
    'http://localhost:5001/api',
    'http://127.0.0.1:5001/api',
    'http://10.0.2.2:3000/api',
    'http://localhost:3000/api',
  ];

  static Future<http.Response?> _getWithFallback(String endpoint) async {
    for (final base in _baseUrls) {
      try {
        final res = await http
            .get(Uri.parse('$base/$endpoint'))
            .timeout(const Duration(seconds: 3));
        if (res.statusCode == 200) {
          return res;
        }
      } catch (_) {
        // Coba port/host berikutnya
      }
    }
    return null;
  }

  /// Sinkronisasi Kehadiran dari Express.js lalu simpan ke SQLite Drift
  static Future<bool> syncKehadiran() async {
    try {
      final res = await _getWithFallback('kehadiran');
      if (res != null) {
        final body = jsonDecode(res.body);
        if (body['success'] == true && body['data'] is List) {
          final List list = body['data'];
          final List<Map<String, dynamic>> converted =
              list.map((e) => Map<String, dynamic>.from(e)).toList();
          await AppDb.instance.saveKehadiranToDrift(converted);
          return true;
        }
      }
    } catch (e) {
      // Offline fallback
    }
    return false;
  }

  /// Sinkronisasi Nilai dari Express.js lalu simpan ke SQLite Drift
  static Future<bool> syncNilai() async {
    try {
      final res = await _getWithFallback('penilaian');
      if (res != null) {
        final body = jsonDecode(res.body);
        if (body['success'] == true && body['data'] is List) {
          final List list = body['data'];
          final List<Map<String, dynamic>> converted =
              list.map((e) => Map<String, dynamic>.from(e)).toList();
          await AppDb.instance.saveNilaiToDrift(converted);
          return true;
        }
      }
    } catch (e) {
      // Offline fallback
    }
    return false;
  }
}
