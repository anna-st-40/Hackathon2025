class Student {
  final String id;
  final String name;
  final String homeroom;

  Student({required this.id, required this.name, required this.homeroom});

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'] as String,
      name: json['name'] as String,
      homeroom: json['homeroom'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'homeroom': homeroom,
  };
}
