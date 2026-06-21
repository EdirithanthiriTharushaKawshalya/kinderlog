enum EventType { holiday, termStart, termEnd, celebration, fieldTrip, sportsDay, concert, activityWeek, parentMeeting, other }
enum EventVisibility { all, branch, classGroup, teachers }

/// A calendar event on the school year plan.
class SchoolEvent {
  final String id;
  final String title;
  final String description;
  final EventType type;
  final DateTime date;
  final DateTime? endDate; // For multi-day events
  final String? branchId;
  final String? branchName;
  final String? classId;
  final String? className;
  final EventVisibility visibility;
  final bool isAllDay;
  final String? location;
  final String createdBy;
  final DateTime createdAt;

  SchoolEvent({
    required this.id,
    required this.title,
    this.description = '',
    required this.type,
    required this.date,
    this.endDate,
    this.branchId,
    this.branchName,
    this.classId,
    this.className,
    this.visibility = EventVisibility.all,
    this.isAllDay = true,
    this.location,
    this.createdBy = 'Management',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id, 'title': title, 'description': description,
        'type': type.name, 'date': date.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
        'branchId': branchId, 'branchName': branchName,
        'classId': classId, 'className': className,
        'visibility': visibility.name, 'isAllDay': isAllDay,
        'location': location, 'createdBy': createdBy,
        'createdAt': createdAt.toIso8601String(),
      };

  factory SchoolEvent.fromJson(Map<String, dynamic> json, String docId) {
    return SchoolEvent(
      id: docId, title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: _parseEventType(json['type']),
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      branchId: json['branchId'], branchName: json['branchName'],
      classId: json['classId'], className: json['className'],
      visibility: _parseVisibility(json['visibility']),
      isAllDay: json['isAllDay'] ?? true,
      location: json['location'], createdBy: json['createdBy'] ?? 'Management',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }

  static EventType _parseEventType(String? name) {
    try { return EventType.values.byName(name ?? ''); } catch (_) { return EventType.other; }
  }
  static EventVisibility _parseVisibility(String? name) {
    try { return EventVisibility.values.byName(name ?? ''); } catch (_) { return EventVisibility.all; }
  }
}
