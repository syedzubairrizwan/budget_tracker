import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

class ReceiptData {
  final String? merchantName;
  final double? amount;
  final DateTime? date;

  ReceiptData({this.merchantName, this.amount, this.date});
}

class OcrService {
  final ImagePicker _picker = ImagePicker();
  final TextRecognizer _textRecognizer = TextRecognizer();

  Future<ReceiptData?> pickImageAndExtractData() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image == null) {
      return null;
    }

    final inputImage = InputImage.fromFilePath(image.path);
    final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

    return _parseReceipt(recognizedText.text);
  }

  ReceiptData _parseReceipt(String text) {
    final lines = text.split('\n');
    String? merchantName;
    double? amount;
    DateTime? date;

    // 1. Try to get merchant name (usually first line)
    if (lines.isNotEmpty) {
      merchantName = lines.first.trim();
    }

    // 2. Try to get amount
    // Look for patterns like "Total: $12.34", "Total 12.34", "$12.34", etc.
    final amountRegExp = RegExp(r'(?:TOTAL|AMOUNT|DUE)[:\s]*\$?\s?(\d+[\.,]\d{2})', caseSensitive: false);
    final allAmountMatches = amountRegExp.allMatches(text);

    if (allAmountMatches.isNotEmpty) {
      // Often the last "Total" mentioned is the final one
      final lastMatch = allAmountMatches.last;
      final amountStr = lastMatch.group(1)?.replaceAll(',', '.');
      if (amountStr != null) {
        amount = double.tryParse(amountStr);
      }
    } else {
      // Fallback: look for any dollar-like amount and take the largest one
      final genericAmountRegExp = RegExp(r'\$?\s?(\d+[\.,]\d{2})');
      final matches = genericAmountRegExp.allMatches(text);
      double maxFound = 0;
      for (final match in matches) {
        final val = double.tryParse(match.group(1)?.replaceAll(',', '.') ?? '');
        if (val != null && val > maxFound) {
          maxFound = val;
        }
      }
      if (maxFound > 0) amount = maxFound;
    }

    // 3. Try to get date
    final dateRegExp = RegExp(r'(\d{1,2}[/-]\d{1,2}[/-]\d{2,4})');
    final dateMatch = dateRegExp.firstMatch(text);
    if (dateMatch != null) {
      final dateStr = dateMatch.group(1);
      if (dateStr != null) {
        // Simple attempt to parse. In a real app, you'd handle multiple formats.
        date = _parseDate(dateStr);
      }
    }

    return ReceiptData(
      merchantName: merchantName,
      amount: amount,
      date: date,
    );
  }

  DateTime? _parseDate(String dateStr) {
    try {
      // This is very basic, real-world apps use more robust date parsing
      final parts = dateStr.split(RegExp(r'[/-]'));
      if (parts.length == 3) {
        int day, month, year;
        if (parts[0].length == 4) {
          year = int.parse(parts[0]);
          month = int.parse(parts[1]);
          day = int.parse(parts[2]);
        } else {
          day = int.parse(parts[0]);
          month = int.parse(parts[1]);
          year = int.parse(parts[2]);
          if (year < 100) year += 2000;
        }
        return DateTime(year, month, day);
      }
    } catch (_) {}
    return null;
  }

  void dispose() {
    _textRecognizer.close();
  }
}
