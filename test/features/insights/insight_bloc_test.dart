import 'package:bloc_test/bloc_test.dart';
import 'package:budget_tracker/features/insights/insight_bloc.dart';
import 'package:budget_tracker/features/insights/insight_event.dart';
import 'package:budget_tracker/features/insights/insight_state.dart';
import 'package:budget_tracker/models/category.dart';
import 'package:budget_tracker/models/transaction.dart';
import 'package:budget_tracker/services/database_service.dart';
import 'package:budget_tracker/services/transaction_analysis_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'insight_bloc_test.mocks.dart';

@GenerateMocks([DatabaseService, TransactionAnalysisService])
void main() {
  group('InsightBloc', () {
    late MockDatabaseService mockDatabaseService;
    late MockTransactionAnalysisService mockAnalysisService;
    late InsightBloc insightBloc;

    setUp(() {
      mockDatabaseService = MockDatabaseService();
      mockAnalysisService = MockTransactionAnalysisService();
      insightBloc = InsightBloc(
        databaseService: mockDatabaseService,
        analysisService: mockAnalysisService,
      );
    });

    final t1 = Transaction(id: '1', title: 'Groceries', amount: 100.0, date: DateTime.now(), categoryId: 'food', type: TransactionType.expense);
    final c1 = Category(id: 'food', name: 'Food & Dining', icon: '');
    final i1 = Insight(title: 'Test Insight', description: 'Test Description');

    blocTest<InsightBloc, InsightState>(
      'emits [InsightLoading, InsightLoaded] when LoadInsights is added successfully',
      build: () {
        when(mockDatabaseService.getTransactions()).thenAnswer((_) async => [t1]);
        when(mockDatabaseService.getCategories()).thenAnswer((_) async => [c1]);
        when(mockAnalysisService.getSpendingInsights(any, any)).thenAnswer((_) async => [i1]);
        return insightBloc;
      },
      act: (bloc) => bloc.add(LoadInsights()),
      expect: () => [
        InsightLoading(),
        InsightLoaded(insights: [i1]),
      ],
      verify: (_) {
        verify(mockDatabaseService.getTransactions()).called(1);
        verify(mockDatabaseService.getCategories()).called(1);
        verify(mockAnalysisService.getSpendingInsights(any, any)).called(1);
      },
    );

    blocTest<InsightBloc, InsightState>(
      'emits [InsightLoading, InsightError] when LoadInsights fails',
      build: () {
        when(mockDatabaseService.getTransactions()).thenThrow(Exception('DB Error'));
        return insightBloc;
      },
      act: (bloc) => bloc.add(LoadInsights()),
      expect: () => [
        InsightLoading(),
        isA<InsightError>(),
      ],
      verify: (_) {
        verify(mockDatabaseService.getTransactions()).called(1);
        verifyNever(mockDatabaseService.getCategories());
        verifyNever(mockAnalysisService.getSpendingInsights(any, any));
      },
    );
  });
}