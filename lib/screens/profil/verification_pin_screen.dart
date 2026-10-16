import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/pin_validation.dart';
import '../../l10n/app_localizations.dart';

/// Écran affiché au démarrage quand un profil avec PIN existe (PROF-01, 1.8).
/// Le PIN saisi est comparé au hash stocké ; [onVerifie] est appelé en cas de succès.
class VerificationPinScreen extends StatefulWidget {
  const VerificationPinScreen({
    super.key,
    required this.pinHash,
    required this.pinSel,
    required this.onVerifie,
  });

  final String pinHash;
  final String pinSel;
  final VoidCallback onVerifie;

  @override
  State<VerificationPinScreen> createState() => _VerificationPinScreenState();
}

class _VerificationPinScreenState extends State<VerificationPinScreen> {
  final _pinCtrl = TextEditingController();
  bool _erreur = false;

  @override
  void dispose() {
    _pinCtrl.dispose();
    super.dispose();
  }

  void _valider() {
    final pin = _pinCtrl.text;
    if (pin.length != longueurPin) {
      setState(() => _erreur = true);
      return;
    }

    final correct = verifierPin(
      pin,
      sel: widget.pinSel,
      hashAttendu: widget.pinHash,
    );

    if (correct) {
      widget.onVerifie();
    } else {
      setState(() {
        _erreur = true;
        _pinCtrl.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.pinVerifyTitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _pinCtrl,
                autofocus: true,
                obscureText: true,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(longueurPin),
                ],
                decoration: InputDecoration(
                  labelText: l10n.profilePin,
                  errorText: _erreur ? l10n.pinVerifyWrong : null,
                ),
                onSubmitted: (_) => _valider(),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _valider,
                child: Text(l10n.profileSave),
              ),
            ],
          ),
        ),
      ),
    );
  }
}