import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:microfinance_tantsaha/data/app_database.dart';
import 'package:microfinance_tantsaha/data/user_profile_repository.dart';
import 'package:microfinance_tantsaha/domain/pin_validation.dart';
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

  /// Agrandit la zone de test pour que le bouton soit visible sans défiler.
  void grandEcran(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  /// Remplit les informations, les deux champs PIN et coche le consentement.
  Future<void> remplirFormulaire(
    WidgetTester tester, {
    required String pin,
    required String confirmation,
    bool consentement = true,
  }) async {
    await tester.enterText(find.widgetWithText(TextField, 'Prénom'), 'Rasoa');
    await tester.enterText(find.widgetWithText(TextField, 'Nom'), 'Andria');
    await tester.enterText(
      find.widgetWithText(TextField, 'Numéro de téléphone'),
      '034 12 345 67',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Code PIN (4 chiffres)'),
      pin,
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Confirmez le code PIN'),
      confirmation,
    );
    if (consentement) {
      await tester.tap(find.byType(CheckboxListTile));
      await tester.pump();
    }
  }

  testWidgets('affiche les erreurs par champ si la saisie est vide',
      (tester) async {
    grandEcran(tester);
    await tester.pumpWidget(
      app(CreationProfilScreen(repository: repository)),
    );

    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    expect(find.text('Saisissez votre prénom'), findsOneWidget);
    expect(find.text('Saisissez votre nom'), findsOneWidget);
    expect(find.text('Numéro valide commençant par 03'), findsOneWidget);
    expect(find.text('Le code doit comporter 4 chiffres'), findsOneWidget);
    expect(find.text('Veuillez accepter pour continuer'), findsOneWidget);
  });

  testWidgets('refuse un profil sans consentement', (tester) async {
    grandEcran(tester);
    UserProfile? enregistre;
    await tester.pumpWidget(
      app(CreationProfilScreen(
        repository: repository,
        onEnregistre: (profil) => enregistre = profil,
      )),
    );

    await remplirFormulaire(
      tester,
      pin: '2581',
      confirmation: '2581',
      consentement: false,
    );
    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    expect(find.text('Veuillez accepter pour continuer'), findsOneWidget);
    expect(enregistre, isNull);
  });

  testWidgets('refuse un PIN trop court sans enregistrer', (tester) async {
    grandEcran(tester);
    UserProfile? enregistre;
    await tester.pumpWidget(
      app(CreationProfilScreen(
        repository: repository,
        onEnregistre: (profil) => enregistre = profil,
      )),
    );

    await remplirFormulaire(tester, pin: '12', confirmation: '12');
    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    expect(find.text('Le code doit comporter 4 chiffres'), findsOneWidget);
    expect(enregistre, isNull);
  });

  testWidgets('refuse un PIN trivial sans enregistrer', (tester) async {
    grandEcran(tester);
    UserProfile? enregistre;
    await tester.pumpWidget(
      app(CreationProfilScreen(
        repository: repository,
        onEnregistre: (profil) => enregistre = profil,
      )),
    );

    await remplirFormulaire(tester, pin: '1234', confirmation: '1234');
    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    expect(
      find.text('Choisissez un code moins évident (pas 1111 ni 1234)'),
      findsOneWidget,
    );
    expect(enregistre, isNull);
  });

  testWidgets('refuse deux PIN différents sans enregistrer', (tester) async {
    grandEcran(tester);
    UserProfile? enregistre;
    await tester.pumpWidget(
      app(CreationProfilScreen(
        repository: repository,
        onEnregistre: (profil) => enregistre = profil,
      )),
    );

    await remplirFormulaire(tester, pin: '2581', confirmation: '2582');
    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    expect(find.text('Les deux codes ne correspondent pas'), findsOneWidget);
    expect(enregistre, isNull);
  });

  testWidgets('enregistre un profil valide avec PIN haché et consentement',
      (tester) async {
    grandEcran(tester);
    UserProfile? enregistre;
    await tester.pumpWidget(
      app(CreationProfilScreen(
        repository: repository,
        onEnregistre: (profil) => enregistre = profil,
      )),
    );

    await remplirFormulaire(tester, pin: '2581', confirmation: '2581');

    // La base est réelle (sqflite FFI) : on sort de la zone fake-async.
    await tester.runAsync(() async {
      await tester.tap(find.byType(FilledButton));
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pump();

    expect(enregistre, isNotNull);
    expect(enregistre!.prenom, 'Rasoa');
    expect(enregistre!.aUnPin, isTrue);
    expect(enregistre!.aConsenti, isTrue);

    final relu = await tester.runAsync(() => repository.charger());
    expect(relu?.prenom, 'Rasoa');
    expect(relu?.aUnPin, isTrue);
    expect(relu?.aConsenti, isTrue);
    expect(
      verifierPin('2581', sel: relu!.pinSel!, hashAttendu: relu.pinHash!),
      isTrue,
    );
    expect(
      verifierPin('2582', sel: relu.pinSel!, hashAttendu: relu.pinHash!),
      isFalse,
    );
  });
}