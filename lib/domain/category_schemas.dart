import 'category_schema.dart';

/// Schémas des 13 catégories. Ajouter une catégorie = ajouter une entrée ici.
/// La clé de la map doit toujours égaler [CategorySchema.categoryKey] (vérifié par les tests).
const Map<String, CategorySchema> categorySchemas = {
  'ventes_recoltes': CategorySchema(
    categoryKey: 'ventes_recoltes',
    fields: [
      ChoiceFieldDef(
        key: 'culture',
        label: 'Type de culture',
        options: ['Fruits', 'Légumes', 'Céréales', 'Tubercules', 'Autres'],
      ),
      NumberFieldDef(key: 'quantite', label: 'Quantité (kg)'),
      NumberFieldDef(key: 'prix_unitaire', label: 'Prix par kg (Ar)'),
      TextFieldDef(key: 'acheteur', label: 'Acheteur', optional: true),
    ],
    amountFactors: ['quantite', 'prix_unitaire'],
  ),
  'elevage': CategorySchema(
    categoryKey: 'elevage',
    fields: [
      ChoiceFieldDef(
        key: 'produit',
        label: 'Animal ou produit',
        options: ['Bétail', 'Lait', 'Œufs', 'Volaille', 'Autre'],
      ),
      NumberFieldDef(key: 'quantite', label: 'Quantité'),
      NumberFieldDef(key: 'prix_unitaire', label: 'Prix unitaire (Ar)'),
      TextFieldDef(key: 'acheteur', label: 'Acheteur', optional: true),
    ],
    amountFactors: ['quantite', 'prix_unitaire'],
  ),
  'pret_recu': CategorySchema(
    categoryKey: 'pret_recu',
    fields: [
      ChoiceFieldDef(
        key: 'source',
        label: 'Source du prêt',
        options: ['IMF', 'Famille', 'Groupe / tontine', 'Autre'],
      ),
      NumberFieldDef(key: 'montant', label: 'Montant (Ar)'),
      DateFieldDef(key: 'echeance', label: 'Échéance prévue', optional: true),
    ],
    amountFactors: ['montant'],
  ),
  'prestations': CategorySchema(
    categoryKey: 'prestations',
    fields: [
      ChoiceFieldDef(
        key: 'nature',
        label: 'Nature du service',
        options: ["Main-d'œuvre", 'Transport', 'Location de matériel', 'Autre'],
      ),
      NumberFieldDef(key: 'jours', label: 'Nombre de jours'),
      NumberFieldDef(key: 'tarif_jour', label: 'Tarif par jour (Ar)'),
    ],
    amountFactors: ['jours', 'tarif_jour'],
  ),
  'intrants': CategorySchema(
    categoryKey: 'intrants',
    fields: [
      ChoiceFieldDef(
        key: 'type',
        label: "Type d'intrant",
        options: ['Semences', 'Engrais', 'Pesticides', 'Outils', 'Autre'],
      ),
      NumberFieldDef(key: 'quantite', label: 'Quantité'),
      NumberFieldDef(key: 'prix_unitaire', label: 'Prix unitaire (Ar)'),
    ],
    amountFactors: ['quantite', 'prix_unitaire'],
  ),
  'carburant_entretien': CategorySchema(
    categoryKey: 'carburant_entretien',
    fields: [
      ChoiceFieldDef(
        key: 'nature',
        label: 'Nature',
        options: ['Carburant', 'Entretien', 'Réparation'],
      ),
      TextFieldDef(key: 'machine', label: 'Machine concernée'),
      NumberFieldDef(key: 'montant', label: 'Montant (Ar)'),
    ],
    amountFactors: ['montant'],
  ),
  'main_oeuvre': CategorySchema(
    categoryKey: 'main_oeuvre',
    fields: [
      NumberFieldDef(key: 'personnes', label: 'Nombre de personnes'),
      NumberFieldDef(key: 'jours', label: 'Nombre de jours'),
      NumberFieldDef(key: 'tarif_jour', label: 'Tarif par jour (Ar)'),
    ],
    amountFactors: ['personnes', 'jours', 'tarif_jour'],
  ),
  'remboursement_pret': CategorySchema(
    categoryKey: 'remboursement_pret',
    fields: [
      TextFieldDef(key: 'reference', label: 'Référence du prêt'),
      NumberFieldDef(key: 'montant', label: 'Montant (Ar)'),
    ],
    amountFactors: ['montant'],
  ),
  'besoins_familiaux': CategorySchema(
    categoryKey: 'besoins_familiaux',
    fields: [
      ChoiceFieldDef(
        key: 'besoin',
        label: 'Type de besoin',
        options: ['Nourriture', 'Santé', 'École', 'Autre'],
      ),
      NumberFieldDef(key: 'montant', label: 'Montant (Ar)'),
      TextFieldDef(key: 'note', label: 'Note', optional: true),
    ],
    amountFactors: ['montant'],
  ),
  'reserve_saison': CategorySchema(
    categoryKey: 'reserve_saison',
    fields: [
      ChoiceFieldDef(
        key: 'saison',
        label: 'Saison ou culture visée',
        options: ['Saison prochaine', 'Contre-saison', 'Autre'],
      ),
      NumberFieldDef(key: 'montant', label: 'Montant mis de côté (Ar)'),
      NumberFieldDef(key: 'objectif', label: 'Objectif (Ar)', optional: true),
    ],
    amountFactors: ['montant'],
  ),
  'imprevus': CategorySchema(
    categoryKey: 'imprevus',
    fields: [
      NumberFieldDef(key: 'montant', label: 'Montant mis de côté (Ar)'),
      TextFieldDef(key: 'note', label: 'Note', optional: true),
    ],
    amountFactors: ['montant'],
  ),
  'scolarite': CategorySchema(
    categoryKey: 'scolarite',
    fields: [
      TextFieldDef(key: 'eleve', label: "Nom de l'élève"),
      TextFieldDef(key: 'annee', label: 'Année scolaire'),
      NumberFieldDef(key: 'montant', label: 'Montant mis de côté (Ar)'),
    ],
    amountFactors: ['montant'],
  ),
  'projet_equipement': CategorySchema(
    categoryKey: 'projet_equipement',
    fields: [
      TextFieldDef(key: 'projet', label: 'Nom du projet'),
      NumberFieldDef(key: 'montant', label: 'Montant mis de côté (Ar)'),
      NumberFieldDef(key: 'objectif', label: 'Objectif (Ar)', optional: true),
    ],
    amountFactors: ['montant'],
  ),
};

/// Schéma d'une catégorie, ou null si la clé est inconnue.
CategorySchema? schemaFor(String categoryKey) => categorySchemas[categoryKey];