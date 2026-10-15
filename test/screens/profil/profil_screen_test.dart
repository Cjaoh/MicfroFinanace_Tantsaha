import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:microfinance_tantsaha/data/app_database.dart';
import 'package:microfinance_tantsaha/data/user_profile_repository.dart';
import 'package:microfinance_tantsaha/l10n/app_localizations.dart';
import 'package:microfinance_tantsaha/models/user_profile.dart';
import 'package:microfinance_tantsaha/providers/locale_provider.dart';
import 'package:microfinance_tantsaha/screens/profil_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  Widget app({
    required UserProfileRepository repository,
    required LocaleProvider lp,
  }) {
    return MultiProvider(
      providers: [
        Provider<UserProfileRepository>.value(value: repository),
        ChangeNotifierProvider<LocaleProvider>.value(value: lp),
      ],
      child: const MaterialApp(
        locale: Locale('fr'),
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: ProfilScreen(),
      ),
    );
  }

  testWidgets('affiche le formulaire quand aucun profil n’existe',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final lp = (await tester.runAsync(LocaleProvider.load))!;
    final appDatabase = AppDatabase.forTesting(inMemoryDatabasePath);
    final repository = UserProfileRepository(appDatabase: appDatabase);

    await tester.pumpWidget(app(repository: repository, lp: lp));
    await tester.runAsync(() => Future<void>.delayed(
          const Duration(milliseconds: 200),
        ));
    await tester.pump();

    expect(find.widgetWithText(TextField, 'Prénom'), findsOneWidget);
    expect(find.text('Langue / Fiteny'), findsNothing);
  });

  testWidgets('affiche les informations du profil existant', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final lp = (await tester.runAsync(LocaleProvider.load))!;
    final appDatabase = AppDatabase.forTesting(inMemoryDatabasePath);
    final repository = UserProfileRepository(appDatabase: appDatabase);

    final profil = UserProfile.creer(
      prenom: 'Rasoa',
      nom: 'Andria',
      telephoneSaisi: '034 12 345 67',
      langue: LangueProfil.malagasy,
      consentement: true,
    ).profil!;
    await tester.runAsync(() => repository.enregistrer(profil));

    await tester.pumpWidget(app(repository: repository, lp: lp));
    await tester.runAsync(() => Future<void>.delayed(
          const Duration(milliseconds: 200),
        ));
    await tester.pump();

    expect(find.text('Rasoa'), findsOneWidget);
    expect(find.text('Andria'), findsOneWidget);
    expect(find.textContaining('+261'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Prénom'), findsNothing);
    expect(find.text('Langue / Fiteny'), findsOneWidget);
  });
}