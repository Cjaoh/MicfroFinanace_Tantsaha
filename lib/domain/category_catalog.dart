import '../models/transaction_type.dart';

/// Catégorie de transaction : une donnée, pas un écran.
/// [key] est l'identifiant stable enregistré en base ; il ne change jamais.
/// [label] est provisoire : il sera remplacé par une clé ARB à l'étape D.
class CategoryDefinition {
  final String key;
  final TransactionType type;
  final String icon;
  final String label;

  const CategoryDefinition({
    required this.key,
    required this.type,
    required this.icon,
    required this.label,
  });
}

const List<CategoryDefinition> categoryCatalog = [
  CategoryDefinition(key: 'ventes_recoltes', type: TransactionType.income, icon: '🌾', label: 'Ventes de récoltes'),
  CategoryDefinition(key: 'elevage', type: TransactionType.income, icon: '🐄', label: 'Élevage / Produits animaux'),
  CategoryDefinition(key: 'pret_recu', type: TransactionType.income, icon: '💸', label: 'Prêt reçu'),
  CategoryDefinition(key: 'prestations', type: TransactionType.income, icon: '🛠️', label: 'Prestations de services'),

  CategoryDefinition(key: 'intrants', type: TransactionType.expense, icon: '🌱', label: 'Intrants agricoles'),
  CategoryDefinition(key: 'carburant_entretien', type: TransactionType.expense, icon: '⛽', label: 'Carburant & Entretien'),
  CategoryDefinition(key: 'main_oeuvre', type: TransactionType.expense, icon: '👥', label: "Main d'œuvre"),
  CategoryDefinition(key: 'remboursement_pret', type: TransactionType.expense, icon: '💰', label: 'Remboursement de prêt'),
  CategoryDefinition(key: 'besoins_familiaux', type: TransactionType.expense, icon: '🏠', label: 'Besoins familiaux'),

  CategoryDefinition(key: 'reserve_saison', type: TransactionType.saving, icon: '🌾', label: 'Réserve prochaine saison'),
  CategoryDefinition(key: 'imprevus', type: TransactionType.saving, icon: '🛡️', label: 'Imprévus'),
  CategoryDefinition(key: 'scolarite', type: TransactionType.saving, icon: '🎓', label: 'Scolarité'),
  CategoryDefinition(key: 'projet_equipement', type: TransactionType.saving, icon: '🎯', label: 'Projet / Équipement'),
];

/// Catégories proposées pour un type donné.
List<CategoryDefinition> categoriesFor(TransactionType type) =>
    categoryCatalog.where((c) => c.type == type).toList();

/// Libellé du type (provisoire, comme [CategoryDefinition.label]).
String libelleType(TransactionType type) {
  switch (type) {
    case TransactionType.income:
      return 'Revenu';
    case TransactionType.expense:
      return 'Dépense';
    case TransactionType.saving:
      return 'Épargne';
  }
}