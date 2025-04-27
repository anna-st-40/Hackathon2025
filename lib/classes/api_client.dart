import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:project/classes/homeroom.dart';

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final String _host = 'https://gradebook-api-cyan.vercel.app/api';
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

  Future<http.Response> put(String url, String body) async {
    try {
      final response = await http.put(Uri.parse('$_host/$url'), body: body);
      if (response.statusCode != 200) {
        throw Exception('PUT $url failed: ${response.body}');
      }
      return response;
    } catch (e) {
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
  Future<List<Homeroom>> getHomerooms() async {
    try {
      final response = await fetch('homerooms');
      final Map<String, dynamic> jsonBody = jsonDecode(response.body);
      final List<dynamic> list = jsonBody['homerooms'] as List<dynamic>;
      return list
          .map((e) => Homeroom.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching homerooms: $e');
      rethrow;
    }
  }
}
