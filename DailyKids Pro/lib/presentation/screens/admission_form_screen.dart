import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kinderlog_core/kinderlog_core.dart';
import '../../providers/admission_provider.dart';

import '../../data/models/admission_model.dart';

/// Parent-facing online admission application form.
class AdmissionFormScreen extends StatefulWidget {
  const AdmissionFormScreen({super.key});

  @override
  State<AdmissionFormScreen> createState() => _AdmissionFormScreenState();
}

class _AdmissionFormScreenState extends State<AdmissionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  int _step = 0;

  // Step 1: Child info
  final _childNameCtrl = TextEditingController();
  final _childDobCtrl = TextEditingController();
  String _gender = 'Male';
  String _preferredBranch = 'branch_01';
  String _preferredClass = 'FS1';

  // Step 2: Parent info
  final _parentNameCtrl = TextEditingController();
  final _parentPhoneCtrl = TextEditingController();
  final _parentEmailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  // Step 3: Medical & Previous
  final _previousSchoolCtrl = TextEditingController();
  final _medicalCtrl = TextEditingController();
  final _allergiesCtrl = TextEditingController();

  // Step 4: Document upload (mock)
  final List<UploadedDocument> _documents = [];

  @override
  void dispose() {
    _childNameCtrl.dispose(); _childDobCtrl.dispose();
    _parentNameCtrl.dispose(); _parentPhoneCtrl.dispose();
    _parentEmailCtrl.dispose(); _addressCtrl.dispose();
    _previousSchoolCtrl.dispose(); _medicalCtrl.dispose();
    _allergiesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final branches = auth.branches;
    final classes = auth.classes;
    final branch = branches.where((b) => b.id == _preferredBranch).firstOrNull;
    final branchClasses = classes.where((c) => c.branchId == _preferredBranch).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(_step == 3 ? 'Review & Submit' : 'Step ${_step + 1} of 4'),
      ),
      body: Consumer<AdmissionProvider>(
        builder: (context, admission, _) {
          return Form(
            key: _formKey,
            child: Column(
              children: [
                // Step indicator
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Row(
                    children: List.generate(4, (i) => Expanded(
                      child: Container(
                        height: 4, margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          color: i <= _step ? AppTheme.primaryTeal : Colors.grey[200],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    )),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: _step == 0 ? _stepChildInfo(branches, branchClasses) :
                           _step == 1 ? _stepParentInfo() :
                           _step == 2 ? _stepMedicalDocs() :
                           _stepReview(branch, admission),
                  ),
                ),
                // Navigation buttons
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      if (_step > 0)
                        Expanded(
                          child: OutlinedButton(onPressed: () => setState(() => _step--), child: const Text('Back')),
                        ),
                      if (_step > 0) const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: admission.isLoading ? null : () => _handleNext(admission),
                          child: admission.isLoading
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : Text(_step == 3 ? 'Submit Application' : 'Next'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _stepChildInfo(List branches, List branchClasses) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Child's Information", style: kTitleLarge),
        const SizedBox(height: 8),
        const Text('Tell us about your child.', style: kBodyMedium),
        const SizedBox(height: 24),
        TextFormField(
          controller: _childNameCtrl,
          decoration: const InputDecoration(labelText: "Child's Full Name *", prefixIcon: Icon(Icons.child_care)),
          validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _childDobCtrl,
          decoration: const InputDecoration(labelText: 'Date of Birth *', prefixIcon: Icon(Icons.calendar_today), hintText: 'YYYY-MM-DD'),
          validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(
          value: _gender,
          decoration: const InputDecoration(labelText: 'Gender *', prefixIcon: Icon(Icons.person)),
          items: ['Male', 'Female'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
          onChanged: (v) => setState(() => _gender = v ?? 'Male'),
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(
          value: _preferredBranch,
          decoration: const InputDecoration(labelText: 'Preferred Branch *', prefixIcon: Icon(Icons.location_city)),
          items: branches.map<DropdownMenuItem<String>>((b) =>
              DropdownMenuItem(value: b.id, child: Text(b.name))).toList(),
          onChanged: (v) => setState(() { _preferredBranch = v ?? 'branch_01'; _preferredClass = branchClasses.isNotEmpty ? branchClasses.first.name : 'FS1'; }),
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(
          value: branchClasses.any((c) => c.name == _preferredClass) ? _preferredClass : (branchClasses.isNotEmpty ? branchClasses.first.name : 'FS1'),
          decoration: const InputDecoration(labelText: 'Preferred Class *', prefixIcon: Icon(Icons.meeting_room)),
          items: branchClasses.map<DropdownMenuItem<String>>((c) => DropdownMenuItem<String>(value: c.name, child: Text(c.name))).toList(),
          onChanged: (v) => setState(() => _preferredClass = v ?? 'FS1'),
        ),
      ],
    );
  }

  Widget _stepParentInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Parent / Guardian Info', style: kTitleLarge),
        const SizedBox(height: 24),
        TextFormField(
          controller: _parentNameCtrl,
          decoration: const InputDecoration(labelText: 'Full Name *', prefixIcon: Icon(Icons.person)),
          validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _parentPhoneCtrl,
          decoration: const InputDecoration(labelText: 'Phone Number *', prefixIcon: Icon(Icons.phone)),
          keyboardType: TextInputType.phone,
          validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _parentEmailCtrl,
          decoration: const InputDecoration(labelText: 'Email Address *', prefixIcon: Icon(Icons.email)),
          keyboardType: TextInputType.emailAddress,
          validator: (v) => v == null || v.trim().isEmpty || !v.contains('@') ? 'Valid email required' : null,
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _addressCtrl,
          decoration: const InputDecoration(labelText: 'Home Address', prefixIcon: Icon(Icons.home)),
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _stepMedicalDocs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Medical & Documents', style: kTitleLarge),
        const SizedBox(height: 24),
        TextFormField(
          controller: _previousSchoolCtrl,
          decoration: const InputDecoration(labelText: 'Previous School / Daycare', prefixIcon: Icon(Icons.school)),
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _medicalCtrl,
          decoration: const InputDecoration(labelText: 'Medical Conditions / Notes', prefixIcon: Icon(Icons.medical_services)),
          maxLines: 2,
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _allergiesCtrl,
          decoration: const InputDecoration(labelText: 'Allergies', prefixIcon: Icon(Icons.warning_amber_outlined)),
        ),
        const SizedBox(height: 24),
        const Text('Required Documents', style: kTitleMedium),
        const SizedBox(height: 4),
        const Text('Tap to simulate document upload (mock)', style: kBodyMedium),
        const SizedBox(height: 12),
        ...['Birth Certificate', 'Medical Records', 'Immunization History'].map((label) {
          final uploaded = _documents.any((d) => d.fileName == label);
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Icon(uploaded ? Icons.check_circle : Icons.upload_file, color: uploaded ? const Color(0xFF16A34A) : Colors.grey),
              title: Text(label, style: TextStyle(fontWeight: FontWeight.w500, color: uploaded ? const Color(0xFF16A34A) : Colors.black87)),
              subtitle: uploaded ? const Text('Uploaded ✓', style: TextStyle(fontSize: 11, color: Color(0xFF16A34A))) : null,
              trailing: uploaded ? IconButton(
                icon: const Icon(Icons.delete_outline, size: 18),
                onPressed: () => setState(() => _documents.removeWhere((d) => d.fileName == label)),
              ) : null,
              onTap: uploaded ? null : () => setState(() {
                _documents.add(UploadedDocument(
                  id: 'doc_${_documents.length + 1}',
                  fileName: label,
                  fileType: label.contains('Birth') ? 'birth_cert' : label.contains('Medical') ? 'medical' : 'immunization',
                  fileUrl: 'mock://${label.toLowerCase().replaceAll(' ', '_')}.pdf',
                ));
              }),
            ),
          );
        }),
      ],
    );
  }

  Widget _stepReview(dynamic branch, AdmissionProvider admission) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Review Your Application', style: kTitleLarge),
        const SizedBox(height: 16),
        _reviewCard('Child', [
          'Name: ${_childNameCtrl.text}',
          'DOB: ${_childDobCtrl.text}',
          'Gender: $_gender',
          'Branch: ${branch?.name ?? "N/A"}',
          'Class: $_preferredClass',
        ]),
        const SizedBox(height: 12),
        _reviewCard('Parent', [
          'Name: ${_parentNameCtrl.text}',
          'Phone: ${_parentPhoneCtrl.text}',
          'Email: ${_parentEmailCtrl.text}',
          'Address: ${_addressCtrl.text}',
        ]),
        if (_medicalCtrl.text.isNotEmpty || _allergiesCtrl.text.isNotEmpty) ...[
          const SizedBox(height: 12),
          _reviewCard('Medical', [
            if (_medicalCtrl.text.isNotEmpty) 'Medical: ${_medicalCtrl.text}',
            if (_allergiesCtrl.text.isNotEmpty) 'Allergies: ${_allergiesCtrl.text}',
          ]),
        ],
        const SizedBox(height: 12),
        _reviewCard('Documents', [
          '${_documents.length} document(s) uploaded',
          ..._documents.map((d) => '  ✓ ${d.fileName}'),
        ]),
      ],
    );
  }

  Widget _reviewCard(String title, List<String> lines) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE5E7EB))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primaryTeal)),
          const SizedBox(height: 6),
          ...lines.map((l) => Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Text(l, style: const TextStyle(fontSize: 13, color: Colors.black87)),
          )),
        ],
      ),
    );
  }

  void _handleNext(AdmissionProvider admission) async {
    if (_step < 3) {
      setState(() => _step++);
    } else {
      // Submit
      final branches = context.read<AuthProvider>().branches;
      final branchName = branches.where((b) => b.id == _preferredBranch).firstOrNull?.name ?? '';

      await admission.submitApplication(
        childName: _childNameCtrl.text.trim(),
        childDob: DateTime.tryParse(_childDobCtrl.text.trim()) ?? DateTime(2020, 1, 1),
        gender: _gender,
        preferredBranchId: _preferredBranch,
        preferredBranchName: branchName,
        preferredClass: _preferredClass,
        parentName: _parentNameCtrl.text.trim(),
        parentPhone: _parentPhoneCtrl.text.trim(),
        parentEmail: _parentEmailCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        previousSchool: _previousSchoolCtrl.text.trim().isEmpty ? null : _previousSchoolCtrl.text.trim(),
        medicalNotes: _medicalCtrl.text.trim().isEmpty ? null : _medicalCtrl.text.trim(),
        allergies: _allergiesCtrl.text.trim().isEmpty ? null : _allergiesCtrl.text.trim(),
        documents: _documents,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Application submitted successfully! 🎉'), backgroundColor: AppTheme.primaryTeal),
        );
        Navigator.pop(context);
      }
    }
  }
}
