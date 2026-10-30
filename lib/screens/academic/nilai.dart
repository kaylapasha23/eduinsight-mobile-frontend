
import 'package:flutter/material.dart';
import '../common_widgets.dart';
import 'academic_widgets.dart';

class NilaiMatkul {
  final int nomor;
  final String nama;
  final String kode;
  final int sks;
  final String grade;

  const NilaiMatkul({
    required this.nomor,
    required this.nama,
    required this.kode,
    required this.sks,
    required this.grade,
  });
}

class NilaiSemester {
  final String judul;
  final String tahunAjaran;
  final double ips;
  final int totalSks;
  final List<NilaiMatkul> matkul;

  const NilaiSemester({
    required this.judul,
    required this.tahunAjaran,
    required this.ips,
    required this.totalSks,
    required this.matkul,
  });
}

const List<ListItem> pilihanSemester = [
  ListItem(value: 0, name: 'Semester Enam - Genap 2025/2026'),
  ListItem(value: 1, name: 'Semester Lima - Ganjil 2025/2026'),
  ListItem(value: 2, name: 'Semester Empat - Genap 2024/2025'),
];

const List<NilaiSemester> dataNilai = [
  NilaiSemester(
    judul: 'Semester Enam',
    tahunAjaran: 'Genap Tahun Ajaran 2025/2026',
    ips: 3.78,
    totalSks: 22,
    matkul: [
      NilaiMatkul(nomor: 6, nama: 'Keamanan Siber', kode: 'VTI51322', sks: 4, grade: 'A+'),
      NilaiMatkul(nomor: 5, nama: 'Rekayasa Perangkat Lunak', kode: 'VTI51375', sks: 4, grade: 'A+'),
      NilaiMatkul(nomor: 4, nama: 'Sistem Informasi', kode: 'VTI51335', sks: 4, grade: 'B+'),
      NilaiMatkul(nomor: 3, nama: 'Statistika Komputasi', kode: 'VTI51389', sks: 4, grade: 'C+'),
      NilaiMatkul(nomor: 2, nama: 'Pemrograman Web', kode: 'VTI51329', sks: 4, grade: 'A+'),
      NilaiMatkul(nomor: 1, nama: 'Kecerdasan Buatan', kode: 'VTI51366', sks: 3, grade: 'A+'),
    ],
  ),
  NilaiSemester(
    judul: 'Semester Lima',
    tahunAjaran: 'Ganjil Tahun Ajaran 2025/2026',
    ips: 3.90,
    totalSks: 20,
    matkul: [
      NilaiMatkul(nomor: 3, nama: 'Basis Data Terdistribusi', kode: 'VTI51250', sks: 4, grade: 'A'),
      NilaiMatkul(nomor: 2, nama: 'Jaringan Komputer', kode: 'VTI51261', sks: 3, grade: 'B+'),
      NilaiMatkul(nomor: 1, nama: 'Interaksi Manusia & Komputer', kode: 'VTI51270', sks: 3, grade: 'A'),
    ],
  ),
  NilaiSemester(
    judul: 'Semester Empat',
    tahunAjaran: 'Genap Tahun Ajaran 2024/2025',
    ips: 4.00,
    totalSks: 21,
    matkul: [
      NilaiMatkul(nomor: 3, nama: 'Struktur Data & Algoritma', kode: 'VTI51180', sks: 4, grade: 'A'),
      NilaiMatkul(nomor: 2, nama: 'Sistem Operasi', kode: 'VTI51191', sks: 3, grade: 'A'),
      NilaiMatkul(nomor: 1, nama: 'Pemrograman Mobile', kode: 'VTI51203', sks: 3, grade: 'A+'),
    ],
  ),
];

class NilaiScreen extends StatefulWidget {
  const NilaiScreen({super.key});

  @override
  State<NilaiScreen> createState() => _NilaiScreenState();
}

class _NilaiScreenState extends State<NilaiScreen> {
  ListItem _selected = pilihanSemester[0];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E222A) : const Color(0xFFF7F9FC);
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final cardBg = isDark ? const Color(0xFF282D37) : Colors.white;

    NilaiSemester smt = dataNilai[_selected.value];

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          const BackHeaderBar(title: 'Rincian Nilai Semester'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  YellowDropdown(
                    items: pilihanSemester,
                    selectedItem: _selected,
                    onChanged: (ListItem? value) {
                      if (value != null) {
                        setState(() {
                          _selected = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 20),

                  _buildSemesterSummaryCard(smt, isDark, cardBg),
                  const SizedBox(height: 22),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Daftar Nilai Mata Kuliah',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: titleColor,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF2563EB).withValues(alpha: 0.25)
                              : const Color(0xFF2563EB).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: isDark
                              ? Border.all(
                                  color: const Color(0xFF60A5FA).withValues(alpha: 0.7),
                                  width: 1.2,
                                )
                              : null,
                        ),
                        child: Text(
                          '${smt.matkul.length} Matkul',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? const Color(0xFF93C5FD)
                                : const Color(0xFF2563EB),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Column(
                    children: smt.matkul
                        .map((m) => _NilaiTile(
                              matkul: m,
                              isDark: isDark,
                              cardBg: cardBg,
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          const BottomBar(currentIndex: 3),
        ],
      ),
    );
  }

  Widget _buildSemesterSummaryCard(
    NilaiSemester smt,
    bool isDark,
    Color cardBg,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      smt.judul,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      smt.tahunAjaran,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white60 : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: isDark ? 0.2 : 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFF10B981).withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'IPS',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF059669),
                      ),
                    ),
                    Text(
                      smt.ips.toStringAsFixed(2),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: isDark ? const Color(0xFF34D399) : const Color(0xFF047857),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(
            color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
            thickness: 1,
            height: 1,
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatMini('Total SKS', '${smt.totalSks} SKS', isDark),
              Container(
                width: 1,
                height: 24,
                color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
              ),
              _buildStatMini('Mata Kuliah', '${smt.matkul.length} Matkul', isDark),
              Container(
                width: 1,
                height: 24,
                color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
              ),
              _buildStatMini('Status', 'Lulus Penuh', isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatMini(String label, String value, bool isDark) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? Colors.white54 : const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}

class _NilaiTile extends StatelessWidget {
  final NilaiMatkul matkul;
  final bool isDark;
  final Color cardBg;

  const _NilaiTile({
    required this.matkul,
    required this.isDark,
    required this.cardBg,
  });

  Color _gradeBgColor(String grade) {
    if (grade.startsWith('A')) return const Color(0xFF10B981);
    if (grade.startsWith('B')) return const Color(0xFF3B82F6);
    if (grade.startsWith('C')) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  @override
  Widget build(BuildContext context) {
    final gradeColor = _gradeBgColor(matkul.grade);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF2563EB).withValues(alpha: 0.35)
                  : const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${matkul.nomor}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF334155),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  matkul.nama,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${matkul.sks} SKS',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : const Color(0xFF475569),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      matkul.kode,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white54 : const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: gradeColor.withValues(alpha: isDark ? 0.25 : 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: gradeColor.withValues(alpha: isDark ? 0.7 : 0.3),
                width: isDark ? 1.2 : 1.0,
              ),
            ),
            child: Center(
              child: Text(
                matkul.grade,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: gradeColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
