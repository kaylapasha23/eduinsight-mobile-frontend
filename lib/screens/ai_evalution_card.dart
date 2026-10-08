import 'package:flutter/material.dart';
import './common_widgets.dart';
import 'academic/academic_widgets.dart'; // untuk class ListItem

// ---------- Warna khusus halaman AI ----------
const Color kAiYellow = Color(0xFFFFFFBB);
const Color kAiGood = Color(0xFFE4FFDF); // hijau: kabar baik
const Color kAiBad = Color(0xFFFFDEE0); // merah muda: perlu perhatian
const Color kDosenTile = Color(0xFFF8FBFF); // putih kebiruan: masukan dosen
const Color kHintOlive = Color(0xFF8C8A63);

// ---------- Model data ----------
class AiMessage {
  final String text;
  final bool isPositive;

  const AiMessage({required this.text, required this.isPositive});
}

class AiDateGroup {
  final String dateText;
  final int tanggal; // dipakai untuk filter dropdown
  final List<AiMessage> aiMessages;
  final String dosenMessage;

  const AiDateGroup({
    required this.dateText,
    required this.tanggal,
    required this.aiMessages,
    required this.dosenMessage,
  });
}

// Pilihan dropdown; value 0 = semua tanggal
const List<ListItem> pilihanTanggal = [
  ListItem(value: 0, name: 'DD/MM/YY'),
  ListItem(value: 24, name: '24/01/26'),
  ListItem(value: 23, name: '23/01/26'),
];

const List<AiDateGroup> dataEvaluasi = [
  AiDateGroup(
    dateText: 'Senin, 24 Januari 2026',
    tanggal: 24,
    aiMessages: [
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
    dosenMessage: 'Tidak ada masukan',
  ),
  AiDateGroup(
    dateText: 'Minggu, 23 Januari',
    tanggal: 23,
    aiMessages: [
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
    dosenMessage:
        'UTS dilaksanakan secara take home, untuk soal UTS akan saya kirim di EduInsight',
  ),
];

// ---------- Halaman ----------
class AiEvalutionScreen extends StatefulWidget {
  const AiEvalutionScreen({super.key});

  @override
  State<AiEvalutionScreen> createState() => _AiEvalutionScreenState();
}

class _AiEvalutionScreenState extends State<AiEvalutionScreen> {
  ListItem _tanggal = pilihanTanggal[0]; // state: pilihan dropdown saat ini

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const HeaderBar(title: 'EduInsight AI'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 38, vertical: 24),
              child: Column(
                children: [
                  _buildDateDropdown(),
                  const SizedBox(height: 26),
                  Column(children: _buildGroups()),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          const BottomBar(currentIndex: 2),
        ],
      ),
    );
  }

  // Dropdown tanggal: ikon kalender + DropdownButton
  Widget _buildDateDropdown() {
    return Container(
      width: 205,
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: kAiYellow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today, size: 18, color: Colors.black),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<ListItem>(
                value: _tanggal,
                isExpanded: true,
                dropdownColor: kAiYellow,
                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
                style: TextStyle(
                  fontSize: 16,
                  color: _tanggal.value == 0 ? kHintOlive : Colors.black,
                ),
                items: pilihanTanggal.map((ListItem item) {
                  return DropdownMenuItem<ListItem>(
                    value: item,
                    child: Text(item.name),
                  );
                }).toList(),
                onChanged: (ListItem? value) {
                  if (value != null) {
                    setState(() {
                      _tanggal = value; // event -> state berubah -> UI berubah
                    });
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Menyusun grup tanggal yang cocok dengan pilihan dropdown
  List<Widget> _buildGroups() {
    List<Widget> hasil = [];

    for (AiDateGroup g in dataEvaluasi) {
      bool cocok = _tanggal.value == 0 || g.tanggal == _tanggal.value;

      if (cocok) {
        // garis pemisah di antara grup tanggal
        if (hasil.isNotEmpty) {
          hasil.add(
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(color: Colors.black, thickness: 0.8, height: 1),
            ),
          );
        }
        hasil.add(_buildDateGroup(g));
      }
    }

    if (hasil.isEmpty) {
      hasil.add(
        const Padding(
          padding: EdgeInsets.only(top: 60),
          child: Text(
            'Belum ada evaluasi pada tanggal yang dipilih.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.black54),
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
        SizedBox(
          width: double.infinity,
          child: Text(
            group.dateText,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
          decoration: BoxDecoration(
            color: kCardBlue,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              const _SectionLabel(label: 'AI'),
              Column(
                children: group.aiMessages
                    .map((msg) => _MessageTile(
                          text: msg.text,
                          color: msg.isPositive ? kAiGood : kAiBad,
                        ))
                    .toList(),
              ),
              const Divider(color: Colors.black, thickness: 0.8, height: 8),
              const _SectionLabel(label: 'Dosen'),
              _MessageTile(text: group.dosenMessage, color: kDosenTile),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------- Label bagian ("AI" / "Dosen") ----------
class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        label,
        style: const TextStyle(fontSize: 14, color: Colors.black),
      ),
    );
  }
}

// ---------- Kartu pesan ----------
class _MessageTile extends StatelessWidget {
  final String text;
  final Color color;

  const _MessageTile({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13.5, height: 1.4, color: Colors.black),
      ),
    );
  }
}