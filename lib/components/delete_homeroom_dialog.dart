import 'package:flutter/material.dart';
import 'package:project/classes/homeroom.dart';
import 'package:project/classes/school_store.dart';
import 'package:provider/provider.dart';

class DeleteHomeroomDialog extends StatefulWidget {
  final List<Homeroom> homerooms;

  const DeleteHomeroomDialog({super.key, required this.homerooms});

  @override
  State<DeleteHomeroomDialog> createState() => _DeleteHomeroomDialogState();
}

class _DeleteHomeroomDialogState extends State<DeleteHomeroomDialog> {
  bool _isLoading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.warning, color: theme.colorScheme.error),
          const SizedBox(width: 8),
          const Text('Delete Homerooms'),
        ],
      ),
      content: _buildContent(theme),
      actions:
          _isLoading
              ? null
              : [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('CANCEL'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.error,
                    foregroundColor: theme.colorScheme.onError,
                  ),
                  onPressed: _handleDelete,
                  child: const Text('DELETE'),
                ),
              ],
    );
  }

  // Extract content into a separate method to fix sizing issues
  Widget _buildContent(ThemeData theme) {
    if (_isLoading) {
      return const SizedBox(
        width: 300, // Explicit width to avoid sizing issues
        height: 100,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return SizedBox(
      width: 400, // Set a specific width for the dialog content
      child: Column(
        mainAxisSize: MainAxisSize.min, // Important!
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Are you sure you want to delete ${widget.homerooms.length} '
            'selected homeroom(s)?',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          const Text('This will permanently delete:'),
          const SizedBox(height: 8),
          ConstrainedBox(
            // Use ConstrainedBox for proper sizing
            constraints: const BoxConstraints(
              maxHeight: 150, // Set maximum height
              minHeight: 50, // Set minimum height
            ),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.builder(
                shrinkWrap: true, // Important to avoid sizing issues
                itemCount: widget.homerooms.length,
                itemBuilder: (context, index) {
                  final homeroom = widget.homerooms[index];
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.home_work),
                    title: Text(homeroom.name),
                    subtitle: Text(
                      '${homeroom.grade.name} • ${homeroom.students.length} students',
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'This action cannot be undone.',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.error,
            ),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _errorMessage!,
                style: TextStyle(color: theme.colorScheme.onErrorContainer),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _handleDelete() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final store = Provider.of<SchoolStore>(context, listen: false);
      final homeroomIds = widget.homerooms.map((h) => h.id).toList();

      final success = await store.deleteHomerooms(homeroomIds);

      if (mounted) {
        Navigator.of(context).pop(success);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: $e';
      });
    }
  }
}
