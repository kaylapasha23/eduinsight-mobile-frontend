import 'package:flutter/material.dart';
import './common_widgets.dart';

class AiEvalutionScreen extends StatelessWidget {
  const AiEvalutionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const HeaderBar(showLogout: false),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFCF9C6),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Tanggal', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                              Icon(Icons.keyboard_arrow_down, color: Colors.black87),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFCF9C6),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Bulan', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                              Icon(Icons.keyboard_arrow_down, color: Colors.black87),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  _buildDateGroup(
                    dateText: 'Senin, 24 Januari',
                    messages: [
                      'Kehadiranmu mengalami penurunan dalam beberapa pertemuan terakhir. Usahakan hadir pada pertemuan berikutnya agar tetap memenuhi batas minimum kehadiran.',
                      'Nilai kuis terakhir masih rendah. Coba pelajari kembali materi yang berkaitan dan kerjakan latihan tambahan.',
                    ],
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(color: Colors.grey, thickness: 0.8),
                  ),

                  _buildDateGroup(
                    dateText: 'Minggu, 23 Januari',
                    messages: [
                      'Kehadiranmu mulai membaik dibanding minggu sebelumnya. Pertahankan konsistensi kehadiran.',
                      'Nilai kuis terakhir meningkat. Pertahankan pola belajar dan fokus pada materi yang masih belum dikuasai.',
                      'Materi yang perlu dipelajari kembali: array dan function.',
                    ],
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(color: Colors.grey, thickness: 0.8),
                  ),

                  _buildDateGroup(
                    dateText: 'Sabtu, 22 Januari',
                    messages: [
                      'Kehadiran telah memenuhi batas minimum.',
                      'Nilai tugas sudah cukup baik, tetapi hasil kuis masih belum konsisten. Perhatikan kembali materi yang mendapat nilai rendah.',
                    ],
                  ),
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

  Widget _buildDateGroup({
    required String dateText,
    required List<String> messages,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          dateText,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: kCardBlue,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: messages.map((msg) {
              return Container(
                width: double.infinity,
                margin: EdgeInsets.only(bottom: msg == messages.last ? 0 : 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5FE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  msg,
                  style: const TextStyle(
                    fontSize: 13.5,
                    height: 1.4,
                    color: Colors.black87,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}