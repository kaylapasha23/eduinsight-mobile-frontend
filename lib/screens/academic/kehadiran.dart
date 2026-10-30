
import 'package:flutter/material.dart';
import '../common_widgets.dart';
import 'academic_widgets.dart';

class Pertemuan {
  final int nomor;
  final String topik;
  final String tanggal;
  final String status;

  const Pertemuan({
    required this.nomor,
    required this.topik,
    required this.tanggal,
    required this.status,
  });
}

class MataKuliahHadir {
  final String nama;
  final String jadwal;
  final List<Pertemuan> riwayat;

  const MataKuliahHadir({
    required this.nama,
    required this.jadwal,
    required this.riwayat,
  });
}

const List<String> daftarStatus = ['Hadir', 'Izin', 'Sakit', 'Alpa'];

const List<ListItem> pilihanMatkul = [
  ListItem(value: 0, name: 'Basis Data'),
  ListItem(value: 1, name: 'Kecerdasan Buatan'),
  ListItem(value: 2, name: 'Pemrograman Web'),
];

const List<MataKuliahHadir> dataKehadiran = [
  MataKuliahHadir(
    nama: 'Basis Data',
    jadwal: '12.00-14.00 Lantai 6, Ruang 606',
    riwayat: [
      Pertemuan(
        nomor: 5,
        topik: 'Query & Relasi Tabel',
        tanggal: 'Rabu, 29 Oktober 2026',
        status: 'Sakit',
      ),
      Pertemuan(
        nomor: 4,
        topik: 'Dasar SQL',
        tanggal: 'Rabu, 22 Oktober 2026',
        status: 'Alpa',
      ),
      Pertemuan(
        nomor: 3,
        topik: 'Relasi Database',
        tanggal: 'Rabu, 15 Oktober 2026',
        status: 'Hadir',
      ),
      Pertemuan(
        nomor: 2,
        topik: 'Model Data & ERD',
        tanggal: 'Rabu, 8 Oktober 2026',
        status: 'Hadir',
      ),
      Pertemuan(
        nomor: 1,
        topik: 'Pengenalan Basis Data',
        tanggal: 'Rabu, 1 Oktober 2026',
        status: 'Hadir',
      ),
    ],
  ),
  MataKuliahHadir(
    nama: 'Kecerdasan Buatan',
    jadwal: '14.00-15.20 Lantai 7, Ruangan 701',
    riwayat: [
      Pertemuan(
        nomor: 4,
        topik: 'Pencarian Heuristik',
        tanggal: 'Senin, 19 Oktober 2026',
        status: 'Hadir',
      ),
      Pertemuan(
        nomor: 3,
        topik: 'Pencarian Buta',
        tanggal: 'Senin, 12 Oktober 2026',
        status: 'Izin',
      ),
      Pertemuan(
        nomor: 2,
        topik: 'Agen Cerdas',
        tanggal: 'Senin, 5 Oktober 2026',
        status: 'Hadir',
      ),
      Pertemuan(
        nomor: 1,
        topik: 'Pengenalan AI',
        tanggal: 'Senin, 28 September 2026',
        status: 'Hadir',
      ),
    ],
  ),
  MataKuliahHadir(
    nama: 'Pemrograman Web',
    jadwal: '08.00-10.00 Lantai 5, Ruang 502',
    riwayat: [
      Pertemuan(
        nomor: 3,
        topik: 'Routing & Navigasi',
        tanggal: 'Selasa, 13 Oktober 2026',
        status: 'Hadir',
      ),
      Pertemuan(
        nomor: 2,
        topik: 'Komponen & Props',
        tanggal: 'Selasa, 6 Oktober 2026',
        status: 'Hadir',
      ),
      Pertemuan(
        nomor: 1,
        topik: 'Dasar HTML & CSS',
        tanggal: 'Selasa, 29 September 2026',
        status: 'Alpa',
      ),
    ],
  ),
];

class KehadiranScreen extends StatefulWidget {
  const KehadiranScreen({super.key});

  @override
  State<KehadiranScreen> createState() => _KehadiranScreenState();
}

class _KehadiranScreenState extends State<KehadiranScreen> {
  ListItem _selected = pilihanMatkul[0];

  int _hitung(MataKuliahHadir mk, String status) {
    int jumlah = 0;

    for (Pertemuan p in mk.riwayat) {
      if (p.status == status) {
        jumlah++;
      }
    }

    return jumlah;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark
        ? const Color(0xFF1E222A)
        : const Color(0xFFF7F9FC);

    final titleColor = isDark
        ? Colors.white
        : const Color(0xFF0F172A);

    final cardBg = isDark
        ? const Color(0xFF282D37)
        : Colors.white;

    MataKuliahHadir mk = dataKehadiran[_selected.value];

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          const BackHeaderBar(title: 'Kehadiran'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  YellowDropdown(
                    items: pilihanMatkul,
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
                  Text(
                    mk.nama,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: titleColor,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 13,
                        color: isDark
                            ? const Color(0xFF9AA4B8)
                            : const Color(0xFF64748B),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        mk.jadwal,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? const Color(0xFF9AA4B8)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _buildRingkasan(mk, isDark, cardBg),
                  const SizedBox(height: 24),
                  _buildRiwayat(mk, isDark, cardBg, titleColor),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          const BottomBar(currentIndex: 1),
        ],
      ),
    );
  }

  Widget _buildRingkasan(
    MataKuliahHadir mk,
    bool isDark,
    Color cardBg,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? const Color(0xFF3B4555)
              : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: isDark ? 0.16 : 0.04,
            ),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ringkasan Presensi',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? Colors.white
                      : const Color(0xFF0F172A),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF323B4C)
                      : const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${mk.riwayat.length} Pertemuan',
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
          const SizedBox(height: 16),
          Row(
            children: daftarStatus.map((s) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _CountTile(
                    label: s,
                    jumlah: _hitung(mk, s),
                    isDark: isDark,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRiwayat(
    MataKuliahHadir mk,
    bool isDark,
    Color cardBg,
    Color titleColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Riwayat Pertemuan',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: titleColor,
                letterSpacing: -0.2,
              ),
            ),
            Text(
              'Selesai',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? const Color(0xFF93C5FD)
                    : const Color(0xFF2563EB),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Column(
          children: mk.riwayat
              .map(
                (p) => _RiwayatTile(
                  pertemuan: p,
                  isDark: isDark,
                  cardBg: cardBg,
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _CountTile extends StatelessWidget {
  final String label;
  final int jumlah;
  final bool isDark;

  const _CountTile({
    required this.label,
    required this.jumlah,
    required this.isDark,
  });

  Color _getStatusThemeColor(String status) {
    switch (status) {
      case 'Hadir':
        return isDark
            ? const Color(0xFF34D399)
            : const Color(0xFF10B981);
      case 'Izin':
        return isDark
            ? const Color(0xFFFBBF24)
            : const Color(0xFFF59E0B);
      case 'Sakit':
        return isDark
            ? const Color(0xFF60A5FA)
            : const Color(0xFF0284C7);
      case 'Alpa':
        return isDark
            ? const Color(0xFFF87171)
            : const Color(0xFFEF4444);
      default:
        return isDark
            ? const Color(0xFF9AA4B8)
            : const Color(0xFF64748B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color themeColor = _getStatusThemeColor(label);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: themeColor.withValues(
          alpha: isDark ? 0.12 : 0.08,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: themeColor.withValues(
            alpha: isDark ? 0.4 : 0.3,
          ),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            '$jumlah',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: themeColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? const Color(0xFFCBD5E1)
                  : const Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }
}

class _RiwayatTile extends StatelessWidget {
  final Pertemuan pertemuan;
  final bool isDark;
  final Color cardBg;

  const _RiwayatTile({
    required this.pertemuan,
    required this.isDark,
    required this.cardBg,
  });

  Color _statusColor(String status) {
    switch (status) {
      case 'Hadir':
        return isDark
            ? const Color(0xFF34D399)
            : const Color(0xFF10B981);
      case 'Izin':
        return isDark
            ? const Color(0xFFFBBF24)
            : const Color(0xFFF59E0B);
      case 'Sakit':
        return isDark
            ? const Color(0xFF60A5FA)
            : const Color(0xFF0284C7);
      case 'Alpa':
        return isDark
            ? const Color(0xFFF87171)
            : const Color(0xFFEF4444);
      default:
        return isDark
            ? const Color(0xFF9AA4B8)
            : const Color(0xFF64748B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(pertemuan.status);

    const numberColor = Color(0xFF60A5FA);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? const Color(0xFF3B4555)
              : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: isDark ? 0.14 : 0.03,
            ),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF323B4C)
                  : const Color(0xFFEFF6FF),
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark
                    ? const Color(0xFF52627A)
                    : const Color(0xFFBFDBFE),
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                '${pertemuan.nomor}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: numberColor,
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
                  pertemuan.topik,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? Colors.white
                        : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  pertemuan.tanggal,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark
                        ? const Color(0xFF9AA4B8)
                        : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: statusColor.withValues(
                alpha: isDark ? 0.12 : 0.08,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: statusColor.withValues(
                  alpha: isDark ? 0.4 : 0.3,
                ),
                width: 1,
              ),
            ),
            child: Text(
              pertemuan.status,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
