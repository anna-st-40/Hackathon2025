import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:project/classes/grade.dart';
import 'package:project/classes/homeroom.dart';
import 'package:project/classes/student.dart';
import 'package:project/classes/teacher.dart';

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final String _host = 'https://gradebook-api-psi.vercel.app/api';
  final http.Client _client;

  Future<http.Response> fetch(String url) async {
    try {
      final response = await _client.get(Uri.parse('$_host/$url'));
      if (response.statusCode != 200) {
        throw Exception('GET $url failed: ${response.body}');
      }
      return response;
    } catch (e) {
      debugPrint('Error in POST request: $e');
      rethrow;
    }
  }

  Future<http.Response> post(String url, String body) async {
    try {
      final response = await http.post(Uri.parse('$_host/$url'), body: body);
      if (response.statusCode != 200) {
        throw Exception('POST $url failed: ${response.body}');
      }
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Simple method to add a student to a homeroom
  /// Returns true if successful, false otherwise
  Future<bool> addStudentToHomeroom(
    String homeroomId,
    String studentId, {
    required String homeroomName,
    required String grade,
  }) async {
    try {
      // Updated request structure with all required fields
      final requestBody = jsonEncode({
        'updatedHomeroom': {
          'id': homeroomId,
          'name': homeroomName, // Required field
          'grade': grade, // Required field
          'students': [studentId],
        },
        'link': {
          'students': [studentId],
        },
        'unlink': {},
      });

      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      final response = await http.put(
        Uri.parse('$_host/homerooms/$homeroomId'),
        headers: headers,
        body: requestBody,
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error adding student to homeroom: $e');
      return false;
    }
  }

  /// Add multiple students to a homeroom at once
  Future<bool> addStudentsToHomeroom(
    String homeroomId,
    List<String> studentIds, {
    required String homeroomName,
    required String grade,
  }) async {
    try {
      // Include all required fields in the request structure
      final requestBody = jsonEncode({
        'updatedHomeroom': {
          'id': homeroomId,
          'name': homeroomName, // Required field
          'grade': grade, // Required field
          'students': [],
        },
        'link': {'students': studentIds},
        'unlink': {'students': []},
      });

      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      final response = await http.put(
        Uri.parse('$_host/homerooms/$homeroomId'),
        headers: headers,
        body: requestBody,
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error adding students to homeroom: $e');
      return false;
    }
  }

  /// Creates a new homeroom
  /// Returns the ID of the newly created homeroom
  Future<String> createHomeroom({
    required String name,
    required String grade,
    required List<String> teacherIds,
  }) async {
    try {
      final requestBody = jsonEncode({
        'newHomeroom': {'name': name, 'grade': grade},
        'link': {'teachers': teacherIds},
      });

      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      final response = await http.post(
        Uri.parse('$_host/homerooms'),
        headers: headers,
        body: requestBody,
      );

      if (response.statusCode == 200) {
        // Parse the response which contains an array with a homeroom ID object
        final List<dynamic> responseData = jsonDecode(response.body);
        final Map<String, dynamic> idObject = responseData[0];
        return idObject['id'] as String;
      } else {
        throw Exception(
          'Failed to create homeroom: [${response.statusCode}] ${response.body}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Deletes a homeroom by ID
  Future<bool> deleteHomeroom(String homeroomId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_host/homerooms/$homeroomId'),
        headers: {'Accept': 'application/json'},
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Error deleting homeroom: $e');
      return false;
    }
  }

  // Add a new method to reload a single homeroom by ID
  Future<Homeroom> getHomeroomById(String homeroomId) async {
    try {
      final response = await fetch('homerooms/$homeroomId');
      final Map<String, dynamic> jsonBody = jsonDecode(response.body);
      return Homeroom.fromJson(jsonBody);
    } catch (e) {
      debugPrint('Error fetching homeroom by ID: $e');
      rethrow;
    }
  }

  Future<http.Response> delete(String url, String body) async {
    try {
      final response = await http.delete(Uri.parse('$_host/$url'), body: body);
      if (response.statusCode != 200) {
        throw Exception('DELETE $url failed: ${response.body}');
      }
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Fetches all homerooms and parses them into model objects.
  Future<Map<String, dynamic>> getSchoolData() async {
    try {
      final response = await fetch('homerooms');
      final Map<String, dynamic> jsonBody = jsonDecode(response.body);

      // Access the 'homerooms' array in the response
      final List<dynamic> homeroomsJson =
          jsonBody['homerooms'] as List<dynamic>;

      // Store grade options for future use
      final List<dynamic> gradesJson =
          jsonBody['classGradeOptions'] as List<dynamic>;
      final grades = gradesJson.map((json) => Grade.fromJson(json)).toList();

      // Store all teachers for future reference
      final List<dynamic> teachersJson = jsonBody['teachers'] as List<dynamic>;
      final allTeachers =
          teachersJson.map((json) => Teacher.fromJson(json)).toList();

      // Store all students for future reference
      final List<dynamic> studentsJson = jsonBody['students'] as List<dynamic>;
      final allStudents =
          studentsJson.map((json) => Student.fromJson(json)).toList();

      // Convert homerooms JSON to Homeroom objects
      final homerooms =
          homeroomsJson.map((json) => Homeroom.fromJson(json)).toList();

      // Return all parsed data in a structured format
      return {
        'homerooms': homerooms,
        'grades': grades,
        'teachers': allTeachers,
        'students': allStudents,
      };
    } catch (e) {
      rethrow;
    }
  }

  // Keep this for backward compatibility
  Future<List<Homeroom>> getHomerooms() async {
    final data = await getSchoolData();
    return data['homerooms'] as List<Homeroom>;
  }
}
