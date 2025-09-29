import 'package:budget_tracker/models/category.dart';
import 'package:budget_tracker/services/ai_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AiService', () {
    late AiService aiService;
    late List<Category> categories;

    setUp(() {
      aiService = AiService();
      categories = [
        Category(id: 'food', name: 'Food & Dining', icon: ''),
        Category(id: 'transport', name: 'Transportation', icon: ''),
        Category(id: 'shopping', name: 'Shopping', icon: ''),
      ];
    });

    test('should predict category based on keyword', () async {
      final predictedCategoryId = await aiService.predictCategory('My morning coffee', categories);
      expect(predictedCategoryId, 'food');
    });

    test('should be case-insensitive', () async {
      final predictedCategoryId = await aiService.predictCategory('UBER ride', categories);
      expect(predictedCategoryId, 'transport');
    });

    test('should return null if no keyword matches', () async {
      final predictedCategoryId = await aiService.predictCategory('A random purchase', categories);
      expect(predictedCategoryId, isNull);
    });

    test('should return null if category list is empty', () async {
      final predictedCategoryId = await aiService.predictCategory('My morning coffee', []);
      expect(predictedCategoryId, isNull);
    });
  });
}