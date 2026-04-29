import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import '../core/app_theme.dart';

class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback onDelete;

  const TransactionTile({
    super.key,
    required this.transaction,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final estRevenu = transaction.type == 'income';
    final dateFormatee = DateFormat('dd/MM/yyyy').format(transaction.date);
    
    // Utiliser les catégories du modèle ou des valeurs par défaut
    final iconCategorie = transaction.iconeCategorie ?? (estRevenu ? '🌾' : '🛒');
    final labelCategorie = transaction.categorie ?? (estRevenu ? 'Revenu' : 'Dépense');

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Icône catégorie
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: estRevenu ? AppColors.revBg : AppColors.depBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  iconCategorie,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Infos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateFormatee,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: estRevenu ? AppColors.revBg : AppColors.depBg,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      labelCategorie,
                      style: TextStyle(
                        fontSize: 10,
                        color: estRevenu ? AppColors.revText : AppColors.depText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Montant
            Text(
              '${estRevenu ? "+" : "-"} ${transaction.amount.toInt()} Ar',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: estRevenu ? AppColors.revAmount : AppColors.depAmount,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
