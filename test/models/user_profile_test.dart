import 'package:flutter_test/flutter_test.dart';
import 'package:microfinance_tantsaha/models/user_profile.dart';

void main() {
  group('UserProfile.creer', () {
    test('crée un profil valide avec téléphone normalisé', () {
      final r = UserProfile.creer(
        prenom: 'Rakoto',
        nom: 'Jean',
        telephoneSaisi: '034 12 34 567',
        langue: LangueProfil.malagasy,
        consentement: true,
      );
      expect(r.estValide, isTrue);
      expect(r.profil!.telephone, '+261341234567');
      expect(r.profil!.langue, LangueProfil.malagasy);
      expect(r.profil!.commune, isNull);
    });

    test('nettoie les espaces et transforme une commune vide en null', () {
      final r = UserProfile.creer(
        prenom: '  Rakoto  ',
        nom: ' Jean ',
        telephoneSaisi: '0341234567',
        langue: LangueProfil.francais,
        consentement: true,
        commune: '   ',
      );
      expect(r.profil!.prenom, 'Rakoto');
      expect(r.profil!.nom, 'Jean');
      expect(r.profil!.commune, isNull);
    });

    test('garde la commune si elle est renseignée', () {
      final r = UserProfile.creer(
        prenom: 'Rakoto',
        nom: 'Jean',
        telephoneSaisi: '0341234567',
        langue: LangueProfil.malagasy,
        consentement: true,
        commune: ' Antsirabe ',
      );
      expect(r.profil!.commune, 'Antsirabe');
    });

    test('signale le prénom vide et le téléphone invalide', () {
      final r = UserProfile.creer(
        prenom: ' ',
        nom: 'Jean',
        telephoneSaisi: '0201234567',
        langue: LangueProfil.malagasy,
        consentement: true,
      );
      expect(r.estValide, isFalse);
      expect(r.profil, isNull);
      expect(r.erreurs, [ChampProfil.prenom, ChampProfil.telephone]);
    });

    test('refuse le profil sans consentement', () {
      final r = UserProfile.creer(
        prenom: 'Rakoto',
        nom: 'Jean',
        telephoneSaisi: '0341234567',
        langue: LangueProfil.malagasy,
        consentement: false,
      );
      expect(r.estValide, isFalse);
      expect(r.erreurs, [ChampProfil.consentement]);
    });

    test('enregistre la date du consentement fournie', () {
      final date = DateTime(2026, 10, 15, 9, 30);
      final r = UserProfile.creer(
        prenom: 'Rakoto',
        nom: 'Jean',
        telephoneSaisi: '0341234567',
        langue: LangueProfil.malagasy,
        consentement: true,
        maintenant: date,
      );
      expect(r.profil!.aConsenti, isTrue);
      expect(r.profil!.consentementLe, date);
    });
  });

  group('UserProfile.copyWith', () {
    late UserProfile profil;

    setUp(() {
      profil = UserProfile.creer(
        prenom: 'Rakoto',
        nom: 'Jean',
        telephoneSaisi: '0341234567',
        langue: LangueProfil.malagasy,
        consentement: true,
        commune: 'Antsirabe',
      ).profil!;
    });

    test('corrige le prénom sans toucher au téléphone ni à la langue', () {
      final corrige = profil.copyWith(prenom: 'Rabe');
      expect(corrige.prenom, 'Rabe');
      expect(corrige.telephone, '+261341234567');
      expect(corrige.langue, LangueProfil.malagasy);
      expect(corrige.commune, 'Antsirabe');
    });

    test('change la langue en conservant le reste', () {
      final corrige = profil.copyWith(langue: LangueProfil.francais);
      expect(corrige.langue, LangueProfil.francais);
      expect(corrige.prenom, 'Rakoto');
    });

    test('efface la commune avec effacerCommune', () {
      final corrige = profil.copyWith(effacerCommune: true);
      expect(corrige.commune, isNull);
    });

    test('conserve le consentement lors d une correction', () {
      final corrige = profil.copyWith(prenom: 'Rabe');
      expect(corrige.consentementLe, profil.consentementLe);
      expect(corrige.aConsenti, isTrue);
    });
  });
}