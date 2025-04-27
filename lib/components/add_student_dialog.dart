import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project/classes/school_store.dart';
import 'package:project/classes/student.dart';
import 'package:project/classes/homeroom.dart';

class AddStudentDialog extends StatefulWidget {
  final Homeroom homeroom;

  const AddStudentDialog({super.key, required this.homeroom});

  @override
  AddStudentDialogState createState() => AddStudentDialogState();
}

class AddStudentDialogState extends State<AddStudentDialog> {
  Student? _selectedStudent;
  String? _searchQuery;
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showCreateStudentDialog(BuildContext context, SchoolStore store) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Create New Student'),
            content: TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Student Name',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('CANCEL'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (nameController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a name')),
                    );
                    return;
                  }

                  try {
                    // Create new student
                    final newStudent = await store.createStudent(
                      nameController.text,
                    );

                    // Close create dialog
                    if (!context.mounted) return;
                    Navigator.of(context).pop();

                    // Set as selected
                    setState(() {
                      _selectedStudent = newStudent;
                    });
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                },
                child: const Text('CREATE'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SchoolStore>(
      builder: (context, store, child) {
        // Get available students (not already in this homeroom)
        final availableStudents =
            store.allStudents
                .where(
                  (student) =>
                      !widget.homeroom.students.any((s) => s.id == student.id),
                )
                .toList();

        // Filter by search query if provided
        final filteredStudents =
            _searchQuery != null && _searchQuery!.isNotEmpty
                ? availableStudents
                    .where(
                      (s) => s.name.toLowerCase().contains(
                        _searchQuery!.toLowerCase(),
                      ),
                    )
                    .toList()
                : availableStudents;

        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Add Student to ${widget.homeroom.name}',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Create new student button
                ElevatedButton.icon(
                  icon: const Icon(Icons.person_add),
                  label: const Text('CREATE NEW STUDENT'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Theme.of(context).colorScheme.onSecondary,
                  ),
                  onPressed: () {
                    _showCreateStudentDialog(context, store);
                  },
                ),
                const SizedBox(height: 16),

                // Search field
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Search Students',
                    prefixIcon: const Icon(Icons.search),
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 8),

                // Student list
                Flexible(
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 300),
                    child:
                        filteredStudents.isEmpty
                            ? const Center(
                              child: Text('No available students found'),
                            )
                            : ListView.builder(
                              shrinkWrap: true,
                              itemCount: filteredStudents.length,
                              itemBuilder: (context, index) {
                                final student = filteredStudents[index];
                                return RadioListTile<Student>(
                                  title: Text(student.name),
                                  subtitle: Text('ID: ${student.id}'),
                                  value: student,
                                  groupValue: _selectedStudent,
                                  onChanged: (Student? value) {
                                    setState(() {
                                      _selectedStudent = value;
                                    });
                                  },
                                );
                              },
                            ),
                  ),
                ),
                const SizedBox(height: 16),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('CANCEL'),
                    ),
                    const SizedBox(width: 8),
                    // In your add_student_dialog.dart file
                    ElevatedButton(
                      onPressed:
                          _selectedStudent == null
                              ? null
                              : () async {
                                final store = Provider.of<SchoolStore>(
                                  context,
                                  listen: false,
                                );

                                // Show loading indicator
                                setState(() {
                                  _isLoading = true;
                                });

                                try {
                                  final success = await store
                                      .addStudentToHomeroom(
                                        widget.homeroom.id,
                                        _selectedStudent!,
                                      );

                                  if (!context.mounted) return;

                                  if (success) {
                                    Navigator.of(context).pop(true);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Failed to add student'),
                                      ),
                                    );
                                  }
                                } finally {
                                  if (mounted) {
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  }
                                }
                              },
                      child:
                          _isLoading
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : const Text('ADD STUDENT'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
