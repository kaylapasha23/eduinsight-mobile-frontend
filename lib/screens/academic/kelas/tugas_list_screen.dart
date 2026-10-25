import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'kelas_screen.dart';
import 'detail_tugas_screen.dart';
import 'kelas_provider.dart';

class TugasListScreen extends StatefulWidget {
  final String type;
  const TugasListScreen({super.key, required this.type});

  @override
  State<TugasListScreen> createState() => _TugasListScreenState();
}

class _TugasListScreenState extends State<TugasListScreen> {
  String _selectedClass = 'Semua Mata Kuliah';

  String get title {
    if (widget.type == 'segera') return 'Segera Dikumpulkan';
    if (widget.type == 'terlambat') return 'Tugas Terlambat';
    return 'Tugas Selesai Diserahkan';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E222A) : const Color(0xFFF7F9FC);
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final cardBg = isDark ? const Color(0xFF282D37) : Colors.white;

    return Consumer<KelasProvider>(builder: (context, kelas, _) {
      // 1. Tugas Selesai (semua tugas yang ditandai complete di provider)
      final allAvailableTasks = [...allSegeraTasks, ...allSelesaiTasks];

      final selesaiTasks = allAvailableTasks
          .where((t) => kelas.isCompleted('${t.className}|${t.title}'))
          .map((t) => TaskItem(t.title, t.subtitle, 'Diserahkan', t.className))
          .toList();

      // 2. Tugas Terlambat (tugas yang diunsub dan lewat deadline)
      final terlambatTasks = allAvailableTasks
          .where((t) => !kelas.isCompleted('${t.className}|${t.title}') && kelas.isLate('${t.className}|${t.title}'))
          .map((t) => TaskItem(t.title, t.subtitle, 'Terlambat', t.className))
          .toList();

      // 3. Tugas Segera (tugas yang belum complete dan belum terlambat)
      final segeraTasks = allAvailableTasks
          .where((t) => !kelas.isCompleted('${t.className}|${t.title}') && !kelas.isLate('${t.className}|${t.title}'))
          .toList();

      List<TaskItem> activeTasks;
      if (widget.type == 'segera') {
        activeTasks = segeraTasks;
      } else if (widget.type == 'selesai') {
        activeTasks = selesaiTasks;
      } else {
        activeTasks = terlambatTasks;
      }

      final classOptions = <String>{'Semua Mata Kuliah'};
      for (var t in activeTasks) {
        classOptions.add(t.className);
      }

      if (!classOptions.contains(_selectedClass)) _selectedClass = 'Semua Mata Kuliah';

      final filtered = _selectedClass == 'Semua Mata Kuliah'
          ? activeTasks
          : activeTasks.where((t) => t.className == _selectedClass).toList();

      return Scaffold(
        backgroundColor: bgColor,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Container(
            color: const Color(0xFF1E2B52),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Row(
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Modern Dropdown Filter Mata Kuliah
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _selectedClass,
                          dropdownColor: cardBg,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                            fontWeight: FontWeight.w600,
                          ),
                          icon: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: isDark ? Colors.white70 : const Color(0xFF64748B),
                          ),
                          items: classOptions.map((v) {
                            return DropdownMenuItem(
                              value: v,
                              child: Text(v),
                            );
                          }).toList(),
                          onChanged: (v) {
                            if (v != null) setState(() => _selectedClass = v);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Section Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Daftar Tugas',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: titleColor,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${filtered.length} Tugas',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2563EB),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    _buildContent(context, filtered, isDark, cardBg),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildContent(BuildContext context, List<TaskItem> tasks, bool isDark, Color cardBg) {
    if (tasks.isEmpty) {
      final isTerlambat = widget.type == 'terlambat';
      return Container(
        padding: const EdgeInsets.all(32),
        width: double.infinity,
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(22),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: (isTerlambat ? const Color(0xFF10B981) : const Color(0xFF2563EB)).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isTerlambat ? Icons.check_circle_outline_rounded : Icons.inbox_outlined,
                color: isTerlambat ? const Color(0xFF10B981) : const Color(0xFF2563EB),
                size: 28,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              isTerlambat ? 'Bagus! Tidak ada tugas yang terlambat' : 'Tidak ada tugas dalam kategori ini',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1E293B),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: tasks.map((t) => _buildTaskCard(context, t, isDark, cardBg)).toList(),
    );
  }

  Widget _buildTaskCard(BuildContext context, TaskItem task, bool isDark, Color cardBg) {
    final bool isDone = task.status == 'Diserahkan';
    final bool isLate = task.status == 'Terlambat';

    final Color badgeBg = isDone
        ? const Color(0xFF10B981).withValues(alpha: isDark ? 0.2 : 0.12)
        : (isLate
            ? const Color(0xFFEF4444).withValues(alpha: isDark ? 0.2 : 0.12)
            : const Color(0xFFF59E0B).withValues(alpha: isDark ? 0.2 : 0.12));

    final Color badgeText = isDone
        ? const Color(0xFF10B981)
        : (isLate ? const Color(0xFFEF4444) : const Color(0xFFD97706));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailTugasScreen(
                taskTitle: task.title,
                className: task.className,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E2532) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    isDone
                        ? Icons.task_alt_rounded
                        : (isLate ? Icons.warning_amber_rounded : Icons.assignment_outlined),
                    size: 22,
                    color: badgeText,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        task.subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white60 : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: badgeText.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    task.status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: badgeText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
