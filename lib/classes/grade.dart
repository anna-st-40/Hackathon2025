class Grade {
  final String value;
  final String name;

  // Private constructor
  const Grade._({required this.value, required this.name});

  // Cache of instances
  static final Map<String, Grade> _cache = {};

  // Factory constructor to get existing or create new instance
  factory Grade({required String value, required String name}) {
    return _cache.putIfAbsent(value, () => Grade._(value: value, name: name));
  }

  // Create from JSON - ensures singleton pattern is maintained
  factory Grade.fromJson(Map<String, dynamic> json) {
    final value = json['value'] as String;
    final name = json['name'] as String;
    return Grade(value: value, name: name);
  }

  // Create from string - ensures singleton pattern
  static Grade fromString(String gradeString) {
    // Try to parse standard formats
    if (gradeString.endsWith('th Grade') ||
        gradeString.endsWith('nd Grade') ||
        gradeString.endsWith('st Grade') ||
        gradeString.endsWith('rd Grade')) {
      return Grade(value: gradeString, name: gradeString);
    }

    // Default case for other formats
    return Grade(value: gradeString, name: '$gradeString Grade');
  }

  String toApiString() => value;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Grade && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Grade($name)';
}
