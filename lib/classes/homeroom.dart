import 'package:project/classes/grade.dart';
import 'package:project/classes/student.dart';
import 'package:project/classes/teacher.dart';

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
    required this.teachers,
    List<Student>? students,
  }) : students = students ?? [];

  factory Homeroom.fromJson(Map<String, dynamic> json) {
    // Parse grade string to Grade object
    final rawGrade = json['grade'];
    final grade = Grade.fromString(rawGrade);

    // Parse teachers list
    final teacherMaps = json['teachers'] as List<dynamic>;
    final teachers = teacherMaps.map((m) => Teacher.fromJson(m)).toList();

    // Parse students list if it exists and is not empty
    final studentMaps = json['students'] as List<dynamic>? ?? [];
    final students = studentMaps.map((m) => Student.fromJson(m)).toList();

    return Homeroom(
      id: json['id'],
      grade: grade,
      name: json['name'],
      teachers: teachers,
      students: students,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'grade': grade.toApiString(),
    'name': name,
    'teachers': teachers.map((t) => t.toJson()).toList(),
    'students': students.map((s) => s.toJson()).toList(),
  };
}
