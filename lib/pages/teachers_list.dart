import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project/classes/school_store.dart';

class TeachersListPage extends StatefulWidget {
  const TeachersListPage({super.key});

  @override
  State<TeachersListPage> createState() => _TeachersListPageState();
}

class _TeachersListPageState extends State<TeachersListPage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('All Teachers')),
      body: Consumer<SchoolStore>(
        builder: (context, store, child) {
          if (store.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Filter teachers by search query
          final filteredTeachers = _searchQuery.isEmpty
              ? store.allTeachers
              : store.allTeachers
                  .where((t) => t.name.toLowerCase().contains(_searchQuery.toLowerCase()))
                  .toList();

          // Empty state if no teachers at all
          if (store.allTeachers.isEmpty) {
            return const Center(child: Text('No teachers found'));
          }

          // No matches for current search
          if (filteredTeachers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No teachers match your search',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    icon: const Icon(Icons.clear),
                    label: const Text('CLEAR SEARCH'),
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
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
                    hintText: 'Search teachers...',
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

              // Showing count
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  children: [
                    Text(
                      'Showing ${filteredTeachers.length} of ${store.allTeachers.length} teachers',
                      style: TextStyle(
                        color: theme.colorScheme.secondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Teacher list
              Expanded(
                child: ListView.separated(
                  itemCount: filteredTeachers.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final teacher = filteredTeachers[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        child: Text(teacher.name.substring(0, 1).toUpperCase()),
                      ),
                      title: Text(teacher.name),
                      subtitle: Text(
                        '${store.getHomeroomsForTeacher(teacher.id).length} homerooms',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // Show teacher details (future enhancement)
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Selected ${teacher.name}')),
                        );
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
}
