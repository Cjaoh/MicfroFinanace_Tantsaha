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
/// vide honnête plutôt que des exemples inventés comme sur la maquette
/// (qui montre un agriculteur fictif "Rado" à titre d'exemple).
class AccueilScreen extends StatelessWidget {
  const AccueilScreen({super.key});

  String _formatAriary(int montant) {
    return '${NumberFormat('#,###', 'fr_FR').format(montant).replaceAll(',', ' ')} Ar';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            // En-tête : salutation + notifications
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bonjour !',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Bon courage pour vos cultures',
                      style: TextStyle(fontSize: 12, color: AppColors.mutedText),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryPale,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.notifications_outlined, color: AppColors.primary, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Carte solde du compte
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SOLDE DE VOTRE COMPTE',
                        style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 1.0,
                          color: AppColors.subtleGreen,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatAriary(provider.balance),
                        style: const TextStyle(
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.account_balance_wallet_outlined, color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Revenus / Dépenses / Épargne
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icone: Icons.trending_up,
                    iconeBg: AppColors.revBg,
                    iconeColor: AppColors.revAmount,
                    label: 'Revenus',
                    valeur: _formatAriary(provider.totalRevenus),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatCard(
                    icone: Icons.trending_down,
                    iconeBg: AppColors.depBg,
                    iconeColor: AppColors.depAmount,
                    label: 'Dépenses',
                    valeur: _formatAriary(provider.totalDepenses),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatCard(
                    icone: Icons.savings_outlined,
                    iconeBg: AppColors.revBg,
                    iconeColor: AppColors.revAmount,
                    label: 'Épargne',
                    valeur: 'Bientôt',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            _SectionHeader(titre: 'Mes exploitations'),
            const SizedBox(height: 8),
            const _EmptyStateCard(
              icone: Icons.agriculture_outlined,
              message:
                  "Aucune exploitation enregistrée pour l'instant.\nArrive dans une prochaine étape (P2).",
            ),
            const SizedBox(height: 24),

            _SectionHeader(titre: 'Prochains événements'),
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

/// Carte de statistique (Revenus / Dépenses / Épargne) avec icône colorée,
/// reproduisant le style de la maquette.
class _StatCard extends StatelessWidget {
  final IconData icone;
  final Color iconeBg;
  final Color iconeColor;
  final String label;
  final String valeur;

  const _StatCard({
    required this.icone,
    required this.iconeBg,
    required this.iconeColor,
    required this.label,
    required this.valeur,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: iconeBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icone, size: 16, color: iconeColor),
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.mutedText)),
            const SizedBox(height: 2),
            Text(
              valeur,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: iconeColor),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String titre;
  const _SectionHeader({required this.titre});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(titre, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        // "Voir tout" désactivé : honnête tant qu'il n'y a rien à voir.
        TextButton(
          onPressed: null,
          child: Text('Voir tout', style: TextStyle(fontSize: 12, color: AppColors.mutedText)),
        ),
      ],
    );
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
              style: const TextStyle(fontSize: 12, color: AppColors.mutedText),
            ),
          ],
        ),
      ),
    );
  }
}