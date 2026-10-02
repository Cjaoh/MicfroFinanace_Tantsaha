import 'package:flutter/material.dart';
import '../core/app_theme.dart';

/// État honnête pour un écran dont le module n'est pas encore implémenté
/// côté données.
///
/// On affiche clairement "pas encore disponible" plutôt que d'inventer du
/// contenu — c'est directement lié à ce qu'on a trouvé dans ce dépôt
/// (des docs qui décrivaient des fonctionnalités inexistantes). Ici, si
/// l'écran dit quelque chose, c'est vrai.
class PlaceholderModule extends StatelessWidget {
  final IconData icone;
  final String titre;
  final String description;

  const PlaceholderModule({
    super.key,
    required this.icone,
    required this.titre,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, size: 56, color: AppColors.mutedText),
            const SizedBox(height: 16),
            Text(
              titre,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.mutedText),
            ),
          ],
        ),
      ),
    );
  }
}