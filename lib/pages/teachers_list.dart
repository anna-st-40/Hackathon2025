import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project/classes/school_store.dart';

class TeachersListPage extends StatelessWidget {
  const TeachersListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Teachers')),
      body: Consumer<SchoolStore>(
        builder: (context, store, child) {
          if (store.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (store.allTeachers.isEmpty) {
            return const Center(child: Text('No teachers found'));
          }

          return ListView.separated(
            itemCount: store.allTeachers.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final teacher = store.allTeachers[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
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
          );
        },
      ),
    );
  }
}
