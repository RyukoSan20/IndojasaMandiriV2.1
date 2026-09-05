import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('fintrack_relational.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // 1. Profil Pengguna
    await db.execute('''
      CREATE TABLE user_profile (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        primary_currency TEXT NOT NULL,
        has_monthly_income INTEGER NOT NULL,
        monthly_income REAL DEFAULT 0.0,
        use_allocation_hack INTEGER DEFAULT 1,
        created_at TEXT NOT NULL
      )
    ''');

    // 2. Buku Catatan / Ledger Books
    await db.execute('''
      CREATE TABLE ledger_books (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        is_default INTEGER DEFAULT 0
      )
    ''');

    // 3. Rekening / Accounts (E-Wallet, Banking, VA, Valas, Cash)
    await db.execute('''
      CREATE TABLE accounts (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        balance REAL NOT NULL,
        currency_code TEXT NOT NULL,
        bank_name TEXT
      )
    ''');

    // 4. Transaksi Relasional
    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        book_id TEXT,
        account_id TEXT NOT NULL,
        type TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        description TEXT NOT NULL,
        date TEXT NOT NULL,
        FOREIGN KEY (account_id) REFERENCES accounts (id) ON DELETE CASCADE,
        FOREIGN KEY (book_id) REFERENCES ledger_books (id) ON DELETE SET NULL
      )
    ''');

    // 5. Aturan Alokasi (50/5/30/15)
    await db.execute('''
      CREATE TABLE allocation_rules (
        id TEXT PRIMARY KEY,
        needs_ratio REAL DEFAULT 0.50,
        wants_ratio REAL DEFAULT 0.05,
        invest_ratio REAL DEFAULT 0.30,
        emergency_ratio REAL DEFAULT 0.15
      )
    ''');

    // Default book record awal
    await db.execute('''
      INSERT INTO ledger_books (id, name, description, is_default)
      VALUES ('default_book', 'Buku Utama', 'Buku pencatatan keuangan harian', 1)
    ''');
  }
}
