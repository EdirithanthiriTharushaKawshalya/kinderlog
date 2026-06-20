enum NotificationTarget { all, branch, classGroup, individual }
enum NotificationPriority { normal, urgent, emergency }

/// A push notification / broadcast message.
class AppNotification {
  final String id;
  final String title;
  final String body;
  final String senderName;
  final String senderId;
  final NotificationTarget target;
  final String? targetId; // branchId or classId depending on target
  final String? targetName;
  final NotificationPriority priority;
  final DateTime sentAt;
  final bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.senderName,
    required this.senderId,
    this.target = NotificationTarget.all,
    this.targetId,
    this.targetName,
    this.priority = NotificationPriority.normal,
    DateTime? sentAt,
    this.isRead = false,
  }) : sentAt = sentAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'senderName': senderName,
        'senderId': senderId,
        'target': target.name,
        'targetId': targetId,
        'targetName': targetName,
        'priority': priority.name,
        'sentAt': sentAt.toIso8601String(),
        'isRead': isRead,
      };

  factory AppNotification.fromJson(Map<String, dynamic> json, String docId) {
    return AppNotification(
      id: docId,
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      senderName: json['senderName'] ?? '',
      senderId: json['senderId'] ?? '',
      target: _parseTarget(json['target']),
      targetId: json['targetId'],
      targetName: json['targetName'],
      priority: _parsePriority(json['priority']),
      sentAt: json['sentAt'] != null ? DateTime.parse(json['sentAt']) : DateTime.now(),
      isRead: json['isRead'] ?? false,
    );
  }

  static NotificationTarget _parseTarget(String? s) {
    try {
      return NotificationTarget.values.byName(s ?? 'all');
    } catch (_) {
      return NotificationTarget.all;
    }
  }

  static NotificationPriority _parsePriority(String? s) {
    try {
      return NotificationPriority.values.byName(s ?? 'normal');
    } catch (_) {
      return NotificationPriority.normal;
    }
  }
}
