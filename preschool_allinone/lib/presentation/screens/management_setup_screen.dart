import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kinderlog_core/kinderlog_core.dart';
import 'management_dashboard_screen.dart';

/// Multi-step wizard for first-time preschool setup:
/// Step 1: Preschool name & owner email
/// Step 2: Add branches
/// Step 3: Add classes to branches
/// Step 4: Add teacher users
class ManagementSetupScreen extends StatefulWidget {
  const ManagementSetupScreen({super.key});

  @override
  State<ManagementSetupScreen> createState() => _ManagementSetupScreenState();
}

class _ManagementSetupScreenState extends State<ManagementSetupScreen> {
  int _step = 0;
  final _nameController = TextEditingController(text: 'KinderLog Preschool');
  final _emailController = TextEditingController(text: 'admin@kinderlog.com');
  final _branchNameController = TextEditingController();
  final _branchLocationController = TextEditingController();
  final _classNameController = TextEditingController();
  String? _selectedBranchForClass;

  // Teacher form
  final _teacherNameController = TextEditingController();
  final _teacherEmailController = TextEditingController();
  String? _selectedBranchForTeacher;
  String? _selectedClassForTeacher;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _branchNameController.dispose();
    _branchLocationController.dispose();
    _classNameController.dispose();
    _teacherNameController.dispose();
    _teacherEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(_stepTitle),
            leading: _step > 0
                ? IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => setState(() => _step--),
                  )
                : null,
          ),
          body: auth.isLoading
              ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryTeal))
              : _buildStepContent(context, auth),
        );
      },
    );
  }

  String get _stepTitle {
    switch (_step) {
      case 0: return 'Step 1: Preschool Profile';
      case 1: return 'Step 2: Add Branches';
      case 2: return 'Step 3: Add Classes';
      case 3: return 'Step 4: Add Teachers';
      default: return 'Setup Complete';
    }
  }

  Widget _buildStepContent(BuildContext context, AuthProvider auth) {
    switch (_step) {
      case 0: return _stepPreschoolProfile(context, auth);
      case 1: return _stepBranches(context, auth);
      case 2: return _stepClasses(context, auth);
      case 3: return _stepTeachers(context, auth);
      default:
        // Setup complete → navigate to management dashboard
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ManagementDashboardScreen()),
          );
        });
        return const SizedBox.shrink();
    }
  }

  // ---- Step 0: Preschool Profile ----
  Widget _stepPreschoolProfile(BuildContext context, AuthProvider auth) {
    final formKey = GlobalKey<FormState>();
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Set up your preschool',
              style: kTitleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'This creates your master management account. You\'ll be able to add branches, classes, and teachers afterwards.',
              style: kBodyMedium,
            ),
            const SizedBox(height: 32),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Preschool Name *',
                prefixIcon: Icon(Icons.school_rounded, size: 20),
                hintText: 'e.g. KinderLog Preschool',
              ),
              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Owner Email (Management Login) *',
                prefixIcon: Icon(Icons.email_outlined, size: 20),
                hintText: 'admin@kinderlog.com',
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                if (!v.contains('@')) return 'Enter a valid email';
                return null;
              },
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState?.validate() ?? false) {
                    await auth.createPreschool(
                      name: _nameController.text.trim(),
                      ownerEmail: _emailController.text.trim(),
                    );
                    if (auth.errorMessage != null && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(auth.errorMessage!), backgroundColor: AppTheme.secondaryCoral),
                      );
                    } else {
                      setState(() => _step = 1);
                    }
                  }
                },
                child: const Text('Next: Add Branches'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ---- Step 1: Branches ----
  Widget _stepBranches(BuildContext context, AuthProvider auth) {
    final formKey = GlobalKey<FormState>();
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add Branch Locations', style: kTitleLarge),
            const SizedBox(height: 8),
            const Text('Create physical branches (e.g. Ambalangoda, Hikkaduwa).', style: kBodyMedium),
            const SizedBox(height: 24),
            TextFormField(
              controller: _branchNameController,
              decoration: const InputDecoration(
                labelText: 'Branch Name *',
                prefixIcon: Icon(Icons.location_city_rounded, size: 20),
                hintText: 'e.g. Ambalangoda',
              ),
              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _branchLocationController,
              decoration: const InputDecoration(
                labelText: 'Address / Location',
                prefixIcon: Icon(Icons.location_on_outlined, size: 20),
                hintText: 'e.g. 123 Galle Road',
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add, size: 20),
                label: const Text('Add Branch'),
                onPressed: () async {
                  if (_branchNameController.text.trim().isEmpty) return;
                  await auth.addBranch(
                    name: _branchNameController.text.trim(),
                    location: _branchLocationController.text.trim(),
                  );
                  _branchNameController.clear();
                  _branchLocationController.clear();
                },
              ),
            ),
            const SizedBox(height: 20),
            // List of added branches
            Expanded(
              child: auth.branches.isEmpty
                  ? Center(
                      child: Text(
                        'No branches added yet. Add at least one.',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    )
                  : ListView.builder(
                      itemCount: auth.branches.length,
                      itemBuilder: (context, index) {
                        final b = auth.branches[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryTeal.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.location_city_rounded, color: AppTheme.primaryTeal, size: 22),
                            ),
                            title: Text(b.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(b.location.isNotEmpty ? b.location : 'No address',
                                style: const TextStyle(fontSize: 12)),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: AppTheme.secondaryCoral),
                              onPressed: () => auth.removeBranch(b.id),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _step = 0),
                    child: const Text('Back'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: auth.branches.isEmpty
                        ? null
                        : () => setState(() => _step = 2),
                    child: const Text('Next: Add Classes'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ---- Step 2: Classes ----
  Widget _stepClasses(BuildContext context, AuthProvider auth) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Add Classes to Branches', style: kTitleLarge),
          const SizedBox(height: 8),
          const Text('Create classes like FS1, FS2, Yellow, Green within each branch.', style: kBodyMedium),
          const SizedBox(height: 24),
          // Branch selector
          DropdownButtonFormField<String>(
            value: _selectedBranchForClass ?? (auth.branches.isNotEmpty ? auth.branches.first.id : null),
            decoration: const InputDecoration(
              labelText: 'Select Branch *',
              prefixIcon: Icon(Icons.location_city_rounded, size: 20),
            ),
            items: auth.branches.map((b) => DropdownMenuItem(value: b.id, child: Text(b.name))).toList(),
            onChanged: (v) => setState(() => _selectedBranchForClass = v),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _classNameController,
            decoration: const InputDecoration(
              labelText: 'Class Name *',
              prefixIcon: Icon(Icons.meeting_room_rounded, size: 20),
              hintText: 'e.g. FS1, Yellow, Green',
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Add Class'),
              onPressed: () async {
                final name = _classNameController.text.trim();
                final branchId = _selectedBranchForClass ?? (auth.branches.isNotEmpty ? auth.branches.first.id : null);
                if (name.isEmpty || branchId == null) return;
                await auth.addClass(branchId: branchId, name: name);
                _classNameController.clear();
              },
            ),
          ),
          const SizedBox(height: 20),
          // List of classes grouped by branch
          Expanded(
            child: auth.classes.isEmpty
                ? Center(child: Text('No classes yet.', style: TextStyle(color: Colors.grey[500])))
                : ListView(
                    children: auth.branches.map((branch) {
                      final branchClasses = auth.classesForBranch(branch.id);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              branch.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primaryTeal),
                            ),
                          ),
                          ...branchClasses.map((c) => Card(
                                margin: const EdgeInsets.only(bottom: 6),
                                child: ListTile(
                                  leading: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryTeal.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.meeting_room_rounded, color: AppTheme.primaryTeal, size: 20),
                                  ),
                                  title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete_outline, color: AppTheme.secondaryCoral, size: 20),
                                    onPressed: () => auth.removeClass(c.id),
                                  ),
                                ),
                              )),
                          if (branchClasses.isEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text('  No classes', style: TextStyle(fontSize: 12, color: Colors.grey[400])),
                            ),
                        ],
                      );
                    }).toList(),
                  ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _step = 1),
                  child: const Text('Back'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: auth.classes.isEmpty
                      ? null
                      : () => setState(() => _step = 3),
                  child: const Text('Next: Add Teachers'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ---- Step 3: Teachers ----
  Widget _stepTeachers(BuildContext context, AuthProvider auth) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Add Teacher Accounts', style: kTitleLarge),
          const SizedBox(height: 8),
          const Text('Teachers will login using their email. They will be restricted to their assigned branch.', style: kBodyMedium),
          const SizedBox(height: 24),
          TextFormField(
            controller: _teacherNameController,
            decoration: const InputDecoration(
              labelText: 'Teacher Full Name *',
              prefixIcon: Icon(Icons.person, size: 20),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _teacherEmailController,
            decoration: const InputDecoration(
              labelText: 'Teacher Email (for login) *',
              prefixIcon: Icon(Icons.email_outlined, size: 20),
              hintText: 'teacher@kinderlog.com',
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedBranchForTeacher ?? (auth.branches.isNotEmpty ? auth.branches.first.id : null),
            decoration: const InputDecoration(
              labelText: 'Assigned Branch *',
              prefixIcon: Icon(Icons.location_city_rounded, size: 20),
            ),
            items: auth.branches.map((b) => DropdownMenuItem(value: b.id, child: Text(b.name))).toList(),
            onChanged: (v) {
              setState(() {
                _selectedBranchForTeacher = v;
                _selectedClassForTeacher = null;
              });
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedClassForTeacher,
            decoration: const InputDecoration(
              labelText: 'Primary Class (optional)',
              prefixIcon: Icon(Icons.meeting_room_rounded, size: 20),
            ),
            items: [
              const DropdownMenuItem<String>(value: null, child: Text('None')),
              ...auth.classes
                  .where((c) => c.branchId == (_selectedBranchForTeacher ?? ''))
                  .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))),
            ],
            onChanged: (v) => setState(() => _selectedClassForTeacher = v),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.person_add, size: 20),
              label: const Text('Add Teacher'),
              onPressed: () async {
                final name = _teacherNameController.text.trim();
                final email = _teacherEmailController.text.trim();
                final bid = _selectedBranchForTeacher ?? (auth.branches.isNotEmpty ? auth.branches.first.id : null);
                if (name.isEmpty || email.isEmpty || bid == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all required fields.'), backgroundColor: AppTheme.alertAmber),
                  );
                  return;
                }
                await auth.addTeacher(
                  name: name,
                  email: email,
                  branchId: bid,
                  classId: _selectedClassForTeacher,
                );
                if (auth.errorMessage != null && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(auth.errorMessage!), backgroundColor: AppTheme.secondaryCoral),
                  );
                  auth.clearError();
                } else {
                  _teacherNameController.clear();
                  _teacherEmailController.clear();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Teacher added successfully!'), backgroundColor: AppTheme.primaryTeal),
                  );
                }
              },
            ),
          ),
          const SizedBox(height: 20),
          // List of teachers
          Expanded(
            child: auth.users.where((u) => u.role == UserRole.teacher).isEmpty
                ? Center(
                    child: Text(
                      'No teacher accounts yet. Add at least one.',
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  )
                : ListView.builder(
                    itemCount: auth.users.where((u) => u.role == UserRole.teacher).length,
                    itemBuilder: (context, index) {
                      final teachers = auth.users.where((u) => u.role == UserRole.teacher).toList();
                      final teacher = teachers[index];
                      final branchName = auth.branches
                          .where((b) => b.id == teacher.branchId)
                          .map((b) => b.name)
                          .firstOrNull ?? 'Unknown';
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppTheme.primaryTeal.withOpacity(0.08),
                            child: Text(teacher.name[0].toUpperCase(),
                                style: const TextStyle(color: AppTheme.primaryTeal, fontWeight: FontWeight.bold)),
                          ),
                          title: Text(teacher.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text('$branchName • ${teacher.email}', style: const TextStyle(fontSize: 11)),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: AppTheme.secondaryCoral, size: 20),
                            onPressed: () => auth.removeTeacher(teacher.id),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _step = 2),
                  child: const Text('Back'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A)),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const ManagementDashboardScreen()),
                    );
                  },
                  child: const Text('Finish Setup'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
