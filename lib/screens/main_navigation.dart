import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../l10n/app_localizations.dart';
import 'accueil_screen.dart';
import 'exploitation_screen.dart';
import 'finances_screen.dart';
import 'marche_screen.dart';
import 'profil_screen.dart';

/// Ossature de navigation principale à 5 onglets.
/// Les libellés viennent de AppLocalizations (malagasy par défaut).
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = [
    AccueilScreen(),
    ExploitationScreen(),
    FinancesScreen(),
    MarcheScreen(),
    ProfilScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      // IndexedStack garde l'état de chaque onglet en mémoire
      // (la saisie en cours n'est pas perdue en changeant d'onglet).
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.mutedText,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: l10n.navHome,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.agriculture_outlined),
            activeIcon: const Icon(Icons.agriculture),
            label: l10n.navFarm,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.account_balance_wallet_outlined),
            activeIcon: const Icon(Icons.account_balance_wallet),
            label: l10n.navFinances,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.storefront_outlined),
            activeIcon: const Icon(Icons.storefront),
            label: l10n.navMarket,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            activeIcon: const Icon(Icons.person),
            label: l10n.navProfile,
          ),
        ],
      ),
    );
  }
}