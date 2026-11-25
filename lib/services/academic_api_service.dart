import 'dart:convert';
import 'package:http/http.dart' as http;
import '../database/app_database.dart';
import '../providers/token_store.dart' as store;

class AcademicApiService {
  // Mendukung Android Emulator (10.0.2.2), Windows / Desktop / Web (localhost & 127.0.0.1)
  // serta port 5001 dan port 3000
  static const List<String> _baseUrls = [
    'http://localhost:3000/api',
    'http://127.0.0.1:3000/api',
    'http://10.0.2.2:3000/api',
    'http://localhost:5001/api',
    'http://10.0.2.2:5001/api',
  ];

  static Future<http.Response?> _getWithFallback(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    for (final base in _baseUrls) {
      try {
        final res = await http
            .get(Uri.parse('$base/$endpoint'), headers: headers)
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

  /// Mengambil data evaluasi AI & catatan feedback dosen dari backend
  static Future<List<Map<String, dynamic>>?> fetchEvaluasi() async {
    try {
      final token = await store.getToken();
      final headers = <String, String>{
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

      final res = await _getWithFallback('evaluasi', headers: headers);
      if (res != null) {
        final dynamic body = jsonDecode(res.body);
        if (body is Map && body['success'] == true && body['data'] is List) {
          return (body['data'] as List)
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        } else if (body is List) {
          return body.map((e) => Map<String, dynamic>.from(e)).toList();
        }
      }
    } catch (e) {
      // Fallback silent
    }
    return null;
  }

  /// Mengambil persentase total kehadiran secara garis besar yang diinput dosen
  static Future<double?> fetchOverallAttendanceRate() async {
    try {
      final token = await store.getToken();
      final headers = <String, String>{
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };
      final res = await _getWithFallback('kehadiran?view=courses', headers: headers);
      if (res != null) {
        final body = jsonDecode(res.body);
        final list = body['data'] ?? body['courses'];
        if (list is List) {
          int totalHadir = 0;
          int totalPertemuan = 0;
          for (final c in list) {
            final riwayat = c['riwayat'] as List? ?? [];
            for (final p in riwayat) {
              totalPertemuan++;
              final st = p['status']?.toString().toLowerCase();
              if (st == 'hadir') totalHadir++;
            }
          }
          if (totalPertemuan > 0) {
            return (totalHadir / totalPertemuan) * 100.0;
          }
          return 0.0;
        }
      }
    } catch (_) {}
    return null;
  }

  /// Mengambil data Kehadiran per mata kuliah secara langsung dari backend
  static Future<List<Map<String, dynamic>>?> fetchKehadiranCourses() async {
    try {
      final token = await store.getToken();
      final headers = <String, String>{
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

      final res = await _getWithFallback('kehadiran?view=courses', headers: headers);
      if (res != null) {
        final body = jsonDecode(res.body);
        if (body['success'] == true) {
          final courses = body['data'] ?? body['courses'];
          if (courses is List) {
            final List<Map<String, dynamic>> converted =
                courses.map((e) => Map<String, dynamic>.from(e)).toList();
            try {
              await AppDb.instance.saveKehadiranToDrift(converted);
            } catch (_) {}
            return converted;
          }
        }
      }
    } catch (_) {}
    return null;
  }

  /// Mengambil data Nilai Semester (KHS) secara langsung dari backend
  static Future<List<Map<String, dynamic>>?> fetchNilaiSemester() async {
    try {
      final token = await store.getToken();
      final headers = <String, String>{
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

      final res = await _getWithFallback('nilai-semester', headers: headers);
      if (res != null) {
        final body = jsonDecode(res.body);
        if (body['success'] == true && body['data'] is List) {
          final List list = body['data'];
          final List<Map<String, dynamic>> converted =
              list.map((e) => Map<String, dynamic>.from(e)).toList();
          try {
            await AppDb.instance.saveNilaiToDrift(converted);
          } catch (_) {}
          return converted;
        }
      }
    } catch (_) {}
    return null;
  }

  /// Sinkronisasi Kehadiran dari Express.js lalu simpan ke SQLite Drift
  static Future<bool> syncKehadiran() async {
    try {
      final token = await store.getToken();
      final headers = <String, String>{
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

      final res = await _getWithFallback('kehadiran?view=courses', headers: headers);
      if (res != null) {
        final body = jsonDecode(res.body);
        if (body['success'] == true) {
          final courses = body['data'] ?? body['courses'];
          if (courses is List) {
            final List<Map<String, dynamic>> converted =
                courses.map((e) => Map<String, dynamic>.from(e)).toList();
            try {
              await AppDb.instance.saveKehadiranToDrift(converted);
            } catch (_) {}
            return true;
          }
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
      final token = await store.getToken();
      final headers = <String, String>{
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

      final res = await _getWithFallback('penilaian', headers: headers);
      if (res != null) {
        final body = jsonDecode(res.body);
        if (body['success'] == true && body['data'] is List) {
          final List list = body['data'];
          final List<Map<String, dynamic>> converted =
              list.map((e) => Map<String, dynamic>.from(e)).toList();
          try {
            await AppDb.instance.saveNilaiToDrift(converted);
          } catch (_) {}
          return true;
        }
      }
    } catch (e) {
      // Offline fallback
    }
    return false;
  }

  /// Sinkronisasi Nilai Semester (KHS) dari backend lalu simpan ke SQLite Drift
  static Future<bool> syncNilaiSemester() async {
    try {
      final token = await store.getToken();
      final headers = <String, String>{
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

      final res = await _getWithFallback('nilai-semester', headers: headers);
      if (res != null) {
        final body = jsonDecode(res.body);
        if (body['success'] == true && body['data'] is List) {
          final List list = body['data'];
          final List<Map<String, dynamic>> converted =
              list.map((e) => Map<String, dynamic>.from(e)).toList();
          try {
            await AppDb.instance.saveNilaiToDrift(converted);
          } catch (_) {}
          return true;
        }
      }
    } catch (e) {
      // Offline fallback
    }
    return false;
  }

  /// Mengambil semua daftar tugas aktif/riwayat dari backend (mengirim token mahasiswa aktif)
  static Future<List<Map<String, dynamic>>?> fetchTugas() async {
    try {
      final token = await store.getToken();
      final headers = <String, String>{
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };
      final res = await _getWithFallback('tugas', headers: headers);
      if (res != null) {
        final dynamic body = jsonDecode(res.body);
        if (body is List) {
          return body.map((e) => Map<String, dynamic>.from(e)).toList();
        } else if (body is Map && body['data'] is List) {
          return (body['data'] as List).map((e) => Map<String, dynamic>.from(e)).toList();
        }
      }
    } catch (e) {
      // Fallback
    }
    return null;
  }

  /// Mengambil semua jadwal kelas dari backend
  static Future<List<Map<String, dynamic>>?> fetchClasses() async {
    try {
      final res = await _getWithFallback('classes');
      if (res != null) {
        final dynamic body = jsonDecode(res.body);
        if (body is List) {
          return body.map((e) => Map<String, dynamic>.from(e)).toList();
        } else if (body is Map && body['data'] is List) {
          return (body['data'] as List).map((e) => Map<String, dynamic>.from(e)).toList();
        }
      }
    } catch (e) {
      // Fallback
    }
    return null;
  }

  /// Mengambil total mahasiswa dari backend untuk sinkronisasi ranking
  static Future<int?> fetchTotalMahasiswa() async {
    try {
      final res = await _getWithFallback('users');
      if (res != null) {
        final dynamic body = jsonDecode(res.body);
        if (body is List) {
          final mhsList = body.where((u) => u['role'] == 'mahasiswa').toList();
          return mhsList.length;
        }
      }
    } catch (e) {
      // Fallback
    }
    return null;
  }

  /// Mengirim pengumpulan tugas mahasiswa ke backend (real-time ke database dosen & Cloudinary)
  static Future<bool> submitPengumpulan({
    required String taskId,
    String? linkRepo,
    String? fileName,
    String? fileUrl,
    List<int>? fileBytes,
    String? filePath,
  }) async {
    try {
      final token = await store.getToken();

      for (final base in _baseUrls) {
        try {
          if (fileBytes != null && fileBytes.isNotEmpty && fileName != null) {
            // Upload file biner langsung via Multipart (didukung di Web CanvasKit/HTML & Mobile)
            final uri = Uri.parse('$base/tugas/$taskId/pengumpulan');
            final req = http.MultipartRequest('POST', uri);
            if (token != null && token.isNotEmpty) {
              req.headers['Authorization'] = 'Bearer $token';
            }
            if (linkRepo != null && linkRepo.isNotEmpty) {
              req.fields['linkRepo'] = linkRepo;
            }
            req.files.add(
              http.MultipartFile.fromBytes(
                'file',
                fileBytes,
                filename: fileName,
              ),
            );
            final streamed = await req.send().timeout(const Duration(seconds: 25));
            final res = await http.Response.fromStream(streamed);
            if (res.statusCode == 200 || res.statusCode == 201) {
              return true;
            }
          } else if (filePath != null && filePath.isNotEmpty && fileName != null) {
            // Upload via path file fisik (Khusus Android/iOS/Desktop)
            final uri = Uri.parse('$base/tugas/$taskId/pengumpulan');
            final req = http.MultipartRequest('POST', uri);
            if (token != null && token.isNotEmpty) {
              req.headers['Authorization'] = 'Bearer $token';
            }
            if (linkRepo != null && linkRepo.isNotEmpty) {
              req.fields['linkRepo'] = linkRepo;
            }
            req.files.add(
              await http.MultipartFile.fromPath(
                'file',
                filePath,
                filename: fileName,
              ),
            );
            final streamed = await req.send().timeout(const Duration(seconds: 25));
            final res = await http.Response.fromStream(streamed);
            if (res.statusCode == 200 || res.statusCode == 201) {
              return true;
            }
          } else {
            // Pengumpulan berupa tautan link atau metadata JSON
            final headers = <String, String>{
              'Content-Type': 'application/json',
              if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
            };
            final res = await http
                .post(
                  Uri.parse('$base/tugas/$taskId/pengumpulan'),
                  headers: headers,
                  body: jsonEncode({
                    if (linkRepo != null && linkRepo.isNotEmpty) 'linkRepo': linkRepo,
                    if (fileName != null && fileName.isNotEmpty) 'fileName': fileName,
                    if (fileUrl != null && fileUrl.isNotEmpty) 'fileUrl': fileUrl,
                  }),
                )
                .timeout(const Duration(seconds: 10));

            if (res.statusCode == 200 || res.statusCode == 201) {
              return true;
            }
          }
        } catch (_) {}
      }
    } catch (_) {}
    return false;
  }

  /// Membatalkan pengumpulan tugas mahasiswa di backend
  static Future<bool> deletePengumpulan({required String taskId}) async {
    try {
      final token = await store.getToken();
      final headers = <String, String>{
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

      for (final base in _baseUrls) {
        try {
          final res = await http
              .delete(
                Uri.parse('$base/tugas/$taskId/pengumpulan'),
                headers: headers,
              )
              .timeout(const Duration(seconds: 8));

          if (res.statusCode == 200 || res.statusCode == 204) {
            return true;
          }
        } catch (_) {}
      }
    } catch (_) {}
    return false;
  }
}
