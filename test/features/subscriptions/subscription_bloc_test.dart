import 'package:bloc_test/bloc_test.dart';
import 'package:budget_tracker/features/subscriptions/subscription_bloc.dart';
import 'package:budget_tracker/features/subscriptions/subscription_event.dart';
import 'package:budget_tracker/features/subscriptions/subscription_state.dart';
import 'package:budget_tracker/models/transaction.dart';
import 'package:budget_tracker/services/database_service.dart';
import 'package:budget_tracker/services/transaction_analysis_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'subscription_bloc_test.mocks.dart';

@GenerateMocks([DatabaseService, TransactionAnalysisService])
void main() {
  group('SubscriptionBloc', () {
    late MockDatabaseService mockDatabaseService;
    late MockTransactionAnalysisService mockAnalysisService;
    late SubscriptionBloc subscriptionBloc;

    setUp(() {
      mockDatabaseService = MockDatabaseService();
      mockAnalysisService = MockTransactionAnalysisService();
      subscriptionBloc = SubscriptionBloc(
        databaseService: mockDatabaseService,
        analysisService: mockAnalysisService,
      );
    });

    final t1 = Transaction(id: '1', title: 'Netflix', amount: 15.99, date: DateTime(2023, 1, 15), categoryId: 'entertainment', type: TransactionType.expense);
    final s1 = Subscription(name: 'Netflix', averageAmount: 15.99, nextDueDate: DateTime(2023, 2, 15));

    blocTest<SubscriptionBloc, SubscriptionState>(
      'emits [SubscriptionLoading, SubscriptionLoaded] when LoadSubscriptions is added successfully',
      build: () {
        when(mockDatabaseService.getTransactions()).thenAnswer((_) async => [t1]);
        when(mockAnalysisService.detectSubscriptions(any)).thenAnswer((_) async => [s1]);
        return subscriptionBloc;
      },
      act: (bloc) => bloc.add(LoadSubscriptions()),
      expect: () => [
        SubscriptionLoading(),
        SubscriptionLoaded(subscriptions: [s1]),
      ],
      verify: (_) {
        verify(mockDatabaseService.getTransactions()).called(1);
        verify(mockAnalysisService.detectSubscriptions(any)).called(1);
      },
    );

    blocTest<SubscriptionBloc, SubscriptionState>(
      'emits [SubscriptionLoading, SubscriptionError] when LoadSubscriptions fails',
      build: () {
        when(mockDatabaseService.getTransactions()).thenThrow(Exception('DB Error'));
        return subscriptionBloc;
      },
      act: (bloc) => bloc.add(LoadSubscriptions()),
      expect: () => [
        SubscriptionLoading(),
        isA<SubscriptionError>(),
      ],
      verify: (_) {
        verify(mockDatabaseService.getTransactions()).called(1);
        verifyNever(mockAnalysisService.detectSubscriptions(any));
      },
    );
  });
}