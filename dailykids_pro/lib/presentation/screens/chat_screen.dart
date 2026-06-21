import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kinderlog_core/kinderlog_core.dart';
import '../../providers/chat_provider.dart';
import '../../providers/attendance_provider.dart';

import '../../data/models/chat_model.dart';

/// Chat screen for parent-teacher intercom.
class ChatScreen extends StatefulWidget {
  final bool hideAppBar;
  const ChatScreen({super.key, this.hideAppBar = false});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String? _selectedThreadId;

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, ChatProvider>(
      builder: (context, auth, chat, _) {
        final isMgmt = auth.isManagement;
        final userId = auth.currentUser?.id ?? 'user_teacher_1';
        final role = isMgmt ? 'management' : (auth.isTeacher ? 'teacher' : 'parent');
        final threads = chat.threadsForUser(userId, role);

        if (_selectedThreadId != null) {
          final thread = threads.where((t) => t.id == _selectedThreadId).firstOrNull;
          if (thread != null) return _chatView(chat, thread, auth);
        }

        return Scaffold(
          appBar: widget.hideAppBar
              ? null
              : AppBar(
                  title: const Text('Messages'),
                  actions: [
              if (chat.totalUnread > 0)
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: AppTheme.secondaryCoral, borderRadius: BorderRadius.circular(10)),
                    child: Text('${chat.totalUnread} new', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          ),
          body: threads.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline_rounded, size: 56, color: Colors.grey[300]),
                      const SizedBox(height: 12),
                      Text('No conversations yet', style: TextStyle(color: Colors.grey[500])),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: threads.length,
                  itemBuilder: (context, index) {
                    final t = threads[index];
                    final last = t.lastMessage;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      elevation: 0,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.primaryTeal.withValues(alpha: 0.08),
                          child: Text(t.studentName[0].toUpperCase(),
                              style: const TextStyle(color: AppTheme.primaryTeal, fontWeight: FontWeight.bold)),
                        ),
                        title: Row(
                          children: [
                            Expanded(child: Text(t.studentName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                            if (t.unreadCount > 0)
                              Container(
                                padding: const EdgeInsets.all(5),
                                decoration: const BoxDecoration(color: AppTheme.secondaryCoral, shape: BoxShape.circle),
                                child: Text('${t.unreadCount}', style: const TextStyle(color: Colors.white, fontSize: 10)),
                              ),
                          ],
                        ),
                        subtitle: Text(
                          last != null ? '${last.senderName}: ${last.text}' : 'No messages',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => setState(() => _selectedThreadId = t.id),
                      ),
                    );
                  },
                ),
          floatingActionButton: isMgmt ? null : FloatingActionButton(
            backgroundColor: AppTheme.primaryTeal,
            onPressed: () => _showNewThreadDialog(context, auth, chat),
            child: const Icon(Icons.add_comment_rounded, color: Colors.white),
          ),
        );
      },
    );
  }

  Widget _chatView(ChatProvider chat, ChatThread thread, AuthProvider auth) {
    final msgCtrl = TextEditingController();
    final scrollCtrl = ScrollController();
    final userName = auth.currentUser?.name ?? 'You';
    final userId = auth.currentUser?.id ?? 'current';
    final role = auth.isManagement ? 'management' : (auth.isTeacher ? 'teacher' : 'parent');

    // Auto-scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollCtrl.hasClients) scrollCtrl.jumpTo(scrollCtrl.position.maxScrollExtent);
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => setState(() => _selectedThreadId = null)),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(thread.studentName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Parent-Teacher Chat', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: scrollCtrl,
              padding: const EdgeInsets.all(16),
              itemCount: thread.messages.length,
              itemBuilder: (context, index) {
                final msg = thread.messages[index];
                final isMe = msg.senderId == userId;

                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isMe ? AppTheme.primaryTeal : Colors.white,
                      borderRadius: BorderRadius.circular(16).copyWith(
                        bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
                        bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(4),
                      ),
                      border: isMe ? null : Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        if (!isMe)
                          Text(msg.senderName, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[600])),
                        const SizedBox(height: 2),
                        Text(msg.text, style: TextStyle(fontSize: 14, color: isMe ? Colors.white : Colors.black87)),
                        const SizedBox(height: 4),
                        Text(
                          '${msg.sentAt.hour}:${msg.sentAt.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(fontSize: 10, color: isMe ? Colors.white70 : Colors.grey[400]),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Message input
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.05), offset: const Offset(0, -2), blurRadius: 6),
            ]),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: msgCtrl,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                      filled: true, fillColor: AppTheme.bgGrey,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (text) => _sendMsg(chat, thread, userId, userName, text, msgCtrl, role),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: AppTheme.primaryTeal,
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                    onPressed: () => _sendMsg(chat, thread, userId, userName, msgCtrl.text, msgCtrl, role),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMsg(ChatProvider chat, ChatThread thread, String userId, String userName, String text, TextEditingController ctrl, String role) {
    if (text.trim().isEmpty) return;
    chat.sendMessage(
      threadId: thread.id,
      senderId: userId,
      senderName: userName,
      senderRole: role,
      text: text.trim(),
    );
    ctrl.clear();
  }

  void _showNewThreadDialog(BuildContext context, AuthProvider auth, ChatProvider chat) {
    final isParent = auth.isParent;
    final isTeacher = auth.isTeacher;
    final currentUserId = auth.currentUser?.id ?? '';
    final currentUserName = auth.currentUser?.name ?? 'You';

    // Resolve student data from AttendanceProvider
    final attendance = context.read<AttendanceProvider>();
    final allStudents = attendance.students;

    // ── Parent: pick a teacher to chat with ──
    if (isParent) {
      final teachers = auth.users.where((u) => u.role == UserRole.teacher).toList();
      final studentIds = auth.currentUser?.studentIds ?? [];
      // Get the first linked child's info
      Student? linkedChild;
      String? selectedTeacherId;
      String? selectedTeacherName;

      if (teachers.isEmpty) {
        _showInfoDialog(context, 'No Teachers Available', 'There are no teachers registered yet. Please contact management.');
        return;
      }

      showDialog(
        context: context,
        builder: (ctx) => StatefulBuilder(
          builder: (ctx, setDialogState) {
            // Auto-select first teacher and first linked child
            if (selectedTeacherId == null && teachers.isNotEmpty) {
              selectedTeacherId = teachers.first.id;
              selectedTeacherName = teachers.first.name;
            }
            if (linkedChild == null && studentIds.isNotEmpty) {
              linkedChild = allStudents.where((s) => s.id == studentIds.first).firstOrNull;
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Row(
                children: [
                  Icon(Icons.person_add_rounded, color: AppTheme.primaryTeal, size: 22),
                  SizedBox(width: 10),
                  Text('New Conversation', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Connect with your child\'s teacher:', style: TextStyle(fontSize: 13, color: Colors.black54)),
                  const SizedBox(height: 14),
                  // Teacher dropdown
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: selectedTeacherId,
                    decoration: const InputDecoration(
                      labelText: 'Teacher',
                      prefixIcon: Icon(Icons.person_rounded, size: 20),
                    ),
                    items: teachers.map((t) => DropdownMenuItem(value: t.id, child: Text(t.name, overflow: TextOverflow.ellipsis))).toList(),
                    onChanged: (v) {
                      setDialogState(() {
                        selectedTeacherId = v;
                        selectedTeacherName = teachers.where((t) => t.id == v).firstOrNull?.name;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  // Child info (read-only)
                  if (linkedChild != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.bgGrey,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.child_care_rounded, size: 18, color: AppTheme.primaryTeal),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(linkedChild!.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              Text('Your child · ${linkedChild!.classroom}', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFCA5A5)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline, size: 16, color: AppTheme.secondaryCoral),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text('No linked child found. Ask management to link your child to your account.',
                                style: TextStyle(fontSize: 12, color: AppTheme.secondaryCoral)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryTeal),
                  onPressed: (selectedTeacherId == null || linkedChild == null)
                      ? null
                      : () {
                          chat.createThread(
                            parentUserId: currentUserId,
                            teacherUserId: selectedTeacherId!,
                            studentId: linkedChild!.id,
                            studentName: linkedChild!.name,
                          );
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Chat started with ${selectedTeacherName}!'),
                              backgroundColor: AppTheme.primaryTeal,
                            ),
                          );
                        },
                  child: const Text('Start Chat', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        ),
      );
      return;
    }

    // ── Teacher: pick a student → their parent is auto-linked ──
    if (isTeacher) {
      // Show all enrolled students for the teacher to pick from
      final studentOptions = allStudents;
      String? selectedStudentId;
      Student? selectedStudent;

      if (studentOptions.isEmpty) {
        _showInfoDialog(context, 'No Students Found', 'There are no students enrolled yet. Please ask management to add students.');
        return;
      }

      showDialog(
        context: context,
        builder: (ctx) => StatefulBuilder(
          builder: (ctx, setDialogState) {
            if (selectedStudentId == null && studentOptions.isNotEmpty) {
              selectedStudentId = studentOptions.first.id;
              selectedStudent = studentOptions.first;
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Row(
                children: [
                  Icon(Icons.person_add_rounded, color: AppTheme.primaryTeal, size: 22),
                  SizedBox(width: 10),
                  Text('New Conversation', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Select a student to chat with their parent:', style: TextStyle(fontSize: 13, color: Colors.black54)),
                  const SizedBox(height: 14),
                  // Student dropdown
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: selectedStudentId,
                    decoration: const InputDecoration(
                      labelText: 'Student',
                      prefixIcon: Icon(Icons.child_care_rounded, size: 20),
                    ),
                    items: studentOptions.map((s) => DropdownMenuItem(value: s.id, child: Text('${s.name} (${s.classroom})', overflow: TextOverflow.ellipsis))).toList(),
                    onChanged: (v) {
                      setDialogState(() {
                        selectedStudentId = v;
                        selectedStudent = studentOptions.where((s) => s.id == v).firstOrNull;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  // Parent info (read-only, auto-detected)
                  if (selectedStudent != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.bgGrey,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.family_restroom_rounded, size: 18, color: AppTheme.excusedIndigo),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Parent: ${selectedStudent!.parentName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                if (selectedStudent!.primaryGuardianEmail != null)
                                  Text(selectedStudent!.primaryGuardianEmail!, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                                Text(selectedStudent!.parentPhone, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryTeal),
                  onPressed: selectedStudent == null
                      ? null
                      : () {
                          // Find parent user by email
                          final parentEmail = selectedStudent!.primaryGuardianEmail;
                          AppUser? parentUser;
                          if (parentEmail != null) {
                            parentUser = auth.users.where(
                              (u) => u.role == UserRole.parent && u.email.toLowerCase() == parentEmail.toLowerCase(),
                            ).firstOrNull;
                          }

                          chat.createThread(
                            parentUserId: parentUser?.id ?? 'parent_${selectedStudent!.id}',
                            teacherUserId: currentUserId,
                            studentId: selectedStudent!.id,
                            studentName: selectedStudent!.name,
                          );
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Chat started for ${selectedStudent!.name}!'),
                              backgroundColor: AppTheme.primaryTeal,
                            ),
                          );
                        },
                  child: const Text('Start Chat', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        ),
      );
      return;
    }
  }

  void _showInfoDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
        ],
      ),
    );
  }
}
