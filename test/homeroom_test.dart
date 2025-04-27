import 'dart:convert';
import 'package:project/classes/api_client.dart';
import 'package:project/classes/homeroom.dart';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('ApiClient.getHomerooms', () {
    test('parses a successful homerooms response', () async {
      // sample minimal JSON
      final sampleJson = {
        'homerooms': [
          {
            'id': 'abc-123',
            'grade': '5',
            'name': 'Test Room',
            'teachers': [
              {'id': 't1', 'name': 'Ms. Test'},
            ],
            'students': [
              {'id': 's1', 'name': 'Student One', 'homeroom': 'abc-123'},
            ],
          },
        ],
      };

      final mockClient = MockClient((request) async {
        return http.Response(jsonEncode(sampleJson), 200);
      });

      final api = ApiClient(client: mockClient);
      final list = await api.getHomerooms();

      expect(list, isA<List<Homeroom>>());
      expect(list, hasLength(1));
      expect(list.first.id, equals('abc-123'));
      expect(list.first.teachers.first.name, equals('Ms. Test'));
      expect(list.first.students.first.name, equals('Student One'));
    });

    test('throws when server returns non-200', () {
      final mockClient = MockClient((request) async {
        return http.Response('Not found', 404);
      });

      final api = ApiClient(client: mockClient);
      expect(api.getHomerooms(), throwsA(isA<Exception>()));
    });
  });
}
