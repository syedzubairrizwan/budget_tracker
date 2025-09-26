import 'package:budget_tracker/core/theme.dart';
import 'package:budget_tracker/features/add_transaction/transaction_bloc.dart';
import 'package:budget_tracker/features/manage_categories/category_bloc.dart';
import 'package:budget_tracker/features/manage_budgets/budget_bloc.dart';
import 'package:budget_tracker/features/manage_goals/goal_bloc.dart';
import 'package:budget_tracker/homepage.dart';
import 'package:budget_tracker/services/database_service.dart';
import 'package:budget_tracker/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService.instance.database;
  await NotificationService().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => TransactionBloc(
            databaseService: DatabaseService.instance,
            notificationService: NotificationService(),
          )..add(LoadTransactions()),
        ),
        BlocProvider(
          create: (context) => CategoryBloc(
            databaseService: DatabaseService.instance,
          )..add(LoadCategories()),
        ),
        BlocProvider(
          create: (context) => BudgetBloc(
            databaseService: DatabaseService.instance,
          )..add(LoadBudgets()),
        ),
        BlocProvider(
          create: (context) => GoalBloc(
            databaseService: DatabaseService.instance,
          )..add(LoadGoals()),
        ),
      ],
      child: MaterialApp(
        title: 'budget_tracker',
        debugShowCheckedModeBanner: false,
        theme: appTheme,
        home: const HomePage(),
      ),
    );
  }
}
