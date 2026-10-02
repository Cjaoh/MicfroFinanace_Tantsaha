import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../core/app_theme.dart';
import '../providers/transaction_provider.dart';

/// Écran "Accueil" — tableau de bord, premier écran de la maquette.
///
/// Le solde et les totaux revenus/dépenses viennent du vrai
/// [TransactionProvider] (donc de SQLite). Les sections "Mes
/// exploitations" et "Prochains événements" n'ont pas encore de données
/// réelles derrière (modules P2/P4 non développés) : on affiche un état
/// vide honnête plutôt que des exemples inventés.
class AccueilScreen extends StatelessWidget {
  const AccueilScreen({super.key});

  String _formatAriary(int montant) {
    return '${NumberFormat('#,###', 'fr_FR').format(montant).replaceAll(',', ' ')} Ar';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Accueil')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Carte solde du compte
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SOLDE DE VOTRE COMPTE',
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 1.2,
                      color: AppColors.subtleBlue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatAriary(provider.balance),
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Revenus / Dépenses / Épargne
            Row(
              children: [
                Expanded(
                  child: _MiniStatCard(
                    label: 'Revenus',
                    valeur: _formatAriary(provider.totalRevenus),
                    couleur: AppColors.revAmount,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MiniStatCard(
                    label: 'Dépenses',
                    valeur: _formatAriary(provider.totalDepenses),
                    couleur: AppColors.depAmount,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MiniStatCard(
                    label: 'Épargne',
                    valeur: 'Bientôt',
                    couleur: AppColors.mutedText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            const _SectionTitle(titre: 'Mes exploitations'),
            const SizedBox(height: 8),
            const _EmptyStateCard(
              icone: Icons.agriculture_outlined,
              message:
                  "Aucune exploitation enregistrée pour l'instant.\nArrive dans une prochaine étape (P2).",
            ),
            const SizedBox(height: 24),

            const _SectionTitle(titre: 'Prochains événements'),
            const SizedBox(height: 8),
            const _EmptyStateCard(
              icone: Icons.event_outlined,
              message: "Aucun événement pour l'instant.",
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final String label;
  final String valeur;
  final Color couleur;

  const _MiniStatCard({
    required this.label,
    required this.valeur,
    required this.couleur,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(label, style: TextStyle(fontSize: 11, color: AppColors.mutedText)),
            const SizedBox(height: 4),
            Text(
              valeur,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: couleur),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String titre;
  const _SectionTitle({required this.titre});

  @override
  Widget build(BuildContext context) {
    return Text(titre, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600));
  }
}

class _EmptyStateCard extends StatelessWidget {
  final IconData icone;
  final String message;
  const _EmptyStateCard({required this.icone, required this.message});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          children: [
            Icon(icone, size: 32, color: AppColors.mutedText),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.mutedText),
            ),
          ],
        ),
      ),
    );
  }
}