import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

// ─── Data Model ───────────────────────────────────────────────────────────────
// Public API is unchanged – callers don't need any modification.
class ReceiptData {
  final String? merchantName;
  final double? amount;
  final DateTime? date;

  ReceiptData({this.merchantName, this.amount, this.date});
}

// ─── OCR Service ──────────────────────────────────────────────────────────────
/// Uses [google_mlkit_text_recognition] for local offline text extraction
/// and extracts transaction fields (merchant, amount, date) via heuristics.
class OcrService {
  final ImagePicker _picker = ImagePicker();
  final TextRecognizer _textRecognizer = TextRecognizer();

  /// Picks an image from the camera and extracts structured receipt data locally.
  /// Returns null if the user cancels or no data can be extracted.
  Future<ReceiptData?> pickImageAndExtractData() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85, // Reduce size for faster OCR processing
      );

      if (image == null) return null;

      final inputImage = InputImage.fromFilePath(image.path);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      return parseRawText(recognizedText.text);
    } catch (e) {
      debugPrint('OCR Error: $e');
      return null;
    }
  }

  /// Parses the raw OCR text locally using regex and heuristics.
  @visibleForTesting
  ReceiptData parseRawText(String text) {
    if (text.isEmpty) {
      return ReceiptData();
    }

    final lines = text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    if (lines.isEmpty) {
      return ReceiptData();
    }

    final String? merchantName = _extractMerchantName(lines);
    final double? amount = _extractAmount(lines);
    final DateTime? date = _extractDate(text);

    return ReceiptData(merchantName: merchantName, amount: amount, date: date);
  }

  String? _extractMerchantName(List<String> lines) {
    // The merchant name is usually the first non-empty line of the receipt.
    // However, sometimes it might be preceded by metadata, but usually the first 3 lines contain it.
    // Let's filter out lines that look like numbers, dates, times, phone numbers, or typical metadata.
    final phoneRegex = RegExp(r'(\+?\d[\d-\s()]{7,}\d)');
    final dateRegex = RegExp(r'\d{1,4}[/\-.]\d{1,2}[/\-.]\d{1,4}');
    final timeRegex = RegExp(r'\d{1,2}:\d{2}');

    for (var line in lines) {
      final isSeparator = line
          .replaceAll(RegExp(r'[-_*=~]'), '')
          .trim()
          .isEmpty;
      if (isSeparator) continue;

      final cleanLine = line.replaceAll(
        RegExp(r'[\d\s.,$€£+\-*/#xX()\[\]{}:]'),
        '',
      );
      final isNumberOrMath = cleanLine.isEmpty;
      final isPhone = phoneRegex.hasMatch(line);
      final isDate = dateRegex.hasMatch(line);
      final isTime = timeRegex.hasMatch(line);
      final isTooShort = line.trim().length < 3;
      final isUrl =
          line.toLowerCase().contains('www.') ||
          line.toLowerCase().contains('.com');

      if (!isNumberOrMath &&
          !isPhone &&
          !isDate &&
          !isTime &&
          !isTooShort &&
          !isUrl) {
        return line;
      }
    }
    return lines.first;
  }

  double? _extractAmount(List<String> lines) {
    // Search for lines containing keywords like total, amount, grand, due.
    final totalKeywords = [
      'total',
      'amount',
      'due',
      'payable',
      'net',
      'sum',
      'grand total',
    ];

    // Collect all numbers in the text that look like prices/amounts (e.g. 10.99)
    final priceRegex = RegExp(r'\b\d+[\.,]\d{2}\b');
    final List<double> allPrices = [];

    double? totalFromKeywords;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].toLowerCase();

      // Collect any price found on this line
      for (final match in priceRegex.allMatches(line)) {
        final val = double.tryParse(match.group(0)!.replaceAll(',', '.'));
        if (val != null) {
          allPrices.add(val);
        }
      }

      // Check for total keywords
      final matchesKeyword = totalKeywords.any((kw) => line.contains(kw));
      if (matchesKeyword) {
        // Exclude lines with change, cash, visa, card, tax, subtotal
        final ignoreKeywords = [
          'change',
          'cash',
          'tendered',
          'subtotal',
          'tax',
          'balance',
        ];
        if (ignoreKeywords.any((ikw) => line.contains(ikw))) {
          continue;
        }

        // Try to extract a decimal number from this line
        final numMatch = priceRegex.firstMatch(line);
        if (numMatch != null) {
          final val = double.tryParse(numMatch.group(0)!.replaceAll(',', '.'));
          if (val != null) {
            totalFromKeywords = val;
          }
        } else {
          // If no number on this line, check the next line if it is just a price
          if (i + 1 < lines.length) {
            final nextLine = lines[i + 1].trim();
            if (priceRegex.hasMatch(nextLine)) {
              final val = double.tryParse(
                nextLine.replaceAll(RegExp(r'[^\d.]'), ''),
              );
              if (val != null) {
                totalFromKeywords = val;
              }
            }
          }
        }
      }
    }

    if (totalFromKeywords != null) {
      return totalFromKeywords;
    }

    // Fallback: Use the largest number found on the receipt under 10000.
    if (allPrices.isNotEmpty) {
      final validPrices = allPrices.where((p) => p < 10000.0).toList();
      if (validPrices.isNotEmpty) {
        validPrices.sort();
        return validPrices.last;
      }
    }

    return null;
  }

  DateTime? _extractDate(String text) {
    // Search for patterns: MM/DD/YYYY, DD/MM/YYYY, YYYY-MM-DD
    final dateRegex = RegExp(r'\b(\d{1,4})[/\-.](\d{1,2})[/\-.](\d{1,4})\b');
    final matches = dateRegex.allMatches(text);

    for (final match in matches) {
      final part1 = int.tryParse(match.group(1) ?? '');
      final part2 = int.tryParse(match.group(2) ?? '');
      final part3 = int.tryParse(match.group(3) ?? '');

      if (part1 == null || part2 == null || part3 == null) continue;

      // Case 1: YYYY-MM-DD
      if (part1 > 1000 && part2 <= 12 && part3 <= 31) {
        return DateTime(part1, part2, part3);
      }

      // Case 2: DD-MM-YYYY or MM-DD-YYYY
      if (part3 > 1000) {
        if (part2 <= 12 && part1 <= 31) {
          if (part1 > 12) {
            return DateTime(part3, part2, part1);
          } else {
            return DateTime(part3, part1, part2);
          }
        }
      }

      // Case 3: 2-digit years (e.g. YY)
      if (part3 < 100 && part3 >= 0) {
        final year = part3 + 2000;
        if (part2 <= 12 && part1 <= 31) {
          if (part1 > 12) {
            return DateTime(year, part2, part1);
          } else {
            return DateTime(year, part1, part2);
          }
        }
      }
    }
    return null;
  }

  void dispose() {
    _textRecognizer.close();
  }
}
