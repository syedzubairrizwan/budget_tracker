import 'dart:io';
import 'package:budget_tracker/models/transaction.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

class ExportService {
  Future<File> exportToCSV(List<Transaction> transactions) async {
    final List<String> csvData = [];
    // Header
    csvData.add('ID,Title,Amount,Date,Category,Type,Is Split,Split With,Split Amount');

    for (final tx in transactions) {
      csvData.add(
        '${tx.id},"${tx.title}",${tx.amount},${DateFormat('yyyy-MM-dd').format(tx.date)},${tx.categoryId},${tx.type.name},${tx.isSplit},"${tx.splitWith ?? ''}",${tx.splitAmount ?? ''}'
      );
    }

    final String csvString = csvData.join('\n');

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/transactions_${DateTime.now().millisecondsSinceEpoch}.csv');

    return await file.writeAsString(csvString);
  }

  // PDF export would typically use the 'pdf' package.
  // Given the environment constraints, I'll implement CSV as the primary format
  // which is most useful for financial data.
}
