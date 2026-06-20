import 'preschool_model.dart';

class Student {
  final String id;
  final String name;
  final String parentName;
  final String parentPhone;
  final String? parentEmail;
  final String classroom;
  final String branchId;
  final String? photoUrl;
  final String? allergies;
  final String? notes;
  final List<Guardian> guardians;

  Student({
    required this.id,
    required this.name,
    required this.parentName,
    required this.parentPhone,
    this.parentEmail,
    required this.classroom,
    this.branchId = '',
    this.photoUrl,
    this.allergies,
    this.notes,
    this.guardians = const [],
  });

  /// Convenience: first guardian's email (or the legacy parentEmail field).
  String? get primaryGuardianEmail =>
      guardians.isNotEmpty ? guardians.first.email : parentEmail;

  Student copyWith({
    String? id,
    String? name,
    String? parentName,
    String? parentPhone,
    String? parentEmail,
    String? classroom,
    String? branchId,
    String? photoUrl,
    String? allergies,
    String? notes,
    List<Guardian>? guardians,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      parentName: parentName ?? this.parentName,
      parentPhone: parentPhone ?? this.parentPhone,
      parentEmail: parentEmail ?? this.parentEmail,
      classroom: classroom ?? this.classroom,
      branchId: branchId ?? this.branchId,
      photoUrl: photoUrl ?? this.photoUrl,
      allergies: allergies ?? this.allergies,
      notes: notes ?? this.notes,
      guardians: guardians ?? this.guardians,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'parentName': parentName,
      'parentPhone': parentPhone,
      'parentEmail': parentEmail,
      'classroom': classroom,
      'branchId': branchId,
      'photoUrl': photoUrl,
      'allergies': allergies,
      'notes': notes,
      'guardians': guardians.map((g) => g.toJson()).toList(),
    };
  }

  factory Student.fromJson(Map<String, dynamic> json, String documentId) {
    final guardiansList = (json['guardians'] as List<dynamic>?)
            ?.map((g) => Guardian.fromJson(g as Map<String, dynamic>, g['id'] ?? ''))
            .toList() ??
        [];
    return Student(
      id: documentId,
      name: json['name'] ?? '',
      parentName: json['parentName'] ?? '',
      parentPhone: json['parentPhone'] ?? '',
      parentEmail: json['parentEmail'],
      classroom: json['classroom'] ?? '',
      branchId: json['branchId'] ?? '',
      photoUrl: json['photoUrl'],
      allergies: json['allergies'],
      notes: json['notes'],
      guardians: guardiansList,
    );
  }
}
