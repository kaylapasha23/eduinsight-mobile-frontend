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
  final List<NilaiMatkul> matkul;

  const NilaiSemester({
    required this.judul,
    required this.tahunAjaran,
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
    matkul: [
      NilaiMatkul(nomor: 6, nama: 'Keamanan Siber', kode: 'VTI51322', sks: 4, grade: 'A+'),
      NilaiMatkul(nomor: 5, nama: 'Rekayasa Perangkat Lunak', kode: 'VTI51375', sks: 4, grade: 'A+'),
      NilaiMatkul(nomor: 4, nama: 'Sistem Informasi', kode: 'VTI51335', sks: 4, grade: 'B+'),
      NilaiMatkul(nomor: 3, nama: 'Statistika', kode: 'VTI51389', sks: 4, grade: 'C+'),
      NilaiMatkul(nomor: 2, nama: 'Pemrograman Web', kode: 'VTI51329', sks: 4, grade: 'A+'),
      NilaiMatkul(nomor: 1, nama: 'Kecerdasan Buatan', kode: 'VTI51366', sks: 3, grade: 'A+'),
    ],
  ),
  NilaiSemester(
    judul: 'Semester Lima',
    tahunAjaran: 'Ganjil Tahun Ajaran 2025/2026',
    matkul: [
      NilaiMatkul(nomor: 3, nama: 'Basis Data', kode: 'VTI51250', sks: 4, grade: 'A'),
      NilaiMatkul(nomor: 2, nama: 'Jaringan Komputer', kode: 'VTI51261', sks: 3, grade: 'B+'),
      NilaiMatkul(nomor: 1, nama: 'Interaksi Manusia dan Komputer', kode: 'VTI51270', sks: 3, grade: 'A'),
    ],
  ),
  NilaiSemester(
    judul: 'Semester Empat',
    tahunAjaran: 'Genap Tahun Ajaran 2024/2025',
    matkul: [
      NilaiMatkul(nomor: 3, nama: 'Struktur Data', kode: 'VTI51180', sks: 4, grade: 'A'),
      NilaiMatkul(nomor: 2, nama: 'Sistem Operasi', kode: 'VTI51191', sks: 3, grade: 'A-'),
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
    NilaiSemester smt = dataNilai[_selected.value];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const BackHeaderBar(title: 'Nilai'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
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
                  const SizedBox(height: 28),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          smt.judul,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          smt.tahunAjaran,
                          style: const TextStyle(fontSize: 14, color: Colors.black),
                        ),
                        const SizedBox(height: 24),
                        TitledCard(
                          title: 'Ringkasan Nilai',
                          color: kCardBlue,
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              children: smt.matkul
                                  .map((m) => _NilaiTile(matkul: m))
                                  .toList(),
                            ),
                          ),
                        ),
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
}

class _NilaiTile extends StatelessWidget {
  final NilaiMatkul matkul;

  const _NilaiTile({required this.matkul});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: kTileBlue,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Text(
              '${matkul.nomor}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  matkul.nama,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  '${matkul.kode} - ${matkul.sks} SKS',
                  style: const TextStyle(fontSize: 12, color: Colors.black),
                ),
              ],
            ),
          ),
          Text(
            matkul.grade,
            style: const TextStyle(fontSize: 18, color: Colors.black),
          ),
        ],
      ),
    );
  }
}