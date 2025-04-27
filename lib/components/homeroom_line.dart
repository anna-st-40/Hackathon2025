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
    return Row(
      children: [
        Text(name),
        const SizedBox(width: 8),
        Text(grade),
        const SizedBox(width: 8),
        Text(teachers.join(', ')),
        const SizedBox(width: 8),
        Text('$students students'),
      ],
    );
  }
}
