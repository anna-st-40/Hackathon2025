import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient();

  final String _host = 'https://gradebook-api-cyan.vercel.app/api';
  Future<dynamic> post(String url, String body) async {
    try {
      final response = await http.post(Uri.parse('$_host/$url'), body: body);
      if (response.statusCode != 200) {
        throw Exception(response.body);
      }
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> put(String url, String body) async {
    try {
      final response = await http.put(Uri.parse('$_host/$url'), body: body);
      if (response.statusCode != 200) {
        throw Exception(response.body);
      }
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> delete(String url, String body) async {
    try {
      final response = await http.delete(Uri.parse('$_host/$url'), body: body);
      if (response.statusCode != 200) {
        throw response.body;
      }
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
