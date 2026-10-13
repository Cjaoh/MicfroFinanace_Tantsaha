import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:microfinance_tantsaha/data/app_database.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Directory dir;
  late String path;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('tantsaha_users_');
    path = '${dir.path}/tantsaha_test.db';
  });

  tearDown(() {
    dir.deleteSync(recursive: true);
  });

  Map<String, Object?> profil({
    String id = 'profil-local',
    String telephone = '+261341234567',
  }) {
    return {
      'id': id,
      'prenom': 'Rakoto',
      'nom': 'Jean',
      'telephone': telephone,
      'langue': 'malagasy',
      'commune': null,
      'created_at': DateTime(2026, 10, 13).millisecondsSinceEpoch,
    };
  }

  test('base neuve : la table users accepte un profil', () async {
    final appDb = AppDatabase.forTesting(path);
    final db = await appDb.database;

    await db.insert(AppDatabase.usersTable, profil());
    final lignes = await db.query(AppDatabase.usersTable);

    expect(lignes, hasLength(1));
    expect(lignes.first['telephone'], '+261341234567');
    await appDb.close();
  });

  test('refuse deux profils avec le même téléphone', () async {
    final appDb = AppDatabase.forTesting(path);
    final db = await appDb.database;

    await db.insert(AppDatabase.usersTable, profil());
    expect(
      () => db.insert(AppDatabase.usersTable, profil(id: 'autre')),
      throwsA(anything),
    );
    await appDb.close();
  });

  test('refuse une langue inconnue', () async {
    final appDb = AppDatabase.forTesting(path);
    final db = await appDb.database;

    final invalide = {...profil(), 'langue': 'anglais'};
    expect(
      () => db.insert(AppDatabase.usersTable, invalide),
      throwsA(anything),
    );
    await appDb.close();
  });

  test('migration v2 -> v3 : garde les transactions et ajoute users', () async {
    // 1. Base "ancienne" en version 2, avec une transaction d'épargne.
    final oldDb = await openDatabase(
      path,
      version: 2,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE transactions (
            id TEXT PRIMARY KEY,
            amount_ariary INTEGER NOT NULL CHECK (amount_ariary > 0),
            type TEXT NOT NULL CHECK (type IN ('income', 'expense', 'saving')),
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
      'id': 'ancienne',
      'amount_ariary': 2000,
      'type': 'saving',
      'date': DateTime(2026, 9, 1).millisecondsSinceEpoch,
      'categorie': null,
      'icone_categorie': null,
    });
    await oldDb.close();

    // 2. Ouverture avec le code actuel : la migration v2 -> v3 se déclenche.
    final appDb = AppDatabase.forTesting(path);
    final db = await appDb.database;

    final transactions = await db.query(AppDatabase.transactionsTable);
    expect(transactions, hasLength(1));
    expect(transactions.first['id'], 'ancienne');

    // 3. La table users existe et accepte un profil.
    await db.insert(AppDatabase.usersTable, profil());
    expect(await db.query(AppDatabase.usersTable), hasLength(1));

    await appDb.close();
  });
}
