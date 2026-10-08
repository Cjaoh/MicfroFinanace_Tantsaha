import 'package:flutter_test/flutter_test.dart';
import 'package:microfinance_tantsaha/domain/category_schema.dart';
import 'package:microfinance_tantsaha/domain/field_validation.dart';

void main() {
  const quantite = NumberFieldDef(key: 'quantite', label: 'Quantité');
  const prix = NumberFieldDef(key: 'prix', label: 'Prix unitaire');
  const culture = ChoiceFieldDef(
    key: 'culture',
    label: 'Culture',
    options: ['riz', 'vanille'],
  );
  const date = DateFieldDef(key: 'date', label: 'Date');
  const note = TextFieldDef(key: 'note', label: 'Note', optional: true);

  const schema = CategorySchema(
    categoryKey: 'test',
    fields: [quantite, prix, culture, date, note],
    amountFactors: ['quantite', 'prix'],
  );

  RawValues valides() => {
        'quantite': '3',
        'prix': '1500',
        'culture': 'riz',
        'date': '2026-10-08',
      };

  group('validateCategoryValues', () {
    test('aucune erreur quand tout est valide', () {
      expect(validateCategoryValues(schema, valides()), isEmpty);
    });

    test('champ obligatoire vide -> required', () {
      final values = valides()..['culture'] = '  ';
      expect(validateCategoryValues(schema, values)['culture'], FieldError.required);
    });

    test('champ facultatif vide -> pas d\'erreur', () {
      expect(validateCategoryValues(schema, valides()), isNot(contains('note')));
    });

    test('nombre non numérique -> invalidNumber', () {
      final values = valides()..['quantite'] = 'abc';
      expect(validateCategoryValues(schema, values)['quantite'], FieldError.invalidNumber);
    });

    test('nombre sous le minimum (défaut 1) -> tooSmall', () {
      final values = valides()..['prix'] = '0';
      expect(validateCategoryValues(schema, values)['prix'], FieldError.tooSmall);
    });

    test('choix hors liste -> invalidChoice', () {
      final values = valides()..['culture'] = 'maïs';
      expect(validateCategoryValues(schema, values)['culture'], FieldError.invalidChoice);
    });

    test('date impossible -> invalidDate', () {
      final values = valides()..['date'] = '2026-13-45';
      expect(validateCategoryValues(schema, values)['date'], FieldError.invalidDate);
    });

    test('montant au-dessus du plafond -> amountTooLarge', () {
      final values = valides()
        ..['quantite'] = '1000001'
        ..['prix'] = '1000000';
      expect(validateCategoryValues(schema, values)[amountErrorKey], FieldError.amountTooLarge);
    });

    test('montant exactement au plafond -> accepté', () {
      final values = valides()
        ..['quantite'] = '1000000'
        ..['prix'] = '1000000';
      expect(validateCategoryValues(schema, values), isEmpty);
    });

    test('pas de calcul de montant si un facteur est invalide', () {
      final values = valides()
        ..['quantite'] = 'abc'
        ..['prix'] = '1000000000000000';
      final errors = validateCategoryValues(schema, values);
      expect(errors['quantite'], FieldError.invalidNumber);
      expect(errors.containsKey(amountErrorKey), isFalse);
    });
  });

  group('computeAmount', () {
    test('produit des facteurs', () {
      expect(computeAmount(schema, valides()), 4500);
    });

    test('saisie directe avec un seul facteur', () {
      const direct = CategorySchema(
        categoryKey: 'direct',
        fields: [NumberFieldDef(key: 'montant', label: 'Montant')],
        amountFactors: ['montant'],
      );
      expect(computeAmount(direct, {'montant': '25000'}), 25000);
    });

    test('lève StateError au-dessus du plafond', () {
      final values = valides()
        ..['quantite'] = '1000001'
        ..['prix'] = '1000000';
      expect(() => computeAmount(schema, values), throwsStateError);
    });
  });
}
