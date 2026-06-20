import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kinderlog_core/kinderlog_core.dart';

class ManagementScreen extends StatefulWidget {
  const ManagementScreen({super.key});

  @override
  State<ManagementScreen> createState() => _ManagementScreenState();
}

class _ManagementScreenState extends State<ManagementScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBranchesSection(auth),
              const SizedBox(height: 24),
              _buildClassesSection(auth),
              const SizedBox(height: 24),
              _buildTeachersSection(auth),
            ],
          ),
        );
      },
    );
  }

  // ── Branches ──────────────────────────────────────────────
  Widget _buildBranchesSection(AuthProvider auth) {
    return _buildSectionCard(
      title: 'Branches',
      icon: Icons.business_rounded,
      count: '${auth.branches.length}',
      addLabel: 'Add Branch',
      onAdd: () => _showAddBranchDialog(auth),
      children: auth.branches.map((branch) {
        final classCount = auth.classes.where((c) => c.branchId == branch.id).length;
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryTeal.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.school_rounded, color: AppTheme.primaryTeal, size: 22),
          ),
          title: Text(branch.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          subtitle: Text('${branch.location}  ·  $classCount classes',
              style: const TextStyle(fontSize: 12)),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline, color: AppTheme.secondaryCoral, size: 20),
            onPressed: () => _confirmDelete(context, 'branch "${branch.name}"',
                () => auth.removeBranch(branch.id)),
          ),
        );
      }).toList(),
    );
  }

  // ── Classes ───────────────────────────────────────────────
  Widget _buildClassesSection(AuthProvider auth) {
    return _buildSectionCard(
      title: 'Classes',
      icon: Icons.meeting_room_rounded,
      count: '${auth.classes.length}',
      addLabel: 'Add Class',
      onAdd: () => _showAddClassDialog(auth),
      children: auth.classes.map((cls) {
        final branch = auth.branches.where((b) => b.id == cls.branchId).firstOrNull;
        final teacher = auth.users.where((u) => u.id == cls.teacherId).firstOrNull;
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.alertAmber.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.meeting_room_rounded, color: AppTheme.alertAmber, size: 22),
          ),
          title: Text(cls.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          subtitle: Text(
            '${branch?.name ?? "Unknown branch"}  ·  Teacher: ${teacher?.name ?? "Unassigned"}',
            style: const TextStyle(fontSize: 12),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline, color: AppTheme.secondaryCoral, size: 20),
            onPressed: () => _confirmDelete(context, 'class "${cls.name}"',
                () => auth.removeClass(cls.id)),
          ),
        );
      }).toList(),
    );
  }

  // ── Teachers ──────────────────────────────────────────────
  Widget _buildTeachersSection(AuthProvider auth) {
    final teachers = auth.users.where((u) => u.role == UserRole.teacher).toList();
    return _buildSectionCard(
      title: 'Teachers',
      icon: Icons.people_rounded,
      count: '${teachers.length}',
      addLabel: 'Add Teacher',
      onAdd: () => _showAddTeacherDialog(auth),
      children: teachers.map((user) {
        final branch = auth.branches.where((b) => b.id == user.branchId).firstOrNull;
        final pinnedClass = auth.classes.where((c) => c.id == user.pinnedClassId).firstOrNull;
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
          leading: CircleAvatar(
            backgroundColor: AppTheme.excusedIndigo.withOpacity(0.1),
            child: Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : 'T',
              style: const TextStyle(color: AppTheme.excusedIndigo, fontWeight: FontWeight.bold),
            ),
          ),
          title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          subtitle: Text(
            '${branch?.name ?? "No branch"}  ·  Class: ${pinnedClass?.name ?? "None"}',
            style: const TextStyle(fontSize: 12),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline, color: AppTheme.secondaryCoral, size: 20),
            onPressed: () => _confirmDelete(context, 'teacher "${user.name}"',
                () => auth.removeTeacher(user.id)),
          ),
        );
      }).toList(),
    );
  }

  // ── Add Branch Dialog ─────────────────────────────────────
  void _showAddBranchDialog(AuthProvider auth) {
    final nameCtrl = TextEditingController();
    final locationCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Add New Branch', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Branch Name *', prefixIcon: Icon(Icons.business, size: 20)),
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: locationCtrl,
                decoration: const InputDecoration(labelText: 'Location *', prefixIcon: Icon(Icons.location_on, size: 20)),
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryTeal),
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                await auth.addBranch(name: nameCtrl.text.trim(), location: locationCtrl.text.trim());
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Create', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── Add Class Dialog ──────────────────────────────────────
  void _showAddClassDialog(AuthProvider auth) {
    final nameCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String selectedBranchId = auth.branches.isNotEmpty ? auth.branches.first.id : '';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Add New Class', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedBranchId,
                  decoration: const InputDecoration(labelText: 'Branch *', prefixIcon: Icon(Icons.business, size: 20)),
                  items: auth.branches.map((b) => DropdownMenuItem(value: b.id, child: Text(b.name))).toList(),
                  onChanged: (v) => setDialogState(() => selectedBranchId = v ?? selectedBranchId),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Class Name *', prefixIcon: Icon(Icons.meeting_room, size: 20)),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryTeal),
              onPressed: () async {
                if (formKey.currentState?.validate() ?? false) {
                  await auth.addClass(branchId: selectedBranchId, name: nameCtrl.text.trim());
                  if (ctx.mounted) Navigator.pop(ctx);
                }
              },
              child: const Text('Create', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // ── Add Teacher Dialog ────────────────────────────────────
  void _showAddTeacherDialog(AuthProvider auth) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String selectedBranchId = auth.branches.isNotEmpty ? auth.branches.first.id : '';
    String? selectedClassId;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final branchClasses = auth.classes.where((c) => c.branchId == selectedBranchId).toList();
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Add New Teacher', style: TextStyle(fontWeight: FontWeight.bold)),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Full Name *', prefixIcon: Icon(Icons.person, size: 20)),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: emailCtrl,
                    decoration: const InputDecoration(labelText: 'Email *', prefixIcon: Icon(Icons.email, size: 20)),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      if (!v.contains('@')) return 'Enter a valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedBranchId,
                    decoration: const InputDecoration(labelText: 'Branch *', prefixIcon: Icon(Icons.business, size: 20)),
                    items: auth.branches.map((b) => DropdownMenuItem(value: b.id, child: Text(b.name))).toList(),
                    onChanged: (v) {
                      setDialogState(() {
                        selectedBranchId = v ?? selectedBranchId;
                        selectedClassId = null;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedClassId,
                    decoration: const InputDecoration(labelText: 'Assigned Class (optional)', prefixIcon: Icon(Icons.meeting_room, size: 20)),
                    items: [
                      const DropdownMenuItem<String>(value: null, child: Text('None')),
                      ...branchClasses.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))),
                    ],
                    onChanged: (v) => setDialogState(() => selectedClassId = v),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryTeal),
                onPressed: () async {
                  if (formKey.currentState?.validate() ?? false) {
                    await auth.addTeacher(
                      name: nameCtrl.text.trim(),
                      email: emailCtrl.text.trim(),
                      branchId: selectedBranchId,
                      classId: selectedClassId,
                    );
                    if (ctx.mounted) Navigator.pop(ctx);
                  }
                },
                child: const Text('Add Teacher', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Confirm Delete Dialog ─────────────────────────────────
  void _confirmDelete(BuildContext context, String item, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirm Delete', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to remove $item?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.secondaryCoral),
            onPressed: () {
              onConfirm();
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── Reusable Section Card ─────────────────────────────────
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required String count,
    required String addLabel,
    required VoidCallback onAdd,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 4),
            child: Row(
              children: [
                Icon(icon, color: AppTheme.primaryTeal, size: 22),
                const SizedBox(width: 10),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryTeal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(count, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal)),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: Text(addLabel, style: const TextStyle(fontSize: 13)),
                ),
              ],
            ),
          ),
          if (children.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text('No $title yet.', style: TextStyle(color: Colors.grey[400], fontSize: 13)),
              ),
            )
          else
            ...children,
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
