import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:budget_tracker/features/add_transaction/transaction_bloc.dart';
import 'package:budget_tracker/models/transaction.dart';
import 'package:intl/intl.dart';

class ReportingScreen extends StatelessWidget {
  const ReportingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
      ),
      body: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          if (state is TransactionLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is TransactionLoaded) {
            return Column(
              children: [
                SizedBox(
                  height: 300,
                  child: PieChart(
                    PieChartData(
                      sections: _generateSections(state.transactions),
                    ),
                  ),
                ),
                SizedBox(
                  height: 300,
                  child: BarChart(
                    BarChartData(
                      barGroups: _generateBarGroups(state.transactions),
                    ),
                  ),
                ),
                SizedBox(
                  height: 300,
                  child: LineChart(
                    LineChartData(
                      lineBarsData: _generateLineBarsData(state.transactions),
                    ),
                  ),
                ),
              ],
            );
          }
          if (state is TransactionError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: Text('No data to display.'));
        },
      ),
    );
  }

  List<PieChartSectionData> _generateSections(List<Transaction> transactions) {
    final Map<String, double> spendingByCategory = {};
    for (var transaction in transactions) {
      if (transaction.amount < 0) {
        spendingByCategory.update(
          transaction.categoryId,
          (value) => value + transaction.amount.abs(),
          ifAbsent: () => transaction.amount.abs(),
        );
      }
    }

    return spendingByCategory.entries.map((entry) {
      return PieChartSectionData(
        value: entry.value,
        title: entry.key,
        radius: 100,
      );
    }).toList();
  }

  List<BarChartGroupData> _generateBarGroups(List<Transaction> transactions) {
    final Map<String, double> spendingByCategory = {};
    for (var transaction in transactions) {
      if (transaction.amount < 0) {
        spendingByCategory.update(
          transaction.categoryId,
          (value) => value + transaction.amount.abs(),
          ifAbsent: () => transaction.amount.abs(),
        );
      }
    }

    return spendingByCategory.entries.map((entry) {
      return BarChartGroupData(
        x: entry.key.hashCode,
        barRods: [
          BarChartRodData(
            toY: entry.value,
            color: Colors.lightBlue,
          ),
        ],
      );
    }).toList();
  }

  List<LineChartBarData> _generateLineBarsData(List<Transaction> transactions) {
    final Map<DateTime, double> spendingByDay = {};
    for (var transaction in transactions) {
      if (transaction.amount < 0) {
        final day = DateTime(
            transaction.date.year, transaction.date.month, transaction.date.day);
        spendingByDay.update(
          day,
          (value) => value + transaction.amount.abs(),
          ifAbsent: () => transaction.amount.abs(),
        );
      }
    }

    final sortedSpendingByDay = spendingByDay.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return [
      LineChartBarData(
        spots: sortedSpendingByDay
            .map((entry) => FlSpot(
                entry.key.millisecondsSinceEpoch.toDouble(), entry.value))
            .toList(),
        isCurved: true,
        color: Colors.blue,
        barWidth: 3,
        isStrokeCapRound: true,
        belowBarData: BarAreaData(show: false),
      ),
    ];
  }
}
