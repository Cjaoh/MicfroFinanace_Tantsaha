import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../models/transaction_type.dart';
import 'choose_category_screen.dart';

/// Étape 1 : choisir Revenu, Dépense ou Épargne.
class ChooseTypeScreen extends StatelessWidget {
  const ChooseTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter une transaction')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _TypeCard(
              icone: Icons.trending_up,
              couleur: AppColors.revAmount,
              fond: AppColors.revBg,
              titre: 'Revenu',
              description: 'Vente, prêt reçu, prestation',
              type: TransactionType.income,
            ),
            SizedBox(height: 12),
            _TypeCard(
              icone: Icons.trending_down,
              couleur: AppColors.depAmount,
              fond: AppColors.depBg,
              titre: 'Dépense',
              description: "Intrants, carburant, main-d'œuvre",
              type: TransactionType.expense,
            ),
            SizedBox(height: 12),
            _TypeCard(
              icone: Icons.savings_outlined,
              couleur: AppColors.savAmount,
              fond: AppColors.savBg,
              titre: 'Épargne',
              description: 'Réserve, imprévus, scolarité',
              type: TransactionType.saving,
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeCard extends StatelessWidget {
  final IconData icone;
  final Color couleur;
  final Color fond;
  final String titre;
  final String description;
  final TransactionType type;

  const _TypeCard({
    required this.icone,
    required this.couleur,
    required this.fond,
    required this.titre,
    required this.description,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ChooseCategoryScreen(type: type)),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderColor, width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: fond,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icone, color: couleur, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titre,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accentText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 12, color: AppColors.mutedText),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.mutedText),
          ],
        ),
      ),
    );
  }
}