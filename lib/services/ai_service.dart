import 'package:budget_tracker/models/category.dart';

class AiService {
  // This is a mock implementation of an AI service.
  // In a real app, this would be replaced with a proper on-device ML model.
  Future<String?> predictCategory(String title, List<Category> categories) async {
    await Future.delayed(const Duration(milliseconds: 100)); // Simulate processing time

    final lowerCaseTitle = title.toLowerCase();

    // Simple keyword-based matching
    if (lowerCaseTitle.contains('coffee') || lowerCaseTitle.contains('restaurant') || lowerCaseTitle.contains('food')) {
      return _findCategoryIdByName('Food & Dining', categories);
    }
    if (lowerCaseTitle.contains('gas') || lowerCaseTitle.contains('uber') || lowerCaseTitle.contains('lyft')) {
      return _findCategoryIdByName('Transportation', categories);
    }
    if (lowerCaseTitle.contains('amazon') || lowerCaseTitle.contains('walmart') || lowerCaseTitle.contains('target')) {
      return _findCategoryIdByName('Shopping', categories);
    }
    if (lowerCaseTitle.contains('movie') || lowerCaseTitle.contains('concert')) {
      return _findCategoryIdByName('Entertainment', categories);
    }
    if (lowerCaseTitle.contains('rent') || lowerCaseTitle.contains('electricity') || lowerCaseTitle.contains('internet')) {
      return _findCategoryIdByName('Bills & Utilities', categories);
    }
    if (lowerCaseTitle.contains('doctor') || lowerCaseTitle.contains('pharmacy')) {
      return _findCategoryIdByName('Healthcare', categories);
    }
    if (lowerCaseTitle.contains('udemy') || lowerCaseTitle.contains('coursera')) {
      return _findCategoryIdByName('Education', categories);
    }
    if (lowerCaseTitle.contains('flight') || lowerCaseTitle.contains('hotel')) {
      return _findCategoryIdByName('Travel', categories);
    }
    if (lowerCaseTitle.contains('salary')) {
      return _findCategoryIdByName('Salary', categories);
    }

    return null; // No prediction
  }

  String? _findCategoryIdByName(String name, List<Category> categories) {
    try {
      return categories.firstWhere((c) => c.name == name).id;
    } catch (e) {
      return null;
    }
  }
}