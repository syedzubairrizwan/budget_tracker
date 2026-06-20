class Category {
  final String id;
  final String name;
  final String icon; // We will use this to store emojis
  final String color; // Store color as a hex string (e.g., '#FF0000')

  Category({
    required this.id,
    required this.name,
    required this.icon,
    this.color = '#1E88E5', // Default color if none provided
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      icon: map['icon'],
      color: map['color'] ?? '#1E88E5',
    );
  }
}
