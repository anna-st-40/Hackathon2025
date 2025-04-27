import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project/classes/api_client.dart';
import 'package:project/classes/school_store.dart';
import 'package:project/pages/home_page.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => SchoolStore(ApiClient())..loadHomerooms(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gradebook',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      home: const HomePage(title: 'Gradebook'),
    );
  }
}
