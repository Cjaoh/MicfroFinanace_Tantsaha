import 'package:flutter/material.dart';
import '../../data/user_profile_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../models/user_profile.dart';

/// Formulaire de création du profil (PROF-01).
/// La validation est faite par UserProfile.creer : cet écran affiche les
/// erreurs par champ et enregistre le profil valide via le repository.
class CreationProfilScreen extends StatefulWidget {
  const CreationProfilScreen({
    super.key,
    required this.repository,
    this.onEnregistre,
  });

  final UserProfileRepository repository;

  /// Appelé après un enregistrement réussi.
  final ValueChanged<UserProfile>? onEnregistre;

  @override
  State<CreationProfilScreen> createState() => _CreationProfilScreenState();
}

class _CreationProfilScreenState extends State<CreationProfilScreen> {
  final _prenomCtrl = TextEditingController();
  final _nomCtrl = TextEditingController();
  final _telephoneCtrl = TextEditingController();
  final _communeCtrl = TextEditingController();
  LangueProfil _langue = LangueProfil.malagasy;

  ResultatProfil? _resultat;
  bool _enregistrement = false;

  @override
  void dispose() {
    _prenomCtrl.dispose();
    _nomCtrl.dispose();
    _telephoneCtrl.dispose();
    _communeCtrl.dispose();
    super.dispose();
  }

  List<ChampProfil> get _erreurs => _resultat?.erreurs ?? const [];

  Future<void> _enregistrer() async {
    final resultat = UserProfile.creer(
      prenom: _prenomCtrl.text,
      nom: _nomCtrl.text,
      telephoneSaisi: _telephoneCtrl.text,
      langue: _langue,
      commune: _communeCtrl.text,
    );
    setState(() => _resultat = resultat);
    if (!resultat.estValide) return;

    final profil = resultat.profil!;
    setState(() => _enregistrement = true);
    await widget.repository.enregistrer(profil);
    if (!mounted) return;
    setState(() => _enregistrement = false);
    widget.onEnregistre?.call(profil);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _prenomCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: l10n.profilePrenom,
              errorText: _erreurs.contains(ChampProfil.prenom)
                  ? l10n.profileErrorPrenom
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nomCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: l10n.profileNom,
              errorText: _erreurs.contains(ChampProfil.nom)
                  ? l10n.profileErrorNom
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _telephoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: l10n.profileTelephone,
              hintText: l10n.profileTelephoneHint,
              errorText: _erreurs.contains(ChampProfil.telephone)
                  ? l10n.profileErrorTelephone
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<LangueProfil>(
            initialValue: _langue,
            decoration: InputDecoration(labelText: l10n.profileLangue),
            items: const [
              DropdownMenuItem(
                value: LangueProfil.malagasy,
                child: Text('Malagasy'),
              ),
              DropdownMenuItem(
                value: LangueProfil.francais,
                child: Text('Français'),
              ),
            ],
            onChanged: (valeur) {
              if (valeur != null) setState(() => _langue = valeur);
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _communeCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(labelText: l10n.profileCommune),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _enregistrement ? null : _enregistrer,
            child: Text(l10n.profileSave),
          ),
        ],
      ),
    );
  }
}