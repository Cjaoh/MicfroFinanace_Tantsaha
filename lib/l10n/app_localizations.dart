import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_fr.dart';
import 'app_localizations_mg.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('fr'),
    Locale('mg'),
  ];

  /// Nom de l'application
  ///
  /// In mg, this message translates to:
  /// **'Tantsaha'**
  String get appTitle;

  /// Onglet Accueil (tableau de bord)
  ///
  /// In mg, this message translates to:
  /// **'Fandraisana'**
  String get navHome;

  /// Onglet Exploitation
  ///
  /// In mg, this message translates to:
  /// **'Fambolena'**
  String get navFarm;

  /// Onglet Finances
  ///
  /// In mg, this message translates to:
  /// **'Vola'**
  String get navFinances;

  /// Onglet Marché
  ///
  /// In mg, this message translates to:
  /// **'Tsena'**
  String get navMarket;

  /// Onglet Profil
  ///
  /// In mg, this message translates to:
  /// **'Momba ahy'**
  String get navProfile;

  /// No description provided for @dashGreeting.
  ///
  /// In mg, this message translates to:
  /// **'Manao ahoana !'**
  String get dashGreeting;

  /// No description provided for @dashEncouragement.
  ///
  /// In mg, this message translates to:
  /// **'Mandrosoa amin\'ny asa fambolenao !'**
  String get dashEncouragement;

  /// No description provided for @dashBalanceLabel.
  ///
  /// In mg, this message translates to:
  /// **'Ny vola misy anao'**
  String get dashBalanceLabel;

  /// No description provided for @dashHideBalance.
  ///
  /// In mg, this message translates to:
  /// **'Afenina ny vola'**
  String get dashHideBalance;

  /// No description provided for @dashShowBalance.
  ///
  /// In mg, this message translates to:
  /// **'Asehoy ny vola'**
  String get dashShowBalance;

  /// No description provided for @dashRevenue.
  ///
  /// In mg, this message translates to:
  /// **'Fidiram-bola'**
  String get dashRevenue;

  /// No description provided for @dashExpenses.
  ///
  /// In mg, this message translates to:
  /// **'Fandaniana'**
  String get dashExpenses;

  /// No description provided for @dashSavings.
  ///
  /// In mg, this message translates to:
  /// **'Tahiry'**
  String get dashSavings;

  /// No description provided for @dashMyFarms.
  ///
  /// In mg, this message translates to:
  /// **'Ny fambolenako'**
  String get dashMyFarms;

  /// No description provided for @dashUpcomingEvents.
  ///
  /// In mg, this message translates to:
  /// **'Ny hetsika manaraka'**
  String get dashUpcomingEvents;

  /// No description provided for @dashEmptyFarms.
  ///
  /// In mg, this message translates to:
  /// **'Tsy misy fambolena voarakitra mbola.'**
  String get dashEmptyFarms;

  /// No description provided for @dashEmptyEvents.
  ///
  /// In mg, this message translates to:
  /// **'Tsy misy hetsika mbola.'**
  String get dashEmptyEvents;

  /// No description provided for @dashSeeAll.
  ///
  /// In mg, this message translates to:
  /// **'Jereo rehetra'**
  String get dashSeeAll;

  /// No description provided for @finTitle.
  ///
  /// In mg, this message translates to:
  /// **'Ny volako'**
  String get finTitle;

  /// No description provided for @finBalanceNow.
  ///
  /// In mg, this message translates to:
  /// **'Vola misy ankehitriny'**
  String get finBalanceNow;

  /// No description provided for @finTabSummary.
  ///
  /// In mg, this message translates to:
  /// **'Fintinana'**
  String get finTabSummary;

  /// No description provided for @finTabTransactions.
  ///
  /// In mg, this message translates to:
  /// **'Fifampiraharahana'**
  String get finTabTransactions;

  /// No description provided for @finTabSavings.
  ///
  /// In mg, this message translates to:
  /// **'Tahiry'**
  String get finTabSavings;

  /// No description provided for @finAddTransaction.
  ///
  /// In mg, this message translates to:
  /// **'Ampidiro fifampiraharahana'**
  String get finAddTransaction;

  /// No description provided for @finEmptyTransactions.
  ///
  /// In mg, this message translates to:
  /// **'Tsy misy fifampiraharahana mbola.'**
  String get finEmptyTransactions;

  /// No description provided for @finEmptySavings.
  ///
  /// In mg, this message translates to:
  /// **'Tsy misy tahiry mbola.'**
  String get finEmptySavings;

  /// No description provided for @finTotalSaved.
  ///
  /// In mg, this message translates to:
  /// **'Tahiry rehetra'**
  String get finTotalSaved;

  /// No description provided for @finSetAside.
  ///
  /// In mg, this message translates to:
  /// **'Apetraka tahiry'**
  String get finSetAside;

  /// No description provided for @finAddIncome.
  ///
  /// In mg, this message translates to:
  /// **'Ampidiro fidiram-bola'**
  String get finAddIncome;

  /// No description provided for @finAddExpense.
  ///
  /// In mg, this message translates to:
  /// **'Ampidiro fandaniana'**
  String get finAddExpense;

  /// No description provided for @finNewIncome.
  ///
  /// In mg, this message translates to:
  /// **'Fidiram-bola vaovao'**
  String get finNewIncome;

  /// No description provided for @finNewExpense.
  ///
  /// In mg, this message translates to:
  /// **'Fandaniana vaovao'**
  String get finNewExpense;

  /// No description provided for @finNewSaving.
  ///
  /// In mg, this message translates to:
  /// **'Apetraka tahiry vaovao'**
  String get finNewSaving;

  /// No description provided for @finAmountHint.
  ///
  /// In mg, this message translates to:
  /// **'Vola amin\'ny Ariary'**
  String get finAmountHint;

  /// No description provided for @finDescriptionHint.
  ///
  /// In mg, this message translates to:
  /// **'Famaritana (tsy voatery)'**
  String get finDescriptionHint;

  /// No description provided for @finErrorAmount.
  ///
  /// In mg, this message translates to:
  /// **'Ampidiro vola marina'**
  String get finErrorAmount;

  /// No description provided for @finErrorCategory.
  ///
  /// In mg, this message translates to:
  /// **'Safidio sokajy'**
  String get finErrorCategory;

  /// No description provided for @finConfirm.
  ///
  /// In mg, this message translates to:
  /// **'Hamarino'**
  String get finConfirm;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['fr', 'mg'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'fr':
      return AppLocalizationsFr();
    case 'mg':
      return AppLocalizationsMg();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
