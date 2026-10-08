import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../domain/category_catalog.dart';
import '../../models/transaction_type.dart';
import 'transaction_detail_screen.dart';

/// Étape 2 : choisir une catégorie parmi celles du type sélectionné.
class ChooseCategoryScreen extends StatelessWidget {
  final TransactionType type;

  const ChooseCategoryScreen({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final categories = categoriesFor(type);

    return Scaffold(
      appBar: AppBar(title: Text(libelleType(type))),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.4,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final categorie = categories[index];
          return InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TransactionDetailScreen(type: type, category: categorie),
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryPale,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderColor, width: 0.5),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(categorie.icon, style: const TextStyle(fontSize: 24)),
                  const SizedBox(height: 8),
                  Text(categorie.label,
                      style: const TextStyle(fontSize: 12, color: AppColors.accentText)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}