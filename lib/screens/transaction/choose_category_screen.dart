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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Texte provisoire : sera remplacé par une clé ARB à l'étape D.
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 4),
            child: Text(
              'Choisissez une catégorie',
              style: TextStyle(fontSize: 16, color: AppColors.mutedText),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final categorie = categories[index];
                return _CategoryCard(
                  category: categorie,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TransactionDetailScreen(
                        type: type,
                        category: categorie,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Carte d'une catégorie : icône en haut, libellé dessous, toujours alignés.
class _CategoryCard extends StatelessWidget {
  final CategoryDefinition category;
  final VoidCallback onTap;

  const _CategoryCard({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(14));

    // Material + InkWell : l'effet de pression reste visible sur la carte.
    return Material(
      color: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: AppColors.borderColor),
      ),
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.primaryPale,
                  shape: BoxShape.circle,
                ),
                child: Text(category.icon, style: const TextStyle(fontSize: 24)),
              ),
              const SizedBox(height: 10),
              Text(
                category.label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accentText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
