import 'package:flutter/material.dart';
import '../../services/academic_api_service.dart';

class ModernRankingCard extends StatefulWidget {
  const ModernRankingCard({super.key});

  @override
  State<ModernRankingCard> createState() => _ModernRankingCardState();
}

class _ModernRankingCardState extends State<ModernRankingCard> {
  int _totalMahasiswa = 4;

  @override
  void initState() {
    super.initState();
    _loadTotalMahasiswa();
  }

  Future<void> _loadTotalMahasiswa() async {
    final total = await AcademicApiService.fetchTotalMahasiswa();
    if (total != null && total > 0 && mounted) {
      setState(() {
        _totalMahasiswa = total;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF282D37) : Colors.white;

    final rankKelas = _totalMahasiswa > 1 ? 2 : 1;

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
            rank: 'Rangking $rankKelas',
            total: 'dari $_totalMahasiswa Mahasiswa',
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
            rank: 'Rangking 1',
            total: 'dari $_totalMahasiswa Mahasiswa',
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
