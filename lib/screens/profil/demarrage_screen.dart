import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/user_profile_repository.dart';
import '../../models/user_profile.dart';
import '../main_navigation.dart';
import 'verification_pin_screen.dart';

/// Premier écran de l'application (PROF-01, 1.8).
/// Si un profil avec PIN existe, demande le PIN avant d'afficher MainNavigation.
class DemarrageScreen extends StatefulWidget {
  const DemarrageScreen({super.key});

  @override
  State<DemarrageScreen> createState() => _DemarrageScreenState();
}

class _DemarrageScreenState extends State<DemarrageScreen> {
  late final Future<UserProfile?> _profil;
  bool _deverrouille = false;

  @override
  void initState() {
    super.initState();
    _profil = context.read<UserProfileRepository>().charger();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserProfile?>(
      future: _profil,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        // En cas d'erreur de lecture, on ne contourne pas le PIN.
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Icon(Icons.error_outline, size: 48)),
          );
        }

        final profil = snapshot.data;
        final hash = profil?.pinHash;
        final sel = profil?.pinSel;
        if (!_deverrouille && hash != null && sel != null) {
          return VerificationPinScreen(
            pinHash: hash,
            pinSel: sel,
            onVerifie: () => setState(() => _deverrouille = true),
          );
        }
        return const MainNavigation();
      },
    );
  }
}