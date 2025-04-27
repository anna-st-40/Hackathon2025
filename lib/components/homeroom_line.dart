import 'package:flutter/material.dart';
import 'package:project/components/actions_popover_button.dart';

class HomeroomLine extends StatelessWidget {
  const HomeroomLine({
    super.key,
    required this.name,
    required this.grade,
    required this.teachers,
    required this.students,
  });
  final String name;
  final String grade;
  final List<String> teachers;
  final int students;

  onTapEdit() {
    // Handle edit action
  }

  onTapDelete() {
    // Handle delete action
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "$name ($grade)",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text("Teacher(s): ${teachers.join(', ')}"),
            ],
          ),
          Row(
            children: [
              Text('$students students'),
              ActionsPopoverButton(onEdit: onTapEdit, onDelete: onTapDelete),
            ],
          ),
        ],
      ),
    );
  }
}
