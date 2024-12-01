class Item {
  final int? id;
  final int userId;
  final String name;
  final String description;
  final DateTime dueDateTime;
  final String category;
  final String type;

  Item({
    this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.dueDateTime,
    required this.category,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'description': description,
      'dueDateTime': dueDateTime.toIso8601String(),
      'category': category,
      'type': type,
    };
  }

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'],
      userId: map['userId'],
      name: map['name'],
      description: map['description'],
      dueDateTime: map['dueDateTime'] != null
          ? DateTime.parse(map['dueDateTime'])
          : DateTime.now(),
      category: map['category'],
      type: map['type'],
    );
  }
}
