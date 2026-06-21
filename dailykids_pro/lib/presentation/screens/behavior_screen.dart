import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:kinderlog_core/kinderlog_core.dart';
import '../../providers/behavior_provider.dart';

import '../../providers/attendance_provider.dart';
import '../../data/models/behavior_model.dart';

/// Confidential behavioral & discipline logging with parent collaboration.
class BehaviorScreen extends StatefulWidget {
  final bool hideAppBar;
  const BehaviorScreen({super.key, this.hideAppBar = false});

  @override
  State<BehaviorScreen> createState() => _BehaviorScreenState();
}

class _BehaviorScreenState extends State<BehaviorScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BehaviorProvider>(
      builder: (context, behavior, _) {
        return Scaffold(
          appBar: widget.hideAppBar
              ? null
              : AppBar(
                  title: const Text('Behavior Logs'),
                  bottom: TabBar(
                    controller: _tabController,
                    indicatorColor: AppTheme.primaryTeal,
                    labelColor: AppTheme.primaryTeal,
                    unselectedLabelColor: Colors.grey,
                    tabs: [
                      Tab(text: 'Active (${behavior.activeLogs.length})'),
                      Tab(text: 'Resolved (${behavior.resolvedLogs.length})'),
                    ],
                  ),
                ),
          body: widget.hideAppBar
              ? Column(
                  children: [
                    TabBar(
                      controller: _tabController,
                      indicatorColor: AppTheme.primaryTeal,
                      labelColor: AppTheme.primaryTeal,
                      unselectedLabelColor: Colors.grey,
                      tabs: [
                        Tab(text: 'Active (${behavior.activeLogs.length})'),
                        Tab(text: 'Resolved (${behavior.resolvedLogs.length})'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _logsList(behavior.activeLogs, behavior),
                          _logsList(behavior.resolvedLogs, behavior),
                        ],
                      ),
                    ),
                  ],
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _logsList(behavior.activeLogs, behavior),
                    _logsList(behavior.resolvedLogs, behavior),
                  ],
                ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: AppTheme.primaryTeal,
            onPressed: () => _showReportDialog(context, behavior),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      },
    );
  }

  Widget _logsList(List<BehaviorLog> logs, BehaviorProvider behavior) {
    if (logs.isEmpty) {
      return Center(child: Text('No logs.', style: TextStyle(color: Colors.grey[500])));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: logs.length,
      itemBuilder: (context, index) => _logCard(logs[index], behavior),
    );
  }

  Widget _logCard(BehaviorLog log, BehaviorProvider behavior) {
    final sevColor = _severityColor(log.severity);
    final statusColor = log.status == BehaviorStatus.open ? AppTheme.alertAmber
        : log.status == BehaviorStatus.underReview ? AppTheme.excusedIndigo
        : log.status == BehaviorStatus.escalated ? AppTheme.secondaryCoral : const Color(0xFF16A34A);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      child: InkWell(
        onTap: () => _showDetail(context, log, behavior),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(log.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text(log.status.name, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(log.studentName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              Text('${log.classroom} · Reported by ${log.reportedBy}', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
              const SizedBox(height: 6),
              Row(
                children: [
                  _sevBadge(log.severity),
                  const SizedBox(width: 10),
                  Icon(Icons.calendar_today, size: 11, color: Colors.grey[400]),
                  const SizedBox(width: 3),
                  Text(DateFormat('MMM d, yyyy').format(log.reportedAt), style: TextStyle(fontSize: 10, color: Colors.grey[400])),
                  const Spacer(),
                  if (log.interventions.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: AppTheme.bgGrey, borderRadius: BorderRadius.circular(6)),
                      child: Text('${log.interventions.length} notes', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                    ),
                  const SizedBox(width: 6),
                  Icon(Icons.visibility, size: 12, color: log.isSharedWithParent ? const Color(0xFF16A34A) : Colors.grey[300]),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sevBadge(BehaviorSeverity s) {
    final color = _severityColor(s);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(s.name, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
    );
  }

  Color _severityColor(BehaviorSeverity s) {
    switch (s) {
      case BehaviorSeverity.low: return AppTheme.primaryTeal;
      case BehaviorSeverity.moderate: return AppTheme.alertAmber;
      case BehaviorSeverity.high: return AppTheme.secondaryCoral;
      case BehaviorSeverity.critical: return const Color(0xFF991B1B);
    }
  }

  // ---- Detail View ----
  void _showDetail(BuildContext context, BehaviorLog log, BehaviorProvider behavior) {
    Navigator.push(context, MaterialPageRoute(builder: (_) =>
      _BehaviorDetailScreen(log: log),
    ));
  }

  void _showReportDialog(BuildContext context, BehaviorProvider behavior) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    BehaviorSeverity severity = BehaviorSeverity.low;
    bool shareParent = false;

    final students = context.read<AttendanceProvider>().branchStudents;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Report Incident', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Student *'),
                  items: students.map<DropdownMenuItem<String>>((s) =>
                      DropdownMenuItem(value: s.id, child: Text('${s.name} (${s.classroom})'))).toList(),
                  onChanged: (v) {},
                ),
                const SizedBox(height: 10),
                TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Incident Title *')),
                const SizedBox(height: 10),
                DropdownButtonFormField<BehaviorSeverity>(
                  value: severity,
                  decoration: const InputDecoration(labelText: 'Severity'),
                  items: BehaviorSeverity.values.map((s) => DropdownMenuItem(value: s, child: Text(s.name))).toList(),
                  onChanged: (v) => setDialogState(() => severity = v ?? BehaviorSeverity.low),
                ),
                const SizedBox(height: 10),
                TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description *'), maxLines: 3),
                const SizedBox(height: 10),
                SwitchListTile(
                  title: const Text('Share with parent immediately', style: TextStyle(fontSize: 14)),
                  value: shareParent, onChanged: (v) => setDialogState(() => shareParent = v),
                  dense: true, contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryTeal),
              onPressed: () {
                if (titleCtrl.text.trim().isEmpty || descCtrl.text.trim().isEmpty) return;
                final s = students.isNotEmpty ? students.first : null;
                if (s == null) return;
                behavior.reportIncident(
                  studentId: s.id, studentName: s.name, classroom: s.classroom,
                  reportedBy: 'Teacher', reporterId: 'current',
                  title: titleCtrl.text.trim(), description: descCtrl.text.trim(),
                  severity: severity, occurredAt: DateTime.now(),
                  shareWithParent: shareParent,
                );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Incident reported.'), backgroundColor: AppTheme.primaryTeal));
              },
              child: const Text('Report', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

// ---- Behavior Detail Screen ----
class _BehaviorDetailScreen extends StatefulWidget {
  final BehaviorLog log;
  const _BehaviorDetailScreen({required this.log});

  @override
  State<_BehaviorDetailScreen> createState() => _BehaviorDetailScreenState();
}

class _BehaviorDetailScreenState extends State<_BehaviorDetailScreen> {
  late BehaviorLog _log;

  @override
  void initState() {
    super.initState();
    _log = widget.log;
  }

  @override
  Widget build(BuildContext context) {
    final behavior = context.watch<BehaviorProvider>();
    // Refresh log from provider
    final current = behavior.logs.where((l) => l.id == _log.id).firstOrNull;
    if (current != null) _log = current;

    final sevColor = _sevColor(_log.severity);

    return Scaffold(
      appBar: AppBar(title: Text(_log.studentName)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Incident header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE5E7EB))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    _badge(_log.severity.name, sevColor),
                    const SizedBox(width: 8),
                    _badge(_log.status.name, _statusColor(_log.status)),
                    const Spacer(),
                    if (!_log.isSharedWithParent)
                      TextButton.icon(
                        icon: const Icon(Icons.share, size: 14),
                        label: const Text('Share', style: TextStyle(fontSize: 12)),
                        onPressed: () {
                          context.read<BehaviorProvider>().shareWithParent(_log.id);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Shared with parent.'), backgroundColor: AppTheme.primaryTeal));
                        },
                      )
                    else
                      _badge('Shared with parent', const Color(0xFF16A34A)),
                  ]),
                  const SizedBox(height: 12),
                  Text(_log.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 6),
                  Text('${_log.classroom} · Reported by ${_log.reportedBy}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  const SizedBox(height: 4),
                  Text('Occurred: ${DateFormat('MMM d, yyyy – hh:mm a').format(_log.occurredAt)}',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                  const Divider(height: 24),
                  Text(_log.description, style: const TextStyle(fontSize: 14, height: 1.5)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Intervention notes
            const Text('Intervention Notes', style: kTitleMedium),
            const SizedBox(height: 8),
            if (_log.interventions.isEmpty)
              Container(
                width: double.infinity, padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE5E7EB))),
                child: const Text('No intervention notes yet.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
              )
            else
              ..._log.interventions.map((n) => Card(
                margin: const EdgeInsets.only(bottom: 8), elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        CircleAvatar(radius: 14, backgroundColor: AppTheme.primaryTeal.withValues(alpha: 0.08),
                            child: Text(n.authorName[0].toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal))),
                        const SizedBox(width: 8),
                        Text(n.authorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(width: 8),
                        _badge(n.authorRole, AppTheme.primaryTeal),
                        const Spacer(),
                        Text(DateFormat('MMM d').format(n.createdAt), style: TextStyle(fontSize: 10, color: Colors.grey[400])),
                      ]),
                      const SizedBox(height: 8),
                      Text(n.note, style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
              )),

            const SizedBox(height: 16),
            // Add intervention note
            if (_log.status != BehaviorStatus.resolved) ...[
              _addInterventionField(context, behavior),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A), minimumSize: const Size(0, 44)),
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  label: const Text('Mark as Resolved'),
                  onPressed: () {
                    behavior.resolveLog(_log.id);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Log resolved.'), backgroundColor: AppTheme.primaryTeal));
                  },
                ),
              ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _addInterventionField(BuildContext context, BehaviorProvider behavior) {
    final ctrl = TextEditingController();
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: ctrl,
            decoration: InputDecoration(
              hintText: 'Add an intervention note...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryTeal, minimumSize: const Size(44, 44)),
          onPressed: () {
            if (ctrl.text.trim().isEmpty) return;
            behavior.addIntervention(
              behaviorLogId: _log.id, authorName: 'Teacher',
              authorRole: 'teacher', note: ctrl.text.trim(),
            );
            ctrl.clear();
          },
          child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
        ),
      ],
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
    );
  }

  Color _sevColor(BehaviorSeverity s) {
    switch (s) {
      case BehaviorSeverity.low: return AppTheme.primaryTeal;
      case BehaviorSeverity.moderate: return AppTheme.alertAmber;
      case BehaviorSeverity.high: return AppTheme.secondaryCoral;
      case BehaviorSeverity.critical: return const Color(0xFF991B1B);
    }
  }

  Color _statusColor(BehaviorStatus s) {
    switch (s) {
      case BehaviorStatus.open: return AppTheme.alertAmber;
      case BehaviorStatus.underReview: return AppTheme.excusedIndigo;
      case BehaviorStatus.resolved: return const Color(0xFF16A34A);
      case BehaviorStatus.escalated: return AppTheme.secondaryCoral;
    }
  }
}
