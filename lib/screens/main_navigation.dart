import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import 'accueil_screen.dart';
import 'exploitation_screen.dart';
import 'finances_screen.dart';
import 'marche_screen.dart';
import 'profil_screen.dart';

/// Ossature de navigation principale.
///
/// Reproduit la barre de navigation à 5 onglets définie dans le cahier des
/// charges (section 16 — UX/UI : "Navigation principale : Accueil,
/// Exploitation, Finances, Marché, Profil.").
///
/// Chaque onglet garde son propre [Scaffold] (AppBar compris) — c'est un
/// pattern standard en Flutter qui laisse chaque écran gérer sa propre
/// barre supérieure sans complexifier cette classe.
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
    return Scaffold(
      // IndexedStack garde l'état de chaque écran en mémoire quand on
      // change d'onglet, au lieu de reconstruire l'écran à chaque fois
      // (important pour ne pas perdre la saisie en cours, par exemple).
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
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.agriculture_outlined),
            activeIcon: Icon(Icons.agriculture),
            label: 'Exploitation',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet),
            label: 'Finances',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront_outlined),
            activeIcon: Icon(Icons.storefront),
            label: 'Marché',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}