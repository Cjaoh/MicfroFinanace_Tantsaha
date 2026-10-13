import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:microfinance_tantsaha/data/app_database.dart';
import 'package:microfinance_tantsaha/data/user_profile_repository.dart';
import 'package:microfinance_tantsaha/l10n/app_localizations.dart';
import 'package:microfinance_tantsaha/models/user_profile.dart';
import 'package:microfinance_tantsaha/screens/profil/creation_profil_screen.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late AppDatabase appDatabase;
  late UserProfileRepository repository;

  setUp(() {
    appDatabase = AppDatabase.forTesting(inMemoryDatabasePath);
    repository = UserProfileRepository(appDatabase: appDatabase);
  });

  Widget app(Widget child) {
    return MaterialApp(
      locale: const Locale('fr'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    );
  }

  testWidgets('affiche les erreurs par champ si la saisie est vide',
      (tester) async {
    await tester.pumpWidget(
      app(CreationProfilScreen(repository: repository)),
    );

    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    expect(find.text('Saisissez votre prénom'), findsOneWidget);
    expect(find.text('Saisissez votre nom'), findsOneWidget);
    expect(find.text('Numéro valide commençant par 03'), findsOneWidget);
  });

  testWidgets('enregistre un profil valide et appelle onEnregistre',
      (tester) async {
    UserProfile? enregistre;

    await tester.pumpWidget(
      app(CreationProfilScreen(
        repository: repository,
        onEnregistre: (profil) => enregistre = profil,
      )),
    );

    await tester.enterText(find.widgetWithText(TextField, 'Prénom'), 'Rasoa');
    await tester.enterText(find.widgetWithText(TextField, 'Nom'), 'Andria');
    await tester.enterText(
      find.widgetWithText(TextField, 'Numéro de téléphone'),
      '034 12 345 67',
    );

    // La base est réelle (sqflite FFI) : on sort de la zone fake-async.
    await tester.runAsync(() async {
      await tester.tap(find.byType(FilledButton));
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pump();

    expect(enregistre, isNotNull);
    expect(enregistre!.prenom, 'Rasoa');

    final relu = await tester.runAsync(() => repository.charger());
    expect(relu?.prenom, 'Rasoa');
  });
}