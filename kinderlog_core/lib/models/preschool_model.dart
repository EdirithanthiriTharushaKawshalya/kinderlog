/// Represents the top-level Preschool / Management entity.
class Preschool {
  final String id;
  final String name;
  final String ownerEmail;
  final String? logoUrl;
  final DateTime createdAt;

  Preschool({
    required this.id,
    required this.name,
    required this.ownerEmail,
    this.logoUrl,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'ownerEmail': ownerEmail,
        'logoUrl': logoUrl,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Preschool.fromJson(Map<String, dynamic> json, String docId) {
    return Preschool(
      id: docId,
      name: json['name'] ?? '',
      ownerEmail: json['ownerEmail'] ?? '',
      logoUrl: json['logoUrl'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Preschool copyWith({
    String? name,
    String? logoUrl,
  }) {
    return Preschool(
      id: id,
      name: name ?? this.name,
      ownerEmail: ownerEmail,
      logoUrl: logoUrl ?? this.logoUrl,
      createdAt: createdAt,
    );
  }
}

/// Represents a physical Branch of the preschool.
class Branch {
  final String id;
  final String preschoolId;
  final String name;
  final String location;
  final DateTime createdAt;

  Branch({
    required this.id,
    required this.preschoolId,
    required this.name,
    this.location = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'preschoolId': preschoolId,
        'name': name,
        'location': location,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Branch.fromJson(Map<String, dynamic> json, String docId) {
    return Branch(
      id: docId,
      preschoolId: json['preschoolId'] ?? '',
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Branch copyWith({String? name, String? location}) {
    return Branch(
      id: id,
      preschoolId: preschoolId,
      name: name ?? this.name,
      location: location ?? this.location,
      createdAt: createdAt,
    );
  }
}

/// Represents a Class within a Branch.
class ClassModel {
  final String id;
  final String branchId;
  final String name;
  final String? teacherId; // assigned primary teacher
  final DateTime createdAt;

  ClassModel({
    required this.id,
    required this.branchId,
    required this.name,
    this.teacherId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'branchId': branchId,
        'name': name,
        'teacherId': teacherId,
        'createdAt': createdAt.toIso8601String(),
      };

  factory ClassModel.fromJson(Map<String, dynamic> json, String docId) {
    return ClassModel(
      id: docId,
      branchId: json['branchId'] ?? '',
      name: json['name'] ?? '',
      teacherId: json['teacherId'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  ClassModel copyWith({String? name, String? teacherId}) {
    return ClassModel(
      id: id,
      branchId: branchId,
      name: name ?? this.name,
      teacherId: teacherId ?? this.teacherId,
      createdAt: createdAt,
    );
  }
}

/// Represents a user of the app (management, teacher, or parent).
enum UserRole { management, teacher, parent }

/// Represents a guardian/parent linked to a child.
class Guardian {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String relationship; // e.g. 'Mother', 'Father', 'Grandmother'

  Guardian({
    required this.id,
    required this.name,
    required this.email,
    this.phone = '',
    this.relationship = 'Parent',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'relationship': relationship,
      };

  factory Guardian.fromJson(Map<String, dynamic> json, String docId) {
    return Guardian(
      id: docId,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      relationship: json['relationship'] ?? 'Parent',
    );
  }

  Guardian copyWith({
    String? name,
    String? email,
    String? phone,
    String? relationship,
  }) {
    return Guardian(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      relationship: relationship ?? this.relationship,
    );
  }
}

class AppUser {
  final String id;
  final String email;
  final String name;
  final UserRole role;
  final String preschoolId;
  final String? branchId; // teacher belongs to one branch
  final String? pinnedClassId; // pinned class for quick access
  final List<String> studentIds; // parent: linked child IDs
  final DateTime createdAt;

  AppUser({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.preschoolId,
    this.branchId,
    this.pinnedClassId,
    this.studentIds = const [],
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
        'role': role.name,
        'preschoolId': preschoolId,
        'branchId': branchId,
        'pinnedClassId': pinnedClassId,
        'studentIds': studentIds,
        'createdAt': createdAt.toIso8601String(),
      };

  factory AppUser.fromJson(Map<String, dynamic> json, String docId) {
    return AppUser(
      id: docId,
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      role: _parseRole(json['role']),
      preschoolId: json['preschoolId'] ?? '',
      branchId: json['branchId'],
      pinnedClassId: json['pinnedClassId'],
      studentIds: (json['studentIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  static UserRole _parseRole(String? roleStr) {
    try {
      return UserRole.values.byName(roleStr ?? 'teacher');
    } catch (_) {
      return UserRole.teacher;
    }
  }

  AppUser copyWith({
    String? name,
    String? branchId,
    String? pinnedClassId,
    List<String>? studentIds,
  }) {
    return AppUser(
      id: id,
      email: email,
      name: name ?? this.name,
      role: role,
      preschoolId: preschoolId,
      branchId: branchId ?? this.branchId,
      pinnedClassId: pinnedClassId ?? this.pinnedClassId,
      studentIds: studentIds ?? this.studentIds,
      createdAt: createdAt,
    );
  }
}
