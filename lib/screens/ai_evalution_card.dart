import 'package:flutter/material.dart';
import './common_widgets.dart';

const Color kAiGood = Color(0xFFE4FFDF);
const Color kAiBad = Color(0xFFFFDEE0);

class AiMessage {
  final String text;
  final bool isPositive;

  const AiMessage({required this.text, required this.isPositive});
}

class AiDateGroup {
  final String dateText;
  final DateTime dateTime;
  final List<AiMessage> messages;
  final String? lecturerNote;

  const AiDateGroup({
    required this.dateText,
    required this.dateTime,
    required this.messages,
    this.lecturerNote,
  });
}

final List<AiDateGroup> dataEvaluasi = [
  AiDateGroup(
    dateText: 'Senin, 24 Januari 2026',
    dateTime: DateTime(2026, 1, 24),
    messages: [
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
    dateTime: DateTime(2026, 1, 23),
    messages: [
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
    dateTime: DateTime(2026, 1, 22),
    messages: [
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
      firstDate: DateTime(2023, 8, 1), // Masuk kuliah FILKOM angkatan 2023
      lastDate: DateTime(2026, 6, 30), // Perkiraan wisuda semester 6 Juni 2026
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
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: Column(
        children: [
          const HeaderBar(title: 'EduInsight AI'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                children: [
                  // Kalender Date Picker Filter dengan format MM/DD/YY
                  GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFDE7),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFFFEE87), width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFD4A300).withValues(alpha: 0.12),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFEE87).withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.calendar_month_rounded,
                              color: Color(0xFF7A6500),
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Filter Kalender (MM/DD/YY)',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF8A7000),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _selectedDate != null
                                      ? _formatDate(_selectedDate!)
                                      : 'Semua Tanggal (Ketuk untuk memilih)',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: _selectedDate != null
                                        ? const Color(0xFF3A3000)
                                        : const Color(0xFF8A7000),
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
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0xFFFFEE87)),
                                ),
                                child: const Icon(
                                  Icons.close_rounded,
                                  color: Color(0xFF7A6500),
                                  size: 18,
                                ),
                              ),
                            )
                          else
                            const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Color(0xFF8A7000),
                              size: 24,
                            ),
                        ],
                      ),
                    ),
                  ),
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

  List<Widget> _buildGroups() {
    List<Widget> hasil = [];

    for (AiDateGroup g in dataEvaluasi) {
      bool cocok = _selectedDate == null ||
          (g.dateTime.year == _selectedDate!.year &&
              g.dateTime.month == _selectedDate!.month &&
              g.dateTime.day == _selectedDate!.day);

      if (cocok) {
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
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
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A2B4A),
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFDDE8FF)),
              ),
              child: Text(
                _formatDate(group.dateTime),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3A6BBF),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          decoration: BoxDecoration(
            color: const Color(0xFFDDE8FF),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3B6FE8).withValues(alpha: 0.12),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header AI dengan Sparkle
              Row(
                children: const [
                  Text(
                    'AI Evaluation',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A2B4A),
                      letterSpacing: 0.2,
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(
                    Icons.auto_awesome,
                    size: 16,
                    color: Color(0xFF1E2B52),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Pesan-pesan evaluasi AI
              ...group.messages.map((msg) => _MessageTile(message: msg)),

              // Catatan Dosen (selalu ada kolomnya pada setiap tanggal)
              const SizedBox(height: 14),
              Divider(
                color: const Color(0xFF1E2B52).withValues(alpha: 0.12),
                thickness: 1,
                height: 1,
              ),
              const SizedBox(height: 14),
              Row(
                children: const [
                  Icon(
                    Icons.person_pin_rounded,
                    size: 18,
                    color: Color(0xFF1A2B4A),
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Catatan Dosen',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A2B4A),
                      letterSpacing: 0.1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Container putih catatan dosen
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      group.lecturerNote != null
                          ? Icons.edit_note_rounded
                          : Icons.info_outline_rounded,
                      size: 20,
                      color: group.lecturerNote != null
                          ? const Color(0xFF3A6BBF)
                          : const Color(0xFF8EA3BF),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        group.lecturerNote != null
                            ? group.lecturerNote!
                            : 'Tidak ada catatan dari dosen',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          fontStyle: group.lecturerNote != null
                              ? FontStyle.normal
                              : FontStyle.italic,
                          color: group.lecturerNote != null
                              ? const Color(0xFF1A2B4A)
                              : const Color(0xFF7A8FAB),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MessageTile extends StatelessWidget {
  final AiMessage message;

  const _MessageTile({required this.message});

  @override
  Widget build(BuildContext context) {
    final bgColor = message.isPositive
        ? const Color(0xFFEAFFF0)
        : const Color(0xFFFFEDED);
    final borderColor = message.isPositive
        ? const Color(0xFF34C759).withValues(alpha: 0.3)
        : const Color(0xFFFF3B30).withValues(alpha: 0.3);
    final iconColor = message.isPositive
        ? const Color(0xFF34C759)
        : const Color(0xFFFF3B30);
    final icon = message.isPositive
        ? Icons.check_circle_outline_rounded
        : Icons.info_outline_rounded;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message.text,
              style: const TextStyle(
                fontSize: 13.5,
                height: 1.5,
                color: Color(0xFF1A2B4A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}