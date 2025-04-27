class Grade {
  final String id;
  final String name;
  final String value;

  Grade({required this.id, required this.name, required this.value});

  factory Grade.fromJson(Map<String, dynamic> json) {
    return Grade(id: json['id'], name: json['name'], value: json['value']);
  }

  factory Grade.fromString(String gradeValue) {
    // This handles cases where we only have the grade value
    // like in the homeroom JSON objects
    switch (gradeValue) {
      case '0':
        return Grade(id: '', name: 'Kindergarten', value: '0');
      case '1':
        return Grade(id: '', name: '1st Grade', value: '1');
      case '2':
        return Grade(id: '', name: '2nd Grade', value: '2');
      case '3':
        return Grade(id: '', name: '3rd Grade', value: '3');
      default:
        if (int.tryParse(gradeValue) != null) {
          return Grade(
            id: '',
            name: '${gradeValue}th Grade',
            value: gradeValue,
          );
        }
        return Grade(id: '', name: 'Unknown', value: gradeValue);
    }
  }

  String toApiString() => value;

  @override
  String toString() => name;
}
