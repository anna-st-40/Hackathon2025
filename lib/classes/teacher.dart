class Teacher {
  final String id;
  final String name;

  Teacher({required this.id, required this.name});

  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(id: json['id'] as String, name: json['name'] as String);
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}
