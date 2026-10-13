import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:microfinance_tantsaha/data/app_database.dart';
import 'package:microfinance_tantsaha/data/user_profile_repository.dart';
import 'package:microfinance_tantsaha/models/user_profile.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Directory dir;
  late AppDatabase appDb;
  late UserProfileRepository repo;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('tantsaha_profil_');
    appDb = AppDatabase.forTesting('${dir.path}/tantsaha_test.db');
    repo = UserProfileRepository(appDatabase: appDb);
  });

  tearDown(() async {
    await appDb.close();
    dir.deleteSync(recursive: true);
  });

  UserProfile profilInitial() => UserProfile.creer(
        prenom: 'Rakoto',
        nom: 'Jean',
        telephoneSaisi: '0341234567',
        langue: LangueProfil.malagasy,
      ).profil!;

  test('charger renvoie null quand aucun profil n\'existe', () async {
    expect(await repo.charger(), isNull);
  });

  test('enregistrer puis charger restitue le profil', () async {
    await repo.enregistrer(profilInitial());

    final relu = await repo.charger();
    expect(relu, isNotNull);
    expect(relu!.prenom, 'Rakoto');
    expect(relu.telephone, '+261341234567');
    expect(relu.langue, LangueProfil.malagasy);
    expect(relu.commune, isNull);
  });

  test('une seconde écriture met à jour sans créer de doublon', () async {
    await repo.enregistrer(profilInitial());
    await repo.enregistrer(
      profilInitial().copyWith(prenom: 'Rabe', commune: 'Antsirabe'),
    );

    final db = await appDb.database;
    expect(await db.query(AppDatabase.usersTable), hasLength(1));

    final relu = await repo.charger();
    expect(relu!.prenom, 'Rabe');
    expect(relu.commune, 'Antsirabe');
  });

  test('le changement de langue persiste', () async {
    await repo.enregistrer(profilInitial());
    await repo.enregistrer(
      profilInitial().copyWith(langue: LangueProfil.francais),
    );

    expect((await repo.charger())!.langue, LangueProfil.francais);
  });
}
