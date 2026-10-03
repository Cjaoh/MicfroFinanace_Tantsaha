import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../core/app_theme.dart';
import '../providers/transaction_provider.dart';

/// Écran 3 de la maquette : Tableau de bord.
///
/// Le solde et les totaux viennent du vrai [TransactionProvider] (SQLite).
/// Les sections "Mes exploitations" et "Prochains événements" restent en
/// état vide tant que les modules correspondants n'existent pas : on
/// n'affiche jamais de données inventées.
class AccueilScreen extends StatefulWidget {
  const AccueilScreen({super.key});

  @override
  State<AccueilScreen> createState() => _AccueilScreenState();
}

class _AccueilScreenState extends State<AccueilScreen> {
  // Œil de la maquette : masque le solde (utile en public).
  bool _soldeVisible = true;

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
            // En-tête : avatar + salutation + cloche
            Row(
              children: [
                const CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.revBg,
                  child: Icon(Icons.person, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bonjour !',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accentText,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Bon courage pour vos cultures !',
                        style: TextStyle(fontSize: 12, color: AppColors.mutedText),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.notifications_outlined, color: AppColors.primary),
              ],
            ),
            const SizedBox(height: 20),

            // Carte solde (vert foncé) avec œil
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
                      const Text(
                        'Solde de votre compte',
                        style: TextStyle(fontSize: 12, color: AppColors.subtleGreen),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _soldeVisible ? _formatAriary(provider.balance) : '•••••• Ar',
                        style: const TextStyle(
                          fontSize: 26,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => setState(() => _soldeVisible = !_soldeVisible),
                    tooltip: _soldeVisible ? 'Masquer le solde' : 'Afficher le solde',
                    icon: Icon(
                      _soldeVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: Colors.white,
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
                  child: _StatCard(
                    icone: Icons.trending_up,
                    iconeBg: AppColors.revBg,
                    iconeColor: AppColors.revAmount,
                    label: 'Revenus',
                    valeur: _soldeVisible ? _formatAriary(provider.totalRevenus) : '••••',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatCard(
                    icone: Icons.trending_down,
                    iconeBg: AppColors.depBg,
                    iconeColor: AppColors.depAmount,
                    label: 'Dépenses',
                    valeur: _soldeVisible ? _formatAriary(provider.totalDepenses) : '••••',
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: _StatCard(
                    icone: Icons.savings_outlined,
                    iconeBg: AppColors.savBg,
                    iconeColor: AppColors.savAmount,
                    label: 'Épargne',
                    valeur: 'Bientôt',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            const _SectionHeader(titre: 'Mes exploitations'),
            const SizedBox(height: 8),
            const _EmptyStateCard(
              icone: Icons.agriculture_outlined,
              message: "Aucune exploitation enregistrée pour l'instant.",
            ),
            const SizedBox(height: 24),

            const _SectionHeader(titre: 'Prochains événements'),
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

/// Carte de statistique avec icône colorée (style maquette).
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
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconeBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icone, size: 18, color: iconeColor),
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.mutedText)),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                valeur,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: iconeColor),
              ),
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
        Text(
          titre,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.accentText,
          ),
        ),
        // "Voir tout" désactivé tant qu'il n'y a rien à voir.
        const TextButton(
          onPressed: null,
          child: Text('Voir tout', style: TextStyle(fontSize: 12)),
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
        child: Center(
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
      ),
    );
  }
}