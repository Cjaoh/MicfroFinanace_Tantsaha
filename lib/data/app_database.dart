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
  static const int _dbVersion = 5;

  static const String transactionsTable = 'transactions';
  static const String usersTable = 'users';

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

  // Profil de l'utilisateur local (version 3). Une seule ligne attendue au MVP.
  // Les colonnes du PIN et du consentement ne figurent pas ici : elles sont
  // ajoutées en versions 4 et 5 (voir _ajoutPinSql et _ajoutConsentementSql).
  static const String _createUsersSql = '''
    CREATE TABLE $usersTable (
      id TEXT PRIMARY KEY,
      prenom TEXT NOT NULL CHECK (length(trim(prenom)) > 0),
      nom TEXT NOT NULL CHECK (length(trim(nom)) > 0),
      telephone TEXT NOT NULL UNIQUE,
      langue TEXT NOT NULL CHECK (langue IN ('malagasy', 'francais')),
      commune TEXT,
      created_at INTEGER NOT NULL
    )
  ''';

  // Colonnes du PIN (version 4). Nullables : les profils existants n'ont pas
  // encore de PIN. Définies ici une seule fois, utilisées à l'installation
  // neuve comme à la migration.
  static const List<String> _ajoutPinSql = [
    'ALTER TABLE $usersTable ADD COLUMN pin_hash TEXT',
    'ALTER TABLE $usersTable ADD COLUMN pin_sel TEXT',
  ];

  // Horodatage du consentement, en millisecondes depuis l'époque (version 5).
  // Nullable : les profils créés avant cette version n'ont pas de consentement
  // enregistré.
  static const String _ajoutConsentementSql =
      'ALTER TABLE $usersTable ADD COLUMN consentement_at INTEGER';

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(_createTransactionsSql);
    await db.execute(_createDateIndexSql);
    await db.execute(_createUsersSql);
    for (final sql in _ajoutPinSql) {
      await db.execute(sql);
    }
    await db.execute(_ajoutConsentementSql);
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

    if (oldVersion < 3) {
      // Ajout de la table du profil : rien à recopier, les transactions
      // ne sont pas modifiées.
      await db.execute(_createUsersSql);
    }

    if (oldVersion < 4) {
      // Ajout des colonnes du PIN. Les lignes existantes gardent NULL.
      for (final sql in _ajoutPinSql) {
        await db.execute(sql);
      }
    }

    if (oldVersion < 5) {
      // Ajout de l'horodatage du consentement. Les lignes existantes gardent NULL.
      await db.execute(_ajoutConsentementSql);
    }
  }

  /// Ferme la connexion (utile pour les tests).
  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}