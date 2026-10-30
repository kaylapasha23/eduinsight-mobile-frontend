import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../common_widgets.dart';
import '../academic/ipk.dart';
import '../academic/nilai.dart';
import '../../providers/auth_provider.dart';

const Color kAvatarGrey = Color.fromRGBO(110, 117, 134, 1);

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E222A) : const Color(0xFFF7F9FC);
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final cardBg = isDark ? const Color(0xFF282D37) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          const HeaderBar(showLogout: true),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Profil Saya',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: titleColor,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF10B981).withValues(alpha: 0.25) : const Color(0xFF10B981).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: isDark ? Border.all(color: const Color(0xFF34D399).withValues(alpha: 0.7), width: 1.2) : null,
                        ),
                        child: Text(
                          'Mahasiswa Aktif',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isDark ? const Color(0xFF34D399) : const Color(0xFF059669),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const ModernProfileCard(),
                  const SizedBox(height: 20),

                  // ================= SECTION HASIL STUDI & KHS =================
                  Row(
                    children: [
                      Text(
                        'Hasil Studi & KHS',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2563EB).withValues(alpha: 0.25) : const Color(0xFF2563EB).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: isDark ? Border.all(color: const Color(0xFF60A5FA).withValues(alpha: 0.7), width: 1.2) : null,
                        ),
                        child: Text(
                          'Akademik',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF2563EB),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildAcademicResultsSection(context, isDark, cardBg),

                  const SizedBox(height: 20),
                  Text(
                    'Peringkat Akademik',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const ModernRankingCard(),
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

  // Section Hasil Studi & KHS (IPK & Nilai yang dipindah dari Akademik)
  Widget _buildAcademicResultsSection(
    BuildContext context,
    bool isDark,
    Color cardBg,
  ) {
    return Row(
      children: [
        // Menu IPK / Transkrip
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const IpkScreen()),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(16),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2563EB).withValues(alpha: 0.25) : const Color(0xFF2563EB).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: isDark ? Border.all(color: const Color(0xFF60A5FA).withValues(alpha: 0.7), width: 1.2) : null,
                        ),
                        child: Icon(
                          Icons.show_chart_rounded,
                          size: 20,
                          color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF2563EB),
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: Color(0xFF94A3B8),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'IPK (KHS)',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '4 Semester Selesai',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white60 : const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '3.78',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF1D4ED8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Menu Nilai Mata Kuliah
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NilaiScreen()),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(16),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF10B981).withValues(alpha: 0.25) : const Color(0xFF10B981).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: isDark ? Border.all(color: const Color(0xFF34D399).withValues(alpha: 0.7), width: 1.2) : null,
                        ),
                        child: Icon(
                          Icons.assignment_outlined,
                          size: 20,
                          color: isDark ? const Color(0xFF34D399) : const Color(0xFF10B981),
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: Color(0xFF94A3B8),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Rincian Nilai',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '6 Mata Kuliah',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white60 : const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Lihat KHS >',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isDark ? const Color(0xFF34D399) : const Color(0xFF059669),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ModernProfileCard extends StatelessWidget {
  const ModernProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF282D37) : Colors.white;
    final auth = Provider.of<AuthProvider>(context);

    final user = auth.user;
    final nama = auth.userName;
    final email = user?['email'] as String? ?? '-';
    final nim = user?['nim'] as String? ?? '-';
    final prodi = user?['prodi'] as String? ?? 'Teknik Informatika';
    final fakultas = user?['fakultas'] as String? ?? 'Ilmu Komputer';
    final angkatan = user?['angkatan'] as String? ?? '-';

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
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.person_rounded, size: 40, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nama,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$prodi (S1)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF2563EB),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      nim != '-' ? 'NIM: $nim' : 'NIM: —',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white54 : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Divider(
            color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
            thickness: 1,
            height: 1,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.alternate_email_rounded,
            label: 'Email',
            value: email,
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          _buildInfoRow(
            icon: Icons.account_balance_outlined,
            label: 'Fakultas',
            value: 'Fak. $fakultas',
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          _buildInfoRow(
            icon: Icons.calendar_today_rounded,
            label: 'Angkatan',
            value: angkatan != '-' ? '$angkatan (Genap)' : '—',
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: isDark ? Colors.white54 : const Color(0xFF64748B),
        ),
        const SizedBox(width: 10),
        Text(
          '$label:',
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white60 : const Color(0xFF64748B),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class ModernRankingCard extends StatelessWidget {
  const ModernRankingCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF282D37) : Colors.white;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
        children: [
          _buildRankTile(
            title: 'Ranking dalam satu kelas',
            rank: 'Rangking 3',
            total: 'dari 36 Mahasiswa',
            icon: Icons.military_tech_rounded,
            badgeColor: const Color(0xFFF59E0B),
            isDark: isDark,
          ),
          Divider(
            color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
            thickness: 1,
            height: 24,
          ),
          _buildRankTile(
            title: 'Rangking dalam satu jurusan',
            rank: 'Rangking 10',
            total: 'dari 140 Mahasiswa',
            icon: Icons.emoji_events_rounded,
            badgeColor: const Color(0xFF3B82F6),
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildRankTile({
    required String title,
    required String rank,
    required String total,
    required IconData icon,
    required Color badgeColor,
    required bool isDark,
  }) {
    return Row(
      children: [
        Builder(
          builder: (context) {
            final effectiveColor = isDark
                ? (badgeColor == const Color(0xFFF59E0B)
                    ? const Color(0xFFFBBF24)
                    : const Color(0xFF60A5FA))
                : badgeColor;

            return Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? effectiveColor.withValues(alpha: 0.25) : effectiveColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: isDark ? Border.all(color: effectiveColor.withValues(alpha: 0.7), width: 1.2) : null,
              ),
              child: Icon(icon, color: effectiveColor, size: 22),
            );
          },
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : const Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Text(
                    rank,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    total,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
