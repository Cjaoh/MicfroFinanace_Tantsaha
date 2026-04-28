import 'package:flutter/material.dart';
import '../models/transaction_model.dart';

class TransactionProvider with ChangeNotifier {
  final List<TransactionModel> _transactions = [];

  List<TransactionModel> get transactions => _transactions;

  // Get balance
  double get balance {
    double total = 0.0;
    for (var transaction in _transactions) {
      if (transaction.type == 'income') {
        total += transaction.amount;
      } else {
        total -= transaction.amount;
      }
    }
    return total;
  }

  // Get total revenues
  double get totalRevenus {
    double total = 0.0;
    for (var transaction in _transactions) {
      if (transaction.type == 'income') {
        total += transaction.amount;
      }
    }
    return total;
  }

  // Get total depenses
  double get totalDepenses {
    double total = 0.0;
    for (var transaction in _transactions) {
      if (transaction.type == 'expense') {
        total += transaction.amount;
      }
    }
    return total;
  }

  // Add transaction
  void addTransaction(TransactionModel transaction) {
    _transactions.add(transaction);
    notifyListeners();
  }

  // Remove transaction by ID
  void removeTransaction(String id) {
    _transactions.removeWhere((transaction) => transaction.id == id);
    notifyListeners();
  }

  // Add transaction with generated ID
  void addTransactionWithAmount({
    required double amount,
    required String type,
    DateTime? date,
  }) {
    final transaction = TransactionModel.create(
      amount: amount,
      type: type,
      date: date ?? DateTime.now(),
    );
    addTransaction(transaction);
  }

  // Clear all transactions
  void clearAllTransactions() {
    _transactions.clear();
    notifyListeners();
  }
}
