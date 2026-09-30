import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../data/transaction_repository.dart';
import '../models/transaction_model.dart';
import '../models/transaction_type.dart';

/// État des transactions, persisté dans SQLite via [TransactionRepository].
///
/// La liste en mémoire sert de cache pour l'UI : chaque modification est
/// d'abord écrite en base, puis répercutée en mémoire. Si l'écriture échoue,
/// l'exception remonte et l'état en mémoire reste inchangé.
class TransactionProvider with ChangeNotifier {
  TransactionProvider({TransactionRepository? repository})
      : _repository = repository ?? TransactionRepository();

  final TransactionRepository _repository;
  final List<TransactionModel> _transactions = [];

  // Totaux en int, jamais en double (RM-03 : précision monétaire
  // déterministe). Recalculés une seule fois par modification, pas à
  // chaque lecture.
  int _totalRevenus = 0;
  int _totalDepenses = 0;
  bool _isLoading = false;

  /// Vue en lecture seule : l'UI ne peut pas modifier la liste directement.
  List<TransactionModel> get transactions =>
      UnmodifiableListView(_transactions);

  int get totalRevenus => _totalRevenus;
  int get totalDepenses => _totalDepenses;
  int get balance => _totalRevenus - _totalDepenses;
  bool get isLoading => _isLoading;

  /// Charge les transactions depuis SQLite (à appeler au démarrage).
  Future<void> loadTransactions() async {
    _isLoading = true;
    notifyListeners();
    try {
      final loaded = await _repository.getAll();
      _transactions
        ..clear()
        ..addAll(loaded);
      _recalculateTotals();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    await _repository.insert(transaction);
    _transactions.add(transaction);
    _transactions.sort((a, b) => b.date.compareTo(a.date));
    _recalculateTotals();
    notifyListeners();
  }

  Future<void> removeTransaction(String id) async {
    await _repository.delete(id);
    _transactions.removeWhere((transaction) => transaction.id == id);
    _recalculateTotals();
    notifyListeners();
  }

  Future<void> addTransactionWithAmount({
    required int amountAriary,
    required TransactionType type,
    DateTime? date,
  }) {
    final transaction = TransactionModel.create(
      amountAriary: amountAriary,
      type: type,
      date: date ?? DateTime.now(),
    );
    return addTransaction(transaction);
  }

  Future<void> clearAllTransactions() async {
    await _repository.deleteAll();
    _transactions.clear();
    _recalculateTotals();
    notifyListeners();
  }

  void _recalculateTotals() {
    var revenus = 0;
    var depenses = 0;
    for (final transaction in _transactions) {
      if (transaction.type == TransactionType.income) {
        revenus += transaction.amountAriary;
      } else {
        depenses += transaction.amountAriary;
      }
    }
    _totalRevenus = revenus;
    _totalDepenses = depenses;
  }
}