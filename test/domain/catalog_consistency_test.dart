import 'package:flutter_test/flutter_test.dart';
import 'package:microfinance_tantsaha/domain/category_catalog.dart';
import 'package:microfinance_tantsaha/domain/category_schema.dart';
import 'package:microfinance_tantsaha/domain/category_schemas.dart';

void main() {
  test('chaque catégorie du catalogue a un schéma', () {
    final catalogKeys = categoryCatalog.map((c) => c.key).toSet();
    expect(categorySchemas.keys.toSet(), equals(catalogKeys));
  });

  test('chaque schéma pointe vers sa propre clé de catégorie', () {
    for (final entry in categorySchemas.entries) {
      expect(entry.value.categoryKey, entry.key);
    }
  });

  test('aucune clé de catégorie n\'est dupliquée dans le catalogue', () {
    final keys = categoryCatalog.map((c) => c.key).toList();
    expect(keys.toSet().length, keys.length);
  });

  test('chaque schéma a au moins un champ et un facteur de montant', () {
    for (final schema in categorySchemas.values) {
      expect(schema.fields, isNotEmpty, reason: schema.categoryKey);
      expect(schema.amountFactors, isNotEmpty, reason: schema.categoryKey);
    }
  });

  test('chaque facteur de montant correspond à un champ numérique du schéma', () {
    for (final schema in categorySchemas.values) {
      final numericKeys = schema.fields
          .whereType<NumberFieldDef>()
          .map((f) => f.key)
          .toSet();
      for (final factor in schema.amountFactors) {
        expect(numericKeys, contains(factor), reason: schema.categoryKey);
      }
    }
  });
}
