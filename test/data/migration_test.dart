import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:microfinance_tantsaha/data/app_database.dart';
import 'package:microfinance_tantsaha/data/transaction_repository.dart';
import 'package:microfinance_tantsaha/models/transaction_model.dart';
import 'package:microfinance_tantsaha/models/transaction_type.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  test('migration v1 -> v2 : garde les anciennes données et accepte saving',
      () async {
    final dir = Directory.systemTemp.createTempSync('tantsaha_migration_');
    final path = '${dir.path}/tantsaha_test.db';

    // 1. On fabrique une base "ancienne" (version 1, sans 'saving').
    final oldDb = await openDatabase(
      path,
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE transactions (
            id TEXT PRIMARY KEY,
            amount_ariary INTEGER NOT NULL CHECK (amount_ariary > 0),
            type TEXT NOT NULL CHECK (type IN ('income', 'expense')),
            date INTEGER NOT NULL,
            categorie TEXT,
            icone_categorie TEXT
          )
        ''');
        await db.execute(
          'CREATE INDEX idx_transactions_date ON transactions (date)',
        );
      },
    );
    await oldDb.insert('transactions', {
      'id': 'ancien',
      'amount_ariary': 5000,
      'type': 'income',
      'date': DateTime(2026, 1, 1).millisecondsSinceEpoch,
      'categorie': 'Ventes de récoltes',
      'icone_categorie': '🌾',
    });
    await oldDb.close();

    // 2. On l'ouvre avec le code actuel : la migration se déclenche.
    final appDatabase = AppDatabase.forTesting(path);
    final repository = TransactionRepository(appDatabase: appDatabase);

    final all = await repository.getAll();
    expect(all, hasLength(1));
    expect(all.first.id, 'ancien');
    expect(all.first.amountAriary, 5000);
    expect(all.first.type, TransactionType.income);

    // 3. Le nouveau type est maintenant accepté.
    await repository.insert(TransactionModel(
      id: 'epargne',
      amountAriary: 2000,
      type: TransactionType.saving,
      date: DateTime(2026, 2, 1),
    ));
    final apres = await repository.getAll();
    expect(apres, hasLength(2));
    expect(apres.first.type, TransactionType.saving);

    await appDatabase.close();
    dir.deleteSync(recursive: true);
  });
}