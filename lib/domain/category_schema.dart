/// Définition d'un champ de formulaire.
/// Les libellés sont provisoires : ils seront remplacés par des clés ARB (étape D).
sealed class FieldDef {
  final String key;
  final String label;
  final bool optional;

  const FieldDef({required this.key, required this.label, this.optional = false});
}

class TextFieldDef extends FieldDef {
  const TextFieldDef({required super.key, required super.label, super.optional});
}

class NumberFieldDef extends FieldDef {
  /// Valeur minimale acceptée (1 par défaut : pas de quantité ou de montant nul).
  final int min;

  const NumberFieldDef({
    required super.key,
    required super.label,
    super.optional,
    this.min = 1,
  });
}

class ChoiceFieldDef extends FieldDef {
  final List<String> options;

  const ChoiceFieldDef({
    required super.key,
    required super.label,
    required this.options,
    super.optional,
  });
}

class DateFieldDef extends FieldDef {
  const DateFieldDef({required super.key, required super.label, super.optional});
}

/// Schéma d'une catégorie : ses champs et la règle de calcul du montant.
/// Les données (la liste des 13 catégories) sont dans category_schemas.dart.
class CategorySchema {
  /// Doit correspondre à la clé de la catégorie dans le catalogue.
  final String categoryKey;
  final List<FieldDef> fields;

  /// Clés des champs numériques dont le produit donne le montant.
  /// Un seul champ = saisie directe du montant (ex. ['montant']).
  final List<String> amountFactors;

  const CategorySchema({
    required this.categoryKey,
    required this.fields,
    required this.amountFactors,
  });
}