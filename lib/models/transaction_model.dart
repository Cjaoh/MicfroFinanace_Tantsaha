class TransactionModel {
  final String id;
  final double amount;
  final String type; // 'income' or 'expense'
  final DateTime date;
  final String? categorie;
  final String? iconeCategorie;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.type,
    required this.date,
    this.categorie,
    this.iconeCategorie,
  });

  // Create a new transaction with generated ID
  TransactionModel.create({
    required this.amount,
    required this.type,
    required this.date,
    this.categorie,
    this.iconeCategorie,
  }) : id = DateTime.now().millisecondsSinceEpoch.toString();

  // Convert to map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'type': type,
      'date': date.millisecondsSinceEpoch,
      'categorie': categorie,
      'iconeCategorie': iconeCategorie,
    };
  }

  // Create from map
  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      amount: map['amount'],
      type: map['type'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      categorie: map['categorie'],
      iconeCategorie: map['iconeCategorie'],
    );
  }

  // Get formatted amount with type
  String get formattedAmount {
    final prefix = type == 'income' ? '+' : '-';
    return '$prefix${amount.toStringAsFixed(2)} Ar';
  }

  // Get day, month, year for display
  int get day => date.day;
  int get month => date.month;
  int get year => date.year;
}
