import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project/classes/school_store.dart';
import 'package:project/classes/teacher.dart';
import 'package:project/classes/grade.dart';

class AddHomeroomDialog extends StatefulWidget {
  const AddHomeroomDialog({super.key});

  @override
  AddHomeroomDialogState createState() => AddHomeroomDialogState();
}

class AddHomeroomDialogState extends State<AddHomeroomDialog> {
  final TextEditingController _nameController = TextEditingController();
  final List<Teacher> _selectedTeachers = [];
  Grade? _selectedGrade;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SchoolStore>(
      builder: (context, store, child) {
        // Default to first grade if not selected and grades are available
        if (_selectedGrade == null && store.availableGrades.isNotEmpty) {
          _selectedGrade = store.availableGrades.first;
        }

        return Dialog(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Add New Homeroom',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Name field
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Homeroom Name',
                      hintText: 'e.g. The Busy Bees, Room 101',
                      prefixIcon: Icon(Icons.home_work),
                      border: OutlineInputBorder(),
                    ),
                    autofocus: true,
                  ),
                  const SizedBox(height: 16),

                  // Grade dropdown
                  DropdownButtonFormField<Grade>(
                    decoration: const InputDecoration(
                      labelText: 'Grade Level',
                      prefixIcon: Icon(Icons.school),
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedGrade,
                    items: (() {
                      final sortedGrades = List<Grade>.from(store.availableGrades)
                        ..sort((a, b) => a.value.compareTo(b.value));
                      return sortedGrades.map((grade) {
                        return DropdownMenuItem<Grade>(
                          value: grade,
                          child: Text(grade.name),
                        );
                      }).toList();
                    })(),
                    onChanged: (Grade? value) {
                      setState(() {
                        _selectedGrade = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Teachers section
                  const Text(
                    'Assigned Teachers:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),

                  // Teachers list
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).dividerColor),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    height: 200,
                    child:
                        store.allTeachers.isEmpty
                            ? const Center(child: Text('No teachers available'))
                            : ListView.builder(
                              itemCount: store.allTeachers.length,
                              itemBuilder: (context, index) {
                                final teacher = store.allTeachers[index];
                                final isSelected = _selectedTeachers.any(
                                  (t) => t.id == teacher.id,
                                );

                                return CheckboxListTile(
                                  title: Text(teacher.name),
                                  subtitle: Text(
                                    'ID: ${teacher.id.substring(0, 8)}...',
                                  ),
                                  value: isSelected,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      if (value == true) {
                                        _selectedTeachers.add(teacher);
                                      } else {
                                        _selectedTeachers.removeWhere(
                                          (t) => t.id == teacher.id,
                                        );
                                      }
                                    });
                                  },
                                );
                              },
                            ),
                  ),
                  const SizedBox(height: 16),

                  // Error message
                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(8),
                      color: Theme.of(context).colorScheme.errorContainer,
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onErrorContainer,
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
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed:
                            _isLoading
                                ? null
                                : () async {
                                  // Validate input
                                  if (_nameController.text.trim().isEmpty) {
                                    setState(() {
                                      _errorMessage =
                                          'Please enter a homeroom name';
                                    });
                                    return;
                                  }

                                  if (_selectedGrade == null) {
                                    setState(() {
                                      _errorMessage =
                                          'Please select a grade level';
                                    });
                                    return;
                                  }

                                  if (_selectedTeachers.isEmpty) {
                                    setState(() {
                                      _errorMessage =
                                          'Please assign at least one teacher';
                                    });
                                    return;
                                  }

                                  setState(() {
                                    _isLoading = true;
                                    _errorMessage = null;
                                  });

                                  try {
                                    final success = await store.createHomeroom(
                                      name: _nameController.text.trim(),
                                      grade: _selectedGrade!,
                                      teacherIds:
                                          _selectedTeachers
                                              .map((t) => t.id)
                                              .toList(),
                                    );

                                    if (success && context.mounted) {
                                      Navigator.of(context).pop(true);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Homeroom created successfully',
                                          ),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    setState(() {
                                      _errorMessage = 'Error: $e';
                                    });
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
                                : const Text('CREATE HOMEROOM'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
