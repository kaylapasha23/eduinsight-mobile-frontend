import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../academic_widgets.dart';
import 'kelas_provider.dart';
import 'kelas_screen.dart';
import 'detail_tugas_screen.dart';

class RuangKelasScreen extends StatefulWidget {
  final String namaMatkul;
  final String dosenPengampu;
  final String? kodeKelas;
  final String? ruangan;
  final String? jadwal;

  const RuangKelasScreen({
    super.key,
    required this.namaMatkul,
    required this.dosenPengampu,
    this.kodeKelas,
    this.ruangan,
    this.jadwal,
  });

  @override
  State<RuangKelasScreen> createState() => _RuangKelasScreenState();
}

class _RuangKelasScreenState extends State<RuangKelasScreen> {
  // Helper warna banner random/spesifik berdasarkan nama matkul
  LinearGradient _getBannerGradient(String nama) {
    if (nama.contains('Jaringan') || nama.contains('Cyber')) {
      return const LinearGradient(
        colors: [Color(0xFF0D9488), Color(0xFF14B8A6)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (nama.contains('Web')) {
      return const LinearGradient(
        colors: [Color(0xFF2563EB), Color(0xFF38BDF8)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (nama.contains('Kecerdasan') || nama.contains('AI')) {
      return const LinearGradient(
        colors: [Color(0xFF7C3AED), Color(0xFFA78BFA)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (nama.contains('UI') || nama.contains('Design')) {
      return const LinearGradient(
        colors: [Color(0xFFEA580C), Color(0xFFFB923C)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    // Default green ala Google Classroom
    return const LinearGradient(
      colors: [Color(0xFF15803D), Color(0xFF22C55E)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E222A) : const Color(0xFFF7F9FC);
    final cardBg = isDark ? const Color(0xFF282D37) : Colors.white;
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subColor = isDark ? const Color(0xFF9AA4B8) : const Color(0xFF64748B);

    final kelasProvider = context.watch<KelasProvider>();
    final allTasks = kelasProvider.dynamicTasks.isNotEmpty
        ? kelasProvider.dynamicTasks
        : [...allSegeraTasks, ...allSelesaiTasks];

    // Filter tugas hanya untuk mata kuliah ini
    final tasksForThisClass = allTasks.where((t) {
      final cName = t.className.toLowerCase();
      final target = widget.namaMatkul.toLowerCase();
      return cName.contains(target) || target.contains(cName);
    }).toList();

    // Pisahkan tugas yang belum selesai (Upcoming / Uncompleted)
    final uncompletedTasks = tasksForThisClass.where((t) {
      final key = '${t.className}|${t.title}';
      return !kelasProvider.isCompleted(key);
    }).toList();

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          BackHeaderBar(
            title: widget.namaMatkul,
            trailing: IconButton(
              icon: const Icon(Icons.info_outline_rounded, color: Colors.white),
              onPressed: () => _showClassInfoDialog(context, isDark),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Banner Kelas Google Classroom Style
                  _buildClassBanner(isDark),
                  const SizedBox(height: 14),

                  // Box Reminder: Upcoming (Tenggat Dekat / Belum Selesai)
                  _buildUpcomingReminderBox(
                    context,
                    uncompletedTasks,
                    isDark,
                    cardBg,
                    titleColor,
                    subColor,
                  ),
                  const SizedBox(height: 18),

                  // Stream Pengumuman Dosen
                  _buildAnnouncementCard(isDark, cardBg, titleColor, subColor),
                  const SizedBox(height: 14),

                  // Feed Tugas yang diposting dosen di kelas ini
                  if (tasksForThisClass.isEmpty)
                    _buildEmptyActivityCard(isDark, cardBg, subColor)
                  else
                    ...tasksForThisClass.map((task) => _buildTaskActivityCard(
                          context,
                          task,
                          kelasProvider,
                          isDark,
                          cardBg,
                          titleColor,
                          subColor,
                        )),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 1. Header Banner Kelas
  Widget _buildClassBanner(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: _getBannerGradient(widget.namaMatkul),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                  color: Colors.black.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  widget.kodeKelas ?? 'VTI-KELAS',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Icon(Icons.school_outlined, color: Colors.white, size: 28),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.namaMatkul,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Pengajar: ${widget.dosenPengampu}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (widget.jadwal != null || widget.ruangan != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.schedule_rounded, color: Colors.white70, size: 14),
                const SizedBox(width: 4),
                Text(
                  widget.jadwal ?? 'Sesuai Jadwal',
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.meeting_room_outlined, color: Colors.white70, size: 14),
                const SizedBox(width: 4),
                Text(
                  widget.ruangan ?? 'Ruang Virtual',
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // 2. Kotak Box Reminder "Upcoming / Tugas Mendatang"
  Widget _buildUpcomingReminderBox(
    BuildContext context,
    List<TaskItem> uncompletedTasks,
    bool isDark,
    Color cardBg,
    Color titleColor,
    Color subColor,
  ) {
    final hasTasks = uncompletedTasks.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: hasTasks
              ? (isDark ? const Color(0xFFF59E0B).withValues(alpha: 0.5) : const Color(0xFFF59E0B).withValues(alpha: 0.3))
              : (isDark ? const Color(0xFF3B4555) : const Color(0xFFE2E8F0)),
          width: hasTasks ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                hasTasks ? Icons.alarm_on_rounded : Icons.check_circle_outline_rounded,
                size: 18,
                color: hasTasks ? const Color(0xFFF59E0B) : const Color(0xFF10B981),
              ),
              const SizedBox(width: 8),
              Text(
                'Mendatang (Upcoming)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: titleColor,
                ),
              ),
              const Spacer(),
              if (hasTasks)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: isDark ? 0.25 : 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${uncompletedTasks.length} Tugas Segera',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFF59E0B),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (!hasTasks) ...[
            Text(
              'Hebat! Tidak ada tugas tertunda di kelas ini.',
              style: TextStyle(fontSize: 12, color: subColor),
            ),
          ] else ...[
            Text(
              'Selesaikan tugas berikut sebelum tenggat berakhir:',
              style: TextStyle(fontSize: 12, color: subColor),
            ),
            const SizedBox(height: 8),
            ...uncompletedTasks.map((t) => InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailTugasScreen(
                          taskTitle: t.title,
                          className: widget.namaMatkul,
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    margin: const EdgeInsets.only(top: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E222A) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.assignment_outlined, size: 16, color: Color(0xFF3B82F6)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            t.title,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: titleColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          t.status,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFEF4444),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right_rounded, size: 16, color: Colors.grey),
                      ],
                    ),
                  ),
                )),
          ],
        ],
      ),
    );
  }

  // 3. Kartu Pengumuman Dosen
  Widget _buildAnnouncementCard(
    bool isDark,
    Color cardBg,
    Color titleColor,
    Color subColor,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF3B4555) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFF3B82F6),
                child: Text(
                  widget.dosenPengampu.isNotEmpty ? widget.dosenPengampu[0] : 'D',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.dosenPengampu,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: titleColor,
                      ),
                    ),
                    Text(
                      'Pengumuman Kelas • Hari ini, 08.00',
                      style: TextStyle(fontSize: 11, color: subColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(
            height: 1,
            thickness: 1,
            color: isDark ? const Color(0xFF3B4555) : const Color(0xFFE2E8F0),
          ),
          const SizedBox(height: 12),
          Text(
            'Selamat datang di kelas perkuliahan virtual ${widget.namaMatkul}. Semua modul, silabus, dan lembar kerja penugasan mingguan akan dipublikasikan secara bertahap di forum ini. Pastikan untuk selalu mengecek tenggat waktu pengerjaan tugas Anda.',
            style: TextStyle(fontSize: 12, color: titleColor, height: 1.4),
          ),
        ],
      ),
    );
  }

  // 4. Aktivitas Feed Tugas Dosen
  Widget _buildTaskActivityCard(
    BuildContext context,
    TaskItem task,
    KelasProvider provider,
    bool isDark,
    Color cardBg,
    Color titleColor,
    Color subColor,
  ) {
    final key = '${task.className}|${task.title}';
    final isDone = provider.isCompleted(key);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF3B4555) : const Color(0xFFE2E8F0),
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailTugasScreen(
                taskTitle: task.title,
                className: widget.namaMatkul,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDone
                      ? const Color(0xFF10B981).withValues(alpha: isDark ? 0.2 : 0.1)
                      : const Color(0xFF3B82F6).withValues(alpha: isDark ? 0.2 : 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isDone ? Icons.check_circle_rounded : Icons.assignment_rounded,
                  color: isDone ? const Color(0xFF10B981) : const Color(0xFF3B82F6),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.dosenPengampu} • Hari ini, 08.30',
                      style: TextStyle(
                        fontSize: 11,
                        color: subColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tenggat: ${task.status}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDone ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 14, color: subColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyActivityCard(bool isDark, Color cardBg, Color subColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF3B4555) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Center(
        child: Text(
          'Belum ada aktivitas tugas di kelas ini.',
          style: TextStyle(fontSize: 13, color: subColor),
        ),
      ),
    );
  }

  void _showClassInfoDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF282D37) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          widget.namaMatkul,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Dosen Pengampu', widget.dosenPengampu, isDark),
            const SizedBox(height: 8),
            _buildInfoRow('Kode Kelas', widget.kodeKelas ?? 'VTI-KELAS', isDark),
            const SizedBox(height: 8),
            _buildInfoRow('Ruangan', widget.ruangan ?? 'Lantai 7, Ruang 701', isDark),
            const SizedBox(height: 8),
            _buildInfoRow('Jadwal', widget.jadwal ?? 'Senin, 14.00 - 15.20 WIB', isDark),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? Colors.white54 : const Color(0xFF64748B),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}
