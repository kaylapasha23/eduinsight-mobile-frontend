import 'package:flutter/material.dart';
import '../../services/notification_service.dart';
import '../academic/kelas/detail_tugas_screen.dart';
import '../academic/kehadiran.dart';
import '../academic/nilai.dart';
import '../ai_evaluation/ai_evalution_card.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _refreshNotifications();
  }

  Future<void> _refreshNotifications() async {
    setState(() => _isLoading = true);
    await NotificationService.fetchNotificationsFromBackend();
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _handleNotificationTap(EduNotification notif) async {
    // 1. Langsung tandai secara lokal & UI seketika agar border/badge langsung berubah
    setState(() {
      notif.isRead = true;
    });
    // Kirim sinkronisasi ke backend secara asinkron tanpa menahan navigasi
    NotificationService.markAsRead(notif.id);

    // 2. Langsung navigasi ke halaman terkait
    if (!mounted) return;

    final type = notif.type.toLowerCase();

    if (type.contains('tugas')) {
      final taskTitle = notif.payload?['taskTitle'] ??
          notif.title.replaceFirst(RegExp(r'^(Tugas Baru|Nilai Tugas|Nilai Baru):\s*', caseSensitive: false), '').trim();
      final className = notif.payload?['className'] ?? notif.payload?['matkul'] ?? '';
      final taskId = notif.payload?['taskId'] ?? notif.targetId;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailTugasScreen(
            taskTitle: taskTitle,
            className: className,
            taskId: taskId,
          ),
        ),
      );
    } else if (type.contains('kehadiran')) {
      final matkul = notif.payload?['matkul'] ?? notif.payload?['course'];
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => KehadiranScreen(initialCourse: matkul?.toString()),
        ),
      );
    } else if (type.contains('penilaian') || type.contains('nilai')) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const NilaiScreen()),
      );
    } else if (type.contains('evaluasi') || type.contains('ai')) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AiEvalutionScreen()),
      );
    }

    if (mounted) {
      _refreshNotifications();
    }
  }

  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inSeconds < 60) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays == 1) return 'Kemarin';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E222A) : const Color(0xFFF8FAFC);
    final cardBg = isDark ? const Color(0xFF282D37) : Colors.white;
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final borderColor = isDark ? const Color(0xFF3B4555) : const Color(0xFFE2E8F0);

    final notifications = NotificationService.history;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: titleColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notifikasi',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: titleColor,
          ),
        ),
        actions: [
          if (notifications.isNotEmpty)
            TextButton(
              onPressed: () async {
                await NotificationService.markAllAsRead();
                setState(() {});
              },
              child: const Text(
                'Tandai dibaca',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2563EB),
                ),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshNotifications,
        color: const Color(0xFF2563EB),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF2563EB)),
              )
            : notifications.isEmpty
            ? Center(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF333B4D) : const Color(0xFFEEF2F6),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.notifications_off_outlined,
                          size: 38,
                          color: subtitleColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Belum Ada Notifikasi',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Pembaruan tugas, nilai, dan kehadiran dari dosen\nakan muncul di sini secara otomatis.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: subtitleColor, height: 1.4),
                      ),
                    ],
                  ),
                ),
              )
            : ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                itemCount: notifications.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final notif = notifications[index];
                  return InkWell(
                    onTap: () => _handleNotificationTap(notif),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: notif.isRead
                              ? borderColor
                              : const Color(0xFF2563EB).withValues(alpha: 0.5),
                          width: notif.isRead ? 1 : 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: notif.iconColor.withValues(alpha: isDark ? 0.25 : 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(notif.icon, color: notif.iconColor, size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        notif.title,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: notif.isRead
                                              ? FontWeight.w600
                                              : FontWeight.w800,
                                          color: titleColor,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      _formatTimestamp(notif.timestamp),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: subtitleColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  notif.body,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    height: 1.35,
                                    color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Text(
                                      'Ketuk untuk melihat detail',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF2563EB),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 12,
                                      color: Color(0xFF2563EB),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (!notif.isRead) ...[
                            const SizedBox(width: 8),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF2563EB),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
