import 'package:budget_tracker/models/goal.dart';
import 'package:budget_tracker/models/budget.dart';
import 'package:budget_tracker/models/category.dart';
import 'package:sqflite/sqflite.dart' hide Transaction;
import 'package:path/path.dart';
import 'package:budget_tracker/models/transaction.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('budget.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    final db = await openDatabase(path,
        version: 2, onCreate: _createDB, onUpgrade: _onUpgrade);
    
    // Check if categories exist, if not insert default ones
    await _ensureDefaultCategories(db);
    
    return db;
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
          "ALTER TABLE transactions ADD COLUMN type TEXT NOT NULL DEFAULT 'expense'");
    }
  }

  Future _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const doubleType = 'REAL NOT NULL';

    await db.execute('''
CREATE TABLE transactions (
  id $idType,
  title $textType,
  amount $doubleType,
  date $textType,
  categoryId $textType,
  type $textType
  )
''');

    await db.execute('''
CREATE TABLE categories (
  id $idType,
  name $textType,
  icon $textType
)
''');

    await db.execute('''
CREATE TABLE budgets (
  id $idType,
  categoryId $textType,
  amount $doubleType,
  spentAmount $doubleType
)
''');

    await db.execute('''
CREATE TABLE goals (
  id $idType,
  name $textType,
  targetAmount $doubleType,
  currentAmount $doubleType
)
''');

    // Insert default categories
    await _insertDefaultCategories(db);
  }

  Future<void> _insertDefaultCategories(Database db) async {
    final defaultCategories = [
      {'id': 'food', 'name': 'Food & Dining', 'icon': 'restaurant'},
      {'id': 'transport', 'name': 'Transportation', 'icon': 'directions_car'},
      {'id': 'shopping', 'name': 'Shopping', 'icon': 'shopping_bag'},
      {'id': 'entertainment', 'name': 'Entertainment', 'icon': 'movie'},
      {'id': 'bills', 'name': 'Bills & Utilities', 'icon': 'receipt'},
      {'id': 'health', 'name': 'Healthcare', 'icon': 'local_hospital'},
      {'id': 'education', 'name': 'Education', 'icon': 'school'},
      {'id': 'travel', 'name': 'Travel', 'icon': 'flight'},
      {'id': 'income', 'name': 'Salary', 'icon': 'work'},
      {'id': 'freelance', 'name': 'Freelance', 'icon': 'laptop'},
      {'id': 'investment', 'name': 'Investment', 'icon': 'trending_up'},
      {'id': 'other', 'name': 'Other', 'icon': 'more_horiz'},
    ];

    for (final category in defaultCategories) {
      await db.insert('categories', category, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }

  Future<void> _ensureDefaultCategories(Database db) async {
    final categories = await db.query('categories');
    if (categories.isEmpty) {
      await _insertDefaultCategories(db);
    }
  }

  Future<void> insertTransaction(Transaction transaction) async {
    final db = await instance.database;
    await db.insert('transactions', transaction.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Transaction>> getTransactions() async {
    final db = await instance.database;
    final maps = await db.query('transactions', orderBy: 'date DESC');

    if (maps.isEmpty) {
      return [];
    }

    return List.generate(maps.length, (i) {
      return Transaction.fromMap(maps[i]);
    });
  }

  Future<void> updateTransaction(Transaction transaction) async {
    final db = await instance.database;
    await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<void> deleteTransaction(String id) async {
    final db = await instance.database;
    await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> insertCategory(Category category) async {
    final db = await instance.database;
    await db.insert('categories', category.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Category>> getCategories() async {
    final db = await instance.database;
    final maps = await db.query('categories');

    if (maps.isEmpty) {
      return [];
    }

    return List.generate(maps.length, (i) {
      return Category.fromMap(maps[i]);
    });
  }

  Future<void> updateCategory(Category category) async {
    final db = await instance.database;
    await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<void> deleteCategory(String id) async {
    final db = await instance.database;
    await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> insertBudget(Budget budget) async {
    final db = await instance.database;
    await db.insert('budgets', budget.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Budget>> getBudgets() async {
    final db = await instance.database;
    final maps = await db.query('budgets');

    if (maps.isEmpty) {
      return [];
    }

    return List.generate(maps.length, (i) {
      return Budget.fromMap(maps[i]);
    });
  }

  Future<void> updateBudget(Budget budget) async {
    final db = await instance.database;
    await db.update(
      'budgets',
      budget.toMap(),
      where: 'id = ?',
      whereArgs: [budget.id],
    );
  }

  Future<void> deleteBudget(String id) async {
    final db = await instance.database;
    await db.delete(
      'budgets',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> insertGoal(Goal goal) async {
    final db = await instance.database;
    await db.insert('goals', goal.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Goal>> getGoals() async {
    final db = await instance.database;
    final maps = await db.query('goals');

    if (maps.isEmpty) {
      return [];
    }

    return List.generate(maps.length, (i) {
      return Goal.fromMap(maps[i]);
    });
  }

  Future<void> updateGoal(Goal goal) async {
    final db = await instance.database;
    await db.update(
      'goals',
      goal.toMap(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }

  Future<void> deleteGoal(String id) async {
    final db = await instance.database;
    await db.delete(
      'goals',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}