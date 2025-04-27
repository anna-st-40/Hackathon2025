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
    required this.teachers,
    required this.students,
  });

  factory Homeroom.fromJson(Map<String, dynamic> json) {
    return Homeroom(
      id: json['id'] as String,
      grade: json['grade'] as String,
      name: json['name'] as String,
      teachers:
          (json['teachers'] as List<dynamic>)
              .map((e) => Teacher.fromJson(e as Map<String, dynamic>))
              .toList(),
      students:
          (json['students'] as List<dynamic>)
              .map((e) => Student.fromJson(e as Map<String, dynamic>))
              .toList(),
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
