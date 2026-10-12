import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart';

class ProfilScreen extends StatelessWidget {
  const ProfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: Consumer<LocaleProvider>(
        builder: (context, lp, _) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                'Langue / Fiteny',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            _ChoixLangue(
              libelle: 'Malagasy',
              selectionnee: lp.locale == LocaleProvider.malagasy,
              onTap: () => lp.setLocale(LocaleProvider.malagasy),
            ),
            _ChoixLangue(
              libelle: 'Français',
              selectionnee: lp.locale == LocaleProvider.francais,
              onTap: () => lp.setLocale(LocaleProvider.francais),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChoixLangue extends StatelessWidget {
  const _ChoixLangue({
    required this.libelle,
    required this.selectionnee,
    required this.onTap,
  });

  final String libelle;
  final bool selectionnee;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(libelle),
        trailing: selectionnee
            ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary)
            : const Icon(Icons.radio_button_unchecked),
        onTap: onTap,
      ),
    );
  }
}