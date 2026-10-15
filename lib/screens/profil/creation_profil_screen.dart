import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/user_profile_repository.dart';
import '../../domain/pin_validation.dart';
import '../../l10n/app_localizations.dart';
import '../../models/user_profile.dart';

/// Formulaire de création du profil (PROF-01).
/// La validation des informations est faite par UserProfile.creer, celle du
/// PIN par validerPin. Le profil et son PIN sont enregistrés en une seule
/// écriture, pour éviter un profil enregistré sans PIN.
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
  final _pinCtrl = TextEditingController();
  final _pinConfirmCtrl = TextEditingController();
  LangueProfil _langue = LangueProfil.malagasy;

  ResultatProfil? _resultat;
  ErreurPin? _erreurPin;
  bool _pinsDifferents = false;
  bool _enregistrement = false;

  @override
  void dispose() {
    _prenomCtrl.dispose();
    _nomCtrl.dispose();
    _telephoneCtrl.dispose();
    _communeCtrl.dispose();
    _pinCtrl.dispose();
    _pinConfirmCtrl.dispose();
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
    final pin = _pinCtrl.text;
    final erreurPin = validerPin(pin);
    final pinsDifferents = erreurPin == null && pin != _pinConfirmCtrl.text;

    setState(() {
      _resultat = resultat;
      _erreurPin = erreurPin;
      _pinsDifferents = pinsDifferents;
    });
    if (!resultat.estValide || erreurPin != null || pinsDifferents) return;

    final sel = genererSel();
    final profil = resultat.profil!.copyWith(
      pinHash: hasherPin(pin, sel),
      pinSel: sel,
    );

    setState(() => _enregistrement = true);
    try {
      await widget.repository.enregistrer(profil);
    } finally {
      if (mounted) setState(() => _enregistrement = false);
    }
    if (!mounted) return;
    widget.onEnregistre?.call(profil);
  }

  String _messageErreurPin(AppLocalizations l10n, ErreurPin erreur) {
    return switch (erreur) {
      ErreurPin.longueur => l10n.profileErrorPinLongueur,
      ErreurPin.chiffresSeulement => l10n.profileErrorPinChiffres,
      ErreurPin.trivial => l10n.profileErrorPinTrivial,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final erreurPin = _erreurPin;

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
          const SizedBox(height: 16),
          TextField(
            controller: _pinCtrl,
            obscureText: true,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(longueurPin),
            ],
            decoration: InputDecoration(
              labelText: l10n.profilePin,
              errorText: erreurPin == null
                  ? null
                  : _messageErreurPin(l10n, erreurPin),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _pinConfirmCtrl,
            obscureText: true,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(longueurPin),
            ],
            decoration: InputDecoration(
              labelText: l10n.profilePinConfirm,
              errorText: _pinsDifferents ? l10n.profileErrorPinConfirm : null,
            ),
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