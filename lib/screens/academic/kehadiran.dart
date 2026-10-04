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
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const BackHeaderBar(title: 'Kehadiran'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
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
                    padding: const EdgeInsets.symmetric(horizontal: 11),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mk.nama,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          mk.jadwal,
                          style: const TextStyle(fontSize: 14, color: Colors.black),
                        ),
                        const SizedBox(height: 16),
                        _buildRingkasan(mk),
                        const SizedBox(height: 16),
                        _buildRiwayat(mk),
                        const SizedBox(height: 24),
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
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: kCardBlue,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Text(
            '${mk.riwayat.length} Pertemuan',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 14),
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
      color: kCardBlue,
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
      width: 58,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: kTileBlue,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text('$jumlah', style: const TextStyle(fontSize: 16, color: Colors.black)),
          const SizedBox(
            width: 38,
            child: Divider(color: Colors.black, thickness: 1, height: 10),
          ),
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.black)),
        ],
      ),
    );
  }
}

class _RiwayatTile extends StatelessWidget {
  final Pertemuan pertemuan;

  const _RiwayatTile({required this.pertemuan});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: kTileBlue,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              '${pertemuan.nomor}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pertemuan.topik,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  pertemuan.tanggal,
                  style: const TextStyle(fontSize: 12, color: Colors.black),
                ),
              ],
            ),
          ),
          Text(
            pertemuan.status,
            style: const TextStyle(fontSize: 13, color: Colors.black),
          ),
        ],
      ),
    );
  }
}