import 'package:intl/intl.dart';
import 'transaction_type.dart';

/// Modèle d'une transaction financière (revenu ou dépense).
///
/// Deux corrections par rapport au prototype d'origine, directement issues
/// de l'audit du cahier des charges :
/// - [amountAriary] est un [int] (Ariary entiers), jamais un [double].
///   RM-03 : "Les montants doivent être représentés avec une précision
///   déterministe." Un double peut perdre en précision lors d'additions
///   répétées (0.1 + 0.2 != 0.3 en binaire) ; un entier ne le peut pas.
///   L'Ariary n'a pas de sous-unité utilisée en pratique, donc l'unité
///   entière suffit ici (pas besoin de "centimes").
/// - [type] est un [TransactionType] (enum), jamais une [String] libre.
///   RM-02 : impossible désormais de créer une transaction avec un type
///   invalide, le compilateur le refuse.
class TransactionModel {
  final String id;
  final int amountAriary;
  final TransactionType type;
  final DateTime date;
  final String? categorie;
  final String? iconeCategorie;

  TransactionModel({
    required this.id,
    required this.amountAriary,
    required this.type,
    required this.date,
    this.categorie,
    this.iconeCategorie,
  }) : assert(amountAriary > 0, 'Le montant doit être strictement positif (RM-01)');

  /// Crée une nouvelle transaction avec un ID généré.
  ///
  /// Remarque pour la suite (étape persistance/repository) : générer l'ID
  /// à partir de l'horodatage local est fragile (collisions possibles,
  /// pas d'UUID). On le remplacera par un UUID v4 quand on introduira le
  /// repository, mais ce n'est pas l'objet de cette étape.
  TransactionModel.create({
    required this.amountAriary,
    required this.type,
    required this.date,
    this.categorie,
    this.iconeCategorie,
  })  : id = DateTime.now().microsecondsSinceEpoch.toString(),
        assert(amountAriary > 0, 'Le montant doit être strictement positif (RM-01)');

  /// Conversion pour stockage (sera utilisée par le futur repository SQLite).
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount_ariary': amountAriary,
      'type': type.toDbValue(),
      'date': date.millisecondsSinceEpoch,
      'categorie': categorie,
      'icone_categorie': iconeCategorie,
    };
  }

  /// Reconstruction depuis le stockage.
  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as String,
      amountAriary: map['amount_ariary'] as int,
      type: TransactionType.fromDbValue(map['type'] as String),
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      categorie: map['categorie'] as String?,
      iconeCategorie: map['icone_categorie'] as String?,
    );
  }

  /// Montant formaté avec séparateur de milliers, jamais tronqué
  /// (exigence UX du cahier des charges : "Montants affichés sans
  /// troncature et avec un format monétaire cohérent").
  String get formattedAmount {
    final prefix = type == TransactionType.income ? '+' : '-';
    final formatte = NumberFormat.decimalPattern('fr_FR').format(amountAriary);
    return '$prefix$formatte Ar';
  }

  int get day => date.day;
  int get month => date.month;
  int get year => date.year;
}