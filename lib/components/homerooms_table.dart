// lib/components/homerooms_data_table.dart
import 'package:flutter/material.dart';
import 'package:project/classes/homeroom.dart';

typedef HomeroomTapCallback = void Function(Homeroom homeroom);

enum HomeroomSortField { grade, name, teachers, studentCount }

class HomeroomsDataTable extends StatefulWidget {
  final List<Homeroom> homerooms;
  final HomeroomTapCallback onTap;

  const HomeroomsDataTable({
    super.key,
    required this.homerooms,
    required this.onTap,
  });

  @override
  State<HomeroomsDataTable> createState() => _HomeroomsDataTableState();
}

class _HomeroomsDataTableState extends State<HomeroomsDataTable> {
  HomeroomSortField _sortField = HomeroomSortField.name;
  bool _ascending = true;

  void _sort(HomeroomSortField field) {
    setState(() {
      if (_sortField == field) {
        // If already sorting by this field, toggle direction
        _ascending = !_ascending;
      } else {
        // If sorting by a new field, default to ascending
        _sortField = field;
        _ascending = true;
      }
    });
  }

  List<Homeroom> get _sortedHomerooms {
    final homerooms = List<Homeroom>.from(widget.homerooms);

    switch (_sortField) {
      case HomeroomSortField.grade:
        homerooms.sort(
          (a, b) =>
              _ascending
                  ? a.grade.name.compareTo(b.grade.name)
                  : b.grade.name.compareTo(a.grade.name),
        );
      case HomeroomSortField.name:
        homerooms.sort(
          (a, b) =>
              _ascending ? a.name.compareTo(b.name) : b.name.compareTo(a.name),
        );
      case HomeroomSortField.teachers:
        homerooms.sort((a, b) {
          final aTeachers = a.teachers.map((t) => t.name).join(', ');
          final bTeachers = b.teachers.map((t) => t.name).join(', ');
          return _ascending
              ? aTeachers.compareTo(bTeachers)
              : bTeachers.compareTo(aTeachers);
        });
      case HomeroomSortField.studentCount:
        homerooms.sort(
          (a, b) =>
              _ascending
                  ? a.students.length.compareTo(b.students.length)
                  : b.students.length.compareTo(a.students.length),
        );
    }

    return homerooms;
  }

  Widget _buildSortableHeader(String text, HomeroomSortField field, int flex) {
    final theme = Theme.of(context);
    final isCurrent = _sortField == field;

    return Expanded(
      flex: flex,
      child: InkWell(
        onTap: () => _sort(field),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Text(
                text,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                  color: isCurrent ? theme.colorScheme.primary : null,
                ),
              ),
              if (isCurrent) ...[
                const SizedBox(width: 4),
                Icon(
                  _ascending ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Calculate positions for column dividers
    const double paddingH = 8.0;
    // Define column flex proportions
    const int col1Flex = 1; // Grade
    const int col2Flex = 2; // Name
    const int col3Flex = 3; // Teachers
    const double col4Width = 120.0; // Students count

    final int totalFlex = col1Flex + col2Flex + col3Flex;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Available width for the columns with flex (excluding fixed width columns)
          final double flexWidth =
              constraints.maxWidth - col4Width - paddingH * 2;

          // Calculate divider positions
          final double divider1Pos =
              (flexWidth * col1Flex / totalFlex) + paddingH;
          final double divider2Pos =
              divider1Pos + (flexWidth * col2Flex / totalFlex);
          final double divider3Pos =
              constraints.maxWidth - col4Width - paddingH;

          return Stack(
            children: [
              // Continuous vertical dividers
              Positioned(
                left: divider1Pos,
                top: 50.0, // Start below the title bar
                bottom: 0,
                child: Container(width: 1, color: theme.dividerColor),
              ),
              Positioned(
                left: divider2Pos,
                top: 50.0,
                bottom: 0,
                child: Container(width: 1, color: theme.dividerColor),
              ),
              Positioned(
                left: divider3Pos,
                top: 50.0,
                bottom: 0,
                child: Container(width: 1, color: theme.dividerColor),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title bar
                  Container(
                    color: theme.colorScheme.primaryContainer,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Homerooms',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Icon(
                              Icons.sort,
                              size: 16,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Click on column headers to sort',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Headers row
                  Material(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16.0,
                        horizontal: paddingH,
                      ),
                      child: Row(
                        children: [
                          _buildSortableHeader(
                            'Grade',
                            HomeroomSortField.grade,
                            col1Flex,
                          ),
                          _buildSortableHeader(
                            'Name',
                            HomeroomSortField.name,
                            col2Flex,
                          ),
                          _buildSortableHeader(
                            'Teachers',
                            HomeroomSortField.teachers,
                            col3Flex,
                          ),
                          SizedBox(
                            width: col4Width,
                            child: InkWell(
                              onTap:
                                  () => _sort(HomeroomSortField.studentCount),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        'Students',
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              fontWeight:
                                                  _sortField ==
                                                          HomeroomSortField
                                                              .studentCount
                                                      ? FontWeight.bold
                                                      : FontWeight.normal,
                                              color:
                                                  _sortField ==
                                                          HomeroomSortField
                                                              .studentCount
                                                      ? theme
                                                          .colorScheme
                                                          .primary
                                                      : null,
                                            ),
                                        overflow:
                                            TextOverflow
                                                .ellipsis, // Add this to handle overflow
                                      ),
                                    ),
                                    if (_sortField ==
                                        HomeroomSortField.studentCount) ...[
                                      const SizedBox(width: 4),
                                      Icon(
                                        _ascending
                                            ? Icons.arrow_upward
                                            : Icons.arrow_downward,
                                        size: 16,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Divider(height: 1, thickness: 1),

                  // Scrollable content
                  Expanded(
                    child: ListView.separated(
                      itemCount: _sortedHomerooms.length,
                      separatorBuilder:
                          (_, __) => Divider(height: 1, thickness: 1),
                      itemBuilder: (context, index) {
                        final hr = _sortedHomerooms[index];
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => widget.onTap(hr),
                            hoverColor: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12.0,
                                horizontal: paddingH,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: col1Flex,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0,
                                      ),
                                      child: Text(
                                        hr.grade.name,
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: col2Flex,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0,
                                      ),
                                      child: Text(
                                        hr.name,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: col3Flex,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0,
                                      ),
                                      child: Text(
                                        hr.teachers
                                            .map((t) => t.name)
                                            .join(', '),
                                        style: theme.textTheme.bodyMedium,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: col4Width,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0,
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              theme
                                                  .colorScheme
                                                  .primaryContainer,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        child: Text(
                                          hr.students.length.toString(),
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                color:
                                                    theme
                                                        .colorScheme
                                                        .onPrimaryContainer,
                                                fontWeight: FontWeight.bold,
                                              ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
