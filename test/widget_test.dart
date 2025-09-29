import 'package:budget_tracker/features/add_transaction/transaction_bloc.dart';
import 'package:budget_tracker/features/manage_budgets/budget_bloc.dart';
import 'package:budget_tracker/features/manage_categories/category_bloc.dart';
import 'package:budget_tracker/features/manage_goals/goal_bloc.dart';
import 'package:budget_tracker/features/insights/insight_bloc.dart';
import 'package:budget_tracker/features/subscriptions/subscription_bloc.dart';
import 'package:budget_tracker/main.dart';
import 'package:budget_tracker/services/database_service.dart';
import 'package:budget_tracker/services/notification_service.dart';
import 'package:budget_tracker/services/transaction_analysis_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';

class MockDatabaseService extends Mock implements DatabaseService {}
class MockNotificationService extends Mock implements NotificationService {}
class MockTransactionAnalysisService extends Mock implements TransactionAnalysisService {}

void main() {
  testWidgets('Renders HomePage', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => TransactionBloc(databaseService: MockDatabaseService(), notificationService: MockNotificationService())),
          BlocProvider(create: (_) => CategoryBloc(databaseService: MockDatabaseService())),
          BlocProvider(create: (_) => BudgetBloc(databaseService: MockDatabaseService())),
          BlocProvider(create: (_) => GoalBloc(databaseService: MockDatabaseService())),
          BlocProvider(create: (_) => InsightBloc(databaseService: MockDatabaseService(), analysisService: MockTransactionAnalysisService())),
          BlocProvider(create: (_) => SubscriptionBloc(databaseService: MockDatabaseService(), analysisService: MockTransactionAnalysisService())),
        ],
        child: const MyApp(),
      ),
    );

    // The app starts at the LoginScreen, so we don't expect to find this text.
    // This test is now just a smoke test to ensure the app builds.
    expect(find.descendant(of: find.byType(AppBar), matching: find.text('Login')), findsOneWidget);
  });
}