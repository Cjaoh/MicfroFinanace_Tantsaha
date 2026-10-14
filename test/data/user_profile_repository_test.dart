import 'package:flutter_test/flutter_test.dart';
import 'package:microfinance_tantsaha/data/app_database.dart';
import 'package:microfinance_tantsaha/data/user_profile_repository.dart';
import 'package:microfinance_tantsaha/models/user_profile.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late AppDatabase appDatabase;
  late UserProfileRepository repository;

  setUp(() {
    appDatabase = AppDatabase.forTesting(inMemoryDatabasePath);
    repository = UserProfileRepository(appDatabase: appDatabase);
  });

  tearDown(() async {
    await appDatabase.close();
  });

  UserProfile profilDeTest() => UserProfile.restaurer(
        prenom: 'Cédrick',
        nom: 'Rakoto',
        telephone: '+261341234567',
        langue: LangueProfil.francais,
      );

  test('un profil sans PIN relit pinHash et pinSel à null', () async {
    await repository.enregistrer(profilDeTest());

    final relu = await repository.charger();

    expect(relu, isNotNull);
    expect(relu!.aUnPin, isFalse);
    expect(relu.pinHash, isNull);
    expect(relu.pinSel, isNull);
  });

  test('enregistrerPin puis charger relit le hash et le sel', () async {
    await repository.enregistrer(profilDeTest());
    await repository.enregistrerPin(pinHash: 'hash-test', pinSel: 'sel-test');

    final relu = await repository.charger();

    expect(relu!.pinHash, 'hash-test');
    expect(relu.pinSel, 'sel-test');
    expect(relu.aUnPin, isTrue);
  });

  test('enregistrer un profil sans PIN n\'efface pas le PIN existant', () async {
    await repository.enregistrer(profilDeTest());
    await repository.enregistrerPin(pinHash: 'hash-test', pinSel: 'sel-test');

    final recharge = await repository.charger();
    await repository.enregistrer(recharge!.copyWith(prenom: 'Jean'));

    final relu = await repository.charger();
    expect(relu!.prenom, 'Jean');
    expect(relu.pinHash, 'hash-test');
    expect(relu.pinSel, 'sel-test');
  });

  test('enregistrerPin échoue si aucun profil n\'existe', () async {
    expect(
      () => repository.enregistrerPin(pinHash: 'h', pinSel: 's'),
      throwsStateError,
    );
  });
}