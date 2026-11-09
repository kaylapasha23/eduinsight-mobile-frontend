import 'package:flutter/material.dart';

class EduNotification {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final IconData icon;
  final Color iconColor;
  bool isRead;

  EduNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.icon = Icons.notifications_active_rounded,
    this.iconColor = const Color(0xFF2563EB),
    this.isRead = false,
  });
}

class NotificationService {
  static final List<EduNotification> _history = [];
  static final ValueNotifier<int> unreadCount = ValueNotifier<int>(0);

  static List<EduNotification> get history => List.unmodifiable(_history);

  /// Menampilkan push notification overlay yang meluncur dari atas layar
  static void showPushNotification(
    BuildContext context, {
    required String title,
    required String body,
    IconData icon = Icons.notifications_active_rounded,
    Color iconColor = const Color(0xFF2563EB),
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onTap,
  }) {
    // 1. Simpan ke riwayat notifikasi
    final notif = EduNotification(
      id: 'notif-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      body: body,
      timestamp: DateTime.now(),
      icon: icon,
      iconColor: iconColor,
    );
    _history.insert(0, notif);
    unreadCount.value = _history.where((n) => !n.isRead).length;

    // 2. Render Overlay Banner Push Notification
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (ctx) => _PushNotificationBanner(
        notification: notif,
        onDismiss: () {
          if (entry.mounted) entry.remove();
        },
        onTap: () {
          if (entry.mounted) entry.remove();
          if (onTap != null) onTap();
        },
        duration: duration,
      ),
    );

    overlay.insert(entry);
  }
}

class _PushNotificationBanner extends StatefulWidget {
  final EduNotification notification;
  final VoidCallback onDismiss;
  final VoidCallback onTap;
  final Duration duration;

  const _PushNotificationBanner({
    required this.notification,
    required this.onDismiss,
    required this.onTap,
    required this.duration,
  });

  @override
  State<_PushNotificationBanner> createState() => _PushNotificationBannerState();
}

class _PushNotificationBannerState extends State<_PushNotificationBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();

    // Auto dismiss setelah durasi
    Future.delayed(widget.duration, () {
      if (mounted) {
        _dismissWithAnimation();
      }
    });
  }

  void _dismissWithAnimation() {
    _controller.reverse().then((_) {
      widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 14,
      right: 14,
      child: SlideTransition(
        position: _offsetAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: widget.onTap,
              onVerticalDragUpdate: (details) {
                if (details.primaryDelta != null && details.primaryDelta! < -4) {
                  _dismissWithAnimation();
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E222A) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF3B4555)
                        : const Color(0xFFE2E8F0),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.12),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: widget.notification.iconColor.withValues(alpha: isDark ? 0.25 : 0.12),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: widget.notification.iconColor.withValues(alpha: isDark ? 0.6 : 0.3),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        widget.notification.icon,
                        color: widget.notification.iconColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'EduInsight System',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
                                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                ),
                              ),
                              Text(
                                'Baru saja',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            widget.notification.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            widget.notification.body,
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.3,
                              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _dismissWithAnimation,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
