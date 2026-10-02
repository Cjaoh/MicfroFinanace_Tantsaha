import 'package:flutter/material.dart';
import '../widgets/placeholder_module.dart';

class ProfilScreen extends StatelessWidget {
  const ProfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: const PlaceholderModule(
        icone: Icons.person_outline,
        titre: 'Profil & authentification',
        description:
            "La gestion du profil agriculteur et la connexion sécurisée arrivent avec le module d'authentification (phases P2/P5 de la roadmap).",
      ),
    );
  }
}