import 'package:flutter/material.dart';
import 'package:project/classes/homeroom.dart';
import 'package:project/components/add_student_dialog.dart';
import 'package:provider/provider.dart';
import 'package:project/classes/school_store.dart';

class HomeroomLandingPage extends StatefulWidget {
  final Homeroom homeroom;
  const HomeroomLandingPage({super.key, required this.homeroom});

  @override
  State<HomeroomLandingPage> createState() => _HomeroomLandingPageState();
}

class _HomeroomLandingPageState extends State<HomeroomLandingPage> {
  late Homeroom _homeroom;

  @override
  void initState() {
    super.initState();
    _homeroom = widget.homeroom;
  }

  void _showAddStudentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddStudentDialog(homeroom: _homeroom),
    ).then((result) {
      if (result == true) {
        // Refresh the homeroom data from the store
        if (!context.mounted) return;
        final store = Provider.of<SchoolStore>(context, listen: false);
        final updatedHomeroom = store.homerooms.firstWhere(
          (h) => h.id == _homeroom.id,
        );

        setState(() {
          _homeroom = updatedHomeroom;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Student added successfully')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Get the SchoolStore to ensure we're using the singleton instances of Grade
    final store = Provider.of<SchoolStore>(context, listen: false);

    // If needed, update the homeroom's grade to use the singleton instance
    final singletonGrade = store.availableGrades.firstWhere(
      (g) => g.value == _homeroom.grade.value,
      orElse: () => _homeroom.grade, // fallback to existing grade if not found
    );

    // If they're not the same instance (but have the same value), update
    if (singletonGrade != _homeroom.grade &&
        singletonGrade.value == _homeroom.grade.value) {
      _homeroom = Homeroom(
        id: _homeroom.id,
        name: _homeroom.name,
        grade: singletonGrade, // Use the singleton instance
        teachers: _homeroom.teachers,
        students: _homeroom.students,
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(_homeroom.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Homeroom',
            onPressed: () {
              // Navigate to edit screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Edit functionality coming soon')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: 'Print roster',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Print functionality coming soon'),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Header section with key info
          Container(
            padding: const EdgeInsets.all(24),
            color: Colors.white,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left side - basic info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _homeroom.name,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _InfoRow(
                        icon: Icons.school,
                        label: 'Grade:',
                        value: _homeroom.grade.name,
                      ),
                      const SizedBox(height: 8),
                      _InfoRow(
                        icon: Icons.person,
                        label: 'Teacher(s):',
                        value: _homeroom.teachers.map((t) => t.name).join(', '),
                      ),
                      const SizedBox(height: 8),
                      _InfoRow(
                        icon: Icons.groups,
                        label: 'Students:',
                        value: _homeroom.students.length.toString(),
                      ),
                    ],
                  ),
                ),
                // Quick stats card
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Quick Stats',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('Total Students: '),
                              Text(
                                _homeroom.students.length.toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tab bar for different sections
          Expanded(
            child: DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  TabBar(
                    tabs: [
                      Tab(text: 'Students (${_homeroom.students.length})'),
                      const Tab(text: 'Schedule'),
                      const Tab(text: 'Assignments'),
                    ],
                    labelColor: theme.colorScheme.primary,
                  ),
                  Expanded(
                    child: TabBarView(
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        // Students tab
                        _buildStudentsList(context),

                        // Schedule tab (placeholder)
                        const Center(child: Text('Schedule coming soon')),

                        // Assignments tab (placeholder)
                        const Center(child: Text('Assignments coming soon')),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddStudentDialog(context),
        tooltip: 'Add student',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStudentsList(BuildContext context) {
    if (_homeroom.students.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.groups_outlined, size: 64, color: Colors.white),
            const SizedBox(height: 16),
            const Text(
              'No students in this homeroom yet',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('ADD YOUR FIRST STUDENT'),
              onPressed: () => _showAddStudentDialog(context),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView.separated(
        itemCount: _homeroom.students.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final student = _homeroom.students[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
              child: Text(
                student.name.substring(0, 1).toUpperCase(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
              ),
            ),
            title: Text(student.name),
            subtitle: Text('ID: ${student.id}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('View details for ${student.name}')),
              );
            },
          );
        },
      ),
    );
  }
}

// Helper widget for info rows
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
      ],
    );
  }
}
