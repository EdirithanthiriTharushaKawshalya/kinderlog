import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:kinderlog_core/kinderlog_core.dart';
import '../../providers/calendar_provider.dart';

import '../../data/models/calendar_model.dart';

/// Interactive school year calendar with upcoming events.
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _focusedMonth;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
    _selectedDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, CalendarProvider>(
      builder: (context, auth, cal, _) {
        final eventsToday = cal.eventsForDate(_selectedDate ?? DateTime.now());
        final upcoming = cal.upcomingEvents;
        final monthEvents = cal.eventsForMonth(_focusedMonth.year, _focusedMonth.month);

        return Scaffold(
          appBar: AppBar(title: const Text('School Calendar')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Month header
                _buildMonthHeader(),
                const SizedBox(height: 8),
                // Day-of-week headers
                _buildDayHeaders(),
                const SizedBox(height: 4),
                // Calendar grid
                _buildCalendarGrid(monthEvents),
                const SizedBox(height: 20),

                // Selected date events
                if (_selectedDate != null) ...[
                  Text(
                    DateFormat('EEEE, MMMM d').format(_selectedDate!),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryTeal),
                  ),
                  const SizedBox(height: 8),
                  if (eventsToday.isEmpty)
                    Container(
                      width: double.infinity, padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE5E7EB))),
                      child: const Text('No events on this day.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                    )
                  else
                    ...eventsToday.map((e) => _eventCard(e)),
                  const SizedBox(height: 24),
                ],

                // Upcoming events
                const Text('Upcoming Events (Next 30 Days)', style: kTitleMedium),
                const SizedBox(height: 8),
                if (upcoming.isEmpty)
                  const Text('No upcoming events.', style: TextStyle(color: Colors.grey))
                else
                  ...upcoming.take(6).map((e) => _eventCard(e)),
              ],
            ),
          ),
          floatingActionButton: (auth.isManagement || auth.isTeacher)
              ? FloatingActionButton(
                  backgroundColor: AppTheme.primaryTeal,
                  onPressed: () => _showAddEventDialog(context, auth, cal),
                  child: const Icon(Icons.add, color: Colors.white),
                )
              : null,
        );
      },
    );
  }

  // ---- Calendar UI ----
  Widget _buildMonthHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => setState(() => _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1)),
        ),
        Text(
          DateFormat('MMMM yyyy').format(_focusedMonth),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () => setState(() => _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1)),
        ),
      ],
    );
  }

  Widget _buildDayHeaders() {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Row(
      children: days.map((d) => Expanded(
        child: Center(child: Text(d, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[500]))),
      )).toList(),
    );
  }

  Widget _buildCalendarGrid(Map<int, List<SchoolEvent>> monthEvents) {
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDay = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    final startOffset = (firstDay.weekday - 1) % 7; // Monday=0
    final totalCells = startOffset + lastDay.day;

    final rows = <TableRow>[];
    List<Widget> cells = [];

    // Empty cells before first day
    for (int i = 0; i < startOffset; i++) {
      cells.add(const SizedBox.shrink());
    }

    for (int day = 1; day <= lastDay.day; day++) {
      final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
      final isSelected = _selectedDate != null &&
          _selectedDate!.year == date.year && _selectedDate!.month == date.month && _selectedDate!.day == date.day;
      final isToday = DateTime.now().year == date.year && DateTime.now().month == date.month && DateTime.now().day == date.day;
      final hasEvents = monthEvents.containsKey(day);

      cells.add(GestureDetector(
        onTap: () => setState(() => _selectedDate = date),
        child: Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryTeal : (isToday ? AppTheme.primaryTeal.withValues(alpha: 0.1) : null),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(6),
          child: Column(
            children: [
              Text('$day', style: TextStyle(
                fontSize: 13, fontWeight: isToday || isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : (isToday ? AppTheme.primaryTeal : Colors.black87),
              )),
              if (hasEvents)
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  width: 6, height: 6,
                  decoration: const BoxDecoration(color: AppTheme.secondaryCoral, shape: BoxShape.circle),
                ),
            ],
          ),
        ),
      ));

      if ((startOffset + day) % 7 == 0 || day == lastDay.day) {
        // Pad last row
        while (cells.length < 7) { cells.add(const SizedBox.shrink()); }
        rows.add(TableRow(children: List.from(cells)));
        cells.clear();
      }
    }

    return Table(
      children: rows,
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
    );
  }

  // ---- Event Card ----
  Widget _eventCard(SchoolEvent e) {
    final iconData = _iconForType(e.type);
    final color = _colorForType(e.type);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(iconData, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(e.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  if (e.description.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(e.description, style: TextStyle(fontSize: 12, color: Colors.grey[600]), maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 11, color: Colors.grey[400]),
                      const SizedBox(width: 3),
                      Text(
                        e.endDate != null
                            ? '${DateFormat('MMM d').format(e.date)} - ${DateFormat('MMM d').format(e.endDate!)}'
                            : DateFormat('MMM d, yyyy').format(e.date),
                        style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                      ),
                      if (e.location != null) ...[
                        const SizedBox(width: 10),
                        Icon(Icons.location_on_outlined, size: 11, color: Colors.grey[400]),
                        const SizedBox(width: 3),
                        Text(e.location!, style: TextStyle(fontSize: 11, color: Colors.grey[400])),
                      ],
                      const Spacer(),
                      if (e.branchName != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(color: AppTheme.bgGrey, borderRadius: BorderRadius.circular(6)),
                          child: Text(e.branchName!, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconForType(EventType t) {
    switch (t) {
      case EventType.holiday: return Icons.beach_access_rounded;
      case EventType.termStart: case EventType.termEnd: return Icons.school_rounded;
      case EventType.celebration: return Icons.celebration_rounded;
      case EventType.fieldTrip: return Icons.directions_bus_rounded;
      case EventType.sportsDay: return Icons.sports_soccer_rounded;
      case EventType.concert: return Icons.music_note_rounded;
      case EventType.activityWeek: return Icons.palette_rounded;
      case EventType.parentMeeting: return Icons.groups_rounded;
      default: return Icons.event_rounded;
    }
  }

  Color _colorForType(EventType t) {
    switch (t) {
      case EventType.holiday: return AppTheme.secondaryCoral;
      case EventType.termStart: case EventType.termEnd: return AppTheme.excusedIndigo;
      case EventType.celebration: return AppTheme.alertAmber;
      case EventType.fieldTrip: return const Color(0xFF16A34A);
      case EventType.sportsDay: return const Color(0xFFEA580C);
      case EventType.concert: return const Color(0xFF9333EA);
      case EventType.activityWeek: return AppTheme.primaryTeal;
      case EventType.parentMeeting: return const Color(0xFF2563EB);
      default: return Colors.grey;
    }
  }

  void _showAddEventDialog(BuildContext context, AuthProvider auth, CalendarProvider cal) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final locCtrl = TextEditingController();
    EventType type = EventType.other;
    DateTime date = DateTime.now();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Add Calendar Event', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Event Title *')),
                const SizedBox(height: 10),
                DropdownButtonFormField<EventType>(
                  value: type,
                  decoration: const InputDecoration(labelText: 'Event Type'),
                  items: EventType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.name))).toList(),
                  onChanged: (v) => setDialogState(() => type = v ?? EventType.other),
                ),
                const SizedBox(height: 10),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(DateFormat('MMM d, yyyy').format(date), style: const TextStyle(fontSize: 14)),
                  leading: const Icon(Icons.calendar_today, size: 20),
                  onTap: () async {
                    final picked = await showDatePicker(context: ctx, initialDate: date, firstDate: DateTime(2020), lastDate: DateTime(2030));
                    if (picked != null) setDialogState(() => date = picked);
                  },
                ),
                const SizedBox(height: 6),
                TextField(controller: locCtrl, decoration: const InputDecoration(labelText: 'Location', hintText: 'Optional')),
                const SizedBox(height: 6),
                TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description', hintText: 'Optional'), maxLines: 2),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryTeal),
              onPressed: () {
                if (titleCtrl.text.trim().isEmpty) return;
                cal.addEvent(title: titleCtrl.text.trim(), type: type, date: date,
                    description: descCtrl.text.trim(), location: locCtrl.text.trim().isEmpty ? null : locCtrl.text.trim(),
                    createdBy: auth.currentUser?.name ?? 'Staff');
                Navigator.pop(ctx);
              },
              child: const Text('Add', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
