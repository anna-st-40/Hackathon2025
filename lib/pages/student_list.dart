import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project/classes/school_store.dart';
import 'package:project/classes/student.dart';

class StudentsListPage extends StatefulWidget {
  const StudentsListPage({super.key});

  @override
  State<StudentsListPage> createState() => _StudentsListPageState();
}

class _StudentsListPageState extends State<StudentsListPage> {
  String _searchQuery = '';
  String? _selectedGrade;

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
                    await store.createStudent(nameController.text);
                    if (!context.mounted) return;
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Created student ${nameController.text}'),
                      ),
                    );
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Students'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: 'Filter options',
            onPressed: () {
              // Show filter options
              _showFilterDialog(context);
            },
          ),
        ],
      ),
      body: Consumer<SchoolStore>(
        builder: (context, store, child) {
          if (store.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (store.allStudents.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.school_outlined, size: 64, color: Colors.white),
                  const SizedBox(height: 16),
                  const Text(
                    'No students found',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('ADD YOUR FIRST STUDENT'),
                    onPressed: () => _showCreateStudentDialog(context, store),
                  ),
                ],
              ),
            );
          }

          // Apply filters
          var filteredStudents = store.allStudents;

          // Apply search filter
          if (_searchQuery.isNotEmpty) {
            filteredStudents =
                filteredStudents
                    .where(
                      (s) => s.name.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      ),
                    )
                    .toList();
          }

          // Apply grade filter if selected
          if (_selectedGrade != null) {
            final homeroomsInGrade = store.getHomeroomsForGrade(
              _selectedGrade!,
            );
            final studentIdsInGrade = <String>{};

            for (final homeroom in homeroomsInGrade) {
              for (final student in homeroom.students) {
                studentIdsInGrade.add(student.id);
              }
            }

            filteredStudents =
                filteredStudents
                    .where((s) => studentIdsInGrade.contains(s.id))
                    .toList();
          }

          if (filteredStudents.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.white),
                  const SizedBox(height: 16),
                  const Text(
                    'No students match your filters',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    icon: const Icon(Icons.clear),
                    label: const Text('CLEAR FILTERS'),
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                        _selectedGrade = null;
                      });
                    },
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search students...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    isDense: true,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),

              // Active filters display
              if (_selectedGrade != null || _searchQuery.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Text(
                        'Filters: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      if (_selectedGrade != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Chip(
                            label: Text(
                              'Grade: ${_getGradeName(store, _selectedGrade!)}',
                            ),
                            onDeleted:
                                () => setState(() => _selectedGrade = null),
                            backgroundColor: theme.colorScheme.primaryContainer,
                          ),
                        ),
                      if (_searchQuery.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Chip(
                            label: Text('Search: $_searchQuery'),
                            onDeleted: () => setState(() => _searchQuery = ''),
                            backgroundColor:
                                theme.colorScheme.secondaryContainer,
                          ),
                        ),
                      const Spacer(),
                      TextButton(
                        child: const Text('Clear All'),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                            _selectedGrade = null;
                          });
                        },
                      ),
                    ],
                  ),
                ),

              // Student count
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  children: [
                    Text(
                      'Showing ${filteredStudents.length} of ${store.allStudents.length} students',
                      style: TextStyle(
                        color: theme.colorScheme.secondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Student list
              Expanded(
                child: ListView.separated(
                  itemCount: filteredStudents.length,
                  separatorBuilder:
                      (_, __) => const Divider(height: 1, indent: 70),
                  itemBuilder: (context, index) {
                    final student = filteredStudents[index];
                    final homeroomsForStudent = store.getHomeroomsForStudent(
                      student.id,
                    );

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: theme.colorScheme.secondary,
                        foregroundColor: theme.colorScheme.onSecondary,
                        child: Text(student.name.substring(0, 1).toUpperCase()),
                      ),
                      title: Text(
                        student.name,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          if (homeroomsForStudent.isNotEmpty)
                            Row(
                              children: [
                                Icon(
                                  Icons.class_,
                                  size: 16,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    homeroomsForStudent
                                        .map((h) => h.name)
                                        .join(', '),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          if (homeroomsForStudent.isNotEmpty)
                            const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                Icons.badge,
                                size: 16,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'ID: ${student.id.substring(0, 8)}...',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.arrow_forward_ios, size: 16),
                        onPressed: () {
                          _showStudentDetailsDialog(context, student, store);
                        },
                      ),
                      onTap: () {
                        _showStudentDetailsDialog(context, student, store);
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Create a new student
          final store = Provider.of<SchoolStore>(context, listen: false);
          _showCreateStudentDialog(context, store);
        },
        tooltip: 'Add Student',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    final store = Provider.of<SchoolStore>(context, listen: false);
    String? tempSelectedGrade = _selectedGrade;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Filter Students'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Grade Level',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('All Grades'),
                        selected: tempSelectedGrade == null,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              tempSelectedGrade = null;
                            });
                          }
                        },
                      ),
                      ...store.availableGrades.map((grade) {
                        return FilterChip(
                          label: Text(grade.name),
                          selected: tempSelectedGrade == grade.value,
                          onSelected: (selected) {
                            setState(() {
                              tempSelectedGrade = selected ? grade.value : null;
                            });
                          },
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CANCEL'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedGrade = tempSelectedGrade;
                  });
                  Navigator.pop(context);
                },
                child: const Text('APPLY'),
              ),
            ],
          ),
    );
  }

  void _showStudentDetailsDialog(
    BuildContext context,
    Student student,
    SchoolStore store,
  ) {
    final homerooms = store.getHomeroomsForStudent(student.id);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(student.name),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Student ID
                  ListTile(
                    leading: const Icon(Icons.badge),
                    title: const Text('Student ID'),
                    subtitle: Text(student.id),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),

                  const Divider(),

                  // Homerooms
                  const Text(
                    'Enrolled in Homerooms:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  if (homerooms.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Not enrolled in any homerooms'),
                    )
                  else
                    ...homerooms.map(
                      (h) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(h.name),
                          subtitle: Text(
                            '${h.grade.name} • ${h.teachers.map((t) => t.name).join(", ")}',
                          ),
                          leading: CircleAvatar(child: Text(h.grade.value)),
                          dense: true,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CLOSE'),
              ),
            ],
          ),
    );
  }

  String _getGradeName(SchoolStore store, String gradeValue) {
    try {
      return store.availableGrades
          .firstWhere((g) => g.value == gradeValue)
          .name;
    } catch (_) {
      return gradeValue;
    }
  }
}
