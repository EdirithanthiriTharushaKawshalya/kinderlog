import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../data/models/notification_model.dart';

/// Manages push notifications, broadcasts, and targeted alerts.
class NotificationProvider extends ChangeNotifier {
  List<AppNotification> _notifications = [];
  bool _isLoading = false;

  List<AppNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;

  List<AppNotification> get unreadNotifications =>
      _notifications.where((n) => !n.isRead).toList();

  int get unreadCount => unreadNotifications.length;

  NotificationProvider() {
    _initMockData();
  }

  void _initMockData() {
    _notifications = [
      AppNotification(
        id: 'notif_01',
        title: 'Welcome to DailyKids!',
        body: 'Thank you for being part of our preschool community. Stay tuned for updates.',
        senderName: 'Ms. Priya (Admin)',
        senderId: 'user_mgmt_01',
        target: NotificationTarget.all,
        priority: NotificationPriority.normal,
        sentAt: DateTime.now().subtract(const Duration(days: 7)),
        isRead: true,
      ),
      AppNotification(
        id: 'notif_02',
        title: 'Sports Day — This Friday!',
        body: 'Annual Sports Day at Ambalangoda branch. Parents are welcome. Bring water bottles and hats.',
        senderName: 'Ms. Priya (Admin)',
        senderId: 'user_mgmt_01',
        target: NotificationTarget.branch,
        targetId: 'branch_01',
        targetName: 'Ambalangoda',
        priority: NotificationPriority.normal,
        sentAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      AppNotification(
        id: 'notif_03',
        title: '⚠️ Weather Alert',
        body: 'Heavy rain expected tomorrow. Please send children with raincoats. Outdoor activities will be moved indoors.',
        senderName: 'Ms. Nimali',
        senderId: 'user_teacher_1',
        target: NotificationTarget.classGroup,
        targetId: 'class_01',
        targetName: 'FS1',
        priority: NotificationPriority.urgent,
        sentAt: DateTime.now().subtract(const Duration(hours: 6)),
      ),
      AppNotification(
        id: 'notif_04',
        title: 'Fee Payment Reminder',
        body: 'Monthly tuition fees for June are due by the 5th. Please ensure timely payment.',
        senderName: 'Ms. Priya (Admin)',
        senderId: 'user_mgmt_01',
        target: NotificationTarget.all,
        priority: NotificationPriority.urgent,
        sentAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ];
  }

  /// Send a broadcast / targeted notification.
  Future<void> sendNotification({
    required String title,
    required String body,
    required String senderName,
    required String senderId,
    NotificationTarget target = NotificationTarget.all,
    String? targetId,
    String? targetName,
    NotificationPriority priority = NotificationPriority.normal,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 400));
      final notif = AppNotification(
        id: 'notif_${const Uuid().v4().substring(0, 6)}',
        title: title,
        body: body,
        senderName: senderName,
        senderId: senderId,
        target: target,
        targetId: targetId,
        targetName: targetName,
        priority: priority,
      );
      _notifications.insert(0, notif);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Send a payment delay notification to a specific parent.
  Future<void> notifyParentAboutPayment({
    required String parentName,
    required String parentEmail,
    required String studentName,
    required String invoiceDescription,
    required double amountDue,
    required String dueDate,
    required String senderName,
    required String senderId,
    String? customMessage,
  }) async {
    final amountStr = 'Rs. ${amountDue.toStringAsFixed(0)}';
    final title = '⚠️ Payment Reminder: $studentName';
    final body = customMessage ??
        'Dear $parentName,\n\n'
        'This is a reminder that the payment for $studentName is overdue.\n\n'
        'Invoice: $invoiceDescription\n'
        'Amount Due: $amountStr\n'
        'Due Date: $dueDate\n\n'
        'Please settle this payment at your earliest convenience. '
        'If you have already made the payment, please disregard this notice.\n\n'
        'Thank you,\nDailyKids Preschool Management';

    await sendNotification(
      title: title,
      body: body,
      senderName: senderName,
      senderId: senderId,
      target: NotificationTarget.individual,
      targetId: parentEmail,
      targetName: parentName,
      priority: NotificationPriority.urgent,
    );
  }

  /// Mark notification as read.
  void markAsRead(String notificationId) {
    final idx = _notifications.indexWhere((n) => n.id == notificationId);
    if (idx != -1) {
      final n = _notifications[idx];
      _notifications[idx] = AppNotification(
        id: n.id, title: n.title, body: n.body, senderName: n.senderName,
        senderId: n.senderId, target: n.target, targetId: n.targetId,
        targetName: n.targetName, priority: n.priority,
        sentAt: n.sentAt, isRead: true,
      );
      notifyListeners();
    }
  }

  /// Mark all as read.
  void markAllAsRead() {
    _notifications = _notifications.map((n) => AppNotification(
      id: n.id, title: n.title, body: n.body, senderName: n.senderName,
      senderId: n.senderId, target: n.target, targetId: n.targetId,
      targetName: n.targetName, priority: n.priority,
      sentAt: n.sentAt, isRead: true,
    )).toList();
    notifyListeners();
  }
}
