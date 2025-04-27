import 'package:flutter/material.dart';

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
              Text("Teacher: ${teachers.join(', ')}"),
            ],
          ),
          Text('$students students'),
        ],
      ),
    );
  }
}
