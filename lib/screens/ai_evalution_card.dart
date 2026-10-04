import 'package:flutter/material.dart';
import './common_widgets.dart';
import 'academic/academic_widgets.dart';

const Color kAiGood = Color(0xFFE4FFDF);
const Color kAiBad = Color(0xFFFFDEE0);

class AiMessage {
  final String text;
  final bool isPositive;

  const AiMessage({required this.text, required this.isPositive});
}

class AiDateGroup {
  final String dateText;
  final int tanggal;
  final int bulan;
  final List<AiMessage> messages;

  const AiDateGroup({
    required this.dateText,
    required this.tanggal,
    required this.bulan,
    required this.messages,
  });
}

const List<ListItem> pilihanTanggal = [
  ListItem(value: 0, name: 'Tanggal'),
  ListItem(value: 22, name: '22'),
  ListItem(value: 23, name: '23'),
  ListItem(value: 24, name: '24'),
];

const List<ListItem> pilihanBulan = [
  ListItem(value: 0, name: 'Bulan'),
  ListItem(value: 1, name: 'Januari'),
];

const List<AiDateGroup> dataEvaluasi = [
  AiDateGroup(
    dateText: 'Senin, 24 Januari',
    tanggal: 24,
    bulan: 1,
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
  ),
  AiDateGroup(
    dateText: 'Minggu, 23 Januari',
    tanggal: 23,
    bulan: 1,
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
  ),
  AiDateGroup(
    dateText: 'Sabtu, 22 Januari',
    tanggal: 22,
    bulan: 1,
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
  ),
];

class AiEvalutionScreen extends StatefulWidget {
  const AiEvalutionScreen({super.key});

  @override
  State<AiEvalutionScreen> createState() => _AiEvalutionScreenState();
}

class _AiEvalutionScreenState extends State<AiEvalutionScreen> {
  ListItem _tanggal = pilihanTanggal[0];
  ListItem _bulan = pilihanBulan[0];

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
                  Row(
                    children: [
                      Expanded(
                        child: YellowDropdown(
                          height: 42,
                          items: pilihanTanggal,
                          selectedItem: _tanggal,
                          onChanged: (ListItem? value) {
                            if (value != null) {
                              setState(() {
                                _tanggal = value;
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: YellowDropdown(
                          height: 42,
                          items: pilihanBulan,
                          selectedItem: _bulan,
                          onChanged: (ListItem? value) {
                            if (value != null) {
                              setState(() {
                                _bulan = value;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
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

  List<Widget> _buildGroups() {
    List<Widget> hasil = [];

    for (AiDateGroup g in dataEvaluasi) {
      bool cocokTanggal = _tanggal.value == 0 || g.tanggal == _tanggal.value;
      bool cocokBulan = _bulan.value == 0 || g.bulan == _bulan.value;

      if (cocokTanggal && cocokBulan) {
        if (hasil.isNotEmpty) {
          hasil.add(
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(color: Colors.black54, thickness: 0.8, height: 1),
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
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 5),
          decoration: BoxDecoration(
            color: kCardBlue,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: group.messages
                .map((msg) => _MessageTile(message: msg))
                .toList(),
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
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: message.isPositive ? kAiGood : kAiBad,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message.text,
        style: const TextStyle(fontSize: 13.5, height: 1.4, color: Colors.black),
      ),
    );
  }
}