import 'package:flutter_test/flutter_test.dart';
import 'package:microfinance_tantsaha/domain/pin_validation.dart';

void main() {
  group('validerPin', () {
    test('accepte un PIN à 4 chiffres non trivial', () {
      expect(validerPin('2580'), isNull);
    });

    test('refuse une longueur différente de 4', () {
      expect(validerPin('123'), ErreurPin.longueur);
      expect(validerPin('12345'), ErreurPin.longueur);
      expect(validerPin(''), ErreurPin.longueur);
    });

    test('refuse les caractères non numériques', () {
      expect(validerPin('12a4'), ErreurPin.chiffresSeulement);
      expect(validerPin('12 4'), ErreurPin.chiffresSeulement);
    });

    test('refuse les PIN triviaux', () {
      expect(validerPin('0000'), ErreurPin.trivial);
      expect(validerPin('1111'), ErreurPin.trivial);
      expect(validerPin('1234'), ErreurPin.trivial);
      expect(validerPin('4321'), ErreurPin.trivial);
    });
  });

  group('hash du PIN', () {
    const sel = 'sel-de-test';

    test('est déterministe pour un même sel', () {
      expect(hasherPin('2580', sel), hasherPin('2580', sel));
    });

    test('change avec le sel', () {
      expect(hasherPin('2580', sel), isNot(hasherPin('2580', 'autre')));
    });

    test('ne contient pas le PIN en clair', () {
      expect(hasherPin('2580', sel), isNot(contains('2580')));
    });

    test('verifierPin accepte le bon PIN et refuse les mauvais', () {
      final hash = hasherPin('2580', sel);

      expect(verifierPin('2580', sel: sel, hashAttendu: hash), isTrue);
      expect(verifierPin('2581', sel: sel, hashAttendu: hash), isFalse);
      expect(
        verifierPin('2580', sel: 'autre', hashAttendu: hash),
        isFalse,
      );
    });

    test('genererSel produit des sels différents', () {
      expect(genererSel(), isNot(genererSel()));
    });
  });
}