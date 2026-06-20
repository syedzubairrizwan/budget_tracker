class Budget {
  final String id;
  final String categoryId;
  final double amount;
  final double spentAmount;
  final String priority; // 'High', 'Medium', 'Low'

  Budget({
    required this.id,
    required this.categoryId,
    required this.amount,
    required this.spentAmount,
    this.priority = 'Medium',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'categoryId': categoryId,
      'amount': amount,
      'spentAmount': spentAmount,
      'priority': priority,
    };
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'],
      categoryId: map['categoryId'],
      amount: map['amount'],
      spentAmount: map['spentAmount'],
      priority: map['priority'] ?? 'Medium',
    );
  }
}

class BudgetTemplate {
  final String name;
  final String description;
  final List<BudgetTemplateItem> items;

  BudgetTemplate({
    required this.name,
    required this.description,
    required this.items,
  });

  static List<BudgetTemplate> get templates => [
    BudgetTemplate(
      name: 'Essential & Healthcare First',
      description:
          'Focuses on medical needs, food, and utilities, with low priority on clothing.',
      items: [
        BudgetTemplateItem(
          categoryId: 'health',
          amount: 12000,
          priority: 'High',
        ),
        BudgetTemplateItem(categoryId: 'food', amount: 15000, priority: 'High'),
        BudgetTemplateItem(
          categoryId: 'bills',
          amount: 10000,
          priority: 'High',
        ),
        BudgetTemplateItem(
          categoryId: 'shopping',
          amount: 3000,
          priority: 'Low',
        ),
      ],
    ),
    BudgetTemplate(
      name: 'Balanced 50-30-20 Rule',
      description:
          'A popular structured split for needs, wants, and minor savings.',
      items: [
        BudgetTemplateItem(categoryId: 'food', amount: 12000, priority: 'High'),
        BudgetTemplateItem(
          categoryId: 'bills',
          amount: 10000,
          priority: 'High',
        ),
        BudgetTemplateItem(
          categoryId: 'transport',
          amount: 5000,
          priority: 'High',
        ),
        BudgetTemplateItem(
          categoryId: 'shopping',
          amount: 8000,
          priority: 'Medium',
        ),
        BudgetTemplateItem(
          categoryId: 'entertainment',
          amount: 4000,
          priority: 'Low',
        ),
      ],
    ),
    BudgetTemplate(
      name: 'Student / Minimalist',
      description:
          'Optimized budget structure with low-spend clothing and entertainment allocations.',
      items: [
        BudgetTemplateItem(categoryId: 'food', amount: 9000, priority: 'High'),
        BudgetTemplateItem(
          categoryId: 'education',
          amount: 6000,
          priority: 'High',
        ),
        BudgetTemplateItem(
          categoryId: 'health',
          amount: 3000,
          priority: 'High',
        ),
        BudgetTemplateItem(
          categoryId: 'transport',
          amount: 3000,
          priority: 'Medium',
        ),
        BudgetTemplateItem(
          categoryId: 'shopping',
          amount: 2000,
          priority: 'Low',
        ),
      ],
    ),
  ];
}

class BudgetTemplateItem {
  final String categoryId;
  final double amount;
  final String priority;

  BudgetTemplateItem({
    required this.categoryId,
    required this.amount,
    required this.priority,
  });
}
