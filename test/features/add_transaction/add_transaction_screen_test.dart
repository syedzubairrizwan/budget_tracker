import 'package:bloc_test/bloc_test.dart';
import 'package:budget_tracker/features/add_transaction/add_transaction_screen.dart';
import 'package:budget_tracker/features/add_transaction/transaction_bloc.dart';
import 'package:budget_tracker/features/manage_categories/category_bloc.dart';
import 'package:budget_tracker/models/category.dart';
import 'package:budget_tracker/services/database_service.dart';
import 'package:budget_tracker/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCategoryBloc extends MockBloc<CategoryEvent, CategoryState>
    implements CategoryBloc {}

class MockTransactionBloc extends MockBloc<TransactionEvent, TransactionState>
    implements TransactionBloc {}

class MockDatabaseService extends Mock implements DatabaseService {}

class MockNotificationService extends Mock implements NotificationService {}

void main() {
  late MockCategoryBloc mockCategoryBloc;
  late MockTransactionBloc mockTransactionBloc;

  setUp(() {
    mockCategoryBloc = MockCategoryBloc();
    mockTransactionBloc = MockTransactionBloc();
  });

  Widget createWidgetUnderTest() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<CategoryBloc>.value(value: mockCategoryBloc),
        BlocProvider<TransactionBloc>.value(value: mockTransactionBloc),
      ],
      child: const MaterialApp(
        home: AddTransactionScreen(),
      ),
    );
  }

  testWidgets(
      'shows error message when amount is negative and does not add transaction',
      (WidgetTester tester) async {
    when(() => mockCategoryBloc.state).thenReturn(
      CategoryLoaded(
        categories: [
          Category(id: '1', name: 'Food', icon: Icons.fastfood.codePoint)
        ],
      ),
    );

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Groceries');
    await tester.enterText(find.byType(TextFormField).at(1), '-50');
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Food').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    expect(find.text('Please enter a positive amount'), findsOneWidget);
    verifyNever(() => mockTransactionBloc.add(any())).called(0);
  });
}