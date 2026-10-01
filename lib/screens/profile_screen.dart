import 'package:flutter/material.dart';
import './common_widgets.dart';

const Color kAvatarGrey = Color.fromRGBO(110, 117, 134, 1);

const String namaMahasiswa = 'Nama\nMahasiswa';

const List<String> dataIdentitas = [
  'NIM: 19746713498174',
  'Email: mahasiswa@gmail.ac.id',
];

const List<String> dataAkademik = [
  'Angkatan: 2025',
  'Fakultas: Ilmu Komputer',
  'Program Studi: Teknik Informatika',
];

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const HeaderBar(showLogout: true),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 41),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SizedBox(height: 28),
                  Text(
                    'Profil Saya',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 24),
                  ProfileCard(),
                  SizedBox(height: 15),
                  RankingCard(),
                  SizedBox(height: 24),
                ],
              ),
            ),
          ),
          const BottomBar(currentIndex: 3),
        ],
      ),
    );
  }
}

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    const double avatarSize = 107;

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: avatarSize / 2),
          padding: const EdgeInsets.fromLTRB(12, avatarSize / 2 + 12, 12, 20),
          decoration: BoxDecoration(
            color: kCardBlue,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            children: [
              const Text(
                namaMahasiswa,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, height: 1.2, color: Colors.black),
              ),
              const SizedBox(height: 18),
              InfoBlock(lines: dataIdentitas),
              const Divider(color: Colors.black, thickness: 1, height: 24),
              InfoBlock(lines: dataAkademik),
            ],
          ),
        ),
        Container(
          width: avatarSize,
          height: avatarSize,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: ClipOval(
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: const [
                Positioned(
                  bottom: -14,
                  child: Icon(Icons.person, size: 108, color: kAvatarGrey),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class RankingCard extends StatelessWidget {
  const RankingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
      decoration: BoxDecoration(
        color: kCardBlue,
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Column(
        children: [
          RankItem(title: 'Ranking dalam satu kelas', value: 'Rangking 3'),
          Divider(color: Colors.black, thickness: 1, height: 20),
          RankItem(title: 'Rangking dalam satu jurusan', value: 'Rangking 10'),
        ],
      ),
    );
  }
}

class RankItem extends StatelessWidget {
  final String title;
  final String value;

  const RankItem({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.only(left: 13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontSize: 14, color: Colors.black)),
          ],
        ),
      ),
    );
  }
}

class InfoBlock extends StatelessWidget {
  final List<String> lines;

  const InfoBlock({super.key, required this.lines});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.only(left: 13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: lines
              .map((line) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(line, style: const TextStyle(fontSize: 15, color: Colors.black)),
                  ))
              .toList(),
        ),
      ),
    );
  }
}