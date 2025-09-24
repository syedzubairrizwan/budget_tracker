class Goal {
  final String id;
  final String name;
  final double targetAmount;
  final double currentAmount;

  Goal({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
    };
  }

  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map['id'],
      name: map['name'],
      targetAmount: map['targetAmount'],
      currentAmount: map['currentAmount'],
    );
  }
}
