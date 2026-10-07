import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'providers/transaction_provider.dart';
import 'screens/main_navigation.dart';
import 'core/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'l10n/fallback_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
            create: (_) => TransactionProvider()..loadTransactions(),
      child: MaterialApp(
        onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
        theme: AppTheme.theme,
        // Malagasy par défaut. Le choix mg/fr viendra du profil (étape 5).
        locale: const Locale('mg'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...mgFallbackDelegates,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        debugShowCheckedModeBanner: false,
        home: const MainNavigation(),
      ),
    );
  }
}