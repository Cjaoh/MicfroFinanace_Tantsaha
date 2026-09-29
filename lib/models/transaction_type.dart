/// Type d'une opération financière.
///
/// Remplace les chaînes magiques 'income' / 'expense' (RM-02 du cahier des
/// charges : "Une transaction ne peut pas avoir un type arbitraire ; utiliser
/// un enum/valeur contrôlée."). Avec un enum, une valeur invalide ne peut
/// tout simplement plus être créée : le compilateur l'empêche.
enum TransactionType {
  income,
  expense;

  /// Valeur stockée en base (SQLite/PostgreSQL) et échangée avec l'API.
  /// On garde une valeur stable et explicite, indépendante du nom Dart de
  /// l'enum, pour ne jamais casser les données déjà enregistrées si le code
  /// évolue.
  String toDbValue() {
    switch (this) {
      case TransactionType.income:
        return 'income';
      case TransactionType.expense:
        return 'expense';
    }
  }

  /// Reconstruit l'enum à partir d'une valeur stockée. Lève une erreur
  /// explicite plutôt que de laisser passer une valeur inconnue en
  /// silence — c'est ce qui manquait dans le prototype.
  static TransactionType fromDbValue(String value) {
    switch (value) {
      case 'income':
        return TransactionType.income;
      case 'expense':
        return TransactionType.expense;
      default:
        throw ArgumentError('Type de transaction inconnu : "$value"');
    }
  }
}