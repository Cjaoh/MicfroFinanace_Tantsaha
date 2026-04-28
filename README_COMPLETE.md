# MicroFinance Tantsaha

## 📱 A Complete Flutter MVP for Rural Farmers

MicroFinance Tantsaha is a mobile application designed to help rural farmers manage their finances and access microcredit services. The app provides comprehensive financial management tools with offline-first capabilities.

## ✨ Features

### 1. **Dashboard**
- View total balance at a glance
- See total income, expenses, and savings
- Monitor credit score and approval status
- Financial overview with key metrics

### 2. **Transactions Management**
- Add income transactions (harvest sales, market sales, etc.)
- Add expense transactions (seeds, fertilizer, tools maintenance)
- View transaction history with dates and amounts
- Color-coded transactions (green for income, red for expenses)
- Delete transactions if needed

### 3. **Savings Tracking**
- Record savings with descriptions
- Track savings goals (emergency fund, equipment fund, etc.)
- View total savings accumulated
- View savings history

### 4. **Microcredit System**
- Automatic credit score calculation (Income - Expenses)
- Eligibility determination (approved if score > 0)
- Loan calculator for estimating monthly payments
- Calculate total loan cost over specified duration
- See credit approval status in real-time

### 5. **Local Storage**
- All data persists locally using Hive database
- No internet connection required
- Offline-first architecture

## 🏗️ Architecture

The app follows **Clean Architecture** principles with a **feature-first structure**:

```
lib/
├── core/
│   ├── constants/          # App constants
│   ├── utils/              # Utilities and extensions
│   └── services/           # Core services (HiveService)
├── features/
│   ├── transactions/       # Transaction feature
│   ├── credit/            # Microcredit feature
│   ├── savings/           # Savings feature
│   └── dashboard/         # Dashboard feature
├── shared/
│   ├── widgets/           # Reusable widgets
│   └── providers/         # Riverpod providers
└── main.dart
```

## 🔧 Tech Stack

- **Flutter**: Latest stable version
- **Riverpod**: State management (StateNotifier pattern)
- **Hive**: Local database (no Firebase, no SQLite)
- **Intl**: Internationalization for currency formatting
- **UUID**: Unique ID generation
- **Material 3**: Modern UI design system

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Dart 3.0+

### Installation

1. **Clone the project**
   ```bash
   cd microfinance_tantsaha
   ```

2. **Get dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## 📊 Initial Demo Data

The app comes pre-loaded with demo data for testing:

### Sample Transactions
- Rice harvest sale: 50,000 Ar (income)
- Vegetable market sales: 30,000 Ar (income)
- Seeds purchase: 15,000 Ar (expense)
- Fertilizer: 8,000 Ar (expense)
- Tools maintenance: 5,000 Ar (expense)

**Calculated Values:**
- Total Income: 80,000 Ar
- Total Expenses: 28,000 Ar
- Balance: 52,000 Ar
- Credit Score: 52,000 Ar (APPROVED ✓)

### Sample Savings
- Emergency fund: 20,000 Ar
- Farming equipment fund: 10,000 Ar
- **Total Savings: 30,000 Ar**

## 💳 Credit Scoring Logic

```
Credit Score = Total Income - Total Expenses

Status:
- If Score > 0: APPROVED ✓ (Eligible for microcredit)
- If Score ≤ 0: NOT APPROVED ✗ (Not eligible)
```

## 🧮 Loan Calculator

The loan calculator helps farmers estimate their monthly payments:

```
Monthly Payment = Loan Amount ÷ Duration (months)
Total Loan Cost = Monthly Payment × Duration
```

## 🎨 UI/UX Design

### Color Scheme
- **Green**: Income (#4CAF50)
- **Red**: Expenses (#F44336)
- **Blue**: Credit & Dashboard (#2196F3)
- **Orange**: Savings (#FF9800)

### Components
- Material 3 Design System
- Card-based layouts
- BottomNavigationBar for main navigation
- FloatingActionButton for adding data
- ListViews for transactions and savings history

## 📱 Navigation

The app uses a **BottomNavigationBar** with 4 main sections:

1. **Dashboard** - Financial overview
2. **Transactions** - Income/Expense management
3. **Savings** - Savings tracking
4. **Microcredit** - Credit scoring and loan calculator

## 💾 Data Persistence

All data is stored locally using **Hive**:

- **transactions**: List of all income and expense transactions
- **savings**: List of all savings entries

No cloud synchronization or internet required.

## 🔍 Project Structure

### Key Files

- `lib/main.dart` - App entry point and main navigation
- `lib/core/services/hive_service.dart` - Hive database initialization
- `lib/shared/providers/*_provider.dart` - Riverpod state management
- `lib/features/*/presentation/*_screen.dart` - UI screens
- `lib/features/*/data/*_repository.dart` - Business logic

## ✅ Code Quality

- ✓ Strong typing throughout
- ✓ Null safety enforced
- ✓ No duplicated logic
- ✓ Separation of concerns (UI/Business/Data)
- ✓ No pseudo-code (100% functional)
- ✓ Production-ready code

## 🧪 Testing the App

1. **Add a transaction**: Go to Transactions tab → Tap + → Enter amount
2. **Add savings**: Go to Savings tab → Tap + → Enter amount
3. **Check dashboard**: Balance and credit score update automatically
4. **Check credit status**: If score > 0, you're approved for microcredit
5. **Calculate loan**: In Microcredit tab, enter loan amount and duration

## 🔄 State Management

The app uses **Riverpod** with **StateNotifier** pattern:

- Each feature has its own providers
- Separation of concerns: repositories, providers, screens
- Automatic UI updates when state changes
- No setState() or manual state management

## 📦 Riverpod Providers

### Transaction Providers
- `transactionsProvider` - List of all transactions
- `totalIncomeProvider` - Total income
- `totalExpensesProvider` - Total expenses
- `balanceProvider` - Current balance

### Savings Providers
- `savingsProvider` - List of all savings
- `totalSavingsProvider` - Total savings amount

### Credit Providers
- `creditScoreProvider` - Credit score and approval status
- `creditScoreValueProvider` - Score value only
- `creditApprovalProvider` - Approval status
- `loanCalculatorProvider` - Loan calculations

## 🎯 Future Enhancements

- User authentication
- Multi-user support
- Cloud backup
- Loan application workflow
- Repayment tracking
- Financial reports and analytics
- Multiple currency support
- Biometric authentication
- Push notifications for savings goals

## 📝 License

This project is for demonstration purposes.

## 👨‍💻 Developer Notes

### Adding New Features

1. Create a new folder in `lib/features/`
2. Follow the same structure: `data/`, `domain/`, `presentation/`
3. Create models in `domain/`
4. Create repositories in `data/`
5. Create providers in `shared/providers/`
6. Create screens in `presentation/`

### Building for Different Platforms

```bash
# Web
flutter build web

# Android
flutter build apk
flutter build aab

# iOS
flutter build ios

# Windows
flutter build windows

# macOS
flutter build macos

# Linux
flutter build linux
```

## 🐛 Troubleshooting

### App won't start
- Run `flutter clean && flutter pub get`
- Delete build folder: `rm -rf build/`
- Try `flutter run` again

### Hive errors
- Clear app data
- Delete `.dart_tool` folder
- Run `flutter pub get` again

### Provider errors
- Check that all providers are properly imported
- Verify Riverpod is properly initialized in main.dart

---

**Built with ❤️ for rural farmers in Madagascar**
