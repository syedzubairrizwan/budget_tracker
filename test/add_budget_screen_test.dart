import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:budget_tracker/features/manage_budgets/add_budget_screen.dart';
import 'package:budget_tracker/features/manage_budgets/budget_bloc.dart';
import 'package:budget_tracker/features/manage_categories/category_bloc.dart';
import 'package:budget_tracker/models/category.dart';
import 'package:mocktail/mocktail.dart';

class MockBudgetBloc extends Mock implements BudgetBloc {}
class MockCategoryBloc extends Mock implements CategoryBloc {}

void main() {
  late MockBudgetBloc mockBudgetBloc;
  late MockCategoryBloc mockCategoryBloc;

  setUp(() {
    mockBudgetBloc = MockBudgetBloc();
    mockCategoryBloc = MockCategoryBloc();

    when(() => mockBudgetBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockCategoryBloc.stream).thenAnswer((_) => const Stream.empty());

    when(() => mockCategoryBloc.state).thenReturn(CategoryLoaded(categories: [
      Category(id: 'food', name: 'Food & Dining', icon: '🍔', color: '#FF5722'),
    ]));
  });

  testWidgets('AddBudgetScreen has Overall Budget option', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<BudgetBloc>.value(value: mockBudgetBloc),
            BlocProvider<CategoryBloc>.value(value: mockCategoryBloc),
          ],
          child: const AddBudgetScreen(),
        ),
      ),
    );

    // Open dropdown
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();

    // Verify 'Overall Budget' text present
    expect(find.text('📊 Overall Budget'), findsOneWidget);
  });
}
