import 'package:budget_tracker/core/theme_bloc.dart';

import 'package:budget_tracker/main.dart';
import 'package:budget_tracker/services/database_service.dart';
import 'package:budget_tracker/services/notification_service.dart';
import 'package:budget_tracker/services/transaction_analysis_service.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

class MockDatabaseService extends Mock implements DatabaseService {}
class MockNotificationService extends Mock implements NotificationService {}
class MockTransactionAnalysisService extends Mock implements TransactionAnalysisService {}

void main() {
  testWidgets('Renders LoginScreen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => ThemeBloc(),
        child: const MyApp(),
      ),
    );

    // The app starts at the LoginScreen
    expect(find.text('Login'), findsWidgets);
  });
}
