
import 'package:flutter/material.dart';
import '../common_widgets.dart';
import 'kehadiran.dart';
import 'kelas/kelas_screen.dart';

// Model rincian jadwal kelas di semester ini
class JadwalKelasSemester {
  final String kode;
  final String nama;
  final int sks;
  final String hari;
  final String jam;
  final String ruang;
  final String dosen;
  final String status;

  const JadwalKelasSemester({
    required this.kode,
    required this.nama,
    required this.sks,
    required this.hari,
    required this.jam,
    required this.ruang,
    required this.dosen,
    this.status = 'Aktif',
  });
}

const List<JadwalKelasSemester> daftarJadwalSemester = [
  JadwalKelasSemester(
    kode: 'VTI51366',
    nama: 'Kecerdasan Buatan',
    sks: 3,
    hari: 'Senin',
    jam: '14.00 - 15.20 WIB',
    ruang: 'Lantai 7, Ruangan 701',
    dosen: 'Dr. Ahmad Sahroni, M.Kom.',
  ),
  JadwalKelasSemester(
    kode: 'VTI51329',
    nama: 'Pemrograman Web',
    sks: 4,
    hari: 'Selasa',
    jam: '08.00 - 10.00 WIB',
    ruang: 'Lantai 5, Ruang 502',
    dosen: 'Ir. Tri Astuti, M.T.',
  ),
  JadwalKelasSemester(
    kode: 'VTI51250',
    nama: 'Basis Data Terdistribusi',
    sks: 4,
    hari: 'Rabu',
    jam: '12.00 - 14.00 WIB',
    ruang: 'Lantai 6, Ruang 606',
    dosen: 'Teddy Indra Wijaya, M.Kom.',
  ),
  JadwalKelasSemester(
    kode: 'VTI51322',
    nama: 'Keamanan Siber & Jaringan',
    sks: 4,
    hari: 'Kamis',
    jam: '10.00 - 12.00 WIB',
    ruang: 'Lab Keamanan, Lantai 4',
    dosen: 'Prof. Bambang Hariyanto, Ph.D.',
  ),
  JadwalKelasSemester(
    kode: 'VTI51375',
    nama: 'Rekayasa Perangkat Lunak',
    sks: 4,
    hari: 'Jumat',
    jam: '08.00 - 10.30 WIB',
    ruang: 'Lantai 3, Ruang 304',
    dosen: 'Ivan Gunawan, M.Ds.',
  ),
  JadwalKelasSemester(
    kode: 'VTI51389',
    nama: 'Statistika Komputasi',
    sks: 3,
    hari: 'Jumat',
    jam: '13.30 - 15.00 WIB',
    ruang: 'Lantai 2, Ruang 201',
    dosen: 'Dra. Endang Sulistyo, M.Stat.',
  ),
];

class AcademicScreen extends StatefulWidget {
  const AcademicScreen({super.key});

  @override
  State<AcademicScreen> createState() => _AcademicScreenState();
}

class _AcademicScreenState extends State<AcademicScreen> {
  String _selectedHari = 'Semua';

  final List<String> _daftarHari = [
    'Semua',
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E222A) : const Color(0xFFF7F9FC);
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final cardBg = isDark ? const Color(0xFF282D37) : Colors.white;

    final filteredList = _selectedHari == 'Semua'
        ? daftarJadwalSemester
        : daftarJadwalSemester.where((j) => j.hari == _selectedHari).toList();

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          const HeaderBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Fast Navigation Cards (Kehadiran & Tugas)
                  _buildQuickAccessRow(context, isDark, cardBg),
                  const SizedBox(height: 22),

                  // Section Title: Rincian Jadwal Kelas Semester Ini
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Jadwal Kelas Semester Ini',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: titleColor,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Semester 4 • 22 SKS Terdaftar',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white60 : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF2563EB).withValues(alpha: 0.25)
                              : const Color(0xFF2563EB).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: isDark
                              ? Border.all(
                                  color: const Color(0xFF60A5FA).withValues(alpha: 0.7),
                                  width: 1.2,
                                )
                              : null,
                        ),
                        child: Text(
                          '${daftarJadwalSemester.length} Matkul',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF2563EB),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Filter Hari Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _daftarHari.map((hari) {
                        final isSelected = _selectedHari == hari;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(hari),
                            selected: isSelected,
                            onSelected: (val) {
                              if (val) setState(() => _selectedHari = hari);
                            },
                            labelStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? Colors.white70 : const Color(0xFF475569)),
                            ),
                            selectedColor: const Color(0xFF2563EB),
                            backgroundColor: isDark ? const Color(0xFF282D37) : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: BorderSide(
                                color: isSelected
                                    ? Colors.transparent
                                    : (isDark
                                        ? const Color(0xFF334155)
                                        : const Color(0xFFE2E8F0)),
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Daftar Jadwal Card
                  if (filteredList.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Tidak ada jadwal kelas pada hari $_selectedHari',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white54 : const Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                    )
                  else
                    Column(
                      children: filteredList
                          .map((j) => _buildScheduleCard(j, isDark, cardBg))
                          .toList(),
                    ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          const BottomBar(currentIndex: 1),
        ],
      ),
    );
  }

  // Quick Access ke Kehadiran dan Tugas
  Widget _buildQuickAccessRow(BuildContext context, bool isDark, Color cardBg) {
    return SizedBox(
      height: 84,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Kehadiran Perkuliahan
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const KehadiranScreen()),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF10B981).withValues(alpha: 0.25)
                            : const Color(0xFF10B981).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: isDark
                            ? Border.all(
                                color: const Color(0xFF34D399).withValues(alpha: 0.7),
                                width: 1.2,
                              )
                            : null,
                      ),
                      child: Icon(
                        Icons.calendar_today_rounded,
                        color: isDark ? const Color(0xFF34D399) : const Color(0xFF10B981),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kehadiran',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Presensi Kelas',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? Colors.white60 : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 13,
                      color: Color(0xFF94A3B8),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Tugas Kuliah
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const KelasScreen()),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFFF59E0B).withValues(alpha: 0.25)
                            : const Color(0xFFF59E0B).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: isDark
                            ? Border.all(
                                color: const Color(0xFFFBBF24).withValues(alpha: 0.7),
                                width: 1.2,
                              )
                            : null,
                      ),
                      child: Icon(
                        Icons.assignment_turned_in_rounded,
                        color: isDark ? const Color(0xFFFBBF24) : const Color(0xFFF59E0B),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tugas',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Deadline & Tugas',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? Colors.white60 : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 13,
                      color: Color(0xFF94A3B8),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Modern Card Jadwal Kuliah
  Widget _buildScheduleCard(JadwalKelasSemester j, bool isDark, Color cardBg) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF2563EB).withValues(alpha: 0.25)
                      : const Color(0xFF2563EB).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: isDark
                      ? Border.all(
                          color: const Color(0xFF60A5FA).withValues(alpha: 0.7),
                          width: 1.2,
                        )
                      : null,
                ),
                child: Text(
                  j.hari,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF2563EB),
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${j.sks} SKS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : const Color(0xFF475569),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    j.kode,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            j.nama,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.person_outline_rounded,
                size: 14,
                color: isDark ? Colors.white60 : const Color(0xFF64748B),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  j.dosen,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white60 : const Color(0xFF64748B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(
            color: isDark ? Colors.white10 : const Color(0xFFF1F5F9),
            thickness: 1,
            height: 1,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                Icons.schedule_rounded,
                size: 14,
                color: const Color(0xFF2563EB),
              ),
              const SizedBox(width: 4),
              Text(
                j.jam,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white70 : const Color(0xFF334155),
                ),
              ),
              const Spacer(),
              Icon(
                Icons.meeting_room_outlined,
                size: 14,
                color: const Color(0xFF10B981),
              ),
              const SizedBox(width: 4),
              Text(
                j.ruang,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white70 : const Color(0xFF334155),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
