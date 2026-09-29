import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../models/transaction_type.dart';

class TransactionProvider with ChangeNotifier {
  final List<TransactionModel> _transactions = [];

  List<TransactionModel> get transactions => _transactions;

  // Solde : un int, jamais un double (RM-03 — précision monétaire
  // déterministe). Plus de risque d'arrondi qui s'accumule silencieusement.
  int get balance {
    var total = 0;
    for (var transaction in _transactions) {
      if (transaction.type == TransactionType.income) {
        total += transaction.amountAriary;
      } else {
        total -= transaction.amountAriary;
      }
    }
    return total;
  }

  int get totalRevenus {
    var total = 0;
    for (var transaction in _transactions) {
      if (transaction.type == TransactionType.income) {
        total += transaction.amountAriary;
      }
    }
    return total;
  }

  int get totalDepenses {
    var total = 0;
    for (var transaction in _transactions) {
      if (transaction.type == TransactionType.expense) {
        total += transaction.amountAriary;
      }
    }
    return total;
  }

  void addTransaction(TransactionModel transaction) {
    _transactions.add(transaction);
    notifyListeners();
  }

  void removeTransaction(String id) {
    _transactions.removeWhere((transaction) => transaction.id == id);
    notifyListeners();
  }

  void addTransactionWithAmount({
    required int amountAriary,
    required TransactionType type,
    DateTime? date,
  }) {
    final transaction = TransactionModel.create(
      amountAriary: amountAriary,
      type: type,
      date: date ?? DateTime.now(),
    );
    addTransaction(transaction);
  }

  void clearAllTransactions() {
    _transactions.clear();
    notifyListeners();
  }
}