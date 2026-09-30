import 'package:sqflite/sqflite.dart';

import '../models/transaction_model.dart';
import 'app_database.dart';

/// Accès aux transactions stockées dans SQLite.
///
/// Le reste de l'application manipule uniquement des [TransactionModel] :
/// aucun SQL en dehors de cette classe.
class TransactionRepository {
  TransactionRepository({AppDatabase? appDatabase})
      : _appDatabase = appDatabase ?? AppDatabase.instance;

  final AppDatabase _appDatabase;

  /// Ajoute une transaction. Échoue si l'id existe déjà.
  Future<void> insert(TransactionModel transaction) async {
    final db = await _appDatabase.database;
    await db.insert(
      AppDatabase.transactionsTable,
      transaction.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  /// Retourne toutes les transactions, de la plus récente à la plus ancienne.
  Future<List<TransactionModel>> getAll() async {
    final db = await _appDatabase.database;
    final rows = await db.query(
      AppDatabase.transactionsTable,
      orderBy: 'date DESC',
    );
    return rows.map(TransactionModel.fromMap).toList();
  }

  /// Supprime une transaction. Retourne true si une ligne a été supprimée.
  Future<bool> delete(String id) async {
    final db = await _appDatabase.database;
    final count = await db.delete(
      AppDatabase.transactionsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    return count > 0;
  }

  /// Supprime toutes les transactions.
  Future<void> deleteAll() async {
    final db = await _appDatabase.database;
    await db.delete(AppDatabase.transactionsTable);
  }
}