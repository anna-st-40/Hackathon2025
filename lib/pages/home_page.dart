import 'package:flutter/material.dart';
import 'package:project/components/homeroom_line.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              HomeroomLine(
                name: "Homeroom 1",
                grade: "9th Grade",
                teachers: ["Jane Doe"],
                students: 23,
              ),
              HomeroomLine(
                name: "Homeroom 2",
                grade: "10th Grade",
                teachers: ["John Smith"],
                students: 25,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
