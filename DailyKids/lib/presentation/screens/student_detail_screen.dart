import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kinderlog_core/kinderlog_core.dart';
import '../../providers/attendance_provider.dart';

class StudentDetailScreen extends StatefulWidget {
  final Student student;

  const StudentDetailScreen({super.key, required this.student});

  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> {
  late Student _currentStudent;

  @override
  void initState() {
    super.initState();
    _currentStudent = widget.student;
  }

  // Edit student profile modal form
  void _showEditStudentDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    String name = _currentStudent.name;
    String parentName = _currentStudent.parentName;
    String parentPhone = _currentStudent.parentPhone;
    String parentEmail = _currentStudent.parentEmail ?? '';
    String classroom = _currentStudent.classroom;
    String allergies = _currentStudent.allergies ?? '';
    String notes = _currentStudent.notes ?? '';

    final attendance = context.read<AttendanceProvider>();
    final classOptions = attendance.availableClassrooms.where((c) => c != 'All').toList();
    if (classOptions.isEmpty) classOptions.add(classroom);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Edit Student Profile', style: TextStyle(fontWeight: FontWeight.bold)),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.85,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          initialValue: name,
                          decoration: const InputDecoration(labelText: "Child's Name *"),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Please enter name' : null,
                          onSaved: (v) => name = v ?? '',
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: classOptions.contains(classroom) ? classroom : classOptions.first,
                          decoration: const InputDecoration(labelText: 'Classroom Assigned *'),
                          items: classOptions
                              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                              .toList(),
                          onChanged: (v) {
                            setDialogState(() {
                              classroom = v ?? classOptions.first;
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          initialValue: parentName,
                          decoration: const InputDecoration(labelText: 'Parent/Guardian *'),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Please enter parent name' : null,
                          onSaved: (v) => parentName = v ?? '',
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          initialValue: parentPhone,
                          decoration: const InputDecoration(labelText: 'Contact Phone *'),
                          keyboardType: TextInputType.phone,
                          validator: (v) => v == null || v.trim().isEmpty ? 'Please enter parent phone' : null,
                          onSaved: (v) => parentPhone = v ?? '',
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          initialValue: parentEmail,
                          decoration: const InputDecoration(labelText: 'Parent Email'),
                          keyboardType: TextInputType.emailAddress,
                          onSaved: (v) => parentEmail = v ?? '',
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          initialValue: allergies,
                          decoration: const InputDecoration(labelText: 'Allergies'),
                          onSaved: (v) => allergies = v ?? '',
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          initialValue: notes,
                          decoration: const InputDecoration(labelText: 'Pickup / Special Notes'),
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
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryTeal),
                  onPressed: () async {
                    if (formKey.currentState?.validate() ?? false) {
                      formKey.currentState?.save();

                      final updated = _currentStudent.copyWith(
                        name: name,
                        parentName: parentName,
                        parentPhone: parentPhone,
                        parentEmail: parentEmail.trim().isEmpty ? null : parentEmail.trim(),
                        classroom: classroom,
                        allergies: allergies.trim().isEmpty ? 'None' : allergies,
                        notes: notes.trim().isEmpty ? null : notes,
                      );

                      final provider = Provider.of<AttendanceProvider>(context, listen: false);
                      await provider.updateStudentDetails(updated);

                      setState(() {
                        _currentStudent = updated;
                      });

                      if (mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Profile updated successfully!'),
                            backgroundColor: AppTheme.primaryTeal,
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Save Changes', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Mock contact action
  void _simulateContact(String mode, String value) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Simulating emergency $mode to $value... 📞'),
        backgroundColor: AppTheme.primaryTeal,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasAllergies = _currentStudent.allergies != null &&
        _currentStudent.allergies!.toLowerCase() != 'none' &&
        _currentStudent.allergies!.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentStudent.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded, color: AppTheme.primaryTeal),
            onPressed: () => _showEditStudentDialog(context),
            tooltip: 'Edit Profile',
          )
        ],
      ),
      body: Consumer<AttendanceProvider>(
        builder: (context, provider, child) {
          // Find records related to this student
          final studentRecords = provider.dailyRecords.where((rec) => rec.studentId == _currentStudent.id).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Profile Summary Card
                _buildHeaderCard(),
                const SizedBox(height: 16),

                // 2. Parents Emergency Contact Information
                _buildGuardianCard(),
                const SizedBox(height: 16),

                // 3. Allergies / Medical warnings
                if (hasAllergies) ...[
                  _buildAllergiesCard(),
                  const SizedBox(height: 16),
                ],

                // 4. Special notes Card
                if (_currentStudent.notes != null && _currentStudent.notes!.isNotEmpty) ...[
                  _buildSpecialNotesCard(),
                  const SizedBox(height: 16),
                ],

                // 5. Historical log Timeline
                const Text(
                  'Recent Attendance History',
                  style: kTitleMedium,
                ),
                const SizedBox(height: 8),
                _buildHistoryTimeline(studentRecords),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: AppTheme.primaryTeal.withOpacity(0.08),
            child: Text(
              _currentStudent.name.substring(0, 1).toUpperCase(),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryTeal,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _currentStudent.name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Classroom: ${_currentStudent.classroom}',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuardianCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.family_restroom_rounded, color: AppTheme.primaryTeal, size: 20),
              const SizedBox(width: 8),
              Text(
                'Parent / Guardian Info',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey[800]),
              ),
            ],
          ),
          const Divider(height: 24),
          Text(
            _currentStudent.parentName,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 2),
          Text(
            'Primary Emergency Contact',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  _currentStudent.parentPhone,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(80, 36),
                  backgroundColor: AppTheme.primaryTeal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => _simulateContact('Call', _currentStudent.parentPhone),
                icon: const Icon(Icons.phone, size: 14),
                label: const Text('Call', style: TextStyle(fontSize: 12)),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(80, 36),
                  foregroundColor: AppTheme.primaryTeal,
                  side: const BorderSide(color: AppTheme.primaryTeal),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => _simulateContact('SMS', _currentStudent.parentPhone),
                icon: const Icon(Icons.message_rounded, size: 14),
                label: const Text('SMS', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          // ── Additional Guardians ──
          if (_currentStudent.guardians.isNotEmpty) ...[
            const Divider(height: 28),
            Row(
              children: [
                const Icon(Icons.people_rounded, color: AppTheme.excusedIndigo, size: 16),
                const SizedBox(width: 6),
                Text(
                  'Additional Guardians (${_currentStudent.guardians.length})',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.grey[700]),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ..._currentStudent.guardians.map((g) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.bgGrey,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppTheme.excusedIndigo.withOpacity(0.1),
                      child: Text(
                        g.name.isNotEmpty ? g.name[0].toUpperCase() : 'G',
                        style: const TextStyle(color: AppTheme.excusedIndigo, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(g.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          Text(g.email, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                          if (g.relationship != 'Parent' || g.phone.isNotEmpty)
                            Text(
                              [if (g.relationship != 'Parent') g.relationship, if (g.phone.isNotEmpty) g.phone].join(' · '),
                              style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                            ),
                        ],
                      ),
                    ),
                    if (g.email.isNotEmpty)
                      Icon(Icons.login_rounded, size: 16, color: Colors.grey[400], semanticLabel: 'Can log in as parent'),
                  ],
                ),
              ),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildAllergiesCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFCA5A5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppTheme.secondaryCoral, size: 20),
              const SizedBox(width: 8),
              Text(
                'Critical Allergy Notice',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.secondaryCoral),
              ),
            ],
          ),
          const Divider(height: 20, color: Color(0xFFFCA5A5)),
          Text(
            _currentStudent.allergies!,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 4),
          const Text(
            'Confirm with kitchen staff before serving any snack or drink.',
            style: TextStyle(fontSize: 11, color: AppTheme.secondaryCoral),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialNotesCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.edit_note_rounded, color: AppTheme.primaryTeal, size: 20),
              const SizedBox(width: 8),
              Text(
                'Pickup Directions & Notes',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey[800]),
              ),
            ],
          ),
          const Divider(height: 20),
          Text(
            _currentStudent.notes!,
            style: const TextStyle(fontSize: 13, height: 1.4, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTimeline(List studentRecords) {
    if (studentRecords.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        alignment: Alignment.center,
        child: Text(
          'No recent attendance logs recorded for this student.',
          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: studentRecords.length,
        itemBuilder: (context, index) {
          final rec = studentRecords[index];
          final isLast = index == studentRecords.length - 1;

          return Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(rec.status).withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getStatusIcon(rec.status),
                          color: _getStatusColor(rec.status),
                          size: 16,
                        ),
                      ),
                      if (!isLast)
                        Container(
                          width: 2,
                          height: 32,
                          color: Colors.grey[200],
                        )
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              rec.date,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              rec.status.toString().split('.').last.toUpperCase(),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: _getStatusColor(rec.status),
                              ),
                            ),
                          ],
                        ),
                        if (rec.note != null && rec.note.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Note: ${rec.note}',
                            style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.grey[600]),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              if (!isLast) const SizedBox(height: 12),
            ],
          );
        },
      ),
    );
  }

  Color _getStatusColor(var status) {
    switch (status.toString()) {
      case 'AttendanceStatus.present':
        return AppTheme.primaryTeal;
      case 'AttendanceStatus.absent':
        return AppTheme.secondaryCoral;
      case 'AttendanceStatus.tardy':
        return AppTheme.alertAmber;
      case 'AttendanceStatus.excused':
        return AppTheme.excusedIndigo;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(var status) {
    switch (status.toString()) {
      case 'AttendanceStatus.present':
        return Icons.check_circle_rounded;
      case 'AttendanceStatus.absent':
        return Icons.cancel_rounded;
      case 'AttendanceStatus.tardy':
        return Icons.watch_later_rounded;
      case 'AttendanceStatus.excused':
        return Icons.event_available_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }
}
