import 'package:flutter_test/flutter_test.dart';
import 'package:budget_tracker/services/ocr_service.dart';

void main() {
  group('OcrService Parser Tests', () {
    late OcrService ocrService;

    setUp(() {
      ocrService = OcrService();
    });

    test('should extract merchant name correctly', () {
      const ocrText = '''
Walmart Store #1234
123 Main Street
Phone: 555-555-5555
-----------------------
TOTAL 12.50
''';
      final result = ocrService.parseRawText(ocrText);
      expect(result.merchantName, equals('Walmart Store #1234'));
    });

    test('should ignore url and metadata for merchant name', () {
      const ocrText = '''
www.starbucks.com
Starbucks Coffee
Store 123
-----------------------
TOTAL 4.75
''';
      final result = ocrService.parseRawText(ocrText);
      expect(result.merchantName, equals('Starbucks Coffee'));
    });

    test('should extract amount when total keyword is present', () {
      const ocrText = '''
Starbucks Coffee
12/12/2025 10:30 AM
-----------------------
Coffee        3.50
Muffin        2.50
Subtotal      6.00
Tax           0.50
TOTAL AMOUNT  6.50
CASH TENDERED 10.00
CHANGE DUE    3.50
''';
      final result = ocrService.parseRawText(ocrText);
      expect(result.amount, equals(6.50));
    });

    test(
      'should fallback to largest number under 10000 when no total keyword matched',
      () {
        const ocrText = '''
Gas Station
Fuel      45.00
Soda       2.50
47.50
''';
        final result = ocrService.parseRawText(ocrText);
        expect(result.amount, equals(47.50));
      },
    );

    test('should extract dates in YYYY-MM-DD format', () {
      const ocrText = '''
Target Store
Date: 2026-05-15
TOTAL 9.99
''';
      final result = ocrService.parseRawText(ocrText);
      expect(result.date, equals(DateTime(2026, 5, 15)));
    });

    test('should extract dates in MM/DD/YYYY or DD/MM/YYYY format', () {
      const ocrText = '''
McDonalds
Date: 15/05/2026 14:22
TOTAL 5.45
''';
      final result = ocrService.parseRawText(ocrText);
      expect(result.date, equals(DateTime(2026, 5, 15)));
    });

    test('should extract dates in YY format', () {
      const ocrText = '''
McDonalds
Date: 15/05/26 14:22
TOTAL 5.45
''';
      final result = ocrService.parseRawText(ocrText);
      expect(result.date, equals(DateTime(2026, 5, 15)));
    });
  });
}
