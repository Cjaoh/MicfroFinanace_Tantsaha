# Architecture et Utilisation - MicroFinance Tantsaha

## 📋 Vue d'ensemble

L'application est structurée suivant une **Clean Architecture** avec:
- **Modèles** immutables avec null safety
- **Services** pour l'accès aux données (Hive)
- **Providers Riverpod** pour la gestion d'état
- **Widgets réutilisables** Material 3
- **Écrans** ConsumerWidget avec Riverpod

## 📁 Structure des fichiers

```
lib/
├── core/
│   ├── adapters/        # Adapteurs Hive manuels
│   ├── models/          # Modèles de données (User, Transaction, Loan, Savings)
│   ├── services/        # Services CRUD (UserService, TransactionService, etc.)
│   ├── constants/       # Constantes de l'app
│   └── utils/           # Initializers (HiveInitializer, DemoDataGenerator)
│
├── features/
│   ├── dashboard/       # Tableau de bord principal
│   ├── transactions/    # Gestion des transactions
│   ├── savings/         # Gestion des épargnes
│   └── credit/          # Gestion des prêts
│
├── shared/
│   ├── providers/       # Providers Riverpod (user, transaction, loan, savings)
│   └── widgets/         # Widgets réutilisables (TransactionCard, LoanCard, etc.)
│
└── main.dart            # Point d'entrée
```

## 🔌 Initialisation

Au lancement, `main.dart`:
1. Initialise Hive et enregistre les adapteurs
2. Popule les données de démo
3. Lance l'app avec ProviderScope

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveInitializer.initializeHive();
  await DemoDataGenerator.populateDemoData();
  runApp(const ProviderScope(child: MyApp()));
}
```

## 📦 Modèles

### User
- Champs: `id`, `name`, `role` (farmer/admin/agent), `phone`, `createdAt`
- Immutable avec `copyWith()`, `toJson()`, `fromJson()`
- Comparaisons `==` et `hashCode`

### Transaction
- Champs: `id`, `userId`, `type` (income/expense), `amount`, `category`, `description`, `date`
- Permet le calcul du solde

### Loan
- Champs: `id`, `userId`, `amount`, `purpose`, `status` (pending/approved/rejected/overdue/paid)
- Contient un `List<Repayment>` avec plan de remboursement

### Savings
- Champs: `id`, `userId`, `amount`, `type` (deposit/withdraw), `date`, `balanceAfter`
- Solde calculé à chaque opération

## 🔧 Services

Chaque service (UserService, TransactionService, etc.):
- Gère une Box Hive spécifique
- Implémente les CRUD + méthodes métier
- Lève des exceptions personnalisées
- Est un singleton via Riverpod

### Exemple: TransactionService

```dart
final service = TransactionService();
await service.initialize();

final balance = await service.getBalance(userId);
await service.addTransaction(transaction);
final byRange = await service.getTransactionsByDateRange(userId, start, end);
```

## 📱 Providers Riverpod

### StateNotifierProvider (pour états complexes)

```dart
final transactionProvider = StateNotifierProvider<
  TransactionNotifier,
  AsyncValue<List<Transaction>>
>((ref) {
  final service = ref.watch(transactionServiceProvider);
  final userId = ref.watch(currentUserIdProvider);
  return TransactionNotifier(service, userId);
});
```

### FutureProvider (pour données asynchrones)

```dart
final transactionBalanceProvider = FutureProvider.autoDispose<double>((ref) async {
  final service = ref.watch(transactionServiceProvider);
  final userId = ref.watch(currentUserIdProvider);
  return service.getBalance(userId);
});
```

### StateProvider (pour état simple)

```dart
final currentUserIdProvider = StateProvider<String>((ref) => 'user_1');
```

## 🎨 Widgets

### TransactionCard
- Props: `Transaction`, `VoidCallback onDelete`
- Affiche icône (income/expense), montant, catégorie, date
- Menu popup pour supprimer

### LoanCard
- Props: `Loan`, callbacks d'approbation/rejet
- Affiche statut (couleur), montant, purpose
- ExpansionTile pour les remboursements

### CreditScoreGauge
- Props: `double score` (0-100)
- Jauge circulaire avec CustomPaint
- Label de score (Excellent/Bon/Moyen/Faible)

### SavingsCard
- Props: `Savings`, `VoidCallback onDelete`
- Affiche type (dépôt/retrait), montant, solde actuel

## 🖥️ Écrans

### DashboardScreen
- Résumé du solde total
- Grille de statistiques (épargnes, prêts actifs, en retard, score)
- Jauge de score de crédit

### TransactionsScreen
- Affichage du solde actuel
- ListView des transactions
- FAB pour ajouter une transaction
- Dialog de création avec validation

### SavingsScreen
- Montant total épargné
- Boutons Dépôt/Retrait
- Historique des opérations

### CreditScreen (ancien LoanScreen)
- Liste des prêts avec statut
- ExpansionTile des remboursements
- Boutons Approuver/Rejeter (si pending)
- FAB pour demander un prêt

## 🚀 Utilisation

### Ajouter une transaction

```dart
final transaction = Transaction(
  id: const Uuid().v4(),
  userId: 'user_1',
  type: TransactionType.income,
  amount: 50000,
  category: 'Vente de riz',
  date: DateTime.now(),
);

await ref.read(transactionProvider.notifier).addTransaction(transaction);
```

### Récupérer le solde

```dart
final balance = ref.watch(transactionBalanceProvider);
balance.when(
  data: (value) => Text('Solde: $value Ar'),
  loading: () => const CircularProgressIndicator(),
  error: (err, stack) => Text('Erreur: $err'),
);
```

### Demander un prêt

```dart
final loan = Loan(
  id: const Uuid().v4(),
  userId: 'user_1',
  amount: 150000,
  purpose: 'Matériel agricole',
  status: LoanStatus.pending,
  repaymentPlan: _generatePlan(150000),
  createdAt: DateTime.now(),
);

await ref.read(loanProvider.notifier).applyLoan(loan);
```

## 📊 Données de démo

`DemoDataGenerator` peuple automatiquement:
- 3 utilisateurs (farmer, farmer, admin)
- 10 transactions variées
- 3 prêts (approved, overdue, pending)
- 5 opérations d'épargne

À utiliser pour tester sans data réelles.

## ⚠️ Important

- **Null safety**: Tous les champs requisis, pas de nullable inutile
- **Immutabilité**: Modèles immuables avec `copyWith()`
- **Types**: Énums pour Role, Status, Type au lieu de String
- **Erreurs**: Exceptions typées pour chaque service
- **Hive**: Adapteurs manuels (pas de build_runner requis)

## 🔄 Flow de données

1. **UI appelle Provider** → `ref.read/watch()`
2. **Provider obtient Service** → `ref.watch(serviceProvider)`
3. **Service accède Hive** → Box CRUD operations
4. **Provider met à jour état** → `StateNotifier.state`
5. **UI se reconstruit** → Widget rebuild

## 🎯 Points clés

✅ Code production-ready (pas de TODOs)
✅ Async/await pour opérations I/O
✅ Gestion d'erreurs avec SnackBar/Dialogs
✅ Material 3 avec ColorScheme moderne
✅ Pas de commentaires superflus
✅ Isolation des concerns (services/providers/widgets)
