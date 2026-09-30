import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Point d'accès unique à la base SQLite locale de Tantsaha.
///
/// Singleton : une seule connexion ouverte pour toute l'application.
/// Ouvrir plusieurs connexions à la même base provoque des verrous
/// et des comportements imprévisibles.
class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  static const String _dbName = 'tantsaha.db';
  static const int _dbVersion = 1;

  static const String transactionsTable = 'transactions';

  Database? _database;

  /// Ouvre la base au premier appel, puis réutilise la même connexion.
  Future<Database> get database async {
    final existing = _database;
    if (existing != null) return existing;

    final dbPath = await getDatabasesPath();
    final db = await openDatabase(
      p.join(dbPath, _dbName),
      version: _dbVersion,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
    );
    _database = db;
    return db;
  }

  Future<void> _onConfigure(Database db) async {
    // Active les clés étrangères (utile dès qu'on ajoutera des relations,
    // par ex. transactions -> comptes ou crédits).
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $transactionsTable (
        id TEXT PRIMARY KEY,
        amount_ariary INTEGER NOT NULL CHECK (amount_ariary > 0),
        type TEXT NOT NULL CHECK (type IN ('income', 'expense')),
        date INTEGER NOT NULL,
        categorie TEXT,
        icone_categorie TEXT
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_transactions_date ON $transactionsTable (date)',
    );
  }

  /// Ferme la connexion (utile pour les tests).
  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}