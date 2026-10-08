// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Tantsaha';

  @override
  String get navHome => 'Accueil';

  @override
  String get navFarm => 'Exploitation';

  @override
  String get navFinances => 'Finances';

  @override
  String get navMarket => 'Marché';

  @override
  String get navProfile => 'Profil';

  @override
  String get dashGreeting => 'Bonjour !';

  @override
  String get dashEncouragement => 'Bon courage pour vos cultures !';

  @override
  String get dashBalanceLabel => 'Solde de votre compte';

  @override
  String get dashHideBalance => 'Masquer le solde';

  @override
  String get dashShowBalance => 'Afficher le solde';

  @override
  String get dashRevenue => 'Revenus';

  @override
  String get dashExpenses => 'Dépenses';

  @override
  String get dashSavings => 'Épargne';

  @override
  String get dashMyFarms => 'Mes exploitations';

  @override
  String get dashUpcomingEvents => 'Prochains événements';

  @override
  String get dashEmptyFarms =>
      'Aucune exploitation enregistrée pour l\'instant.';

  @override
  String get dashEmptyEvents => 'Aucun événement pour l\'instant.';

  @override
  String get dashSeeAll => 'Voir tout';

  @override
  String get finTitle => 'Mes finances';

  @override
  String get finBalanceNow => 'Solde actuel';

  @override
  String get finTabSummary => 'Synthèse';

  @override
  String get finTabTransactions => 'Transactions';

  @override
  String get finTabSavings => 'Épargne';

  @override
  String get finAddTransaction => 'Ajouter une transaction';

  @override
  String get finEmptyTransactions => 'Aucune transaction pour l\'instant';

  @override
  String get finEmptySavings => 'Aucune épargne pour l\'instant';

  @override
  String get finTotalSaved => 'Total épargné';

  @override
  String get finSetAside => 'Mettre de l\'argent de côté';

  @override
  String get finAddIncome => 'Ajouter un revenu';

  @override
  String get finAddExpense => 'Ajouter une dépense';

  @override
  String get finNewIncome => 'Nouveau revenu';

  @override
  String get finNewExpense => 'Nouvelle dépense';

  @override
  String get finNewSaving => 'Mettre de côté';

  @override
  String get finAmountHint => 'Montant en Ariary';

  @override
  String get finDescriptionHint => 'Description (optionnel)';

  @override
  String get finErrorAmount => 'Entrez un montant valide';

  @override
  String get finErrorCategory => 'Sélectionnez une catégorie';

  @override
  String get finConfirm => 'Confirmer';
}
