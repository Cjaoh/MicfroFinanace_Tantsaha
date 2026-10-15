import '../domain/phone_validation.dart';

enum LangueProfil { malagasy, francais }

enum ChampProfil { prenom, nom, telephone, consentement }

class UserProfile {
  const UserProfile._({
    required this.prenom,
    required this.nom,
    required this.telephone,
    required this.langue,
    this.commune,
    this.pinHash,
    this.pinSel,
    this.consentementLe,
  });

  final String prenom;
  final String nom;

  /// Format international +261. Non modifiable ici : le changement de
  /// téléphone est reporté (vérification d'identité).
  final String telephone;
  final LangueProfil langue;

  /// Commune ou fokontany, facultative au MVP.
  final String? commune;

  /// Hash salé du PIN. Null tant qu'aucun PIN n'est défini.
  final String? pinHash;

  /// Sel utilisé pour hasher le PIN. Null tant qu'aucun PIN n'est défini.
  final String? pinSel;

  /// Date et heure du consentement. Obligatoire à la création, donc non null
  /// pour tout profil créé par [creer].
  final DateTime? consentementLe;

  /// Vrai si un PIN est défini pour ce profil.
  bool get aUnPin => pinHash != null && pinSel != null;

  /// Vrai si le consentement a été donné.
  bool get aConsenti => consentementLe != null;

  /// Crée un profil à partir de la saisie brute.
  /// Retourne la liste des champs invalides si la saisie est refusée.
  /// Le consentement est obligatoire : sans lui, la saisie est refusée.
  /// [maintenant] permet de fixer la date du consentement dans les tests.
  static ResultatProfil creer({
    required String prenom,
    required String nom,
    required String telephoneSaisi,
    required LangueProfil langue,
    required bool consentement,
    String? commune,
    DateTime? maintenant,
  }) {
    final prenomNettoye = prenom.trim();
    final nomNettoye = nom.trim();
    final telephone = validerTelephoneMg(telephoneSaisi);

    final erreurs = <ChampProfil>[
      if (prenomNettoye.isEmpty) ChampProfil.prenom,
      if (nomNettoye.isEmpty) ChampProfil.nom,
      if (!telephone.estValide) ChampProfil.telephone,
      if (!consentement) ChampProfil.consentement,
    ];
    if (erreurs.isNotEmpty) {
      return ResultatProfil.invalide(erreurs);
    }

    return ResultatProfil.valide(
      UserProfile._(
        prenom: prenomNettoye,
        nom: nomNettoye,
        telephone: telephone.normalise!,
        langue: langue,
        commune: _nettoyerCommune(commune),
        consentementLe: maintenant ?? DateTime.now(),
      ),
    );
  }

  /// Corrige les données modifiables. Le téléphone ne change pas.
  /// Les champs PIN ne sont modifiés que si on les fournit, sauf
  /// [effacerPin] qui les remet à null. Le consentement n'est pas modifiable.
  UserProfile copyWith({
    String? prenom,
    String? nom,
    LangueProfil? langue,
    String? commune,
    bool effacerCommune = false,
    String? pinHash,
    String? pinSel,
    bool effacerPin = false,
  }) {
    assert(prenom == null || prenom.trim().isNotEmpty);
    assert(nom == null || nom.trim().isNotEmpty);

    return UserProfile._(
      prenom: prenom?.trim() ?? this.prenom,
      nom: nom?.trim() ?? this.nom,
      telephone: telephone,
      langue: langue ?? this.langue,
      commune: effacerCommune
          ? null
          : (commune != null ? _nettoyerCommune(commune) : this.commune),
      pinHash: effacerPin ? null : (pinHash ?? this.pinHash),
      pinSel: effacerPin ? null : (pinSel ?? this.pinSel),
      consentementLe: consentementLe,
    );
  }

  /// Reconstruit un profil déjà validé, par exemple depuis la base.
  /// Ne revalide pas le téléphone : il est déjà au format +261.
  factory UserProfile.restaurer({
    required String prenom,
    required String nom,
    required String telephone,
    required LangueProfil langue,
    String? commune,
    String? pinHash,
    String? pinSel,
    DateTime? consentementLe,
  }) {
    return UserProfile._(
      prenom: prenom,
      nom: nom,
      telephone: telephone,
      langue: langue,
      commune: _nettoyerCommune(commune),
      pinHash: pinHash,
      pinSel: pinSel,
      consentementLe: consentementLe,
    );
  }

  static String? _nettoyerCommune(String? valeur) {
    final nettoye = valeur?.trim();
    return (nettoye == null || nettoye.isEmpty) ? null : nettoye;
  }
}

class ResultatProfil {
  const ResultatProfil.valide(this.profil) : erreurs = const [];
  const ResultatProfil.invalide(this.erreurs) : profil = null;

  /// Présent seulement si la saisie est valide.
  final UserProfile? profil;

  /// Champs refusés, vide si la saisie est valide.
  final List<ChampProfil> erreurs;

  bool get estValide => profil != null;
}