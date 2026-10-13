import '../domain/phone_validation.dart';

enum LangueProfil { malagasy, francais }

enum ChampProfil { prenom, nom, telephone }

class UserProfile {
  const UserProfile._({
    required this.prenom,
    required this.nom,
    required this.telephone,
    required this.langue,
    this.commune,
  });

  final String prenom;
  final String nom;

  /// Format international +261. Non modifiable ici : le changement de
  /// téléphone est reporté (vérification d'identité).
  final String telephone;
  final LangueProfil langue;

  /// Commune ou fokontany, facultative au MVP.
  final String? commune;

  /// Crée un profil à partir de la saisie brute.
  /// Retourne la liste des champs invalides si la saisie est refusée.
  static ResultatProfil creer({
    required String prenom,
    required String nom,
    required String telephoneSaisi,
    required LangueProfil langue,
    String? commune,
  }) {
    final prenomNettoye = prenom.trim();
    final nomNettoye = nom.trim();
    final telephone = validerTelephoneMg(telephoneSaisi);

    final erreurs = <ChampProfil>[
      if (prenomNettoye.isEmpty) ChampProfil.prenom,
      if (nomNettoye.isEmpty) ChampProfil.nom,
      if (!telephone.estValide) ChampProfil.telephone,
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
      ),
    );
  }

  /// Corrige les données modifiables. Le téléphone ne change pas.
  UserProfile copyWith({
    String? prenom,
    String? nom,
    LangueProfil? langue,
    String? commune,
    bool effacerCommune = false,
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
  }) {
    return UserProfile._(
      prenom: prenom,
      nom: nom,
      telephone: telephone,
      langue: langue,
      commune: _nettoyerCommune(commune),
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
