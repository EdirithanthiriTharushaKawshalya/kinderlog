import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kinderlog_core/kinderlog_core.dart';
import '../../providers/attendance_provider.dart';
import '../widgets/attendance_card.dart';

class AttendanceMarkingScreen extends StatefulWidget {
  const AttendanceMarkingScreen({super.key});

  @override
  State<AttendanceMarkingScreen> createState() => _AttendanceMarkingScreenState();
}

class _AttendanceMarkingScreenState extends State<AttendanceMarkingScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mark Attendance'),
      ),
      body: Consumer<AttendanceProvider>(
        builder: (context, provider, child) {
          final filteredList = provider.filteredStudents;
          final classrooms = provider.availableClassrooms;

          return Column(
            children: [
              // 1. Search Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search child name...',
                    prefixIcon: const Icon(Icons.search, color: AppTheme.primaryTeal),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              _searchController.clear();
                              provider.setSearchQuery('');
                              FocusScope.of(context).unfocus();
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) => provider.setSearchQuery(value),
                ),
              ),

              // 2. Horizontal Classroom Chip Filter
              SizedBox(
                height: 48,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: classrooms.length,
                  itemBuilder: (context, index) {
                    final isSelected = provider.selectedClassFilter == classrooms[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: FilterChip(
                        label: Text(
                          classrooms[index],
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? Colors.white : Colors.grey[700],
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          provider.setClassFilter(classrooms[index]);
                        },
                        selectedColor: AppTheme.primaryTeal,
                        checkmarkColor: Colors.white,
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected ? AppTheme.primaryTeal : const Color(0xFFE5E7EB),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 8),

              // 3. Main Roster List
              Expanded(
                child: provider.isLoading && filteredList.isEmpty
                    ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryTeal))
                    : filteredList.isEmpty
                        ? _buildEmptyState(provider)
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            itemCount: filteredList.length,
                            itemBuilder: (context, index) {
                              final student = filteredList[index];
                              final record = provider.getRecordForStudent(student.id);

                              return AttendanceCard(
                                student: student,
                                record: record,
                                onStatusChanged: (status) {
                                  provider.markAttendance(student.id, status);
                                },
                                onCheckOut: () {
                                  if (record != null) {
                                    provider.markAttendance(
                                      student.id,
                                      record.status,
                                      doCheckOut: true,
                                    );
                                  }
                                },
                                onSaveNote: (note) {
                                  provider.updateRecordNote(student.id, note);
                                },
                              );
                            },
                          ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(AttendanceProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No students found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            provider.searchQuery.isNotEmpty
                ? 'Try searching with another name'
                : 'No students enrolled in this classroom.',
            style: TextStyle(color: Colors.grey[500], fontSize: 13),
          ),
        ],
      ),
    );
  }
}
