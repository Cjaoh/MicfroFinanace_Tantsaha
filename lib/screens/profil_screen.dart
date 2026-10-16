import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/user_profile_repository.dart';
import '../l10n/app_localizations.dart';
import '../models/user_profile.dart';
import '../providers/locale_provider.dart';
import 'profil/creation_profil_screen.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  late final UserProfileRepository _repository;
  late Future<UserProfile?> _chargement;

  @override
  void initState() {
    super.initState();
    _repository = context.read<UserProfileRepository>();
    _chargement = _repository.charger();
  }

  void _recharger() {
    setState(() {
      _chargement = _repository.charger();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserProfile?>(
      future: _chargement,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Erreur : ${snapshot.error}')),
          );
        }

        final profil = snapshot.data;
        if (profil == null) {
          return CreationProfilScreen(
            repository: _repository,
            onEnregistre: (_) => _recharger(),
          );
        }
        return _EcranProfil(profil: profil);
      },
    );
  }
}

class _EcranProfil extends StatelessWidget {
  const _EcranProfil({required this.profil});

  final UserProfile profil;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: Consumer<LocaleProvider>(
        builder: (context, lp, _) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Column(
                children: [
                  ListTile(
                    title: Text(l10n.profilePrenom),
                    subtitle: Text(profil.prenom),
                  ),
                  ListTile(
                    title: Text(l10n.profileNom),
                    subtitle: Text(profil.nom),
                  ),
                  ListTile(
                    title: Text(l10n.profileTelephone),
                    subtitle: Text(profil.telephone),
                  ),
                  if (profil.commune != null)
                    ListTile(
                      title: Text(l10n.profileCommune),
                      subtitle: Text(profil.commune!),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
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
            ? Icon(Icons.check_circle,
                color: Theme.of(context).colorScheme.primary)
            : const Icon(Icons.radio_button_unchecked),
        onTap: onTap,
      ),
    );
  }
}