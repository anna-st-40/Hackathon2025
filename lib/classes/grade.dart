// lib/classes/grade.dart

class Grade {
  /// The numeric grade (0–9) as an integer.
  final int number;

  /// A human-readable name, e.g. "Kindergarten", "1st Grade", etc.
  final String name;

  Grade({required this.number, required this.name});

  /// Parses the server’s string (e.g. "0", "1", "2", …) into a Grade.
  factory Grade.fromString(String value) {
    final n = int.tryParse(value) ?? 0;
    const names = {
      0: 'Kindergarten',
      1: '1st Grade',
      2: '2nd Grade',
      3: '3rd Grade',
      4: '4th Grade',
      5: '5th Grade',
      6: '6th Grade',
      7: '7th Grade',
      8: '8th Grade',
      9: '9th Grade',
    };
    return Grade(number: n, name: names[n] ?? '$n');
  }

  /// When sending back to the API, use the original numeric string.
  String toApiString() => number.toString();
}
