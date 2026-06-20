import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../data/models/chat_model.dart';

/// Manages real-time chat threads between parents and teachers.
class ChatProvider extends ChangeNotifier {
  List<ChatThread> _threads = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ChatThread> get threads => _threads;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get totalUnread => _threads.fold(0, (sum, t) => sum + t.unreadCount);

  ChatProvider() {
    _initMockData();
  }

  void _initMockData() {
    _threads = [
      ChatThread(
        id: 'chat_01',
        parentUserId: 'parent_01',
        teacherUserId: 'user_teacher_1',
        studentId: 'std_1',
        studentName: 'Liam Smith',
        messages: [
          ChatMessage(
            id: 'msg_01', threadId: 'chat_01', senderId: 'parent_01',
            senderName: 'John Smith', senderRole: 'parent',
            text: 'Hi Ms. Nimali, Liam has a slight cough today. Please keep an eye on him.',
            sentAt: DateTime.now().subtract(const Duration(hours: 2)),
          ),
          ChatMessage(
            id: 'msg_02', threadId: 'chat_01', senderId: 'user_teacher_1',
            senderName: 'Ms. Nimali', senderRole: 'teacher',
            text: 'Thank you for letting me know, John. I\'ll make sure he stays hydrated and comfortable.',
            sentAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 50)),
          ),
          ChatMessage(
            id: 'msg_03', threadId: 'chat_01', senderId: 'parent_01',
            senderName: 'John Smith', senderRole: 'parent',
            text: 'Also, I\'ll pick him up at 3pm instead of 4pm today.',
            sentAt: DateTime.now().subtract(const Duration(minutes: 30)),
          ),
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        lastActivityAt: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      ChatThread(
        id: 'chat_02',
        parentUserId: 'parent_02',
        teacherUserId: 'user_teacher_1',
        studentId: 'std_2',
        studentName: 'Emma Johnson',
        messages: [
          ChatMessage(
            id: 'msg_04', threadId: 'chat_02', senderId: 'parent_02',
            senderName: 'Sarah Johnson', senderRole: 'parent',
            text: 'Can you confirm if the epinephrine is still in Emma\'s locker? We replaced it last week.',
            sentAt: DateTime.now().subtract(const Duration(hours: 5)),
          ),
          ChatMessage(
            id: 'msg_05', threadId: 'chat_02', senderId: 'user_teacher_1',
            senderName: 'Ms. Nimali', senderRole: 'teacher',
            text: 'Yes, confirmed! It\'s in her locker with the expiry date January 2027.',
            sentAt: DateTime.now().subtract(const Duration(hours: 4)),
          ),
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 14)),
        lastActivityAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      ChatThread(
        id: 'chat_03',
        parentUserId: 'parent_03',
        teacherUserId: 'user_teacher_2',
        studentId: 'std_3',
        studentName: 'Noah Garcia',
        messages: [
          ChatMessage(
            id: 'msg_06', threadId: 'chat_03', senderId: 'user_teacher_2',
            senderName: 'Mr. Sunil', senderRole: 'teacher',
            text: 'Hello Maria, Noah has been absent for 3 days now. Is everything okay?',
            sentAt: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        lastActivityAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }

  /// Get threads visible to the current user (teacher or parent).
  List<ChatThread> threadsForUser(String userId, String role) {
    return _threads.where((t) {
      if (role == 'management') return true;
      if (role == 'teacher') return t.teacherUserId == userId;
      if (role == 'parent') return t.parentUserId == userId;
      return false;
    }).toList();
  }

  /// Send a message in a thread.
  Future<void> sendMessage({
    required String threadId,
    required String senderId,
    required String senderName,
    required String senderRole,
    required String text,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      await Future.delayed(const Duration(milliseconds: 200));
      final idx = _threads.indexWhere((t) => t.id == threadId);
      if (idx != -1) {
        final thread = _threads[idx];
        final msg = ChatMessage(
          id: 'msg_${const Uuid().v4().substring(0, 6)}',
          threadId: threadId,
          senderId: senderId,
          senderName: senderName,
          senderRole: senderRole,
          text: text,
        );
        final updatedMessages = List<ChatMessage>.from(thread.messages)..add(msg);
        _threads[idx] = ChatThread(
          id: thread.id,
          parentUserId: thread.parentUserId,
          teacherUserId: thread.teacherUserId,
          studentId: thread.studentId,
          studentName: thread.studentName,
          messages: updatedMessages,
          createdAt: thread.createdAt,
          lastActivityAt: DateTime.now(),
        );
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Start a new chat thread.
  Future<void> createThread({
    required String parentUserId,
    required String teacherUserId,
    required String studentId,
    required String studentName,
  }) async {
    final thread = ChatThread(
      id: 'chat_${const Uuid().v4().substring(0, 6)}',
      parentUserId: parentUserId,
      teacherUserId: teacherUserId,
      studentId: studentId,
      studentName: studentName,
    );
    _threads.add(thread);
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
