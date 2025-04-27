// lib/classes/homeroom.dart
import 'package:project/classes/teacher.dart';
import 'package:project/classes/student.dart';
import 'package:project/classes/grade.dart';

class Homeroom {
  final String id;
  final Grade grade;
  final String name;
  final List<Teacher> teachers;
  final List<Student> students;

  Homeroom({
    required this.id,
    required this.grade,
    required this.name,
    List<Teacher>? teachers,
    List<Student>? students,
  }) : teachers = teachers ?? [],
       students = students ?? [];

  factory Homeroom.fromJson(Map<String, dynamic> json) {
    // parse grade string → Grade object
    final rawGrade = json['grade'] as String? ?? '0';
    final grade = Grade.fromString(rawGrade);

    // existing filtering logic for teachers/students
    final rawTeachers = json['teachers'] as List<dynamic>? ?? [];
    final teacherMaps =
        rawTeachers
            .where(
              (e) =>
                  e is Map<String, dynamic> &&
                  (e['id'] != null || e['name'] != null),
            )
            .cast<Map<String, dynamic>>();

    final rawStudents = json['students'] as List<dynamic>? ?? [];
    final studentMaps =
        rawStudents
            .where(
              (e) =>
                  e is Map<String, dynamic> &&
                  (e['id'] != null || e['name'] != null),
            )
            .cast<Map<String, dynamic>>();

    return Homeroom(
      id: json['id'] as String? ?? '',
      grade: grade,
      name: json['name'] as String? ?? '',
      teachers: teacherMaps.map((m) => Teacher.fromJson(m)).toList(),
      students: studentMaps.map((m) => Student.fromJson(m)).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    // send back the numeric string
    'grade': grade.toApiString(),
    'name': name,
    'teachers': teachers.map((t) => t.toJson()).toList(),
    'students': students.map((s) => s.toJson()).toList(),
  };
}
