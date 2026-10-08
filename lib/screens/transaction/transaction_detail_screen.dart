import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../domain/category_catalog.dart';
import '../../models/transaction_type.dart';

/// Étape B à venir : formulaire de détail par catégorie.
/// Pour l'instant, l'écran confirme seulement que la navigation fonctionne.
class TransactionDetailScreen extends StatelessWidget {
  final TransactionType type;
  final CategoryDefinition category;

  const TransactionDetailScreen({super.key, required this.type, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(category.label)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            '${libelleType(type)} › ${category.label}\n\nFormulaire de détail : étape B',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.mutedText),
          ),
        ),
      ),
    );
  }
}