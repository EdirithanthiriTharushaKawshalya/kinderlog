import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kinderlog_core/kinderlog_core.dart';
import 'package:intl/intl.dart';
import '../../data/models/homework_model.dart';
import '../../providers/homework_provider.dart';

/// Homework screen — teachers create & manage, parents view & mark as done.
class HomeworkScreen extends StatefulWidget {
  final bool hideAppBar;
  const HomeworkScreen({super.key, this.hideAppBar = false});

  @override
  State<HomeworkScreen> createState() => _HomeworkScreenState();
}

class _HomeworkScreenState extends State<HomeworkScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, HomeworkProvider>(
      builder: (context, auth, hwProvider, _) {
        final isTeacher = auth.isTeacher;
        final isParent = auth.isParent;
        final userId = auth.currentUser?.id ?? '';

        List<Homework> items;
        if (isTeacher) {
          items = hwProvider.homeworkForTeacher(userId);
        } else if (isParent) {
          // Parent sees homework for their children's classes
          final studentIds = auth.currentUser?.studentIds ?? [];
          final allHomework = <Homework>{};
          for (final sid in studentIds) {
            // In a real app we'd look up the class; for mock, show all
            allHomework.addAll(hwProvider.homework.where((h) => true));
          }
          items = allHomework.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        } else {
          // Management sees all
          items = List.of(hwProvider.homework)
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        }

        return Scaffold(
          appBar: widget.hideAppBar
              ? null
              : AppBar(title: const Text('Homework')),
          body: items.isEmpty
              ? _buildEmptyState(isTeacher)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (context, index) => _buildHomeworkCard(
                    items[index],
                    auth,
                    hwProvider,
                    isTeacher,
                    userId,
                  ),
                ),
          floatingActionButton: isTeacher
              ? FloatingActionButton(
                  backgroundColor: AppTheme.primaryTeal,
                  onPressed: () => _showCreateDialog(context, auth, hwProvider),
                  child: const Icon(Icons.add_rounded, color: Colors.white),
                )
              : null,
        );
      },
    );
  }

  Widget _buildEmptyState(bool isTeacher) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            isTeacher ? 'No homework assigned yet' : 'No homework for your child yet',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[600]),
          ),
          const SizedBox(height: 4),
          Text(
            isTeacher
                ? 'Tap + to create your first homework assignment.'
                : 'Homework from teachers will appear here.',
            style: TextStyle(color: Colors.grey[500], fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeworkCard(
    Homework hw,
    AuthProvider auth,
    HomeworkProvider hwProvider,
    bool isTeacher,
    String userId,
  ) {
    final isOverdue = hw.isOverdue;
    final dueDateStr = DateFormat('MMM d, yyyy').format(hw.dueDate);
    final createdStr = DateFormat('MMM d').format(hw.createdAt);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isOverdue ? AppTheme.secondaryCoral.withOpacity(0.3) : const Color(0xFFE5E7EB),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _showDetailDialog(context, hw, auth, hwProvider, isTeacher),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row: title + overdue badge
              Row(
                children: [
                  Expanded(
                    child: Text(
                      hw.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                  if (isOverdue)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryCoral.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'OVERDUE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.secondaryCoral,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              // Description preview
              Text(
                hw.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.4),
              ),
              const SizedBox(height: 12),
              // Metadata row
              Row(
                children: [
                  // Teacher avatar
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: AppTheme.primaryTeal.withOpacity(0.08),
                    child: Text(
                      hw.teacherName.isNotEmpty ? hw.teacherName[0].toUpperCase() : 'T',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${hw.teacherName} · ${hw.className}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          'Due $dueDateStr · Created $createdStr',
                          style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  ),
                  // Status icon for parents
                  if (!isTeacher && !auth.isManagement) ...[
                    if (hw.isViewedBy(userId))
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryTeal.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle_rounded, size: 14, color: AppTheme.primaryTeal),
                            SizedBox(width: 4),
                            Text('Viewed', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.primaryTeal)),
                          ],
                        ),
                      )
                    else
                      TextButton(
                        onPressed: () => hwProvider.markAsViewed(hw.id, userId),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('Mark Viewed', style: TextStyle(fontSize: 11)),
                      ),
                  ],
                  // Viewed count for teachers
                  if (isTeacher) ...[
                    Icon(Icons.visibility_outlined, size: 14, color: Colors.grey[400]),
                    const SizedBox(width: 3),
                    Text(
                      '${hw.viewedByStudentIds.length}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                    if (isTeacher)
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, size: 18, color: Colors.grey),
                        padding: EdgeInsets.zero,
                        onSelected: (action) {
                          if (action == 'delete') {
                            _confirmDelete(context, hwProvider, hw);
                          }
                        },
                        itemBuilder: (_) => [
                          const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: AppTheme.secondaryCoral, fontSize: 13))),
                        ],
                      ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Create Homework Dialog ──────────────────────────────────
  void _showCreateDialog(BuildContext context, AuthProvider auth, HomeworkProvider hwProvider) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    DateTime dueDate = DateTime.now().add(const Duration(days: 3));
    String? selectedClassId;
    String? selectedClassName;

    // Pre-select teacher's pinned class
    final classes = auth.accessibleClasses;
    if (classes.isNotEmpty) {
      final pinned = auth.pinnedClass;
      if (pinned != null) {
        selectedClassId = pinned.id;
        selectedClassName = pinned.name;
      } else {
        selectedClassId = classes.first.id;
        selectedClassName = classes.first.name;
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.assignment_rounded, color: AppTheme.primaryTeal, size: 24),
              SizedBox(width: 10),
              Text('New Homework', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.85,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Class selector
                    DropdownButtonFormField<String>(
                      value: selectedClassId,
                      decoration: const InputDecoration(labelText: 'Assign to Class *'),
                      items: classes.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                      onChanged: (v) {
                        setDialogState(() {
                          selectedClassId = v;
                          selectedClassName = classes.where((c) => c.id == v).firstOrNull?.name;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(labelText: 'Homework Title *', hintText: 'e.g. Color the Rainbow'),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: descCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Description *',
                        hintText: 'Describe the activity and what parents should do...',
                        alignLabelWithHint: true,
                      ),
                      maxLines: 4,
                      validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    // Due date picker
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: ctx,
                          initialDate: dueDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 90)),
                        );
                        if (picked != null) {
                          setDialogState(() => dueDate = picked);
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Due Date *',
                          prefixIcon: Icon(Icons.calendar_today_rounded, size: 20),
                        ),
                        child: Text(
                          DateFormat('EEEE, MMM d, yyyy').format(dueDate),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryTeal),
              onPressed: hwProvider.isLoading
                  ? null
                  : () async {
                      if (formKey.currentState?.validate() ?? false) {
                        if (selectedClassId == null) return;
                        await hwProvider.createHomework(
                          teacherId: auth.currentUser!.id,
                          teacherName: auth.currentUser!.name,
                          classId: selectedClassId!,
                          className: selectedClassName ?? '',
                          title: titleCtrl.text.trim(),
                          description: descCtrl.text.trim(),
                          dueDate: dueDate,
                        );
                        if (ctx.mounted) Navigator.pop(ctx);
                      }
                    },
              child: hwProvider.isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Assign Homework', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // ── Detail Dialog ───────────────────────────────────────────
  void _showDetailDialog(BuildContext context, Homework hw, AuthProvider auth, HomeworkProvider hwProvider, bool isTeacher) {
    final dueDateStr = DateFormat('EEEE, MMM d, yyyy').format(hw.dueDate);
    final createdStr = DateFormat('MMM d, yyyy · h:mm a').format(hw.createdAt);
    final userId = auth.currentUser?.id ?? '';
    final isOverdue = hw.isOverdue;
    final viewed = hw.isViewedBy(userId);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(hw.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ),
                if (isOverdue)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryCoral.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('OVERDUE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.secondaryCoral)),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                CircleAvatar(radius: 10, backgroundColor: AppTheme.primaryTeal.withOpacity(0.08), child: Text(hw.teacherName[0].toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal))),
                const SizedBox(width: 6),
                Text('${hw.teacherName} · ${hw.className}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ],
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.85,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(hw.description, style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.black87)),
                const SizedBox(height: 16),
                // Due date info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isOverdue ? const Color(0xFFFEF2F2) : AppTheme.bgGrey,
                    borderRadius: BorderRadius.circular(10),
                    border: isOverdue ? Border.all(color: const Color(0xFFFCA5A5)) : null,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isOverdue ? Icons.warning_amber_rounded : Icons.event_rounded,
                        size: 18,
                        color: isOverdue ? AppTheme.secondaryCoral : AppTheme.primaryTeal,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Due: $dueDateStr',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: isOverdue ? AppTheme.secondaryCoral : Colors.black87),
                            ),
                            Text('Created $createdStr', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Viewed status
                if (isTeacher) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Viewed by ${hw.viewedByStudentIds.length} student(s)',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600], fontStyle: FontStyle.italic),
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          if (!isTeacher && !auth.isManagement) ...[
            if (viewed)
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryTeal.withOpacity(0.1), foregroundColor: AppTheme.primaryTeal),
                onPressed: null,
                icon: const Icon(Icons.check_circle_rounded, size: 16),
                label: const Text('Viewed'),
              )
            else
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryTeal),
                onPressed: () {
                  hwProvider.markAsViewed(hw.id, userId);
                  Navigator.pop(ctx);
                },
                icon: const Icon(Icons.visibility_rounded, size: 16),
                label: const Text('Mark as Viewed', style: TextStyle(color: Colors.white)),
              ),
          ],
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, HomeworkProvider hwProvider, Homework hw) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Homework', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Remove "${hw.title}"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.secondaryCoral),
            onPressed: () {
              hwProvider.deleteHomework(hw.id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
