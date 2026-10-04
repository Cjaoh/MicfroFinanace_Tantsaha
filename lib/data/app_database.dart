import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Point d'accès unique à la base SQLite locale de Tantsaha.
///
/// Singleton : une seule connexion ouverte pour toute l'application.
/// Ouvrir plusieurs connexions à la même base provoque des verrous
/// et des comportements imprévisibles.
class AppDatabase {
  AppDatabase._([this._customPath]);

  static final AppDatabase instance = AppDatabase._();

  /// Base séparée pour les tests (ex. [inMemoryDatabasePath]).
  factory AppDatabase.forTesting(String path) => AppDatabase._(path);

  static const String _dbName = 'tantsaha.db';
  static const int _dbVersion = 2;

  static const String transactionsTable = 'transactions';

  final String? _customPath;
  Database? _database;

  /// Ouvre la base au premier appel, puis réutilise la même connexion.
  Future<Database> get database async {
    final existing = _database;
    if (existing != null) return existing;

    final path = _customPath ?? p.join(await getDatabasesPath(), _dbName);
    final db = await openDatabase(
      path,
      version: _dbVersion,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    _database = db;
    return db;
  }

  Future<void> _onConfigure(Database db) async {
    // Active les clés étrangères (utile dès qu'on ajoutera des relations,
    // par ex. transactions -> comptes ou crédits).
    await db.execute('PRAGMA foreign_keys = ON');
  }

  // Schéma de la table des transactions (version 2 : ajout du type 'saving').
  static const String _createTransactionsSql = '''
    CREATE TABLE $transactionsTable (
      id TEXT PRIMARY KEY,
      amount_ariary INTEGER NOT NULL CHECK (amount_ariary > 0),
      type TEXT NOT NULL CHECK (type IN ('income', 'expense', 'saving')),
      date INTEGER NOT NULL,
      categorie TEXT,
      icone_categorie TEXT
    )
  ''';

  static const String _createDateIndexSql =
      'CREATE INDEX idx_transactions_date ON $transactionsTable (date)';

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(_createTransactionsSql);
    await db.execute(_createDateIndexSql);
  }

  /// Migrations successives. Chaque `if (oldVersion < N)` ne s'exécute que
  /// pour les bases plus anciennes que N : une base déjà à jour n'est pas
  /// touchée, et une base très ancienne passe par toutes les étapes.
  ///
  /// Important : sqflite exécute déjà onUpgrade dans une transaction.
  /// On n'ouvre donc PAS db.transaction() ici (risque de blocage).
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // SQLite ne permet pas de modifier une contrainte CHECK existante :
      // on recrée la table, on recopie les données, puis on supprime
      // l'ancienne. Les transactions déjà saisies sont conservées.
      await db.execute(
        'ALTER TABLE $transactionsTable RENAME TO transactions_old',
      );
      await db.execute(_createTransactionsSql);
      await db.execute('''
        INSERT INTO $transactionsTable
          (id, amount_ariary, type, date, categorie, icone_categorie)
        SELECT id, amount_ariary, type, date, categorie, icone_categorie
        FROM transactions_old
      ''');
      await db.execute('DROP TABLE transactions_old');
      await db.execute(_createDateIndexSql);
    }
  }

  /// Ferme la connexion (utile pour les tests).
  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}