import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:budget_tracker/features/manage_budgets/monthly_budgets_screen.dart';
import 'package:budget_tracker/features/manage_budgets/budget_bloc.dart';
import 'package:budget_tracker/features/add_transaction/transaction_bloc.dart';
import 'package:budget_tracker/features/manage_categories/category_bloc.dart';
import 'package:budget_tracker/models/budget.dart';
import 'package:budget_tracker/models/transaction.dart';
import 'package:budget_tracker/models/category.dart';
import 'package:mocktail/mocktail.dart';

class MockBudgetBloc extends Mock implements BudgetBloc {}
class MockTransactionBloc extends Mock implements TransactionBloc {}
class MockCategoryBloc extends Mock implements CategoryBloc {}

void main() {
  late MockBudgetBloc mockBudgetBloc;
  late MockTransactionBloc mockTransactionBloc;
  late MockCategoryBloc mockCategoryBloc;

  setUp(() {
    mockBudgetBloc = MockBudgetBloc();
    mockTransactionBloc = MockTransactionBloc();
    mockCategoryBloc = MockCategoryBloc();

    when(() => mockBudgetBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockTransactionBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockCategoryBloc.stream).thenAnswer((_) => const Stream.empty());

    // Setup stub responses
    when(() => mockBudgetBloc.state).thenReturn(BudgetLoaded(budgets: [
      Budget(id: '1', categoryId: 'overall', amount: 50000, spentAmount: 10000, priority: 'High'),
      Budget(id: '2', categoryId: 'food', amount: 15000, spentAmount: 5000, priority: 'Medium'),
    ]));
    when(() => mockTransactionBloc.state).thenReturn(TransactionLoaded(transactions: [
      Transaction(
        id: 't1',
        title: 'Dinner',
        amount: 2000,
        date: DateTime.now(),
        categoryId: 'food',
        type: TransactionType.expense,
      ),
      Transaction(
        id: 't2',
        title: 'Electricity Bill',
        amount: 8000,
        date: DateTime.now(),
        categoryId: 'bills',
        type: TransactionType.expense,
      ),
    ]));
    when(() => mockCategoryBloc.state).thenReturn(CategoryLoaded(categories: [
      Category(id: 'food', name: 'Food & Dining', icon: '🍔', color: '#FF5722'),
      Category(id: 'bills', name: 'Bills & Utilities', icon: '💡', color: '#FBC02D'),
    ]));
  });

  testWidgets('MonthlyBudgetsScreen renders heading and category scroll catalogue', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<BudgetBloc>.value(value: mockBudgetBloc),
            BlocProvider<TransactionBloc>.value(value: mockTransactionBloc),
            BlocProvider<CategoryBloc>.value(value: mockCategoryBloc),
          ],
          child: const MonthlyBudgetsScreen(),
        ),
      ),
    );

    // Verify Title
    expect(find.text('Monthly Budgets'), findsOneWidget);

    // Verify Overall budget catalogue item is displayed
    expect(find.text('Overall').first, findsOneWidget);

    // Verify Food budget catalogue item is displayed
    expect(find.text('Food & Dining'), findsOneWidget);

    // Verify Active category card shows spent details
    expect(find.text('Spent Amount'), findsOneWidget);
    expect(find.text('Total Budget Limit'), findsOneWidget);
  });
}
