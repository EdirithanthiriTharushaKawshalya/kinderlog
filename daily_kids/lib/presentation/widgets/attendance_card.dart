import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kinderlog_core/kinderlog_core.dart';
import '../../data/models/attendance_record_model.dart';

class AttendanceCard extends StatelessWidget {
  final Student student;
  final AttendanceRecord? record;
  final Function(AttendanceStatus) onStatusChanged;
  final Function() onCheckOut;
  final Function(String) onSaveNote;

  const AttendanceCard({
    super.key,
    required this.student,
    required this.record,
    required this.onStatusChanged,
    required this.onCheckOut,
    required this.onSaveNote,
  });

  // Get color based on status
  Color _getStatusColor(AttendanceStatus? status) {
    switch (status) {
      case AttendanceStatus.present:
        return AppTheme.primaryTeal;
      case AttendanceStatus.absent:
        return AppTheme.secondaryCoral;
      case AttendanceStatus.tardy:
        return AppTheme.alertAmber;
      case AttendanceStatus.excused:
        return AppTheme.excusedIndigo;
      case null:
        return Colors.grey[400]!;
    }
  }

  // Get initial letters of student name
  String _getInitials(String name) {
    if (name.isEmpty) return 'K';
    final parts = name.split(' ');
    if (parts.length > 1) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return name[0].toUpperCase();
  }

  // Quick dialog to edit/add a note
  void _showNoteDialog(BuildContext context) {
    final controller = TextEditingController(text: record?.note ?? '');
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Attendance Note for ${student.name}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Enter reason, pick-up notes, or details...',
              hintStyle: TextStyle(fontSize: 14),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(80, 36),
                backgroundColor: AppTheme.primaryTeal,
              ),
              onPressed: () {
                onSaveNote(controller.text.trim());
                Navigator.pop(context);
              },
              child: const Text('Save Note', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = record?.status;
    final checkInFormatted = record?.checkInTime != null
        ? DateFormat('hh:mm a').format(record!.checkInTime!)
        : null;
    final checkOutFormatted = record?.checkOutTime != null
        ? DateFormat('hh:mm a').format(record!.checkOutTime!)
        : null;

    final hasAllergies = student.allergies != null &&
        student.allergies!.toLowerCase() != 'none' &&
        student.allergies!.trim().isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: status != null ? _getStatusColor(status).withOpacity(0.3) : const Color(0xFFE5E7EB),
          width: status != null ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Student Profile Section
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: status != null
                    ? _getStatusColor(status).withOpacity(0.12)
                    : AppTheme.primaryTeal.withOpacity(0.08),
                child: Text(
                  _getInitials(student.name),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: status != null ? _getStatusColor(status) : AppTheme.primaryTeal,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            student.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            student.classroom,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    if (hasAllergies)
                      Container(
                        margin: const EdgeInsets.only(bottom: 4, top: 2),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFFCA5A5).withOpacity(0.5)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.warning_amber_rounded, size: 12, color: AppTheme.secondaryCoral),
                            const SizedBox(width: 4),
                            Text(
                              'Allergy: ${student.allergies}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.secondaryCoral,
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    // Display timestamps / note summaries
                    if (status != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (checkInFormatted != null) ...[
                            Icon(Icons.login, size: 12, color: Colors.grey[500]),
                            const SizedBox(width: 2),
                            Text(
                              'In: $checkInFormatted',
                              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                            ),
                          ],
                          if (checkOutFormatted != null) ...[
                            const SizedBox(width: 8),
                            Icon(Icons.logout, size: 12, color: Colors.grey[500]),
                            const SizedBox(width: 2),
                            Text(
                              'Out: $checkOutFormatted',
                              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                            ),
                          ],
                        ],
                      ),
                    ],
                    if (record?.note != null && record!.note!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        '📝 ${record!.note}',
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Action row: Status selector buttons and comments
          Row(
            children: [
              // 4 standard status buttons
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _buildStatusButton(
                      context,
                      status: AttendanceStatus.present,
                      label: 'Present',
                      activeColor: AppTheme.primaryTeal,
                      icon: Icons.check_circle_rounded,
                      currentStatus: status,
                    ),
                    const SizedBox(width: 6),
                    _buildStatusButton(
                      context,
                      status: AttendanceStatus.absent,
                      label: 'Absent',
                      activeColor: AppTheme.secondaryCoral,
                      icon: Icons.cancel_rounded,
                      currentStatus: status,
                    ),
                    const SizedBox(width: 6),
                    _buildStatusButton(
                      context,
                      status: AttendanceStatus.tardy,
                      label: 'Late',
                      activeColor: AppTheme.alertAmber,
                      icon: Icons.watch_later_rounded,
                      currentStatus: status,
                    ),
                    const SizedBox(width: 6),
                    _buildStatusButton(
                      context,
                      status: AttendanceStatus.excused,
                      label: 'Excused',
                      activeColor: AppTheme.excusedIndigo,
                      icon: Icons.event_available_rounded,
                      currentStatus: status,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Option actions: Add Note & Checkout
              Row(
                children: [
                  IconButton(
                    onPressed: () => _showNoteDialog(context),
                    icon: Icon(
                      record?.note != null ? Icons.edit_note_rounded : Icons.note_add_outlined,
                      color: record?.note != null ? AppTheme.primaryTeal : Colors.grey[600],
                      size: 24,
                    ),
                    tooltip: 'Add Note',
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                  ),
                  if (status == AttendanceStatus.present || status == AttendanceStatus.tardy) ...[
                    const SizedBox(width: 6),
                    IconButton(
                      onPressed: record?.checkOutTime != null ? null : onCheckOut,
                      icon: Icon(
                        Icons.logout_rounded,
                        color: record?.checkOutTime != null ? Colors.grey[300] : AppTheme.secondaryCoral,
                        size: 22,
                      ),
                      tooltip: record?.checkOutTime != null ? 'Checked out' : 'Sign Out Student',
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(4),
                    ),
                  ]
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  // Compact circular option selector
  Widget _buildStatusButton(
    BuildContext context, {
    required AttendanceStatus status,
    required String label,
    required Color activeColor,
    required IconData icon,
    required AttendanceStatus? currentStatus,
  }) {
    final isSelected = currentStatus == status;

    return GestureDetector(
      onTap: () => onStatusChanged(status),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: isSelected
            ? const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
            : const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withOpacity(0.12) : Colors.grey[100],
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? activeColor : Colors.transparent,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? activeColor : Colors.grey[600],
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: activeColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
