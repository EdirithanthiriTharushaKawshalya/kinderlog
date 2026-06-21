import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kinderlog_core/kinderlog_core.dart';
import '../../providers/admission_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../data/models/admission_model.dart';

/// Management dashboard to review, approve/reject incoming applications.
class AdmissionReviewScreen extends StatefulWidget {
  final bool hideAppBar;
  const AdmissionReviewScreen({super.key, this.hideAppBar = false});

  @override
  State<AdmissionReviewScreen> createState() => _AdmissionReviewScreenState();
}

class _AdmissionReviewScreenState extends State<AdmissionReviewScreen> {
  String _filter = 'pending';

  @override
  Widget build(BuildContext context) {
    return Consumer<AdmissionProvider>(
      builder: (context, admission, _) {
        final apps = _filter == 'pending' ? admission.pendingApplications :
                    _filter == 'review' ? admission.underReviewApplications :
                    _filter == 'approved' ? admission.approvedApplications :
                    admission.rejectedApplications;

        return Scaffold(
          appBar: widget.hideAppBar
              ? null
              : AppBar(title: const Text('Admission Review')),
          body: Column(
            children: [
              // Filter tabs
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _filterChip('Pending (${admission.pendingApplications.length})', 'pending'),
                      const SizedBox(width: 8),
                      _filterChip('Under Review', 'review'),
                      const SizedBox(width: 8),
                      _filterChip('Approved', 'approved'),
                      const SizedBox(width: 8),
                      _filterChip('Rejected', 'rejected'),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: admission.isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryTeal))
                    : apps.isEmpty
                        ? Center(child: Text('No $_filter applications.', style: TextStyle(color: Colors.grey[500])))
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: apps.length,
                            itemBuilder: (context, index) {
                              final app = apps[index];
                              return _buildAppCard(admission, app);
                            },
                          ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _filterChip(String label, String value) {
    final selected = _filter == value;
    return ChoiceChip(
      label: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
          color: selected ? Colors.white : Colors.grey[700])),
      selected: selected,
      onSelected: (_) => setState(() => _filter = value),
      selectedColor: AppTheme.primaryTeal,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: selected ? AppTheme.primaryTeal : const Color(0xFFE5E7EB))),
    );
  }

  Widget _buildAppCard(AdmissionProvider admission, AdmissionApplication app) {
    final statusColor = app.status == AdmissionStatus.pending ? AppTheme.alertAmber :
                        app.status == AdmissionStatus.underReview ? AppTheme.excusedIndigo :
                        app.status == AdmissionStatus.approved ? const Color(0xFF16A34A) :
                        AppTheme.secondaryCoral;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: statusColor.withValues(alpha: 0.1),
                  child: Text(app.childName[0].toUpperCase(), style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(app.childName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Text('${app.gender} · DOB: ${app.childDob.toString().substring(0, 10)}',
                          style: const TextStyle(fontSize: 11, color: Colors.black54)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                  child: Text(app.status.name.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _infoRow('Branch', app.preferredBranchName),
            _infoRow('Class', app.preferredClass),
            _infoRow('Parent', '${app.parentName} · ${app.parentPhone}'),
            _infoRow('Email', app.parentEmail),
            if (app.medicalNotes != null) _infoRow('Medical', app.medicalNotes!),
            if (app.allergies != null) _infoRow('Allergies', app.allergies!),
            if (app.documents.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('Documents: ${app.documents.map((d) => d.fileName).join(", ")}',
                  style: const TextStyle(fontSize: 11, color: Colors.black54)),
            ],
            if (app.reviewerNote != null) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppTheme.bgGrey, borderRadius: BorderRadius.circular(8)),
                child: Text('Note: ${app.reviewerNote}', style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic)),
              ),
            ],
            if (app.status == AdmissionStatus.pending || app.status == AdmissionStatus.underReview) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A), minimumSize: const Size(0, 40)),
                      icon: const Icon(Icons.check_circle, size: 16),
                      label: const Text('Approve'),
                      onPressed: () => _confirmAction(admission, app, AdmissionStatus.approved),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(foregroundColor: AppTheme.secondaryCoral,
                          side: const BorderSide(color: AppTheme.secondaryCoral), minimumSize: const Size(0, 40)),
                      icon: const Icon(Icons.cancel, size: 16),
                      label: const Text('Reject'),
                      onPressed: () => _confirmAction(admission, app, AdmissionStatus.rejected),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (app.status == AdmissionStatus.pending)
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(foregroundColor: AppTheme.excusedIndigo,
                            side: const BorderSide(color: AppTheme.excusedIndigo), minimumSize: const Size(0, 40)),
                        icon: const Icon(Icons.visibility, size: 16),
                        label: const Text('Review'),
                        onPressed: () => admission.updateStatus(app.id, AdmissionStatus.underReview),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[600])),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }

  void _confirmAction(AdmissionProvider admission, AdmissionApplication app, AdmissionStatus status) {
    final title = status == AdmissionStatus.approved ? 'Approve Application' : 'Reject Application';
    final body = status == AdmissionStatus.approved
        ? 'Approve ${app.childName}? They will be added to the ${app.preferredBranchName} — ${app.preferredClass} roster.'
        : 'Reject ${app.childName}\'s application? This cannot be undone.';

    final noteCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(body, style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 12),
            TextField(
              controller: noteCtrl,
              decoration: const InputDecoration(labelText: 'Reviewer note (optional)', hintText: 'e.g. Welcome to DailyKids!'),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: status == AdmissionStatus.approved ? const Color(0xFF16A34A) : AppTheme.secondaryCoral),
            onPressed: () async {
              await admission.updateStatus(app.id, status, note: noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim());

              // If approved, auto-add to attendance roster
              if (status == AdmissionStatus.approved && mounted) {
                final attProvider = context.read<AttendanceProvider>();
                await attProvider.addNewStudent(
                  name: app.childName,
                  parentName: app.parentName,
                  parentPhone: app.parentPhone,
                  parentEmail: app.parentEmail,
                  classroom: app.preferredClass,
                  allergies: app.allergies,
                  notes: app.medicalNotes,
                );
              }

              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${app.childName} ${status.name}!'), backgroundColor: AppTheme.primaryTeal),
                );
              }
            },
            child: Text(status == AdmissionStatus.approved ? 'Approve' : 'Reject', style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
