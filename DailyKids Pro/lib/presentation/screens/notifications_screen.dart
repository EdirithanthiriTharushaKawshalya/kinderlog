import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kinderlog_core/kinderlog_core.dart';
import '../../providers/notification_provider.dart';

import '../../data/models/notification_model.dart';

/// Notification inbox with broadcast capability for management/teachers.
class NotificationsScreen extends StatefulWidget {
  final bool hideAppBar;
  const NotificationsScreen({super.key, this.hideAppBar = false});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, NotificationProvider>(
      builder: (context, auth, notif, _) {
        return Scaffold(
          appBar: widget.hideAppBar
              ? null
              : AppBar(
                  title: const Text('Notifications'),
                  actions: [
              if (notif.unreadCount > 0)
                TextButton(
                  onPressed: () => notif.markAllAsRead(),
                  child: const Text('Mark All Read', style: TextStyle(fontSize: 12)),
                ),
            ],
          ),
          body: notif.notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_none_rounded, size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 12),
                      Text('No notifications', style: TextStyle(color: Colors.grey[500])),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: notif.notifications.length,
                  itemBuilder: (context, index) {
                    final n = notif.notifications[index];
                    final isUnread = !n.isRead;
                    final priorityColor = n.priority == NotificationPriority.emergency
                        ? AppTheme.secondaryCoral
                        : n.priority == NotificationPriority.urgent ? AppTheme.alertAmber : AppTheme.primaryTeal;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      elevation: 0,
                      color: isUnread ? AppTheme.primaryTeal.withValues(alpha: 0.04) : Colors.white,
                      child: InkWell(
                        onTap: () {
                          if (isUnread) notif.markAsRead(n.id);
                          _showDetail(context, n);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 8, height: 8,
                                margin: const EdgeInsets.only(top: 6, right: 12),
                                decoration: BoxDecoration(
                                  color: isUnread ? priorityColor : Colors.transparent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(n.title, style: TextStyle(fontWeight: isUnread ? FontWeight.bold : FontWeight.w500, fontSize: 14)),
                                    const SizedBox(height: 3),
                                    Text(n.body, style: TextStyle(fontSize: 12, color: Colors.grey[600]), maxLines: 2, overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Text(n.senderName, style: TextStyle(fontSize: 11, color: Colors.grey[400])),
                                        const SizedBox(width: 8),
                                        Text(_formatTime(n.sentAt), style: TextStyle(fontSize: 11, color: Colors.grey[400])),
                                        const Spacer(),
                                        if (n.target != NotificationTarget.all)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(color: priorityColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                                            child: Text(n.targetName ?? n.target.name, style: TextStyle(fontSize: 10, color: priorityColor)),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
          floatingActionButton: (auth.isManagement || auth.isTeacher)
              ? FloatingActionButton(
                  backgroundColor: AppTheme.primaryTeal,
                  onPressed: () => _showBroadcastDialog(context, auth, notif),
                  child: const Icon(Icons.campaign_rounded, color: Colors.white),
                )
              : null,
        );
      },
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  void _showDetail(BuildContext context, AppNotification n) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            Text(n.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('From: ${n.senderName} · ${_formatTime(n.sentAt)}', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            if (n.target != NotificationTarget.all)
              Text('Target: ${n.targetName ?? n.target.name}', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            const SizedBox(height: 16),
            Text(n.body, style: const TextStyle(fontSize: 14, height: 1.5)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showBroadcastDialog(BuildContext context, AuthProvider auth, NotificationProvider notif) {
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();
    NotificationTarget target = NotificationTarget.all;
    String? targetId;
    String? targetName;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(children: [
            Icon(Icons.campaign_rounded, color: AppTheme.primaryTeal),
            SizedBox(width: 10),
            Text('Send Notification', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ]),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title *')),
                const SizedBox(height: 12),
                TextField(controller: bodyCtrl, decoration: const InputDecoration(labelText: 'Message *'), maxLines: 3),
                const SizedBox(height: 12),
                DropdownButtonFormField<NotificationTarget>(
                  value: target,
                  decoration: const InputDecoration(labelText: 'Target Audience'),
                  items: NotificationTarget.values.map((t) => DropdownMenuItem(value: t, child: Text(t.name))).toList(),
                  onChanged: (v) => setDialogState(() { target = v ?? NotificationTarget.all; targetId = null; targetName = null; }),
                ),
                if (target == NotificationTarget.branch) ...[
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Select Branch'),
                    items: auth.branches.map((b) => DropdownMenuItem(value: b.id, child: Text(b.name))).toList(),
                    onChanged: (v) => setDialogState(() { targetId = v; targetName = auth.branches.where((b) => b.id == v).firstOrNull?.name; }),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryTeal),
              onPressed: () {
                if (titleCtrl.text.trim().isEmpty || bodyCtrl.text.trim().isEmpty) return;
                notif.sendNotification(
                  title: titleCtrl.text.trim(),
                  body: bodyCtrl.text.trim(),
                  senderName: auth.currentUser?.name ?? 'Staff',
                  senderId: auth.currentUser?.id ?? '',
                  target: target,
                  targetId: targetId,
                  targetName: targetName,
                  priority: NotificationPriority.normal,
                );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Notification sent! 📢'), backgroundColor: AppTheme.primaryTeal),
                );
              },
              child: const Text('Send', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
