import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:budget_tracker/features/manage_budgets/manage_budgets_screen.dart';
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

    when(() => mockBudgetBloc.state).thenReturn(BudgetLoaded(budgets: []));
    when(() => mockTransactionBloc.state).thenReturn(TransactionLoaded(transactions: []));
    when(() => mockCategoryBloc.state).thenReturn(CategoryLoaded(categories: []));
  });

  testWidgets('Template dialog flow does not crash', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<BudgetBloc>.value(value: mockBudgetBloc),
            BlocProvider<TransactionBloc>.value(value: mockTransactionBloc),
            BlocProvider<CategoryBloc>.value(value: mockCategoryBloc),
          ],
          child: const ManageBudgetsScreen(),
        ),
      ),
    );

    // Verify placeholder UI
    expect(find.text('No budgets configured.'), findsOneWidget);

    // Open template dialog
    await tester.tap(find.byIcon(Icons.auto_awesome).first);
    await tester.pumpAndSettle();

    // Verify template names are displayed
    expect(find.text('Essential & Healthcare First'), findsOneWidget);

    // Tap on the first template card
    await tester.tap(find.text('Essential & Healthcare First'));
    await tester.pumpAndSettle();

    // Overwrite button should appear in the confirmation dialog
    expect(find.text('Overwrite'), findsOneWidget);

    // Tap Overwrite
    await tester.tap(find.text('Overwrite'));
    await tester.pumpAndSettle();
  });
}
