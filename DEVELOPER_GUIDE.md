# 🛠️ DEVELOPER GUIDE - Comment Ajouter des Features

Ce guide explique comment étendre l'application sans casser l'architecture.

---

## 1️⃣ Ajouter un Nouveau Modèle

### Étape 1: Créer le Modèle (immutable)

```dart
// lib/core/models/expense_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

part 'expense_model.freezed.dart';
part 'expense_model.g.dart';

enum ExpenseCategory { food, transport, utilities, other }

@freezed
class Expense with _$Expense {
  const Expense._();
  
  const factory Expense({
    required String id,
    required String userId,
    required double amount,
    required ExpenseCategory category,
    required DateTime date,
    String? notes,
  }) = _Expense;
  
  factory Expense.fromJson(Map<String, dynamic> json) =>
    _$ExpenseFromJson(json);
}
```

### Étape 2: Créer les Adapteurs Hive

```dart
// lib/core/adapters/expense_adapter.dart
import 'package:hive/hive.dart';
import '../models/expense_model.dart';

class ExpenseCategoryAdapter extends TypeAdapter<ExpenseCategory> {
  @override
  final int typeId = 15; // Nouvel ID unique
  
  @override
  ExpenseCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0: return ExpenseCategory.food;
      case 1: return ExpenseCategory.transport;
      case 2: return ExpenseCategory.utilities;
      default: return ExpenseCategory.other;
    }
  }
  
  @override
  void write(BinaryWriter writer, ExpenseCategory obj) {
    switch (obj) {
      case ExpenseCategory.food: writer.writeByte(0);
      case ExpenseCategory.transport: writer.writeByte(1);
      case ExpenseCategory.utilities: writer.writeByte(2);
      case ExpenseCategory.other: writer.writeByte(3);
    }
  }
}

class ExpenseAdapter extends TypeAdapter<Expense> {
  @override
  final int typeId = 5; // Nouvel ID unique
  
  @override
  Expense read(BinaryReader reader) {
    return Expense(
      id: reader.read() as String,
      userId: reader.read() as String,
      amount: reader.read() as double,
      category: reader.read() as ExpenseCategory,
      date: reader.read() as DateTime,
      notes: reader.read() as String?,
    );
  }
  
  @override
  void write(BinaryWriter writer, Expense obj) {
    writer.write(obj.id);
    writer.write(obj.userId);
    writer.write(obj.amount);
    writer.write(obj.category);
    writer.write(obj.date);
    writer.write(obj.notes);
  }
}
```

### Étape 3: Enregistrer les Adapteurs

```dart
// Dans lib/core/utils/hive_initializer.dart

static Future<void> initializeHive() async {
  await Hive.initFlutter();
  
  // ... adapteurs existants ...
  
  // Ajouter les nouveaux
  Hive.registerAdapter(ExpenseCategoryAdapter());
  Hive.registerAdapter(ExpenseAdapter());
  
  // ... le reste ...
}
```

---

## 2️⃣ Créer un Service pour le Modèle

```dart
// lib/core/services/expense_service.dart
import 'package:hive_flutter/hive_flutter.dart';
import '../models/expense_model.dart';

class ExpenseService {
  late Box<Expense> _box;
  
  Future<void> initialize() async {
    _box = await Hive.openBox<Expense>('expenses');
  }
  
  Future<void> addExpense(Expense expense) async {
    await _box.put(expense.id, expense);
  }
  
  Future<Expense?> getExpense(String id) async {
    return _box.get(id);
  }
  
  Future<List<Expense>> getExpensesByUser(String userId) async {
    return _box.values
        .where((e) => e.userId == userId)
        .toList();
  }
  
  Future<double> getTotalExpenses(String userId) async {
    final expenses = await getExpensesByUser(userId);
    return expenses.fold<double>(0, (sum, e) => sum + e.amount);
  }
  
  Future<void> deleteExpense(String id) async {
    await _box.delete(id);
  }
  
  Future<void> clear() async {
    await _box.clear();
  }
}
```

---

## 3️⃣ Créer un Provider pour le Service

```dart
// lib/shared/providers/expense_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/expense_model.dart';
import '../../core/services/expense_service.dart';

final expenseServiceProvider = Provider<ExpenseService>((ref) {
  return ExpenseService();
});

class ExpenseNotifier extends StateNotifier<AsyncValue<List<Expense>>> {
  final ExpenseService _service;
  final String _userId;
  
  ExpenseNotifier(this._service, this._userId)
      : super(const AsyncValue.loading()) {
    _loadExpenses();
  }
  
  Future<void> _loadExpenses() async {
    try {
      final expenses = await _service.getExpensesByUser(_userId);
      state = AsyncValue.data(expenses);
    } catch (err, stack) {
      state = AsyncValue.error(err, stack);
    }
  }
  
  Future<void> addExpense(Expense expense) async {
    try {
      await _service.addExpense(expense);
      await _loadExpenses();
    } catch (err, stack) {
      state = AsyncValue.error(err, stack);
    }
  }
  
  Future<void> deleteExpense(String id) async {
    try {
      await _service.deleteExpense(id);
      await _loadExpenses();
    } catch (err, stack) {
      state = AsyncValue.error(err, stack);
    }
  }
}

final expenseProvider = StateNotifierProvider<
  ExpenseNotifier,
  AsyncValue<List<Expense>>
>((ref) {
  final service = ref.watch(expenseServiceProvider);
  final userId = ref.watch(currentUserIdProvider);
  return ExpenseNotifier(service, userId);
});

final totalExpensesProvider = FutureProvider.autoDispose<double>((ref) async {
  final service = ref.watch(expenseServiceProvider);
  final userId = ref.watch(currentUserIdProvider);
  return service.getTotalExpenses(userId);
});

final currentUserIdProvider = StateProvider<String>((ref) => 'user_1');
```

---

## 4️⃣ Créer des Widgets pour le Modèle

```dart
// lib/shared/widgets/expense_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/expense_model.dart';

class ExpenseCard extends ConsumerWidget {
  final Expense expense;
  final VoidCallback onDelete;
  
  const ExpenseCard({
    required this.expense,
    required this.onDelete,
    Key? key,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryIcons = {
      ExpenseCategory.food: Icons.restaurant,
      ExpenseCategory.transport: Icons.directions_car,
      ExpenseCategory.utilities: Icons.lightbulb,
      ExpenseCategory.other: Icons.shopping_bag,
    };
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.red.shade100,
          child: Icon(
            categoryIcons[expense.category],
            color: Colors.red,
          ),
        ),
        title: Text(expense.category.toString().split('.').last),
        subtitle: Text(
          '${expense.date.toString().split(' ')[0]} ${expense.notes ?? ''}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              child: const Text('Supprimer'),
              onTap: onDelete,
            ),
          ],
        ),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${expense.amount} Ar')),
          );
        },
      ),
    );
  }
}
```

---

## 5️⃣ Créer un Écran pour la Feature

```dart
// lib/features/expenses/presentation/expenses_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/expense_model.dart';
import '../../../shared/providers/expense_provider.dart';
import '../../../shared/widgets/expense_card.dart';

class ExpensesScreen extends ConsumerStatefulWidget {
  const ExpensesScreen({Key? key}) : super(key: key);
  
  @override
  ConsumerState<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends ConsumerState<ExpensesScreen> {
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  ExpenseCategory _selectedCategory = ExpenseCategory.food;
  
  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }
  
  void _showAddExpenseDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter une dépense'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButton<ExpenseCategory>(
              value: _selectedCategory,
              items: ExpenseCategory.values.map((cat) => 
                DropdownMenuItem(
                  value: cat,
                  child: Text(cat.toString().split('.').last),
                ),
              ).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedCategory = value);
                }
              },
            ),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Montant'),
            ),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notes (optionnel)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              final amount = double.tryParse(_amountController.text) ?? 0;
              final expense = Expense(
                id: const Uuid().v4(),
                userId: 'user_1',
                amount: amount,
                category: _selectedCategory,
                date: DateTime.now(),
                notes: _notesController.text.isEmpty ? null : _notesController.text,
              );
              
              await ref.read(expenseProvider.notifier).addExpense(expense);
              
              if (mounted) {
                Navigator.pop(context);
                _amountController.clear();
                _notesController.clear();
              }
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final expensesAsync = ref.watch(expenseProvider);
    final totalAsync = ref.watch(totalExpensesProvider);
    
    return Scaffold(
      appBar: AppBar(title: const Text('Dépenses')),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.red.shade50,
            child: totalAsync.when(
              data: (total) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total dépenses'),
                  Text(
                    '${total.toStringAsFixed(2)} Ar',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              loading: () => const CircularProgressIndicator(),
              error: (err, stack) => Text('Erreur: $err'),
            ),
          ),
          Expanded(
            child: expensesAsync.when(
              data: (expenses) => expenses.isEmpty
                  ? const Center(child: Text('Aucune dépense'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: expenses.length,
                      itemBuilder: (context, index) => ExpenseCard(
                        expense: expenses[index],
                        onDelete: () async {
                          await ref
                              .read(expenseProvider.notifier)
                              .deleteExpense(expenses[index].id);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Dépense supprimée')),
                            );
                          }
                        },
                      ),
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Erreur: $err')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddExpenseDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

---

## 6️⃣ Ajouter l'Écran à la Navigation

```dart
// Modifier lib/main.dart

class MainApp extends StatefulWidget {
  const MainApp({Key? key}) : super(key: key);
  
  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _selectedIndex = 0;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          DashboardScreen(),
          TransactionsScreen(),
          SavingsScreen(),
          ExpensesScreen(),      // ← NOUVEAU
          CreditScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.savings),
            label: 'Épargnes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.credit_card),
            label: 'Dépenses',       // ← NOUVEAU
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: 'Prêts',
          ),
        ],
      ),
    );
  }
}
```

---

## ✅ Checklist pour Ajouter une Feature

- [ ] Modèle créé (immutable, copyWith, serialization)
- [ ] TypeId unique assigné (30+)
- [ ] Adapteurs Hive créés + enregistrés
- [ ] Service créé avec CRUD
- [ ] Service initialisé dans HiveInitializer
- [ ] Provider créé (StateNotifier + helpers)
- [ ] Widget créé (Card ou équivalent)
- [ ] Écran créé (ConsumerWidget/StatefulWidget)
- [ ] Écran ajouté à la navigation
- [ ] Données de démo populées (optionnel)
- [ ] Tests unitaires (optionnel)

---

## 🚫 Pièges à Éviter

### ❌ Ne pas faire:
```dart
// ❌ TypeIds en dur sans doc
Hive.registerAdapter(MyAdapter()); // Quel typeId?

// ❌ Mutable models
class User {
  String name;  // Pas const, pas @final
}

// ❌ Pas d'exception handling
Future<void> add(Item item) async {
  await box.put(item.id, item);  // Pas de try/catch
}

// ❌ Watch dans ref.read()
ref.read(provider.watch);  // Erreur!

// ❌ Adapter Hive manuels mal implémentés
class MyAdapter extends TypeAdapter {
  @override
  MyAdapter read(BinaryReader reader) {
    // reader.read() sans ordre correct = data loss
  }
}
```

### ✅ Faire plutôt:
```dart
// ✅ TypeId documenté
class MyAdapter extends TypeAdapter<MyModel> {
  @override
  final int typeId = 20;  // Commentaire: "20 est libre, >= 15"
}

// ✅ Immutable models
@freezed
class User with _$User {
  const factory User({...}) = _User;
}

// ✅ Exception handling
Future<void> add(Item item) async {
  try {
    await box.put(item.id, item);
  } catch (e) {
    throw ServiceException('Failed to add: $e');
  }
}

// ✅ Correct watch usage
final data = ref.watch(provider);
ref.read(provider).method();  // OK pour appeler méthodes

// ✅ Adapter corrects
class MyAdapter extends TypeAdapter<MyModel> {
  @override
  MyModel read(BinaryReader reader) {
    final id = reader.read() as String;
    final name = reader.read() as String;
    final date = reader.read() as DateTime;
    return MyModel(id: id, name: name, date: date);
  }
  
  @override
  void write(BinaryWriter writer, MyModel obj) {
    writer.write(obj.id);
    writer.write(obj.name);
    writer.write(obj.date);
  }
}
```

---

## 📚 Ressources Utiles

- [Riverpod Doc](https://riverpod.dev)
- [Hive Doc](https://docs.hivedb.dev)
- [Flutter Material Design](https://material.io/design)
- [Dart Null Safety](https://dart.dev/null-safety)

---

**Happy Coding! 🚀**
