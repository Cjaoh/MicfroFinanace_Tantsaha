import 'package:flutter_test/flutter_test.dart';
import 'package:microfinance_tantsaha/data/app_database.dart';
import 'package:microfinance_tantsaha/data/transaction_repository.dart';
import 'package:microfinance_tantsaha/models/transaction_model.dart';
import 'package:microfinance_tantsaha/models/transaction_type.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  // Utilise SQLite "bureau" (FFI) à la place de sqflite Android/iOS.
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late AppDatabase appDatabase;
  late TransactionRepository repository;

  // Une base en mémoire toute neuve avant chaque test : les tests
  // sont isolés et ne dépendent pas de leur ordre d'exécution.
  setUp(() {
    appDatabase = AppDatabase.forTesting(inMemoryDatabasePath);
    repository = TransactionRepository(appDatabase: appDatabase);
  });

  tearDown(() async {
    await appDatabase.close();
  });

  TransactionModel makeTransaction({
    required String id,
    int amount = 1000,
    TransactionType type = TransactionType.income,
    DateTime? date,
  }) {
    return TransactionModel(
      id: id,
      amountAriary: amount,
      type: type,
      date: date ?? DateTime(2026, 1, 1),
      categorie: 'Riz',
      iconeCategorie: 'grain',
    );
  }

  test('insert puis getAll retrouve la transaction à l\'identique', () async {
    final original = makeTransaction(
      id: 'a',
      amount: 25000,
      type: TransactionType.expense,
    );

    await repository.insert(original);
    final all = await repository.getAll();

    expect(all, hasLength(1));
    expect(all.first.id, 'a');
    expect(all.first.amountAriary, 25000);
    expect(all.first.type, TransactionType.expense);
    expect(all.first.date, original.date);
    expect(all.first.categorie, 'Riz');
    expect(all.first.iconeCategorie, 'grain');
  });

  test('getAll trie de la plus récente à la plus ancienne', () async {
    await repository.insert(makeTransaction(id: 'old', date: DateTime(2026, 1, 1)));
    await repository.insert(makeTransaction(id: 'new', date: DateTime(2026, 3, 1)));
    await repository.insert(makeTransaction(id: 'mid', date: DateTime(2026, 2, 1)));

    final all = await repository.getAll();

    expect(all.map((t) => t.id).toList(), ['new', 'mid', 'old']);
  });

  test('delete retire la transaction et retourne true', () async {
    await repository.insert(makeTransaction(id: 'a'));

    final deleted = await repository.delete('a');

    expect(deleted, isTrue);
    expect(await repository.getAll(), isEmpty);
  });

  test('delete d\'un id inexistant retourne false', () async {
    final deleted = await repository.delete('inconnu');

    expect(deleted, isFalse);
  });

  test('insérer deux fois le même id est refusé', () async {
    await repository.insert(makeTransaction(id: 'a'));

    expect(
      () => repository.insert(makeTransaction(id: 'a')),
      throwsA(isA<DatabaseException>()),
    );
  });

  test('la base refuse un montant nul même en contournant le modèle', () async {
    final db = await appDatabase.database;

    expect(
      () => db.insert(AppDatabase.transactionsTable, {
        'id': 'x',
        'amount_ariary': 0,
        'type': 'income',
        'date': DateTime(2026, 1, 1).millisecondsSinceEpoch,
      }),
      throwsA(isA<DatabaseException>()),
    );
  });

  test('la base refuse un type invalide même en contournant le modèle', () async {
    final db = await appDatabase.database;

    expect(
      () => db.insert(AppDatabase.transactionsTable, {
        'id': 'y',
        'amount_ariary': 1000,
        'type': 'virement',
        'date': DateTime(2026, 1, 1).millisecondsSinceEpoch,
      }),
      throwsA(isA<DatabaseException>()),
    );
  });
}