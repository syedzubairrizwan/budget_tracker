import 'package:bloc_test/bloc_test.dart';
import 'package:budget_tracker/features/add_transaction/add_transaction_screen.dart';
import 'package:budget_tracker/features/add_transaction/transaction_bloc.dart';
import 'package:budget_tracker/features/manage_categories/category_bloc.dart';
import 'package:budget_tracker/models/category.dart';
import 'package:budget_tracker/models/transaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCategoryBloc extends MockBloc<CategoryEvent, CategoryState>
    implements CategoryBloc {}

class MockTransactionBloc extends MockBloc<TransactionEvent, TransactionState>
    implements TransactionBloc {}

void main() {
  late MockCategoryBloc mockCategoryBloc;
  late MockTransactionBloc mockTransactionBloc;
  final testCategory = Category(id: '1', name: 'Food', icon: Icons.fastfood.codePoint.toString());
  final testCategories = [testCategory];

  setUpAll(() {
    registerFallbackValue(AddTransaction(
      transaction: Transaction(
        id: '1',
        title: 'test',
        amount: 10,
        date: DateTime.now(),
        categoryId: '1',
      ),
    ));
  });

  setUp(() {
    mockCategoryBloc = MockCategoryBloc();
    mockTransactionBloc = MockTransactionBloc();
    when(() => mockCategoryBloc.state)
        .thenReturn(CategoryLoaded(categories: testCategories));
    when(() => mockTransactionBloc.state)
        .thenReturn(const TransactionLoaded(transactions: []));
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

  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();
  }

  Future<void> fillForm(WidgetTester tester) async {
    await tester.enterText(find.byType(TextFormField).at(0), 'Groceries');
    await tester.enterText(find.byType(TextFormField).at(1), '50.00');
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Food').last);
    await tester.pumpAndSettle();
  }

  testWidgets(
      'shows error message when amount is not positive and does not add transaction',
      (WidgetTester tester) async {
    await pumpScreen(tester);
    await tester.enterText(find.byType(TextFormField).at(0), 'Groceries');
    await tester.enterText(find.byType(TextFormField).at(1), '-50');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    expect(find.text('Please enter a positive amount'), findsOneWidget);
    verifyNever(() => mockTransactionBloc.add(any()));
  });

  testWidgets('adds expense transaction when expense is selected',
      (WidgetTester tester) async {
    await pumpScreen(tester);
    await fillForm(tester);

    // Expense is selected by default
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    final captured =
        verify(() => mockTransactionBloc.add(captureAny())).captured.first
            as AddTransaction;
    expect(captured.transaction.title, 'Groceries');
    expect(captured.transaction.amount, 50.00);
    expect(captured.transaction.type, TransactionType.expense);
  });

  testWidgets('adds income transaction when income is selected',
      (WidgetTester tester) async {
    await pumpScreen(tester);
    await fillForm(tester);

    await tester.tap(find.text('Income'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    final captured =
        verify(() => mockTransactionBloc.add(captureAny())).captured.first
            as AddTransaction;
    expect(captured.transaction.title, 'Groceries');
    expect(captured.transaction.amount, 50.00);
    expect(captured.transaction.type, TransactionType.income);
  });
}