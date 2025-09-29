import 'package:budget_tracker/features/auth/screens/registration_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:budget_tracker/features/add_transaction/transaction_bloc.dart';
import 'package:budget_tracker/features/manage_categories/category_bloc.dart';
import 'package:budget_tracker/features/manage_budgets/budget_bloc.dart';
import 'package:budget_tracker/features/manage_goals/goal_bloc.dart';
import 'package:budget_tracker/features/insights/insight_bloc.dart';
import 'package:budget_tracker/features/subscriptions/subscription_bloc.dart';
import 'package:budget_tracker/services/database_service.dart';
import 'package:budget_tracker/services/notification_service.dart';
import 'package:budget_tracker/services/transaction_analysis_service.dart';
import 'package:mockito/mockito.dart';

class MockDatabaseService extends Mock implements DatabaseService {}
class MockNotificationService extends Mock implements NotificationService {}

void main() {
  group('RegistrationScreen', () {
    testWidgets('should render all widgets and handle empty validation',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => TransactionBloc(databaseService: MockDatabaseService(), notificationService: MockNotificationService())),
            BlocProvider(create: (_) => CategoryBloc(databaseService: MockDatabaseService())),
            BlocProvider(create: (_) => BudgetBloc(databaseService: MockDatabaseService())),
            BlocProvider(create: (_) => GoalBloc(databaseService: MockDatabaseService())),
            BlocProvider(create: (_) => InsightBloc(databaseService: MockDatabaseService(), analysisService: TransactionAnalysisService())),
            BlocProvider(create: (_) => SubscriptionBloc(databaseService: MockDatabaseService(), analysisService: TransactionAnalysisService())),
          ],
          child: const MaterialApp(
            home: RegistrationScreen(),
          ),
        ),
      );

      // Verify that the widgets are present
      expect(find.text('Register'), findsNWidgets(2));
      expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Register'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Already have an account? Login'), findsOneWidget);

      // Test validation
      await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
      await tester.pump(); // Rebuild the widget after the validation error

      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });
  });
}