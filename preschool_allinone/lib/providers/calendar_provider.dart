import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../data/models/calendar_model.dart';

/// Manages the school year calendar and upcoming events.
class CalendarProvider extends ChangeNotifier {
  List<SchoolEvent> _events = [];
  bool _isLoading = false;

  List<SchoolEvent> get events => _events;
  bool get isLoading => _isLoading;

  /// Events for a specific date.
  List<SchoolEvent> eventsForDate(DateTime date) {
    return _events.where((e) =>
      e.date.year == date.year && e.date.month == date.month && e.date.day == date.day
    ).toList();
  }

  /// Events for a month (for calendar dots).
  Map<int, List<SchoolEvent>> eventsForMonth(int year, int month) {
    final map = <int, List<SchoolEvent>>{};
    for (final e in _events) {
      if (e.date.year == year && e.date.month == month) {
        map.putIfAbsent(e.date.day, () => []).add(e);
      }
    }
    return map;
  }

  /// Upcoming events (next 30 days, sorted).
  List<SchoolEvent> get upcomingEvents {
    final now = DateTime.now();
    final cutoff = now.add(const Duration(days: 30));
    return _events.where((e) =>
      e.date.isAfter(now.subtract(const Duration(days: 1))) && e.date.isBefore(cutoff)
    ).toList()..sort((a, b) => a.date.compareTo(b.date));
  }

  CalendarProvider() {
    _initMockData();
  }

  void _initMockData() {
    final now = DateTime.now();
    final year = now.year;
    final month = now.month;

    _events = [
      // Term dates
      SchoolEvent(id: 'evt_01', title: 'Term 2 Begins', description: 'All students return for Term 2.',
          type: EventType.termStart, date: DateTime(year, 6, 2), visibility: EventVisibility.all),
      SchoolEvent(id: 'evt_02', title: 'Term 2 Ends', description: 'Last day of Term 2. Half-day dismissal.',
          type: EventType.termEnd, date: DateTime(year, 8, 29), visibility: EventVisibility.all),

      // Holidays & celebrations
      SchoolEvent(id: 'evt_03', title: 'Poson Poya Day (Holiday)', description: 'School closed for Poson Poya.',
          type: EventType.holiday, date: DateTime(year, month, month == 6 ? 14 : 10), visibility: EventVisibility.all),
      SchoolEvent(id: 'evt_04', title: 'Mid-Term Break', description: 'No classes. School closed.',
          type: EventType.holiday, date: DateTime(year, month + 1 > 12 ? month - 1 : month + 1, 15),
          endDate: DateTime(year, month + 1 > 12 ? month - 1 : month + 1, 17), visibility: EventVisibility.all),
      SchoolEvent(id: 'evt_05', title: 'Children\'s Day Celebration', description: 'Fun activities, games, and treats for all students!',
          type: EventType.celebration, date: DateTime(year, 10, 1), visibility: EventVisibility.all),

      // Events near current date
      SchoolEvent(id: 'evt_06', title: 'Sports Day — Ambalangoda', description: 'Annual sports meet at Ambalangoda branch. Parents welcome!',
          type: EventType.sportsDay, date: now.add(const Duration(days: 7)), branchId: 'branch_01',
          branchName: 'Ambalangoda', location: 'Ambalangoda Playground', visibility: EventVisibility.branch),
      SchoolEvent(id: 'evt_07', title: 'Field Trip — Botanical Gardens', description: 'FS1 & FS2 students visit the Botanical Gardens. Permission slips required.',
          type: EventType.fieldTrip, date: now.add(const Duration(days: 14)), branchId: 'branch_01',
          branchName: 'Ambalangoda', classId: 'class_01', className: 'FS1', location: 'Hakgala Gardens',
          visibility: EventVisibility.classGroup),
      SchoolEvent(id: 'evt_08', title: 'Art & Craft Week', description: 'A week of special creative activities across all classes.',
          type: EventType.activityWeek, date: now.add(const Duration(days: 21)),
          endDate: now.add(const Duration(days: 25)), visibility: EventVisibility.all),
      SchoolEvent(id: 'evt_09', title: 'Annual Concert Rehearsal', description: 'Practice for the upcoming annual concert.',
          type: EventType.concert, date: now.add(const Duration(days: 28)), location: 'School Hall',
          visibility: EventVisibility.all),
      SchoolEvent(id: 'evt_10', title: 'Parent-Teacher Meeting — FS1', description: 'Individual progress discussions for FS1 parents.',
          type: EventType.parentMeeting, date: now.add(const Duration(days: 5)), branchId: 'branch_01',
          branchName: 'Ambalangoda', classId: 'class_01', className: 'FS1', visibility: EventVisibility.classGroup),
    ];
  }

  /// Add a new event (management/teacher).
  Future<void> addEvent({
    required String title,
    required EventType type,
    required DateTime date,
    String description = '',
    DateTime? endDate,
    String? branchId,
    String? branchName,
    String? classId,
    String? className,
    EventVisibility visibility = EventVisibility.all,
    String? location,
    String createdBy = 'Teacher',
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      _events.add(SchoolEvent(
        id: 'evt_${const Uuid().v4().substring(0, 6)}',
        title: title, type: type, date: date, description: description,
        endDate: endDate, branchId: branchId, branchName: branchName,
        classId: classId, className: className, visibility: visibility,
        location: location, createdBy: createdBy,
      ));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
