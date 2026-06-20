import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:budget_tracker/models/transaction.dart';

class AIParserService {
  static const String _apiKey = 'AIzaSyCfJb-YOfOKz6HTpyPx5H4mBqvpYV6kiIY';

  final GenerativeModel _model;

  AIParserService()
    : _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: _apiKey);

  Future<ParsedTransactionResult?> parseTransaction(String text) async {
    if (text.isEmpty) return null;

    final prompt =
        '''
You are a financial transaction parser. Extract the details from the following user speech and return ONLY a valid JSON object. 
Do not include markdown blocks like ```json. Just raw JSON.

User Speech: "$text"

Fields required in JSON:
- "title": (String) A short title for the transaction.
- "amount": (Number) The total amount spent or received.
- "type": (String) Either "income" or "expense".
- "isSplit": (Boolean) True if the user mentions splitting the bill with someone.
- "splitWith": (String or null) The name of the person they split with, if any.
- "splitAmount": (Number or null) The amount the other person owes, if mentioned. If they say "split", assume it's split equally (50/50) unless specified otherwise.
- "categoryHint": (String) A short category name (e.g. "Food", "Transport", "Salary", "Shopping", "Entertainment", "Utilities", "Health", "Other").

JSON Output:
''';

    try {
      final response = await _model
          .generateContent([Content.text(prompt)])
          .timeout(const Duration(seconds: 10));
      String resultText = response.text?.trim() ?? '';

      // Extract JSON if it's wrapped in markdown or other text
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(resultText);
      if (jsonMatch == null) return null;

      final jsonString = jsonMatch.group(0)!;
      final Map<String, dynamic> data = jsonDecode(jsonString);

      return ParsedTransactionResult(
        title: data['title'] ?? 'Unknown',
        amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
        type: data['type'] == 'income'
            ? TransactionType.income
            : TransactionType.expense,
        isSplit: data['isSplit'] ?? false,
        splitWith: data['splitWith'],
        splitAmount: (data['splitAmount'] as num?)?.toDouble(),
        categoryHint: data['categoryHint'] ?? 'Other',
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing transaction: $e');
      }
      return null;
    }
  }
}

class ParsedTransactionResult {
  final String title;
  final double amount;
  final TransactionType type;
  final bool isSplit;
  final String? splitWith;
  final double? splitAmount;
  final String categoryHint;

  ParsedTransactionResult({
    required this.title,
    required this.amount,
    required this.type,
    required this.isSplit,
    this.splitWith,
    this.splitAmount,
    required this.categoryHint,
  });
}
