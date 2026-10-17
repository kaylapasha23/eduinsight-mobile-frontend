import 'package:flutter/material.dart';
import '../academic_widgets.dart'; // kYellow

// Gabung Kelas sebagai notifikasi (dialog), bukan halaman baru
class GabungKelasScreen extends StatelessWidget {
  const GabungKelasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          color: kYellow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black, width: 1.5),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Gabung Kelas',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 26),
              const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Text(
                  'Kode Kelas:',
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                style: const TextStyle(fontSize: 17, color: Colors.black),
                decoration: InputDecoration(
                  hintText: 'Masukkan Kode Kelas',
                  hintStyle: const TextStyle(
                    fontSize: 17,
                    color: Color(0xFF8C8A7A),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFFFFFEE),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Text(
                  'Untuk bergabung, Anda perlu:',
                  style: TextStyle(fontSize: 15, color: Colors.black),
                ),
              ),
              const SizedBox(height: 4),
              const _Bullet(text: 'Menanyakan kode kelas kepada pengajar'),
              const _Bullet(
                text: 'Mengisi kode kelas yang harus terdiri dari 6-8 karakter acak',
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Gabung',
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Batal',
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Satu poin daftar (• teks) dengan baris kedua yang rapi
class _Bullet extends StatelessWidget {
  final String text;

  const _Bullet({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, top: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  ', style: TextStyle(fontSize: 15, color: Colors.black)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}