import 'package:flutter/material.dart';
import '../common_widgets.dart';

// ---------- Warna (dipertahankan kalau dipakai file lain) ----------
const Color kAiGood = Color(0xFFE4FFDF);
const Color kAiBad = Color(0xFFFFDEE0);

// ---------- Model data ----------
class AiMessage {
  final String text;
  final bool isPositive;

  const AiMessage({required this.text, required this.isPositive});
}

class AiDateGroup {
  final String dateText;
  final String lecturerName;
  final List<AiMessage> messages;
  final String? lecturerNote;

  const AiDateGroup({
    required this.dateText,
    required this.lecturerName,
    required this.messages,
    this.lecturerNote,
  });

  // Helper untuk mendapatkan DateTime dari teks tanggal
  DateTime get dateTime {
    if (dateText.contains('24 Januari 2026')) return DateTime(2026, 1, 24);
    if (dateText.contains('23 Januari 2026')) return DateTime(2026, 1, 23);
    if (dateText.contains('22 Januari 2026')) return DateTime(2026, 1, 22);
    return DateTime(2026, 1, 24);
  }
}

final List<AiDateGroup> dataEvaluasi = [
  AiDateGroup(
    dateText: 'Senin, 24 Januari 2026',
    lecturerName: 'Dr. Ahmad Sahroni, M.Kom.',
    messages: const [
      AiMessage(
        text:
            'Kehadiranmu mengalami penurunan dalam beberapa pertemuan terakhir. Usahakan hadir pada pertemuan berikutnya agar tetap memenuhi batas minimum kehadiran.',
        isPositive: false,
      ),
      AiMessage(
        text:
            'Nilai kuis terakhir masih rendah. Coba pelajari kembali materi yang berkaitan dan kerjakan latihan tambahan.',
        isPositive: false,
      ),
    ],
    lecturerNote:
        'Mohon temui saya di ruang dosen pada hari Rabu jam 10.00 untuk membahas remedial kuis dan perbaikan presensi sebelum UTS.',
  ),
  AiDateGroup(
    dateText: 'Minggu, 23 Januari 2026',
    lecturerName: 'Ir. Tri Astuti, M.T.',
    messages: const [
      AiMessage(
        text:
            'Kehadiranmu mulai membaik dibanding minggu sebelumnya. Pertahankan konsistensi kehadiran.',
        isPositive: true,
      ),
      AiMessage(
        text:
            'Nilai kuis terakhir meningkat. Pertahankan pola belajar dan fokus pada materi yang masih belum dikuasai.',
        isPositive: true,
      ),
      AiMessage(
        text: 'Materi yang perlu dipelajari kembali: array dan function.',
        isPositive: false,
      ),
    ],
    lecturerNote: null,
  ),
  AiDateGroup(
    dateText: 'Sabtu, 22 Januari 2026',
    lecturerName: 'Prof. Bambang Hariyanto, Ph.D.',
    messages: const [
      AiMessage(
        text: 'Kehadiran telah memenuhi batas minimum.',
        isPositive: true,
      ),
      AiMessage(
        text:
            'Nilai tugas sudah cukup baik, tetapi hasil kuis masih belum konsisten. Perhatikan kembali materi yang mendapat nilai rendah.',
        isPositive: false,
      ),
    ],
    lecturerNote: null,
  ),
];

// ---------- Halaman ----------
class AiEvalutionScreen extends StatefulWidget {
  const AiEvalutionScreen({super.key});

  @override
  State<AiEvalutionScreen> createState() => _AiEvalutionScreenState();
}

class _AiEvalutionScreenState extends State<AiEvalutionScreen> {
  DateTime? _selectedDate;

  String _formatDate(DateTime date) {
    final mm = date.month.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    final yy = (date.year % 100).toString().padLeft(2, '0');
    return '$mm/$dd/$yy';
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2026, 1, 24),
      firstDate: DateTime(2023, 8, 1),
      lastDate: DateTime(2026, 6, 30),
      helpText: 'Pilih Tanggal Evaluasi (MM/DD/YY)',
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
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                children: [
                  _buildDateFilter(),
                  const SizedBox(height: 28),
                  Column(children: _buildGroups()),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          const BottomBar(currentIndex: 2),
        ],
      ),
    );
  }

  // Filter tanggal dengan teks yang lebih singkat
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

    final filteredData = dataEvaluasi.where((g) {
      if (_selectedDate == null) return true;
      return g.dateTime.year == _selectedDate!.year &&
          g.dateTime.month == _selectedDate!.month &&
          g.dateTime.day == _selectedDate!.day;
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

    if (hasil.isEmpty) {
      hasil.add(
        Padding(
          padding: const EdgeInsets.only(top: 48),
          child: Column(
            children: [
              Icon(
                Icons.event_busy_rounded,
                size: 48,
                color: Colors.black.withValues(alpha: 0.2),
              ),
              const SizedBox(height: 12),
              Text(
                _selectedDate != null
                    ? 'Tidak ada evaluasi pada tanggal ${_formatDate(_selectedDate!)}.'
                    : 'Belum ada evaluasi.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF5C6B8A),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedDate = null;
                  });
                },
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Tampilkan Semua Evaluasi'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF1E2B52),
                  backgroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
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
        // Bagian tanggal di sebelah kanan telah dihapus
        Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Color(0xFF3A6BBF),
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
                        'AI Evaluation',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: titleColor,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Pesan-pesan evaluasi AI
                  ...group.messages.map((msg) => _MessageTile(message: msg)),

                  // Catatan dosen
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
                          group.lecturerNote != null
                              ? Icons.edit_note_rounded
                              : Icons.info_outline_rounded,
                          size: 20,
                          color: headerBlue,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            group.lecturerNote ?? 'Tidak ada catatan dari dosen',
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.5,
                              fontStyle: group.lecturerNote != null
                                  ? FontStyle.normal
                                  : FontStyle.italic,
                              color: group.lecturerNote != null
                                  ? (isDark ? Colors.white70 : const Color(0xFF334155))
                                  : (isDark ? Colors.white38 : const Color(0xFF94A3B8)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
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