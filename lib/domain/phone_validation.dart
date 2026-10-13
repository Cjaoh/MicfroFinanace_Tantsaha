// Validation du numéro de téléphone malgache (PROF-01).
// Saisie : 10 chiffres commençant par 03 (espaces, tirets et points tolérés).
// Stockage : format international, par exemple 0341234567 -> +261341234567.

enum PhoneValidationError { vide, caracteresInvalides, longueur, prefixe }

class PhoneValidationResult {
  const PhoneValidationResult.valide(this.normalise) : erreur = null;
  const PhoneValidationResult.invalide(this.erreur) : normalise = null;

  /// Numéro au format +261, présent seulement si la saisie est valide.
  final String? normalise;

  /// Raison du rejet, présente seulement si la saisie est invalide.
  final PhoneValidationError? erreur;

  bool get estValide => erreur == null;
}

PhoneValidationResult validerTelephoneMg(String saisie) {
  final nettoye = saisie.replaceAll(RegExp(r'[\s.\-]'), '');

  if (nettoye.isEmpty) {
    return const PhoneValidationResult.invalide(PhoneValidationError.vide);
  }
  if (!RegExp(r'^\d+$').hasMatch(nettoye)) {
    return const PhoneValidationResult.invalide(
        PhoneValidationError.caracteresInvalides);
  }
  if (nettoye.length != 10) {
    return const PhoneValidationResult.invalide(PhoneValidationError.longueur);
  }
  if (!nettoye.startsWith('03')) {
    return const PhoneValidationResult.invalide(PhoneValidationError.prefixe);
  }
  return PhoneValidationResult.valide('+261${nettoye.substring(1)}');
}
