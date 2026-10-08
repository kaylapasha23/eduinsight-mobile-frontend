import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../common_widgets.dart';
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
      for (var t in activeTasks) { classOptions.add(t.className); }

      // Reset if filter no longer valid
      if (!classOptions.contains(_selectedClass)) _selectedClass = 'Semua Kelas';

      final filtered = _selectedClass == 'Semua Kelas'
          ? activeTasks
          : activeTasks.where((t) => t.className == _selectedClass).toList();

      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: kNavy,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Kelas',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        body: Column(children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                const SizedBox(height: 16),
                // Dropdown filter
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: kActive,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedClass,
                      style: const TextStyle(fontSize: 14, color: Colors.black),
                      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black87),
                      dropdownColor: kActive,
                      items: classOptions.map((v) {
                        return DropdownMenuItem(
                          value: v,
                          child: Text(v, style: const TextStyle(fontSize: 14, color: Colors.black)),
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
              ]),
            ),
          ),
          const BottomBar(currentIndex: 1),
        ]),
      );
    });
  }

  Widget _buildContent(BuildContext context, List<TaskItem> tasks) {
    if (widget.type == 'terlambat' || tasks.isEmpty) {
      return Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(color: kCardBlue, borderRadius: BorderRadius.circular(16)),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black38, width: 1.5),
            ),
            child: const Icon(Icons.check, color: Colors.black38, size: 28),
          ),
          const SizedBox(height: 16),
          const Text('Tidak Ada Tugas Yang Terlambat Diserahkan',
              style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w400, fontSize: 13)),
        ]),
      );
    }

    return Column(
      children: tasks.map((t) => _buildTaskCard(context, t)).toList(),
    );
  }

  Widget _buildTaskCard(BuildContext context, TaskItem task) {
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
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: kCardBlue, borderRadius: BorderRadius.circular(16)),
        child: Row(children: [
          const Icon(Icons.assignment_outlined, size: 32, color: Colors.black87),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(task.title,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
              const SizedBox(height: 4),
              Text(task.subtitle,
                  style: const TextStyle(fontSize: 10, color: Colors.black54)),
            ]),
          ),
          Text(task.status, style: const TextStyle(fontSize: 10, color: Colors.black87)),
        ]),
      ),
    );
  }
}
