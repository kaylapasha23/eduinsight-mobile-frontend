import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import '../providers/token_store.dart' as store;

/// Notifikasi lokal di status bar HP
class SystemNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _notificationsPlugin.initialize(initSettings);

    _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> showSystemNotification({
    required String title,
    required String body,
  }) async {
    if (kIsWeb) return;
    const androidDetails = AndroidNotificationDetails(
      'eduinsight_channel',
      'EduInsight Notifikasi',
      channelDescription: 'Notifikasi Sinkronisasi & Evaluasi Akademik',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );
    const details = NotificationDetails(android: androidDetails);
    await _notificationsPlugin.show(
      DateTime.now().millisecond,
      title,
      body,
      details,
    );
  }
}

class EduNotification {
  final String id;
  final String type; // tugas, kehadiran, penilaian, evaluasi
  final String title;
  final String body;
  final DateTime timestamp;
  final IconData icon;
  final Color iconColor;
  final String? targetId;
  final String? targetType;
  final Map<String, dynamic>? payload;
  bool isRead;

  EduNotification({
    required this.id,
    this.type = 'tugas',
    required this.title,
    required this.body,
    required this.timestamp,
    this.icon = Icons.notifications_active_rounded,
    this.iconColor = const Color(0xFF2563EB),
    this.targetId,
    this.targetType,
    this.payload,
    this.isRead = false,
  });

  factory EduNotification.fromJson(Map<String, dynamic> json) {
    final type = (json['type'] ?? 'tugas').toString().toLowerCase();
    IconData icon = Icons.notifications_active_rounded;
    Color iconColor = const Color(0xFF2563EB);

    if (type.contains('tugas')) {
      icon = Icons.assignment_rounded;
      iconColor = const Color(0xFF2563EB);
    } else if (type.contains('kehadiran')) {
      icon = Icons.how_to_reg_rounded;
      iconColor = const Color(0xFF10B981);
    } else if (type.contains('penilaian') || type.contains('nilai')) {
      icon = Icons.military_tech_rounded;
      iconColor = const Color(0xFFF59E0B);
    } else if (type.contains('evaluasi') || type.contains('ai')) {
      icon = Icons.auto_awesome_rounded;
      iconColor = const Color(0xFF8B5CF6);
    }

    DateTime time;
    try {
      time = json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now();
    } catch (_) {
      time = DateTime.now();
    }

    Map<String, dynamic>? payloadMap;
    if (json['payload'] is Map) {
      payloadMap = Map<String, dynamic>.from(json['payload']);
    } else if (json['payload'] is String) {
      try {
        payloadMap = jsonDecode(json['payload']);
      } catch (_) {}
    }

    return EduNotification(
      id: json['id']?.toString() ?? 'notif-${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      title: json['title'] ?? 'Pemberitahuan Baru',
      body: json['body'] ?? '',
      timestamp: time,
      icon: icon,
      iconColor: iconColor,
      targetId: json['targetId']?.toString(),
      targetType: json['targetType']?.toString(),
      payload: payloadMap,
      isRead: json['isRead'] == true,
    );
  }
}

/// Notifikasi in-app & Sinkronisasi dengan Backend
class NotificationService {
  static final List<EduNotification> _history = [];
  static final ValueNotifier<int> unreadCount = ValueNotifier<int>(0);
  static Timer? _pollingTimer;

  static List<EduNotification> get history => List.unmodifiable(_history);

  static const List<String> _baseUrls = [
    'http://localhost:3000/api',
    'http://127.0.0.1:3000/api',
    'http://10.0.2.2:3000/api',
    'http://localhost:5001/api',
    'http://10.0.2.2:5001/api',
  ];

  /// Inisialisasi Firebase & polling sinkronisasi notifikasi
  static Future<void> init() async {
    if (!kIsWeb) {
      await SystemNotificationService.init();
    }

    try {
      if (kIsWeb) {
        await Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: 'AIzaSyAAeAZot4U2_b3qRUspcBTZJx55fMstNG0',
            appId: '1:503511522205:web:a3d6d6f5e9daf9f875ad74',
            messagingSenderId: '503511522205',
            projectId: 'eduinsight-storage',
            storageBucket: 'eduinsight-storage.firebasestorage.app',
          ),
        );
      } else {
        await Firebase.initializeApp();
      }
      final messaging = FirebaseMessaging.instance;

      await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      final token = await messaging.getToken();
      if (token != null) {
        debugPrint('[FCM] Device Token: $token');
        await sendFcmTokenToBackend(token);
      }

      // Handler ketika push notification diterima saat app aktif (foreground)
      FirebaseMessaging.onMessage.listen((RemoteMessage msg) {
        debugPrint('[FCM] Foreground notification: ${msg.notification?.title}');
        final title = msg.notification?.title ?? 'Notifikasi Baru';
        final body = msg.notification?.body ?? '';

        SystemNotificationService.showSystemNotification(
          title: title,
          body: body,
        );

        fetchNotificationsFromBackend();
      });
    } catch (e) {
      debugPrint('[Firebase/FCM Init Exception]: $e');
    }

    // Ambil notifikasi awal dari backend
    await fetchNotificationsFromBackend();

    // Polling periodik setiap 10 detik agar tetap sinkron jika dosen update via web
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      fetchNotificationsFromBackend();
    });
  }

  /// Kirim token FCM ke backend
  static Future<void> sendFcmTokenToBackend(String token) async {
    for (final base in _baseUrls) {
      try {
        final authToken = await store.getToken();
        final res = await http.post(
          Uri.parse('$base/notifications/fcm-token'),
          headers: {
            'Content-Type': 'application/json',
            if (authToken != null && authToken.isNotEmpty)
              'Authorization': 'Bearer $authToken',
          },
          body: jsonEncode({'token': token}),
        ).timeout(const Duration(seconds: 3));

        if (res.statusCode == 200) {
          debugPrint('[FCM] Token synced to backend $base');
          break;
        }
      } catch (_) {}
    }
  }

  /// Ambil notifikasi dari database backend
  static Future<void> fetchNotificationsFromBackend() async {
    for (final base in _baseUrls) {
      try {
        final authToken = await store.getToken();
        final res = await http.get(
          Uri.parse('$base/notifications'),
          headers: {
            'Content-Type': 'application/json',
            if (authToken != null && authToken.isNotEmpty)
              'Authorization': 'Bearer $authToken',
          },
        ).timeout(const Duration(seconds: 4));

        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          if (data['success'] == true && data['data'] is List) {
            final List items = data['data'];
            _history.clear();
            for (final item in items) {
              _history.add(EduNotification.fromJson(item));
            }
            unreadCount.value = _history.where((n) => !n.isRead).length;
            break;
          }
        }
      } catch (_) {}
    }
  }

  /// Tandai notifikasi sebagai dibaca
  static Future<void> markAsRead(String notifId) async {
    final idx = _history.indexWhere((n) => n.id == notifId);
    if (idx != -1) {
      _history[idx].isRead = true;
      unreadCount.value = _history.where((n) => !n.isRead).length;
    }

    for (final base in _baseUrls) {
      try {
        await http.patch(
          Uri.parse('$base/notifications/$notifId/read'),
          headers: {'Content-Type': 'application/json'},
        ).timeout(const Duration(seconds: 3));
        break;
      } catch (_) {}
    }
  }

  /// Tandai semua sebagai dibaca
  static Future<void> markAllAsRead() async {
    for (final n in _history) {
      n.isRead = true;
    }
    unreadCount.value = 0;

    for (final base in _baseUrls) {
      try {
        await http.post(
          Uri.parse('$base/notifications/read-all'),
          headers: {'Content-Type': 'application/json'},
        ).timeout(const Duration(seconds: 3));
        break;
      } catch (_) {}
    }
  }

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
