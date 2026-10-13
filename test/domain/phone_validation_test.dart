import 'package:flutter_test/flutter_test.dart';
import 'package:microfinance_tantsaha/domain/phone_validation.dart';

void main() {
  group('validerTelephoneMg', () {
    test('accepte un numéro valide et le normalise en +261', () {
      final r = validerTelephoneMg('0341234567');
      expect(r.estValide, isTrue);
      expect(r.normalise, '+261341234567');
    });

    test('accepte espaces, tirets et points à la saisie', () {
      final r = validerTelephoneMg('034 12-34.567');
      expect(r.normalise, '+261341234567');
    });

    test('refuse une saisie vide', () {
      expect(validerTelephoneMg('  ').erreur, PhoneValidationError.vide);
    });

    test('refuse les lettres', () {
      expect(validerTelephoneMg('03412abcde').erreur,
          PhoneValidationError.caracteresInvalides);
    });

    test('refuse un numéro trop court ou trop long', () {
      expect(validerTelephoneMg('034123456').erreur,
          PhoneValidationError.longueur);
      expect(validerTelephoneMg('03412345678').erreur,
          PhoneValidationError.longueur);
    });

    test('refuse un préfixe qui ne commence pas par 03', () {
      expect(validerTelephoneMg('0201234567').erreur,
          PhoneValidationError.prefixe);
    });
  });
}
