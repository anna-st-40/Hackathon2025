import 'package:flutter/material.dart';
import 'package:project/classes/api_client.dart';
import 'package:project/classes/homeroom.dart';
import 'package:project/components/homerooms_table.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiClient _api = ApiClient();
  List<Homeroom> _homerooms = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchHomerooms();
  }

  Future<void> _fetchHomerooms() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final list = await _api.getHomerooms();
      setState(() {
        _homerooms = list;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget body;

    if (_isLoading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (_error != null) {
      body = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Error loading homerooms:\n$_error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _fetchHomerooms,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    } else if (_homerooms.isEmpty) {
      body = const Center(child: Text('No homerooms found.'));
    } else {
      body = Padding(
        padding: const EdgeInsets.all(8.0),
        child: HomeroomsTable(homerooms: _homerooms),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: body,
    );
  }
}
