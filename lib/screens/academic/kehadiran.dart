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
      Pertemuan(nomor: 5, topik: 'Query & Relasi Tabel', tanggal: 'Rabu, 29 Oktober 2026', status: 'Sakit'),
      Pertemuan(nomor: 4, topik: 'Dasar SQL', tanggal: 'Rabu, 22 Oktober 2026', status: 'Alpa'),
      Pertemuan(nomor: 3, topik: 'Relasi Database', tanggal: 'Rabu, 15 Oktober 2026', status: 'Hadir'),
      Pertemuan(nomor: 2, topik: 'Model Data & ERD', tanggal: 'Rabu, 8 Oktober 2026', status: 'Hadir'),
      Pertemuan(nomor: 1, topik: 'Pengenalan Basis Data', tanggal: 'Rabu, 1 Oktober 2026', status: 'Hadir'),
    ],
  ),
  MataKuliahHadir(
    nama: 'Kecerdasan Buatan',
    jadwal: '14.00-15.20 Lantai 7, Ruangan 701',
    riwayat: [
      Pertemuan(nomor: 4, topik: 'Pencarian Heuristik', tanggal: 'Senin, 19 Oktober 2026', status: 'Hadir'),
      Pertemuan(nomor: 3, topik: 'Pencarian Buta', tanggal: 'Senin, 12 Oktober 2026', status: 'Izin'),
      Pertemuan(nomor: 2, topik: 'Agen Cerdas', tanggal: 'Senin, 5 Oktober 2026', status: 'Hadir'),
      Pertemuan(nomor: 1, topik: 'Pengenalan AI', tanggal: 'Senin, 28 September 2026', status: 'Hadir'),
    ],
  ),
  MataKuliahHadir(
    nama: 'Pemrograman Web',
    jadwal: '08.00-10.00 Lantai 5, Ruang 502',
    riwayat: [
      Pertemuan(nomor: 3, topik: 'Routing & Navigasi', tanggal: 'Selasa, 13 Oktober 2026', status: 'Hadir'),
      Pertemuan(nomor: 2, topik: 'Komponen & Props', tanggal: 'Selasa, 6 Oktober 2026', status: 'Hadir'),
      Pertemuan(nomor: 1, topik: 'Dasar HTML & CSS', tanggal: 'Selasa, 29 September 2026', status: 'Alpa'),
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
        jumlah = jumlah + 1;
      }
    }
    return jumlah;
  }

  @override
  Widget build(BuildContext context) {
    MataKuliahHadir mk = dataKehadiran[_selected.value];

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: Column(
        children: [
          const BackHeaderBar(title: 'Kehadiran'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 28),
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
                  const SizedBox(height: 28),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mk.nama,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0D1B40),
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          mk.jadwal,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF5C6B8A),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildRingkasan(mk),
                        const SizedBox(height: 18),
                        _buildRiwayat(mk),
                        const SizedBox(height: 28),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const BottomBar(currentIndex: 1),
        ],
      ),
    );
  }

  Widget _buildRingkasan(MataKuliahHadir mk) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFDDE8FF),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B6FE8).withValues(alpha: 0.14),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '${mk.riwayat.length} Pertemuan',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A2B4A),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: daftarStatus
                .map((s) => _CountTile(label: s, jumlah: _hitung(mk, s)))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRiwayat(MataKuliahHadir mk) {
    return TitledCard(
      title: 'Riwayat Pertemuan',
      color: const Color(0xFFDDE8FF),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: mk.riwayat.map((p) => _RiwayatTile(pertemuan: p)).toList(),
        ),
      ),
    );
  }
}

class _CountTile extends StatelessWidget {
  final String label;
  final int jumlah;

  const _CountTile({required this.label, required this.jumlah});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '$jumlah',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A2B4A),
            ),
          ),
          Divider(
            color: Colors.black.withValues(alpha: 0.12),
            thickness: 1,
            height: 10,
            indent: 8,
            endIndent: 8,
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF3A5A9B)),
          ),
        ],
      ),
    );
  }
}

class _RiwayatTile extends StatelessWidget {
  final Pertemuan pertemuan;

  const _RiwayatTile({required this.pertemuan});

  Color _statusColor(String status) {
    switch (status) {
      case 'Hadir':
        return const Color(0xFF34C759);
      case 'Izin':
        return const Color(0xFFFF9F0A);
      case 'Sakit':
        return const Color(0xFF5AC8FA);
      case 'Alpa':
        return const Color(0xFFFF3B30);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F7FF),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF1A2B4A).withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${pertemuan.nomor}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A2B4A),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pertemuan.topik,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A2B4A),
                  ),
                ),
                Text(
                  pertemuan.tanggal,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF5C6B8A)),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _statusColor(pertemuan.status).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              pertemuan.status,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _statusColor(pertemuan.status),
              ),
            ),
          ),
        ],
      ),
    );
  }
}