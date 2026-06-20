import 'package:budget_tracker/models/goal.dart';
import 'package:budget_tracker/models/budget.dart';
import 'package:budget_tracker/models/category.dart';
import 'package:budget_tracker/models/planned_payment.dart';
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
        version: 10, onCreate: _createDB, onUpgrade: _onUpgrade);
    
    // Check if categories exist, if not insert default ones
    await _ensureDefaultCategories(db);
    
    return db;
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
          "ALTER TABLE transactions ADD COLUMN type TEXT NOT NULL DEFAULT 'expense'");
    }
    if (oldVersion < 3) {
      await db.execute("ALTER TABLE transactions ADD COLUMN isSplit INTEGER DEFAULT 0");
      await db.execute("ALTER TABLE transactions ADD COLUMN splitWith TEXT");
      await db.execute("ALTER TABLE transactions ADD COLUMN splitAmount REAL");
    }
    if (oldVersion < 4) {
      await db.execute("ALTER TABLE categories ADD COLUMN color TEXT DEFAULT '#1E88E5'");
    }
    if (oldVersion < 5) {
      await db.execute("ALTER TABLE goals ADD COLUMN deadline TEXT");
      await db.execute("ALTER TABLE goals ADD COLUMN icon TEXT");
    }
    if (oldVersion < 6) {
      await db.execute("ALTER TABLE transactions ADD COLUMN details TEXT");
    }
    if (oldVersion < 7) {
      // Add the 4 new categories for existing users
      final newCategories = [
        {'id': 'cash', 'name': 'Cash', 'icon': '💵', 'color': '#4CAF50'},
        {'id': 'celebration', 'name': 'Celebration', 'icon': '🎉', 'color': '#FFD700'},
        {'id': 'heart', 'name': 'Charity/Love', 'icon': '❤️', 'color': '#F44336'},
        {'id': 'weeping', 'name': 'Loss/Tears', 'icon': '😢', 'color': '#2196F3'},
      ];
      for (final category in newCategories) {
        await db.insert('categories', category, conflictAlgorithm: ConflictAlgorithm.ignore);
      }
    }
    if (oldVersion < 8) {
      await db.execute('''
CREATE TABLE planned_payments (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  type TEXT NOT NULL,
  categoryId TEXT NOT NULL,
  amount REAL NOT NULL,
  paymentMethod TEXT NOT NULL,
  payee TEXT NOT NULL,
  frequency TEXT NOT NULL,
  dueDate TEXT NOT NULL,
  notificationEnabled INTEGER NOT NULL DEFAULT 0,
  notes TEXT,
  isPaid INTEGER NOT NULL DEFAULT 0,
  paidDate TEXT
)
''');
    }
    if (oldVersion < 9) {
      await db.execute(
          "ALTER TABLE budgets ADD COLUMN priority TEXT NOT NULL DEFAULT 'Medium'");
    }
    if (oldVersion < 10) {
      await _addColumnIfNotExists(db, 'transactions', 'splitWithUserId', 'TEXT');
      await _addColumnIfNotExists(db, 'transactions', 'splitWithName', 'TEXT');
      await _addColumnIfNotExists(db, 'transactions', 'splitWithAvatar', 'TEXT');
      await _addColumnIfNotExists(db, 'transactions', 'splitGroupId', 'TEXT');
      await _addColumnIfNotExists(db, 'transactions', 'splitStatus', "TEXT DEFAULT 'none'");
      await _addColumnIfNotExists(db, 'transactions', 'isCreator', 'INTEGER DEFAULT 1');
    }
  }

  Future<void> _addColumnIfNotExists(
      Database db, String tableName, String columnName, String columnType) async {
    final columns = await db.rawQuery('PRAGMA table_info($tableName)');
    final columnExists = columns.any((column) => column['name'] == columnName);
    if (!columnExists) {
      await db.execute('ALTER TABLE $tableName ADD COLUMN $columnName $columnType');
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
  type $textType,
  details TEXT,
  isSplit INTEGER DEFAULT 0,
  splitWith TEXT,
  splitAmount REAL,
  splitWithUserId TEXT,
  splitWithName TEXT,
  splitWithAvatar TEXT,
  splitGroupId TEXT,
  splitStatus TEXT DEFAULT 'none',
  isCreator INTEGER DEFAULT 1
  )
''');

    await db.execute('''
CREATE TABLE categories (
  id $idType,
  name $textType,
  icon $textType,
  color $textType
)
''');

    await db.execute('''
CREATE TABLE budgets (
  id $idType,
  categoryId $textType,
  amount $doubleType,
  spentAmount $doubleType,
  priority TEXT NOT NULL DEFAULT 'Medium'
)
''');

    await db.execute('''
CREATE TABLE goals (
  id $idType,
  name $textType,
  targetAmount $doubleType,
  currentAmount $doubleType,
  deadline TEXT,
  icon TEXT
)
''');

    await db.execute('''
CREATE TABLE planned_payments (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  type TEXT NOT NULL,
  categoryId TEXT NOT NULL,
  amount REAL NOT NULL,
  paymentMethod TEXT NOT NULL,
  payee TEXT NOT NULL,
  frequency TEXT NOT NULL,
  dueDate TEXT NOT NULL,
  notificationEnabled INTEGER NOT NULL DEFAULT 0,
  notes TEXT,
  isPaid INTEGER NOT NULL DEFAULT 0,
  paidDate TEXT
)
''');

    // Insert default categories
    await _insertDefaultCategories(db);
  }

  Future<void> _insertDefaultCategories(Database db) async {
    final defaultCategories = [
      {'id': 'food', 'name': 'Food & Dining', 'icon': '🍔', 'color': '#FF5722'},
      {'id': 'transport', 'name': 'Transportation', 'icon': '🚗', 'color': '#2196F3'},
      {'id': 'shopping', 'name': 'Shopping', 'icon': '🛍️', 'color': '#E91E63'},
      {'id': 'entertainment', 'name': 'Entertainment', 'icon': '🍿', 'color': '#9C27B0'},
      {'id': 'bills', 'name': 'Bills & Utilities', 'icon': '💡', 'color': '#FBC02D'},
      {'id': 'health', 'name': 'Healthcare', 'icon': '💊', 'color': '#4CAF50'},
      {'id': 'education', 'name': 'Education', 'icon': '🎓', 'color': '#00BCD4'},
      {'id': 'travel', 'name': 'Travel', 'icon': '✈️', 'color': '#3F51B5'},
      {'id': 'income', 'name': 'Salary', 'icon': '💰', 'color': '#8BC34A'},
      {'id': 'freelance', 'name': 'Freelance', 'icon': '💻', 'color': '#607D8B'},
      {'id': 'investment', 'name': 'Investment', 'icon': '📈', 'color': '#009688'},
      {'id': 'cash', 'name': 'Cash', 'icon': '💵', 'color': '#4CAF50'},
      {'id': 'celebration', 'name': 'Celebration', 'icon': '🎉', 'color': '#FFD700'},
      {'id': 'heart', 'name': 'Charity/Love', 'icon': '❤️', 'color': '#F44336'},
      {'id': 'weeping', 'name': 'Loss/Tears', 'icon': '😢', 'color': '#2196F3'},
      {'id': 'other', 'name': 'Other', 'icon': '📌', 'color': '#9E9E9E'},
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

  Future<void> deleteAllBudgets() async {
    final db = await instance.database;
    await db.delete('budgets');
  }

  Future<List<Budget>> getBudgets() async {
    final db = await instance.database;
    final maps = await db.query('budgets');

    if (maps.isEmpty) {
      return [];
    }

    final budgets = List.generate(maps.length, (i) {
      return Budget.fromMap(maps[i]);
    });

    // Dynamically calculate spent amount from transactions of the current month
    final transactions = await getTransactions();
    final now = DateTime.now();
    final List<Budget> updatedBudgets = [];

    for (final budget in budgets) {
      final monthlySpent = budget.categoryId == 'overall'
          ? transactions
              .where((t) => t.type == TransactionType.expense &&
                            t.date.year == now.year &&
                            t.date.month == now.month)
              .fold<double>(0.0, (sum, t) => sum + t.amount)
          : transactions
              .where((t) => t.categoryId == budget.categoryId &&
                            t.type == TransactionType.expense &&
                            t.date.year == now.year &&
                            t.date.month == now.month)
              .fold<double>(0.0, (sum, t) => sum + t.amount);

      final updatedBudget = Budget(
        id: budget.id,
        categoryId: budget.categoryId,
        amount: budget.amount,
        spentAmount: monthlySpent,
        priority: budget.priority,
      );

      // Persist back to DB if spentAmount changed to keep local DB table consistent
      if (budget.spentAmount != monthlySpent) {
        await updateBudget(updatedBudget);
      }
      updatedBudgets.add(updatedBudget);
    }

    return updatedBudgets;
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

  Future<void> insertPlannedPayment(PlannedPayment payment) async {
    final db = await instance.database;
    await db.insert('planned_payments', payment.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<PlannedPayment>> getPlannedPayments() async {
    final db = await instance.database;
    final maps = await db.query('planned_payments');

    if (maps.isEmpty) {
      return [];
    }

    return List.generate(maps.length, (i) {
      return PlannedPayment.fromMap(maps[i]);
    });
  }

  Future<void> updatePlannedPayment(PlannedPayment payment) async {
    final db = await instance.database;
    await db.update(
      'planned_payments',
      payment.toMap(),
      where: 'id = ?',
      whereArgs: [payment.id],
    );
  }

  Future<void> deletePlannedPayment(String id) async {
    final db = await instance.database;
    await db.delete(
      'planned_payments',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearAllData() async {
    final db = await instance.database;
    await db.delete('transactions');
    await db.delete('budgets');
    await db.delete('goals');
    await db.delete('planned_payments');
    await db.delete('categories');
    await _insertDefaultCategories(db);
  }
}