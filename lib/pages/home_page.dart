import 'package:flutter/material.dart';
import 'package:project/components/add_homeroom_dialog.dart';
import 'package:project/components/delete_homeroom_dialog.dart';
import 'package:project/pages/homeroom.dart';
import 'package:project/pages/student_list.dart';
import 'package:project/pages/teachers_list.dart';
import 'package:provider/provider.dart';
import 'package:project/classes/school_store.dart';
import 'package:project/components/homerooms_table.dart';
import 'package:project/classes/homeroom.dart'; // Add this import

class HomePage extends StatefulWidget {
  // Changed to StatefulWidget
  final String title;

  const HomePage({super.key, required this.title});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Homeroom> _selectedHomerooms = []; // Track selected homerooms

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title), // Use widget.title
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
      drawer: _buildDrawer(context),
      body: Consumer<SchoolStore>(
        builder: (context, store, child) {
          if (store.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (store.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 60,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text('Error loading data', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(store.error!),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => store.loadHomerooms(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Main content - dashboard with homerooms
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _dashboardHeader(theme, context, store),
                const SizedBox(height: 24),
                _actionsRow(context, theme, store),
                const SizedBox(height: 24),
                _homeroomsTable(store, context),
              ],
            ),
          );
        },
      ),
    );
  }

  Expanded _homeroomsTable(SchoolStore store, BuildContext context) {
    return Expanded(
      child: HomeroomsDataTable(
        homerooms: store.homerooms,
        onTap: (homeroom) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HomeroomLandingPage(homeroom: homeroom),
            ),
          );
        },
        onSelectionChanged: (selectedHomerooms) {
          setState(() {
            _selectedHomerooms = selectedHomerooms;
          });
        },
      ),
    );
  }

  Row _dashboardHeader(
    ThemeData theme,
    BuildContext context,
    SchoolStore store,
  ) {
    return Row(
      children: [
        Text(
          'Dashboard',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const Spacer(),
        _buildSummaryChip(
          context,
          'Homerooms',
          store.homerooms.length,
          Icons.home_work,
          theme.colorScheme.tertiaryContainer,
          theme.colorScheme.onTertiaryContainer,
        ),
        const SizedBox(width: 8),
        _buildSummaryChip(
          context,
          'Teachers',
          store.allTeachers.length,
          Icons.person,
          theme.colorScheme.primaryContainer,
          theme.colorScheme.onPrimaryContainer,
        ),
        const SizedBox(width: 8),
        _buildSummaryChip(
          context,
          'Students',
          store.allStudents.length,
          Icons.school,
          theme.colorScheme.secondaryContainer,
          theme.colorScheme.onSecondaryContainer,
        ),
      ],
    );
  }

  Row _actionsRow(BuildContext context, ThemeData theme, SchoolStore store) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _actionButton(
          () {
            showDialog(
              context: context,
              builder: (context) => const AddHomeroomDialog(),
            );
          },
          const Icon(Icons.add),
          'Add New Homeroom',
          theme,
        ),
        const SizedBox(width: 16),
        _actionButton(
          // Enable only if homerooms are selected
          _selectedHomerooms.isEmpty
              ? null
              : () => _deleteSelectedHomerooms(context, store),
          const Icon(Icons.delete),
          _selectedHomerooms.isEmpty
              ? 'Delete Selected Homerooms'
              : 'Delete ${_selectedHomerooms.length} Homeroom(s)',
          theme,
          // Add red color for delete button when enabled
          _selectedHomerooms.isEmpty ? null : theme.colorScheme.errorContainer,
          _selectedHomerooms.isEmpty
              ? null
              : theme.colorScheme.onErrorContainer,
        ),
      ],
    );
  }

  ElevatedButton _actionButton(
    VoidCallback? onPressed,
    Icon icon,
    String label,
    ThemeData theme, [
    Color? backgroundColor,
    Color? foregroundColor,
  ]) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: IconTheme(
        data: IconThemeData(
          color: foregroundColor ?? theme.colorScheme.onPrimaryContainer,
        ),
        child: icon,
      ),
      label: Text(
        label,
        style: TextStyle(
          color: foregroundColor ?? theme.colorScheme.onPrimaryContainer,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? theme.colorScheme.primaryContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
      ),
    );
  }

  Future<void> _deleteSelectedHomerooms(
    BuildContext context,
    SchoolStore store,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => DeleteHomeroomDialog(homerooms: _selectedHomerooms),
    );

    // If deletion was successful
    if (result == true && context.mounted) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Successfully deleted ${_selectedHomerooms.length} homeroom(s)',
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Clear selection
      setState(() {
        _selectedHomerooms = [];
      });
    } else if (result == false && context.mounted) {
      // User canceled deletion, no need for notification
    } else if (context.mounted) {
      // Deletion failed
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete some or all homerooms'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildSummaryChip(
    BuildContext context,
    String label,
    int count,
    IconData icon,
    Color backgroundColor,
    Color foregroundColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: foregroundColor),
          const SizedBox(width: 8),
          Text(
            '$label: $count',
            style: TextStyle(
              color: foregroundColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gradebook',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'School Management System',
                  style: TextStyle(color: Colors.amberAccent),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Dashboard'),
            selected: true,
            onTap: () {
              Navigator.pop(context); // Close the drawer
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.groups),
            title: const Text('Homerooms'),
            onTap: () {
              Navigator.pop(context);
              // Already on homerooms page/dashboard
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Teachers'),
            trailing: Consumer<SchoolStore>(
              builder: (context, store, child) {
                return Chip(
                  label: Text(store.allTeachers.length.toString()),
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  labelStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                );
              },
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TeachersListPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.school),
            title: const Text('Students'),
            trailing: Consumer<SchoolStore>(
              builder: (context, store, child) {
                return Chip(
                  label: Text(store.allStudents.length.toString()),
                  backgroundColor:
                      Theme.of(context).colorScheme.secondaryContainer,
                  labelStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                );
              },
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => StudentsListPage()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to settings page
            },
          ),
        ],
      ),
    );
  }
}
