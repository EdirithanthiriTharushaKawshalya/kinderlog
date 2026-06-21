/// Represents a chat thread between a parent and a teacher.
class ChatThread {
  final String id;
  final String parentUserId; // parent's user ID (or parent name for mock)
  final String teacherUserId; // teacher's user ID (or teacher name for mock)
  final String studentId;
  final String studentName;
  final List<ChatMessage> messages;
  final DateTime createdAt;
  final DateTime lastActivityAt;

  ChatThread({
    required this.id,
    required this.parentUserId,
    required this.teacherUserId,
    required this.studentId,
    required this.studentName,
    this.messages = const [],
    DateTime? createdAt,
    DateTime? lastActivityAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        lastActivityAt = lastActivityAt ?? DateTime.now();

  ChatMessage? get lastMessage =>
      messages.isNotEmpty ? messages.last : null;

  int get unreadCount =>
      messages.where((m) => !m.isRead && m.senderId != 'current_user').length;
}

/// A single chat message.
class ChatMessage {
  final String id;
  final String threadId;
  final String senderId;
  final String senderName;
  final String senderRole; // 'parent', 'teacher', 'management'
  final String text;
  final DateTime sentAt;
  final bool isRead;

  ChatMessage({
    required this.id,
    required this.threadId,
    required this.senderId,
    required this.senderName,
    this.senderRole = 'teacher',
    required this.text,
    DateTime? sentAt,
    this.isRead = false,
  }) : sentAt = sentAt ?? DateTime.now();
}
