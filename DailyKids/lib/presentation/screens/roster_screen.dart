import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kinderlog_core/kinderlog_core.dart';
import '../../providers/attendance_provider.dart';
import 'student_detail_screen.dart';

class RosterScreen extends StatefulWidget {
  const RosterScreen({super.key});

  @override
  State<RosterScreen> createState() => _RosterScreenState();
}

class _RosterScreenState extends State<RosterScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedClassFilter = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddStudentDialog(BuildContext context) {
    final attendance = context.read<AttendanceProvider>();
    final formKey = GlobalKey<FormState>();
    String name = '';
    String parentName = '';
    String parentPhone = '';
    String parentEmail = '';
    String classroom = attendance.availableClassrooms.length > 1
        ? attendance.availableClassrooms[1]
        : 'FS1';
    String allergies = '';
    String notes = '';

    final classOptions = attendance.availableClassrooms.where((c) => c != 'All').toList();
    if (classOptions.isEmpty) classOptions.add('FS1');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Row(
                children: [
                  Icon(Icons.child_care_rounded, color: AppTheme.primaryTeal, size: 28),
                  SizedBox(width: 10),
                  Text('Enroll New Child', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Child\'s Full Name *',
                            prefixIcon: Icon(Icons.person, size: 20),
                          ),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                          onSaved: (v) => name = v ?? '',
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: classroom,
                          decoration: const InputDecoration(
                            labelText: 'Classroom Assigned *',
                            prefixIcon: Icon(Icons.meeting_room_rounded, size: 20),
                          ),
                          items: classOptions.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                          onChanged: (v) => setDialogState(() => classroom = v ?? classOptions.first),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Parent/Guardian Name *',
                            prefixIcon: Icon(Icons.family_restroom, size: 20),
                          ),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                          onSaved: (v) => parentName = v ?? '',
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Emergency Contact Phone *',
                            prefixIcon: Icon(Icons.phone, size: 20),
                            hintText: '+1 (555) 000-0000',
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                          onSaved: (v) => parentPhone = v ?? '',
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Parent Email (for alerts)',
                            prefixIcon: Icon(Icons.email_outlined, size: 20),
                            hintText: 'parent@email.com',
                          ),
                          keyboardType: TextInputType.emailAddress,
                          onSaved: (v) => parentEmail = v ?? '',
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Allergies (if any)',
                            prefixIcon: Icon(Icons.warning_amber_outlined, size: 20),
                            hintText: 'e.g. Peanuts, Gluten (or None)',
                          ),
                          onSaved: (v) => allergies = v ?? '',
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Special Pickup / General Notes',
                            prefixIcon: Icon(Icons.edit_note, size: 20),
                            hintText: 'e.g. Always picked up by Grandma',
                          ),
                          maxLines: 2,
                          onSaved: (v) => notes = v ?? '',
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
                  onPressed: () async {
                    if (formKey.currentState?.validate() ?? false) {
                      formKey.currentState?.save();
                      await attendance.addNewStudent(
                        name: name,
                        parentName: parentName,
                        parentPhone: parentPhone,
                        parentEmail: parentEmail.trim().isEmpty ? null : parentEmail.trim(),
                        classroom: classroom,
                        allergies: allergies,
                        notes: notes,
                      );
                      if (mounted) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('$name enrolled successfully!'), backgroundColor: AppTheme.primaryTeal),
                        );
                      }
                    }
                  },
                  child: const Text('Enroll', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, AttendanceProvider>(
      builder: (context, auth, provider, child) {
        final classrooms = provider.availableClassrooms;
        final allStudents = provider.branchStudents;

        final filteredList = allStudents.where((student) {
          final matchesClass = _selectedClassFilter == 'All' || student.classroom == _selectedClassFilter;
          final matchesSearch = student.name.toLowerCase().contains(_searchController.text.toLowerCase()) ||
              student.parentName.toLowerCase().contains(_searchController.text.toLowerCase());
          return matchesClass && matchesSearch;
        }).toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Student Roster'),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddStudentDialog(context),
            backgroundColor: AppTheme.primaryTeal,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.person_add_alt_1_rounded),
          ),
          body: Column(
            children: [
              // Search input
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search roster by name/parent...',
                    prefixIcon: const Icon(Icons.search, color: AppTheme.primaryTeal),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                  ),
                  onChanged: (v) => setState(() {}),
                ),
              ),
              // Filter Chips
              SizedBox(
                height: 48,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: classrooms.length,
                  itemBuilder: (context, index) {
                    final isSelected = _selectedClassFilter == classrooms[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(
                          classrooms[index],
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? Colors.white : Colors.grey[700],
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() => _selectedClassFilter = classrooms[index]);
                        },
                        selectedColor: AppTheme.primaryTeal,
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected ? AppTheme.primaryTeal : const Color(0xFFE5E7EB),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              // Roster Directory List
              Expanded(
                child: provider.isLoading && filteredList.isEmpty
                    ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryTeal))
                    : filteredList.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                            itemCount: filteredList.length,
                            itemBuilder: (context, index) {
                              final student = filteredList[index];
                              final hasAllergies = student.allergies != null &&
                                  student.allergies!.toLowerCase() != 'none' &&
                                  student.allergies!.trim().isNotEmpty;

                              return Card(
                                margin: const EdgeInsets.only(bottom: 10),
                                elevation: 0,
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(12),
                                  leading: CircleAvatar(
                                    radius: 24,
                                    backgroundColor: AppTheme.primaryTeal.withOpacity(0.08),
                                    child: Text(
                                      student.name.substring(0, 1).toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primaryTeal,
                                      ),
                                    ),
                                  ),
                                  title: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          student.name,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                        ),
                                      ),
                                      if (hasAllergies)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFEF2F2),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: const Icon(
                                            Icons.warning_amber_rounded,
                                            size: 14,
                                            color: AppTheme.secondaryCoral,
                                          ),
                                        ),
                                    ],
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(Icons.meeting_room_outlined, size: 13, color: Colors.grey[500]),
                                          const SizedBox(width: 4),
                                          Text(
                                            student.classroom,
                                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                          ),
                                          const SizedBox(width: 12),
                                          Icon(Icons.family_restroom_outlined, size: 13, color: Colors.grey[500]),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              student.parentName,
                                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (student.notes != null && student.notes!.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          student.notes!,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.grey[500]),
                                        ),
                                      ],
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: AppTheme.secondaryCoral, size: 20),
                                        tooltip: 'Remove student',
                                        onPressed: () => _confirmRemoveStudent(context, provider, student),
                                      ),
                                      Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
                                    ],
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => StudentDetailScreen(student: student),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmRemoveStudent(BuildContext context, AttendanceProvider provider, dynamic student) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remove Student', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to remove ${student.name} from the roster?\n\nThis will also delete all their attendance records.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.secondaryCoral),
            onPressed: () {
              provider.removeStudent(student.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${student.name} removed.'), backgroundColor: AppTheme.primaryTeal),
              );
            },
            child: const Text('Remove', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline_rounded, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Roster is Empty',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _searchController.text.isNotEmpty
                ? 'Try searching with another keyword'
                : 'Enroll a new child to build the roster.',
            style: TextStyle(color: Colors.grey[500], fontSize: 13),
          ),
        ],
      ),
    );
  }
}
