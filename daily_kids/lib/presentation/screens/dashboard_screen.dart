import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kinderlog_core/kinderlog_core.dart';
import '../../data/models/attendance_record_model.dart';
import '../../providers/attendance_provider.dart';
import '../widgets/summary_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, AttendanceProvider>(
      builder: (context, auth, provider, child) {
        if (provider.isLoading && provider.students.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.primaryTeal));
        }

        final uncheckedStudents = provider.filteredStudents.where((s) {
          final rec = provider.getRecordForStudent(s.id);
          return rec == null;
        }).toList();

        return RefreshIndicator(
          onRefresh: () async {
            provider.initialize(auth);
          },
          color: AppTheme.primaryTeal,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Welcome & branch info
                _buildWelcomeHeader(auth, provider),
                const SizedBox(height: 16),

                // 1b. Management: Per-branch overview cards
                if (auth.isManagement) ...[
                  _buildBranchOverviewCards(auth, provider),
                  const SizedBox(height: 16),
                ],

                // 2. Attendance Analytics (Moved from below to top)
                const Text('Attendance Analytics', style: kTitleMedium),
                const SizedBox(height: 8),
                _buildTimeframeAnalytics(provider),
                const SizedBox(height: 24),

                // 3. Today's Summary
                const Text('Today\'s Summary', style: kTitleMedium),
                const SizedBox(height: 8),
                _buildMetricsGrid(provider),
                const SizedBox(height: 24),

                // 4. Unmarked children quick actions
                _buildUncheckedSection(provider, uncheckedStudents),
                const SizedBox(height: 24),

                // 5. Top & Low Attenders
                _buildTopLowAttenders(context, provider),
                const SizedBox(height: 24),

                // 6. Parent Absence Monitoring
                _buildParentMonitoring(context, provider),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Management: Per-branch overview cards ─────────────────
  Widget _buildBranchOverviewCards(AuthProvider auth, AttendanceProvider provider) {
    final branches = auth.branches;
    if (branches.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: branches.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final branch = branches[index];
          final branchStudents = provider.students.where((s) => s.branchId == branch.id).toList();
          final totalStudents = branchStudents.length;
          final todayPresent = branchStudents.where((s) {
            final r = provider.getRecordForStudent(s.id);
            return r != null && (r.status == AttendanceStatus.present || r.status == AttendanceStatus.tardy);
          }).length;
          final rate = totalStudents > 0 ? (todayPresent / totalStudents * 100) : 0.0;

          return GestureDetector(
            onTap: () => provider.setBranchFilter(branch.id),
            child: Container(
              width: 170,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.school_rounded, color: Colors.black87, size: 18),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(branch.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${rate.toStringAsFixed(0)}% Today',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: rate >= 80 ? AppTheme.primaryTeal : rate >= 60 ? AppTheme.alertAmber : AppTheme.secondaryCoral,
                    ),
                  ),
                  Text(
                    '$totalStudents students',
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeHeader(AuthProvider auth, AttendanceProvider provider) {
    final isManagement = auth.isManagement;
    final branchName = provider.isSubstituteMode
        ? provider.substituteBranchName ?? ''
        : auth.currentBranch?.name;
    final userName = auth.currentUser?.name ?? 'Teacher';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Good morning, $userName',
          style: isManagement
              ? kTitleMedium.copyWith(color: Colors.black, fontSize: 20)
              : kTitleLarge.copyWith(color: Colors.black),
        ),
        const SizedBox(height: 2),
        if (isManagement)
          Text(
            branchName != null ? 'Viewing: $branchName' : 'All Branches — School-wide Overview',
            style: kBodyMedium,
          )
        else
          Text(
            '$branchName — ${provider.selectedClassFilter}',
            style: kBodyMedium,
          ),
      ],
    );
  }

  Widget _buildMetricsGrid(AttendanceProvider provider) {
    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 2.1,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        SummaryCard(
          title: 'Present',
          value: provider.presentCount.toString(),
          icon: Icons.check_circle_rounded,
          color: AppTheme.primaryTeal,
        ),
        SummaryCard(
          title: 'Absent',
          value: provider.absentCount.toString(),
          icon: Icons.cancel_rounded,
          color: AppTheme.secondaryCoral,
        ),
        SummaryCard(
          title: 'Tardy / Late',
          value: provider.tardyCount.toString(),
          icon: Icons.watch_later_rounded,
          color: AppTheme.alertAmber,
        ),
        SummaryCard(
          title: 'Excused',
          value: provider.excusedCount.toString(),
          icon: Icons.event_available_rounded,
          color: AppTheme.excusedIndigo,
        ),
      ],
    );
  }

  Widget _buildUncheckedSection(AttendanceProvider provider, List uncheckedList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Unmarked Children', style: kTitleMedium),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.primaryTeal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${uncheckedList.length} Remaining',
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        uncheckedList.isEmpty
            ? Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.done_all_rounded, size: 36, color: Color(0xFF16A34A)),
                    SizedBox(height: 8),
                    Text(
                      'Excellent! All children are marked today.',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: uncheckedList.length,
                itemBuilder: (context, index) {
                  final student = uncheckedList[index];
                  return Card(
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.primaryTeal.withOpacity(0.08),
                        child: Text(
                          student.name.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                              color: AppTheme.primaryTeal, fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(student.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: Text(student.classroom,
                          style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryTeal,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              minimumSize: const Size(60, 32),
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () => provider.markAttendance(
                                student.id, AttendanceStatus.present),
                            child: const Text('Present', style: TextStyle(fontSize: 11)),
                          ),
                          const SizedBox(width: 6),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.alertAmber,
                              side: const BorderSide(color: AppTheme.alertAmber),
                              minimumSize: const Size(50, 32),
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () => provider.markAttendance(
                                student.id, AttendanceStatus.tardy),
                            child: const Text('Late', style: TextStyle(fontSize: 11)),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ],
    );
  }

  // ============================================================
  //  MULTI-TIMEFRAME ANALYTICS
  // ============================================================
  Widget _buildTimeframeAnalytics(AttendanceProvider provider) {
    final timeframes = provider.allTimeframeAnalytics;
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: timeframes.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final tf = timeframes[index];
          final overall = (tf['overall'] as double);
          return GestureDetector(
            onTap: () => _showTimeframeDetail(context, provider, tf),
            child: Container(
              width: 155,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(tf['label'] as String,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  Text(
                    '${overall.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: overall >= 80
                          ? AppTheme.primaryTeal
                          : overall >= 60
                              ? AppTheme.alertAmber
                              : AppTheme.secondaryCoral,
                    ),
                  ),
                  Text('attendance', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showTimeframeDetail(
      BuildContext context, AttendanceProvider provider, Map<String, dynamic> tf) {
    final top = (tf['top'] as List<MapEntry<Student, double>>);
    final low = (tf['low'] as List<MapEntry<Student, double>>);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.75,
            ),
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '${tf['label']} — ${(tf['overall'] as double).toStringAsFixed(1)}% Overall',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  if (top.isNotEmpty) ...[
                    const Text('Top Attenders', style: kTitleMedium),
                    const SizedBox(height: 8),
                    ...top.map((e) => _attendeeRow(e.key.name, e.value, AppTheme.primaryTeal)),
                  ],
                  const SizedBox(height: 16),
                  if (low.isNotEmpty) ...[
                    const Text('Low Attenders', style: kTitleMedium),
                    const SizedBox(height: 8),
                    ...low.map((e) => _attendeeRow(e.key.name, e.value, AppTheme.secondaryCoral)),
                  ],
                  if (top.isEmpty && low.isEmpty)
                    const Text('Not enough data for this period.',
                        style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  //  TOP & LOW ATTENDERS (30-day default)
  // ============================================================
  Widget _buildTopLowAttenders(BuildContext context, AttendanceProvider provider) {
    final monthly = provider.monthlyAnalytics;
    final top = (monthly['top'] as List<MapEntry<Student, double>>);
    final low = (monthly['low'] as List<MapEntry<Student, double>>);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Top & Low Attenders (30 Days)', style: kTitleMedium),
            TextButton(
              onPressed: () => _showTimeframeDetail(context, provider, monthly),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            // Top Attenders
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.emoji_events_rounded, color: AppTheme.primaryTeal, size: 18),
                        const SizedBox(width: 6),
                        const Text('Top',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primaryTeal)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (top.isEmpty)
                      Text('No data', style: TextStyle(fontSize: 12, color: Colors.grey[400]))
                    else
                      ...top.take(3).map((e) => _compactAttendeeRow(e.key.name, e.value, AppTheme.primaryTeal)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Low Attenders
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.trending_down_rounded, color: AppTheme.secondaryCoral, size: 18),
                        const SizedBox(width: 6),
                        const Text('Low',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.secondaryCoral)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (low.isEmpty)
                      Text('No data', style: TextStyle(fontSize: 12, color: Colors.grey[400]))
                    else
                      ...low.take(3).map((e) => _compactAttendeeRow(e.key.name, e.value, AppTheme.secondaryCoral)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _compactAttendeeRow(String name, double pct, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(name,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(width: 4),
          Text(
            '${pct.toStringAsFixed(0)}%',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget _attendeeRow(String name, double pct, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(name[0].toUpperCase(),
                  style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 14)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          ),
          Text(
            '${pct.toStringAsFixed(1)}%',
            style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // ============================================================
  //  PARENT ABSENCE MONITORING
  // ============================================================
  Widget _buildParentMonitoring(BuildContext context, AttendanceProvider provider) {
    final alerts = provider.getLowAttendanceAlerts(threshold: 75.0, periodDays: 30);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Parent Absence Alerts', style: kTitleMedium),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: alerts.isNotEmpty
                    ? AppTheme.secondaryCoral.withOpacity(0.1)
                    : const Color(0xFF16A34A).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                alerts.isEmpty
                    ? 'All Good ✓'
                    : '${alerts.length} Alert${alerts.length > 1 ? 's' : ''}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: alerts.isEmpty ? const Color(0xFF16A34A) : AppTheme.secondaryCoral,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (alerts.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: const Column(
              children: [
                Icon(Icons.check_circle_outline, color: Color(0xFF16A34A), size: 32),
                SizedBox(height: 8),
                Text('All students have attendance above 75%.',
                    style: TextStyle(fontSize: 13, color: Colors.black54)),
              ],
            ),
          )
        else
          ...alerts.map((entry) => _buildAlertCard(context, provider, entry.key, entry.value)),
      ],
    );
  }

  Widget _buildAlertCard(BuildContext context, AttendanceProvider provider, Student student, double pct) {
    final consecutive = provider.consecutiveAbsences(student.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppTheme.secondaryCoral.withOpacity(0.1),
                  child: Text(student.name[0].toUpperCase(),
                      style: const TextStyle(color: AppTheme.secondaryCoral, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(student.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text(
                        '${pct.toStringAsFixed(1)}% attendance · ${student.classroom}',
                        style: const TextStyle(fontSize: 11, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryCoral.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    pct < 50 ? 'Critical' : 'Warning',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.secondaryCoral,
                    ),
                  ),
                ),
              ],
            ),
            if (consecutive >= 3) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, size: 14, color: AppTheme.alertAmber),
                    const SizedBox(width: 6),
                    Text(
                      '$consecutive consecutive unexcused absences',
                      style: const TextStyle(fontSize: 11, color: AppTheme.alertAmber),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryTeal,
                      side: const BorderSide(color: AppTheme.primaryTeal),
                      minimumSize: const Size(0, 36),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.message_rounded, size: 16),
                    label: const Text('Message', style: TextStyle(fontSize: 12)),
                    onPressed: () {
                      final msg = provider.generateParentMessage(student, pct,
                          consecutiveAbsences: consecutive);
                      _showParentMessageDialog(context, student, msg);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.secondaryCoral,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 36),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.call_rounded, size: 16),
                    label: const Text('Call', style: TextStyle(fontSize: 12)),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Simulating call to ${student.parentName} at ${student.parentPhone}... 📞'),
                          backgroundColor: AppTheme.primaryTeal,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showParentMessageDialog(BuildContext context, Student student, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.email_rounded, color: AppTheme.primaryTeal, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text('Message to ${student.parentName}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (student.parentEmail != null) ...[
                Text('To: ${student.parentEmail}',
                    style: const TextStyle(fontSize: 11, color: Colors.black54)),
                const SizedBox(height: 12),
              ],
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.bgGrey,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(message, style: const TextStyle(fontSize: 13, height: 1.5)),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryTeal),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Message sent to ${student.parentName}! 📤'),
                  backgroundColor: const Color(0xFF16A34A),
                ),
              );
            },
            child: const Text('Send Message', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
