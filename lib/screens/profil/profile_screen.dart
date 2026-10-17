import 'package:flutter/material.dart';
import '../common_widgets.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF23272F) : const Color(0xFFFDFDFD);

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          const HeaderBar(showLogout: true),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 28),
                  Text(
                    'Profil Saya',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? const Color(0xFF82B1FF) : const Color(0xFF0D1B40),
                      letterSpacing: -0.3,
                    ),
                  ),
                  SizedBox(height: 24),
                  ProfileCard(),
                  SizedBox(height: 16),
                  RankingCard(),
                  SizedBox(height: 28),
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
    const double avatarSize = 110;

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: avatarSize / 2),
          padding: const EdgeInsets.fromLTRB(18, avatarSize / 2 + 16, 18, 24),
          decoration: BoxDecoration(
            color: const Color(0xFFDDE8FF),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3B6FE8).withValues(alpha: 0.14),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              const Text(
                namaMahasiswa,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  height: 1.3,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D1B40),
                ),
              ),
              const SizedBox(height: 20),
              InfoBlock(lines: dataIdentitas),
              Divider(
                color: Colors.black.withValues(alpha: 0.1),
                thickness: 1,
                height: 28,
              ),
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
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3B6FE8).withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
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
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: const Color(0xFFDDE8FF),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B6FE8).withValues(alpha: 0.14),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Column(
        children: [
          RankItem(title: 'Ranking dalam satu kelas', value: 'Rangking 3'),
          Divider(color: Color(0x1A000000), thickness: 1, height: 24),
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
        padding: const EdgeInsets.only(left: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A2B4A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF3A6BBF),
                fontWeight: FontWeight.w500,
              ),
            ),
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
        padding: const EdgeInsets.only(left: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: lines
              .map((line) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Text(
                      line,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF2A3B5E),
                        height: 1.4,
                      ),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }
}