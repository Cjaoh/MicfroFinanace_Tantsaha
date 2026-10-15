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
  String get finRemaining => 'Reste disponible';

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

  @override
  String get profileTitle => 'Créer mon profil';

  @override
  String get profilePrenom => 'Prénom';

  @override
  String get profileNom => 'Nom';

  @override
  String get profileTelephone => 'Numéro de téléphone';

  @override
  String get profileTelephoneHint => 'Ex. : 034 12 345 67';

  @override
  String get profileCommune => 'Commune ou fokontany (facultatif)';

  @override
  String get profileLangue => 'Langue';

  @override
  String get profileSave => 'Enregistrer';

  @override
  String get profileErrorPrenom => 'Saisissez votre prénom';

  @override
  String get profileErrorNom => 'Saisissez votre nom';

  @override
  String get profileErrorTelephone => 'Numéro valide commençant par 03';

  @override
  String get profilePin => 'Code PIN (4 chiffres)';

  @override
  String get profilePinConfirm => 'Confirmez le code PIN';

  @override
  String get profileErrorPinLongueur => 'Le code doit comporter 4 chiffres';

  @override
  String get profileErrorPinChiffres => 'Chiffres seulement';

  @override
  String get profileErrorPinTrivial =>
      'Choisissez un code moins évident (pas 1111 ni 1234)';

  @override
  String get profileErrorPinConfirm => 'Les deux codes ne correspondent pas';

  @override
  String get profileConsent =>
      'J\'accepte que mes informations soient utilisées pour accéder au service Tantsaha';

  @override
  String get profileErrorConsent => 'Veuillez accepter pour continuer';
}
