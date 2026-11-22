import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/transaction_model.dart';
class DbHelper {
  static Database? _database;
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await initDatabase();
    return _database!;
  }
  Future<Database> initDatabase() async {
    String databasePath = await getDatabasesPath();
    String path = join(databasePath, 'expense_tracker.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id TEXT NOT NULL,
            title TEXT,
            amount REAL,
            type TEXT,
            category TEXT,
            date TEXT,
            description TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'ALTER TABLE transactions ADD COLUMN user_id TEXT',
          );
        }
      },
    );
  }
  Future<int> insertTransaction(
      TransactionModel transaction) async {
    final db = await database;

    return await db.insert(
      'transactions',
      transaction.toMap(),
    );
  }
  Future<List<TransactionModel>> getTransactions(
      String userId) async {
    final db = await database;

    final maps = await db.query(
      'transactions',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'id DESC',
    );
    return List.generate(
      maps.length,
          (index) => TransactionModel.fromMap(maps[index]),
    );
  }
  Future<int> updateTransaction(
      TransactionModel transaction) async {
    final db = await database;

    return await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ? AND user_id = ?',
      whereArgs: [transaction.id, transaction.userId],
    );
  }
  Future<int> deleteTransaction(int id, String userId) async {
    final db = await database;

    return await db.delete(
      'transactions',
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
    );
  }
  Future<void> assignOldTransactionsToUser(String userId) async {
    final db = await database;

    await db.update(
      'transactions',
      {'user_id': userId},
      where: 'user_id IS NULL',
    );
  }
}