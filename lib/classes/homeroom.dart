import 'package:project/classes/student.dart';
import 'package:project/classes/teacher.dart';

class Homeroom {
  final String id;
  final String grade;
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
    // Grab raw lists (could be null, single {}, etc.)
    final rawTeachers = json['teachers'] as List<dynamic>? ?? [];
    final rawStudents = json['students'] as List<dynamic>? ?? [];

    // Filter out any empty maps before mapping
    final teacherMaps =
        rawTeachers
            .where(
              (e) =>
                  e is Map<String, dynamic> &&
                  (e['id'] != null || e['name'] != null),
            )
            .cast<Map<String, dynamic>>();

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
      grade: json['grade'] as String? ?? '',
      name: json['name'] as String? ?? '',
      teachers: teacherMaps.map((m) => Teacher.fromJson(m)).toList(),
      students: studentMaps.map((m) => Student.fromJson(m)).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'grade': grade,
    'name': name,
    'teachers': teachers.map((t) => t.toJson()).toList(),
    'students': students.map((s) => s.toJson()).toList(),
  };
}
