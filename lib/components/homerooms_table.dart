import 'package:flutter/material.dart';
import 'package:project/classes/homeroom.dart';
import 'package:trina_grid/trina_grid.dart';

class HomeroomsTable extends StatefulWidget {
  const HomeroomsTable({super.key, required this.homerooms});
  final List<Homeroom> homerooms;

  @override
  State<HomeroomsTable> createState() => _HomeroomsTableState();
}

class _HomeroomsTableState extends State<HomeroomsTable> {
  late TrinaGridStateManager stateManager;

  final List<TrinaColumn> columns = [
    TrinaColumn(
      readOnly: true,
      title: 'Grade',
      field: 'grade',
      type: TrinaColumnType.select([
        'Kindergarten',
        '1st Grade',
        '2nd Grade',
        '3rd Grade',
        '4th Grade',
        '5th Grade',
        '6th Grade',
        '7th Grade',
        '8th Grade',
        '9th Grade',
      ]),
    ),
    TrinaColumn(readOnly: true, title: 'Name', field: 'name', type: TrinaColumnType.text()),
    TrinaColumn(
      readOnly: true,
      title: 'Teachers',
      field: 'teachers',
      type: TrinaColumnType.text(),
    ),
    TrinaColumn(
      readOnly: true,
      title: 'Students',
      field: 'students',
      type: TrinaColumnType.number(),
    ),
  ];

  late final List<TrinaRow> rows;

  @override
  void initState() {
    super.initState();
    rows =
        widget.homerooms.map((hr) {
          return TrinaRow(
            cells: {
              'grade': TrinaCell(value: hr.grade.name),
              'name': TrinaCell(value: hr.name),
              'teachers': TrinaCell(value: hr.teachers.map((t) => t.name).toList().join(', ')),
              'students': TrinaCell(value: hr.students.length),
            },
          );
        }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return TrinaGrid(
      columns: columns,
      rows: rows,
      onLoaded: (TrinaGridOnLoadedEvent event) {
        stateManager = event.stateManager;
      },
    );
  }
}
