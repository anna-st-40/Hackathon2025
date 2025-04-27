// lib/classes/school_store.dart
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:project/classes/api_client.dart';
import 'package:project/classes/grade.dart';
import 'package:project/classes/homeroom.dart';
import 'package:project/classes/student.dart';
import 'package:project/classes/teacher.dart';

class SchoolStore extends ChangeNotifier {
  final ApiClient _api;

  bool isLoading = false;
  String? error;

  List<Homeroom> homerooms = [];
  List<Grade> gradeOptions = [];
  List<Teacher> _allTeachers = [];
  List<Student> _allStudents = [];

  SchoolStore(this._api);

  List<Teacher> get allTeachers => _allTeachers;
  List<Student> get allStudents => _allStudents;
  List<Grade> get availableGrades => gradeOptions;

  /// Loads all homerooms, teachers, students, and grade options from the API.
  Future<void> loadHomerooms() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final data = await _api.getSchoolData();

      // For homerooms, teachers, and students, use the data as is
      homerooms = data['homerooms'] as List<Homeroom>;
      _allTeachers = data['teachers'] as List<Teacher>;
      _allStudents = data['students'] as List<Student>;

      // For grades, ensure we're using unique instances by explicitly using
      // the Grade factory constructor that checks the cache
      final rawGrades = data['grades'] as List<Grade>;

      // Clear gradeOptions and rebuild it with singleton instances
      gradeOptions = [];
      for (final grade in rawGrades) {
        // This uses the factory constructor which ensures singleton pattern
        final singletonGrade = Grade(value: grade.value, name: grade.name);
        // Only add if not already in the list
        if (!gradeOptions.any((g) => g.value == singletonGrade.value)) {
          gradeOptions.add(singletonGrade);
        }
      }
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Creates a new homeroom
  Future<bool> createHomeroom({
    required String name,
    required Grade grade,
    required List<String> teacherIds,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      // Make API call to create homeroom and get its ID
      final newHomeroomId = await _api.createHomeroom(
        name: name,
        grade: grade.toApiString(),
        teacherIds: teacherIds,
      );

      // Since we only got an ID back, create a temporary homeroom object
      // with the information we have
      final teachers =
          teacherIds
              .map((id) => findTeacherById(id))
              .where((t) => t != null)
              .cast<Teacher>()
              .toList();

      final newHomeroom = Homeroom(
        id: newHomeroomId,
        grade: grade,
        name: name,
        teachers: teachers,
        students: [], // New homeroom has no students yet
      );

      // Add to local list
      homerooms.add(newHomeroom);

      // Optional: Refresh all data to ensure we have the latest
      try {
        await loadHomerooms();
      } catch (refreshError) {
        debugPrint('Warning: Could not refresh homerooms: $refreshError');
        rethrow;
      }

      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      debugPrint('Error creating homeroom: $e');
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Gets homerooms for a specific teacher
  List<Homeroom> getHomeroomsForTeacher(String teacherId) {
    return homerooms
        .where((h) => h.teachers.any((t) => t.id == teacherId))
        .toList();
  }

  /// Gets homerooms for a specific student
  List<Homeroom> getHomeroomsForStudent(String studentId) {
    return homerooms
        .where((h) => h.students.any((s) => s.id == studentId))
        .toList();
  }

  /// Finds a teacher by their ID
  Teacher? findTeacherById(String id) {
    try {
      return _allTeachers.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Finds a student by their ID
  Student? findStudentById(String id) {
    try {
      return _allStudents.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Gets homerooms for a specific grade
  List<Homeroom> getHomeroomsForGrade(String gradeValue) {
    return homerooms.where((h) => h.grade.value == gradeValue).toList();
  }

  Future<bool> addStudentToHomeroom(String homeroomId, Student student) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      // Find the homeroom
      final index = homerooms.indexWhere((h) => h.id == homeroomId);
      if (index == -1) {
        throw Exception('Homeroom not found');
      }

      final homeroom = homerooms[index];

      // Check if student already exists in the homeroom
      if (homeroom.students.any((s) => s.id == student.id)) {
        throw Exception('Student already exists in this homeroom');
      }

      // Make the API call with all required fields
      final success = await _api.addStudentToHomeroom(
        homeroomId,
        student.id,
        homeroomName: homeroom.name,
        grade: homeroom.grade.toApiString(),
      );

      if (success) {
        // Fetch fresh data for this homeroom - no fallback if this fails
        await reloadHomeroom(homeroomId);

        // Refresh the cache of students
        _refreshStudentsCache();
        return true;
      } else {
        throw Exception('Failed to add student to homeroom');
      }
    } catch (e) {
      error = e.toString();
      debugPrint('Error adding student to homeroom: $e');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Add multiple students to a homeroom at once
  Future<bool> addStudentsToHomeroom(
    String homeroomId,
    List<Student> students,
  ) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      // Find the homeroom
      final index = homerooms.indexWhere((h) => h.id == homeroomId);
      if (index == -1) {
        throw Exception('Homeroom not found');
      }

      final homeroom = homerooms[index];

      // Extract student IDs
      final studentIds = students.map((s) => s.id).toList();

      // Make the API call with all required fields
      final success = await _api.addStudentsToHomeroom(
        homeroomId,
        studentIds,
        homeroomName: homeroom.name,
        grade: homeroom.grade.toApiString(),
      );

      if (success) {
        // Reload the homeroom data directly from the server - no fallback
        await reloadHomeroom(homeroomId);

        // Refresh the cache of students
        _refreshStudentsCache();
        return true;
      } else {
        throw Exception('Failed to add students to homeroom');
      }
    } catch (e) {
      error = e.toString();
      debugPrint('Error adding students to homeroom: $e');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Add this new method to reload a single homeroom
  Future<void> reloadHomeroom(String homeroomId) async {
    try {
      // Fetch the latest data from server
      final data = await _api.getSchoolData();
      final updatedHomerooms = data['homerooms'] as List<Homeroom>;

      // Find and update the specific homeroom
      final index = homerooms.indexWhere((h) => h.id == homeroomId);
      if (index >= 0) {
        final updatedHomeroom = updatedHomerooms.firstWhere(
          (h) => h.id == homeroomId,
          orElse:
              () =>
                  throw Exception('Homeroom not found on server after update'),
        );

        homerooms[index] = updatedHomeroom;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error reloading homeroom data: $e');
      rethrow;
    }
  }

  void _refreshStudentsCache() {
    final studentSet = <String>{};
    final studentList = <Student>[];

    // Collect all students across homerooms
    for (final homeroom in homerooms) {
      for (final student in homeroom.students) {
        if (!studentSet.contains(student.id)) {
          studentSet.add(student.id);
          studentList.add(student);
        }
      }
    }

    // Sort alphabetically by name
    studentList.sort((a, b) => a.name.compareTo(b.name));

    // Update cached list
    _allStudents = studentList;
  }

  Future<Student> createStudent(String name) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await _api.post(
        'students',
        jsonEncode({
          'newStudent': {'name': name},
        }),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final student = Student.fromJson(responseData['students'][0]);

      // Add to the cache
      _allStudents = [..._allStudents, student];
      _allStudents.sort((a, b) => a.name.compareTo(b.name));

      return student;
    } catch (e) {
      error = e.toString();
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
