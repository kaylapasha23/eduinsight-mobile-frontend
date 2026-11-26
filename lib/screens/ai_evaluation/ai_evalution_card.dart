import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../services/academic_api_service.dart';
import '../common_widgets.dart';

// ---------- Warna ----------
const Color kAiGood = Color(0xFFE4FFDF);
const Color kAiBad = Color(0xFFFFDEE0);

// ---------- Model data ----------
class AiMessage {
  final String text;
  final bool isPositive;

  const AiMessage({required this.text, required this.isPositive});

  factory AiMessage.fromDynamic(dynamic item) {
    if (item is Map) {
      final txt = (item['text'] ?? item['ringkasan'] ?? item['rekomendasi'] ?? '').toString();
      final isPos = item['isPositive'] == true ||
          item['status'] == 'Aman' ||
          item['is_positive'] == true;
      return AiMessage(text: txt, isPositive: isPos);
    }
    return AiMessage(text: item?.toString() ?? '', isPositive: true);
  }
}

class AiDateGroup {
  final String? id;
  final String dateText;
  final String lecturerName;
  final List<AiMessage> messages;
  final String? lecturerNote;
  final String? indikatorRisiko;
  final String? trenKehadiran;
  final double? nilaiAkhir;
  final DateTime dateTime;

  AiDateGroup({
    this.id,
    required this.dateText,
    required this.lecturerName,
    required this.messages,
    this.lecturerNote,
    this.indikatorRisiko,
    this.trenKehadiran,
    this.nilaiAkhir,
    required this.dateTime,
  });

  bool get hasLecturerNote =>
      lecturerNote != null && lecturerNote!.trim().isNotEmpty;

  factory AiDateGroup.fromJson(Map<String, dynamic> json) {
    // 1. Parse messages
    List<AiMessage> parsedMessages = [];
    final rawMessages = json['messages'];

    if (rawMessages is List) {
      parsedMessages = rawMessages.map((m) => AiMessage.fromDynamic(m)).toList();
    } else if (rawMessages is String && rawMessages.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(rawMessages);
        if (decoded is List) {
          parsedMessages = decoded.map((m) => AiMessage.fromDynamic(m)).toList();
        } else {
          parsedMessages = [AiMessage(text: rawMessages, isPositive: true)];
        }
      } catch (_) {
        parsedMessages = [AiMessage(text: rawMessages, isPositive: true)];
      }
    }

    // Jika pesan masih kosong, fallback dari insightPerforma & rekomendasi
    if (parsedMessages.isEmpty) {
      if (json['insightPerforma'] != null && json['insightPerforma'].toString().isNotEmpty) {
        parsedMessages.add(AiMessage(
          text: json['insightPerforma'].toString(),
          isPositive: json['indikatorRisiko'] != 'Tinggi',
        ));
      }
      if (json['ringkasan_analisis'] != null && json['ringkasan_analisis'].toString().isNotEmpty) {
        parsedMessages.add(AiMessage(
          text: json['ringkasan_analisis'].toString(),
          isPositive: json['status_risiko'] == 'Aman',
        ));
      }
      if (json['rekomendasi'] != null && json['rekomendasi'].toString().isNotEmpty) {
        parsedMessages.add(AiMessage(
          text: json['rekomendasi'].toString(),
          isPositive: false,
        ));
      }
    }

    // 2. Parse DateTime
    DateTime dt = DateTime.now();
    if (json['createdAt'] != null) {
      final parsed = DateTime.tryParse(json['createdAt'].toString());
      if (parsed != null) dt = parsed;
    }

    // 3. Tanggal tampilan
    String dtText = json['dateText']?.toString() ?? '';
    if (dtText.isEmpty) {
      const List<String> namaBulan = [
        'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
      ];
      const List<String> namaHari = [
        'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
      ];
      final hari = namaHari[dt.weekday - 1];
      final bulan = namaBulan[dt.month - 1];
      dtText = '$hari, ${dt.day} $bulan ${dt.year}';
    }

    // 4. Catatan dosen manual (footprint)
    final rawNote = json['lecturerNote'] ?? json['catatanDosen'];
    final String? note = (rawNote != null && rawNote.toString().trim().isNotEmpty)
        ? rawNote.toString().trim()
        : null;

    return AiDateGroup(
      id: json['id']?.toString(),
      dateText: dtText,
      lecturerName: json['lecturerName']?.toString() ?? 'Dosen Pengampu',
      messages: parsedMessages,
      lecturerNote: note,
      indikatorRisiko: json['indikatorRisiko']?.toString() ?? json['status_risiko']?.toString(),
      trenKehadiran: json['trenKehadiran']?.toString(),
      nilaiAkhir: json['nilaiAkhir'] != null ? (json['nilaiAkhir'] as num).toDouble() : null,
      dateTime: dt,
    );
  }
}

// Data sampel cadangan jika backend belum terhubung/offline (dikosongkan agar murni menampilkan inputan real-time dosen)
final List<AiDateGroup> dataEvaluasiSampel = [];

// ---------- Halaman ----------
class AiEvalutionScreen extends StatefulWidget {
  const AiEvalutionScreen({super.key});

  @override
  State<AiEvalutionScreen> createState() => _AiEvalutionScreenState();
}

class _AiEvalutionScreenState extends State<AiEvalutionScreen> {
  DateTime? _selectedDate;
  List<AiDateGroup> _evaluations = [];
  bool _isLoading = true;
  bool _isOfflineFallback = false;
  Timer? _realtimeTimer;

  @override
  void initState() {
    super.initState();
    _loadEvaluations();
    // Polling ringan setiap 25 detik agar HP tetap responsif dan tidak boros baterai
    _realtimeTimer = Timer.periodic(const Duration(seconds: 25), (_) {
      _loadEvaluations(isSilent: true);
    });
  }

  @override
  void dispose() {
    _realtimeTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadEvaluations({bool isSilent = false}) async {
    if (!isSilent) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final data = await AcademicApiService.fetchEvaluasi();
      if (mounted) {
        if (data != null) {
          // Berhasil terhubung ke backend
          final parsed = data.map((json) => AiDateGroup.fromJson(json)).toList();
          // Urutkan evaluasi dari yang paling baru
          parsed.sort((a, b) => b.dateTime.compareTo(a.dateTime));

          setState(() {
            _evaluations = parsed;
            _isOfflineFallback = false;
            _isLoading = false;
          });
        } else if (!isSilent) {
          // Gagal koneksi backend -> gunakan sampel data agar tidak crash
          setState(() {
            _evaluations = List.from(dataEvaluasiSampel);
            _isOfflineFallback = true;
            _isLoading = false;
          });
        }
      }
    } catch (_) {
      if (mounted && !isSilent) {
        setState(() {
          _evaluations = List.from(dataEvaluasiSampel);
          _isOfflineFallback = true;
          _isLoading = false;
        });
      }
    }
  }

  String _formatDate(DateTime date) {
    final mm = date.month.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    final yy = (date.year % 100).toString().padLeft(2, '0');
    return '$mm/$dd/$yy';
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2023, 1, 1),
      lastDate: DateTime(2028, 12, 31),
      helpText: 'Pilih Tanggal Evaluasi',
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E222A) : const Color(0xFFF7F9FC);

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          const HeaderBar(title: 'EduInsight AI'),
          if (_isOfflineFallback)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.amber.withValues(alpha: 0.15),
              child: Row(
                children: [
                  const Icon(Icons.cloud_off_rounded, size: 16, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Menampilkan data lokal/pratinjau (Backend offline).',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.orange[200] : Colors.orange[900],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: _loadEvaluations,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      child: Text(
                        'Coba Lagi',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadEvaluations,
              color: const Color(0xFF2563EB),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  children: [
                    _buildDateFilter(),
                    const SizedBox(height: 28),
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.only(top: 60),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else
                      Column(children: _buildGroups()),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
          const BottomBar(currentIndex: 2),
        ],
      ),
    );
  }

  // Filter tanggal
  Widget _buildDateFilter() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF282D37) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1);
    final iconBg = isDark ? const Color(0xFF334155) : const Color(0xFFEFF6FF);
    final primaryBlue = isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB);
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);

    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.calendar_month_rounded,
                color: primaryBlue,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filter Tanggal',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white54 : const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _selectedDate != null
                        ? _formatDate(_selectedDate!)
                        : 'Semua Tanggal',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
            if (_selectedDate != null)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDate = null;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    color: isDark ? Colors.white70 : const Color(0xFF475569),
                    size: 16,
                  ),
                ),
              )
            else
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: isDark ? Colors.white70 : const Color(0xFF64748B),
                size: 22,
              ),
          ],
        ),
      ),
    );
  }

  // Menyusun grup tanggal yang cocok dengan filter
  List<Widget> _buildGroups() {
    final List<Widget> hasil = [];

    // Urutkan selalu dari yang terbaru (paling atas) ke yang terlama (paling bawah)
    final sortedData = List<AiDateGroup>.from(_evaluations)
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

    final filteredData = sortedData.where((g) {
      if (_selectedDate != null) {
        return g.dateTime.year == _selectedDate!.year &&
            g.dateTime.month == _selectedDate!.month &&
            g.dateTime.day == _selectedDate!.day;
      }
      // Pada pilihan default 'Semua Tanggal', tampilkan seluruh riwayat evaluasi
      return true;
    }).toList();

    for (var g in filteredData) {
      if (hasil.isNotEmpty) {
        hasil.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Divider(
              color: Colors.black.withValues(alpha: 0.1),
              thickness: 1,
              height: 1,
            ),
          ),
        );
      }
      hasil.add(_buildDateGroup(g));
    }

    // Kondisi kosong (Empty State saat dosen belum membuat keputusan/mengirim evaluasi)
    if (hasil.isEmpty) {
      hasil.add(
        Padding(
          padding: const EdgeInsets.only(top: 48, bottom: 24),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF282D37)
                      : const Color(0xFFEFF6FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome_motion_rounded,
                  size: 48,
                  color: Color(0xFF3B82F6),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _selectedDate != null
                    ? 'Tidak ada evaluasi pada tanggal ${_formatDate(_selectedDate!)}.'
                    : 'Belum Ada Evaluasi dari Dosen',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Dosen belum mengirimkan evaluasi atau catatan untuk Anda. Evaluasi AI dan catatan dosen akan muncul secara otomatis di sini setelah dosen mempublikasikannya.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white60
                        : const Color(0xFF64748B),
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedDate = null;
                  });
                  _loadEvaluations();
                },
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Perbarui Data'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFF2563EB),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return hasil;
  }

  Widget _buildDateGroup(AiDateGroup group) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFF2563EB),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              group.dateText,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF82B1FF)
                    : const Color(0xFF1A2B4A),
                letterSpacing: 0.1,
              ),
            ),
            const Spacer(),
            // Badge tipe evaluasi
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: group.hasLecturerNote
                    ? (Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF78350F).withValues(alpha: 0.4)
                        : const Color(0xFFFEF3C7))
                    : (Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF1E3A8A).withValues(alpha: 0.4)
                        : const Color(0xFFDBEAFE)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    group.hasLecturerNote
                        ? Icons.edit_note_rounded
                        : Icons.auto_awesome,
                    size: 13,
                    color: group.hasLecturerNote
                        ? const Color(0xFFD97706)
                        : const Color(0xFF2563EB),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    group.hasLecturerNote ? 'AI + Catatan' : 'AI Only',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: group.hasLecturerNote
                          ? const Color(0xFFD97706)
                          : const Color(0xFF2563EB),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Builder(
          builder: (context) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final cardBg = isDark ? const Color(0xFF282D37) : Colors.white;
            final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
            final noteBoxBg = isDark ? const Color(0xFF1E2532) : const Color(0xFFF8FAFC);
            final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
            final headerBlue = isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB);

            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: borderColor, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header AI Evaluation & Status Risiko
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: headerBlue.withValues(alpha: isDark ? 0.2 : 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.auto_awesome,
                          size: 16,
                          color: headerBlue,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'AI Evaluation Card',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: titleColor,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const Spacer(),
                      if (group.indikatorRisiko != null)
                        _buildRiskBadge(group.indikatorRisiko!, isDark),
                    ],
                  ),

                  // Indikator ringkas (Nilai & Kehadiran jika ada)
                  if (group.nilaiAkhir != null || group.trenKehadiran != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        if (group.nilaiAkhir != null)
                          _buildMiniMetric(
                            icon: Icons.grade_rounded,
                            label: 'Rata-rata: ${group.nilaiAkhir!.toStringAsFixed(1)}',
                            isDark: isDark,
                          ),
                        if (group.nilaiAkhir != null && group.trenKehadiran != null)
                          const SizedBox(width: 8),
                        if (group.trenKehadiran != null)
                          _buildMiniMetric(
                            icon: Icons.how_to_reg_rounded,
                            label: 'Hadir: ${group.trenKehadiran}',
                            isDark: isDark,
                          ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 14),

                  // Pesan-pesan evaluasi AI
                  if (group.messages.isNotEmpty)
                    ...group.messages.map((msg) => _MessageTile(message: msg))
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Evaluasi AI telah direkam untuk mahasiswa.',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white70 : const Color(0xFF475569),
                        ),
                      ),
                    ),

                  // Catatan Manual Dosen (Footprint)
                  // HANYA jika dosen mengisi catatan manual, bagian ini dimunculkan!
                  if (group.hasLecturerNote) ...[
                    const SizedBox(height: 12),
                    Divider(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      thickness: 1,
                      height: 1,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Icon(
                          Icons.person_pin_rounded,
                          size: 18,
                          color: headerBlue,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Catatan Dosen (${group.lecturerName})',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: titleColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: noteBoxBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.edit_note_rounded,
                            size: 20,
                            color: const Color(0xFFD97706),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              group.lecturerNote!,
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.5,
                                fontWeight: FontWeight.w500,
                                color: isDark ? Colors.white70 : const Color(0xFF334155),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRiskBadge(String risk, bool isDark) {
    Color bg;
    Color textColor;
    final rLower = risk.toLowerCase();

    if (rLower == 'aman' || rLower == 'rendah') {
      bg = isDark ? const Color(0xFF064E3B) : const Color(0xFFDCFCE7);
      textColor = isDark ? const Color(0xFF86EFAC) : const Color(0xFF15803D);
    } else if (rLower == 'sedang' || rLower == 'waspada') {
      bg = isDark ? const Color(0xFF78350F) : const Color(0xFFFEF3C7);
      textColor = isDark ? const Color(0xFFFCD34D) : const Color(0xFFB45309);
    } else {
      bg = isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFEE2E2);
      textColor = isDark ? const Color(0xFFFCA5A5) : const Color(0xFFB91C1C);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        risk,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildMiniMetric({
    required IconData icon,
    required String label,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2532) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: isDark ? Colors.white54 : const Color(0xFF64748B),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : const Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- Kartu pesan ----------
class _MessageTile extends StatelessWidget {
  final AiMessage message;

  const _MessageTile({required this.message});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color badgeBg = message.isPositive
        ? (isDark ? const Color(0xFF064E3B).withValues(alpha: 0.55) : const Color(0xFFEAFFF0))
        : (isDark ? const Color(0xFF7F1D1D).withValues(alpha: 0.55) : const Color(0xFFFFEDED));

    final Color borderColor = message.isPositive
        ? (isDark ? const Color(0xFF34D399).withValues(alpha: 0.55) : const Color(0xFF34C759).withValues(alpha: 0.3))
        : (isDark ? const Color(0xFFF87171).withValues(alpha: 0.55) : const Color(0xFFFF3B30).withValues(alpha: 0.3));

    final Color iconColor = message.isPositive
        ? (isDark ? const Color(0xFF34D399) : const Color(0xFF10B981))
        : (isDark ? const Color(0xFFF87171) : const Color(0xFFEF4444));

    final Color textColor = isDark
        ? (message.isPositive ? const Color(0xFFA7F3D0) : const Color(0xFFFECACA))
        : const Color(0xFF1A2B4A);

    final icon = message.isPositive
        ? Icons.check_circle_outline_rounded
        : Icons.info_outline_rounded;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: badgeBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message.text,
              style: TextStyle(
                fontSize: 13.5,
                height: 1.5,
                fontWeight: isDark ? FontWeight.w500 : FontWeight.normal,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
