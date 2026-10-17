import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../common_widgets.dart';
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
  String _selectedClass = 'Semua Kelas';

  String get title {
    if (widget.type == 'segera') return 'Segera Dikumpulkan';
    if (widget.type == 'terlambat') return 'Tugas Terlambat';
    return 'Tugas Terselesaikan';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<KelasProvider>(builder: (context, kelas, _) {
      // Build effective task lists from provider state
      final segeraTasks = allSegeraTasks
          .where((t) => !kelas.isCompleted('${t.className}|${t.title}'))
          .toList();

      // Selesai = original selesai + user-completed segera
      final userCompletedSegera = allSegeraTasks
          .where((t) => kelas.isCompleted('${t.className}|${t.title}'))
          .map((t) => TaskItem(t.title, t.subtitle, 'Diserahkan', t.className))
          .toList();
      final selesaiTasks = [...allSelesaiTasks, ...userCompletedSegera];

      List<TaskItem> activeTasks;
      if (widget.type == 'segera') {
        activeTasks = segeraTasks;
      } else if (widget.type == 'selesai') {
        activeTasks = selesaiTasks;
      } else {
        activeTasks = []; // terlambat
      }

      final classOptions = <String>{'Semua Kelas'};
      for (var t in activeTasks) {
        classOptions.add(t.className);
      }

      // Reset if filter no longer valid
      if (!classOptions.contains(_selectedClass)) _selectedClass = 'Semua Kelas';

      final filtered = _selectedClass == 'Semua Kelas'
          ? activeTasks
          : activeTasks.where((t) => t.className == _selectedClass).toList();

      final isDark = Theme.of(context).brightness == Brightness.dark;
      final bgColor = isDark ? const Color(0xFF23272F) : const Color(0xFFFDFDFD);

      return Scaffold(
        backgroundColor: bgColor,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A2547), Color(0xFF253672)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x551E2B52),
                  blurRadius: 16,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              title: const Text(
                'Kelas',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1A2B4A),
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Dropdown filter
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF9DB),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFD4A300).withValues(alpha: 0.14),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(color: const Color(0xFFFFEE87), width: 1),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _selectedClass,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF3A3000),
                            fontWeight: FontWeight.w600,
                          ),
                          icon: const Icon(Icons.keyboard_arrow_down_rounded,
                              color: Color(0xFF8A7000)),
                          dropdownColor: const Color(0xFFFFFDE7),
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
                    const SizedBox(height: 24),
                    _buildContent(context, filtered),
                  ],
                ),
              ),
            ),
            const BottomBar(currentIndex: 1),
          ],
        ),
      );
    });
  }

  Widget _buildContent(BuildContext context, List<TaskItem> tasks) {
    if (widget.type == 'terlambat' || tasks.isEmpty) {
      return Container(
        height: 220,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFDDE8FF),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3B6FE8).withValues(alpha: 0.12),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline_rounded,
                color: Color(0xFF34C759),
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Tidak Ada Tugas Yang Terlambat Diserahkan',
              style: TextStyle(
                color: Color(0xFF1A2B4A),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: tasks.map((t) => _buildTaskCard(context, t)).toList(),
    );
  }

  Widget _buildTaskCard(BuildContext context, TaskItem task) {
    final bool isDone = task.status == 'Diserahkan';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailTugasScreen(
            taskTitle: task.title,
            className: task.className,
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFDDE8FF),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3B6FE8).withValues(alpha: 0.12),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.assignment_outlined,
                size: 24,
                color: Color(0xFF1A2547),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A2B4A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    task.subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF5C6B8A),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isDone
                    ? const Color(0xFF34C759).withValues(alpha: 0.15)
                    : Colors.white.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                task.status,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDone
                      ? const Color(0xFF248A3D)
                      : const Color(0xFF1A2B4A),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
