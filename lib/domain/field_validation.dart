import 'category_schema.dart';

/// Montant maximal accepté (1 000 milliards d'Ariary). Garde-fou contre
/// les erreurs de saisie et contre le dépassement d'entier.
const int maxAmountAriary = 1000000000000;

/// Erreurs de validation : des codes, pas des textes. L'interface les traduit.
enum FieldError {
  required,
  invalidNumber,
  tooSmall,
  invalidChoice,
  invalidDate,
  amountTooLarge,
}

/// Clé de l'erreur portant sur le montant calculé (et non sur un champ précis).
const String amountErrorKey = '_amount';

/// Valeurs saisies telles quelles dans les champs (toujours des textes).
typedef RawValues = Map<String, String>;

/// Retourne les erreurs par champ. Une map vide signifie que tout est valide.
Map<String, FieldError> validateCategoryValues(CategorySchema schema, RawValues values) {
  final errors = <String, FieldError>{};

  for (final field in schema.fields) {
    final raw = (values[field.key] ?? '').trim();

    if (raw.isEmpty) {
      if (!field.optional) errors[field.key] = FieldError.required;
      continue;
    }

    switch (field) {
      case TextFieldDef():
        break;
      case NumberFieldDef(:final min):
        final n = int.tryParse(raw);
        if (n == null) {
          errors[field.key] = FieldError.invalidNumber;
        } else if (n < min) {
          errors[field.key] = FieldError.tooSmall;
        }
      case ChoiceFieldDef(:final options):
        if (!options.contains(raw)) errors[field.key] = FieldError.invalidChoice;
      case DateFieldDef():
        if (DateTime.tryParse(raw) == null) errors[field.key] = FieldError.invalidDate;
    }
  }

  // Le montant n'est vérifié que si tous ses facteurs sont valides.
  final factorsValid = schema.amountFactors.every((key) => !errors.containsKey(key));
  if (factorsValid && _productOf(schema, values) > BigInt.from(maxAmountAriary)) {
    errors[amountErrorKey] = FieldError.amountTooLarge;
  }

  return errors;
}

/// Montant en Ariary. Doit être appelé uniquement après validation,
/// sinon une [StateError] est levée.
int computeAmount(CategorySchema schema, RawValues values) {
  final total = _productOf(schema, values);
  if (total > BigInt.from(maxAmountAriary)) {
    throw StateError('Montant hors limite : valider les valeurs avant de calculer.');
  }
  return total.toInt();
}

/// Produit des facteurs, calculé en BigInt pour ne jamais déborder.
BigInt _productOf(CategorySchema schema, RawValues values) {
  var total = BigInt.one;
  for (final key in schema.amountFactors) {
    total *= BigInt.from(int.parse(values[key]!.trim()));
  }
  return total;
}