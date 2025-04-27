class Teacher {
  final String id;
  final String name;

  Teacher({required this.id, required this.name});

  factory Teacher.fromJson(Map<String, dynamic> json) {
    print('Parsing Teacher from JSON: $json');
    if (json['id'] == null) {
      throw Exception('Missing "id" field in Teacher: $json');
    }
    if (json['name'] == null) {
      throw Exception('Missing "name" field in Teacher: $json');
    }

    return Teacher(id: json['id'] as String, name: json['name'] as String);
  }
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}
