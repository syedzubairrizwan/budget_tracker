import 'package:bloc_test/bloc_test.dart';
import 'package:budget_tracker/core/constants.dart';
import 'package:budget_tracker/features/add_transaction/transaction_bloc.dart';
import 'package:budget_tracker/features/manage_budgets/budget_bloc.dart';
import 'package:budget_tracker/features/manage_categories/category_bloc.dart';
import 'package:budget_tracker/features/manage_goals/goal_bloc.dart';
import 'package:budget_tracker/features/insights/insight_bloc.dart';
import 'package:budget_tracker/features/insights/insight_state.dart';
import 'package:budget_tracker/features/insights/insight_event.dart';
import 'package:budget_tracker/homepage.dart';
import 'package:budget_tracker/models/budget.dart';
import 'package:budget_tracker/models/category.dart';
import 'package:budget_tracker/models/goal.dart';
import 'package:budget_tracker/models/transaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockTransactionBloc extends MockBloc<TransactionEvent, TransactionState>
    implements TransactionBloc {}

class MockCategoryBloc extends MockBloc<CategoryEvent, CategoryState>
    implements CategoryBloc {}

class MockBudgetBloc extends MockBloc<BudgetEvent, BudgetState>
    implements BudgetBloc {}

class MockGoalBloc extends MockBloc<GoalEvent, GoalState> implements GoalBloc {}

class MockInsightBloc extends MockBloc<InsightEvent, InsightState> implements InsightBloc {}

void main() {
  late MockTransactionBloc mockTransactionBloc;
  late MockCategoryBloc mockCategoryBloc;
  late MockBudgetBloc mockBudgetBloc;
  late MockGoalBloc mockGoalBloc;
  late MockInsightBloc mockInsightBloc;

  final testCategory = Category(id: '1', name: 'Groceries', icon: Icons.shopping_cart.codePoint.toString());
  final testTransactions = [
    Transaction(
      id: '1',
      title: 'Milk',
      amount: 5.00,
      date: DateTime.now(),
      categoryId: '1',
      type: TransactionType.expense,
    ),
    Transaction(
      id: '2',
      title: 'Salary',
      amount: 100.00,
      date: DateTime.now(),
      categoryId: '1',
      type: TransactionType.income,
    ),
  ];

  setUp(() {
    mockTransactionBloc = MockTransactionBloc();
    mockCategoryBloc = MockCategoryBloc();
    mockBudgetBloc = MockBudgetBloc();
    mockGoalBloc = MockGoalBloc();
    mockInsightBloc = MockInsightBloc();

    when(() => mockBudgetBloc.state).thenReturn(BudgetLoaded(budgets: []));
    when(() => mockGoalBloc.state).thenReturn(GoalLoaded(goals: []));
    when(() => mockInsightBloc.state).thenReturn(const InsightLoaded(insights: []));
  });

  Widget createWidgetUnderTest() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TransactionBloc>.value(value: mockTransactionBloc),
        BlocProvider<CategoryBloc>.value(value: mockCategoryBloc),
        BlocProvider<BudgetBloc>.value(value: mockBudgetBloc),
        BlocProvider<GoalBloc>.value(value: mockGoalBloc),
        BlocProvider<InsightBloc>.value(value: mockInsightBloc),
      ],
      child: const MaterialApp(
        home: HomePage(),
      ),
    );
  }

  testWidgets('shows empty state when there are no transactions',
      (WidgetTester tester) async {
    when(() => mockTransactionBloc.state)
        .thenReturn(const TransactionLoaded(transactions: []));
    when(() => mockCategoryBloc.state)
        .thenReturn(CategoryLoaded(categories: [testCategory]));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('No transactions yet'), findsOneWidget);
    expect(find.widgetWithIcon(ElevatedButton, Icons.add), findsOneWidget);
  });

  testWidgets('displays transaction list and calculates balance correctly',
      (WidgetTester tester) async {
    when(() => mockTransactionBloc.state)
        .thenReturn(TransactionLoaded(transactions: testTransactions));
    when(() => mockCategoryBloc.state)
        .thenReturn(CategoryLoaded(categories: [testCategory]));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Verify balance is correct (100 income - 5 expense = 95)
    expect(find.text('\$95.00'), findsOneWidget);

    // Verify transactions are displayed
    expect(find.text('Milk'), findsOneWidget);
    expect(find.text('Salary'), findsOneWidget);

    // Verify income/expense colors
    final milkAmount = tester.widget<Text>(find.text('- \$5.00'));
    expect(milkAmount.style?.color, const Color(0xFFFF3B30));

    final salaryAmount = tester.widget<Text>(find.text('+ \$100.00'));
    expect(salaryAmount.style?.color, const Color(0xFF34C759));
  });
}