import 'package:budget_tracker/models/category.dart';

class AiService {
  // Enhanced mock implementation of an AI service.
  // In a real app, this would use a more sophisticated model or a cloud API.
  Future<String?> predictCategory(String title, List<Category> categories) async {
    await Future.delayed(const Duration(milliseconds: 50)); // Fast response

    final lowerCaseTitle = title.toLowerCase();

    // Map keywords to category names
    final Map<String, List<String>> keywordMap = {
      'Food & Dining': ['coffee', 'restaurant', 'food', 'starbucks', 'mcdonald', 'burger', 'pizza', 'cafe', 'dinner', 'lunch', 'eat'],
      'Transportation': ['gas', 'uber', 'lyft', 'fuel', 'petrol', 'train', 'bus', 'taxi', 'parking', 'garage'],
      'Shopping': ['amazon', 'walmart', 'target', 'ebay', 'clothes', 'shoe', 'mall', 'store', 'grocery', 'supermarket'],
      'Entertainment': ['movie', 'concert', 'cinema', 'netflix', 'spotify', 'gaming', 'steam', 'theatre', 'zoo'],
      'Bills & Utilities': ['rent', 'electricity', 'internet', 'water', 'gas bill', 'insurance', 'phone', 'mobile', 'subscription'],
      'Healthcare': ['doctor', 'pharmacy', 'hospital', 'medical', 'dentist', 'clinic', 'health', 'medicine'],
      'Education': ['udemy', 'coursera', 'book', 'school', 'tuition', 'university', 'course', 'training'],
      'Travel': ['flight', 'hotel', 'airbnb', 'vacation', 'resort', 'booking', 'airline', 'visa'],
      'Salary': ['salary', 'paycheck', 'payroll', 'bonus'],
      'Freelance': ['upwork', 'fiverr', 'contract', 'freelance', 'project'],
      'Investment': ['dividend', 'stock', 'crypto', 'bitcoin', 'trading', 'investment', 'interest'],
    };

    for (var entry in keywordMap.entries) {
      if (entry.value.any((keyword) => lowerCaseTitle.contains(keyword))) {
        return _findCategoryIdByName(entry.key, categories);
      }
    }

    return _findCategoryIdByName('Other', categories);
  }

  String? _findCategoryIdByName(String name, List<Category> categories) {
    try {
      return categories.firstWhere((c) => c.name.toLowerCase() == name.toLowerCase()).id;
    } catch (e) {
      return null;
    }
  }
}
