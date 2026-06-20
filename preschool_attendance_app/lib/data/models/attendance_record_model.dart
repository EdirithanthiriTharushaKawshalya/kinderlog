enum AttendanceStatus { present, absent, excused, tardy }

class AttendanceRecord {
  final String id;
  final String studentId;
  final String date; // Format: YYYY-MM-DD
  final AttendanceStatus status;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final String markedBy;
  final String? note;

  AttendanceRecord({
    required this.id,
    required this.studentId,
    required this.date,
    required this.status,
    this.checkInTime,
    this.checkOutTime,
    required this.markedBy,
    this.note,
  });

  AttendanceRecord copyWith({
    String? id,
    String? studentId,
    String? date,
    AttendanceStatus? status,
    DateTime? checkInTime,
    DateTime? checkOutTime,
    String? markedBy,
    String? note,
  }) {
    return AttendanceRecord(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      date: date ?? this.date,
      status: status ?? this.status,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      markedBy: markedBy ?? this.markedBy,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'date': date,
      'status': status.toString().split('.').last, // Serializes to string name (e.g. 'present')
      'checkInTime': checkInTime?.toIso8601String(),
      'checkOutTime': checkOutTime?.toIso8601String(),
      'markedBy': markedBy,
      'note': note,
    };
  }

  factory AttendanceRecord.fromJson(Map<String, dynamic> json, String documentId) {
    // Parse status securely
    AttendanceStatus parsedStatus;
    try {
      parsedStatus = AttendanceStatus.values.byName(json['status'] ?? 'present');
    } catch (_) {
      parsedStatus = AttendanceStatus.present;
    }

    return AttendanceRecord(
      id: documentId,
      studentId: json['studentId'] ?? '',
      date: json['date'] ?? '',
      status: parsedStatus,
      checkInTime: json['checkInTime'] != null ? DateTime.parse(json['checkInTime']) : null,
      checkOutTime: json['checkOutTime'] != null ? DateTime.parse(json['checkOutTime']) : null,
      markedBy: json['markedBy'] ?? 'Staff',
      note: json['note'],
    );
  }
}
