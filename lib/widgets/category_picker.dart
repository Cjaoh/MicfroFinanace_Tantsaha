import 'package:flutter/material.dart';
import '../core/app_theme.dart';

class Category {
  final String icon;
  final String label;

  const Category({required this.icon, required this.label});
}

class CategoryPicker extends StatefulWidget {
  final String transactionType;
  final Function(Category) onCategorySelected;

  const CategoryPicker({
    super.key,
    required this.transactionType,
    required this.onCategorySelected,
  });

  @override
  State<CategoryPicker> createState() => _CategoryPickerState();
}

class _CategoryPickerState extends State<CategoryPicker> {
  Category? selectedCategory;

  static const List<Category> revenueCategories = [
    Category(icon: '🌾', label: 'Ventes de récoltes'),
    Category(icon: '🐄', label: 'Élevage / Produits animaux'),
    Category(icon: '💸', label: 'Prêt reçu'),
    Category(icon: '🛠️', label: 'Prestations de services'),
  ];

  static const List<Category> expenseCategories = [
    Category(icon: '🌱', label: 'Intrants agricoles'),
    Category(icon: '⛽', label: 'Carburant & Entretien'),
    Category(icon: '👥', label: 'Main d\'œuvre'),
    Category(icon: '💰', label: 'Remboursement de prêt'),
    Category(icon: '🏠', label: 'Besoins familiaux'),
  ];

  List<Category> get categories => 
      widget.transactionType == 'income' ? revenueCategories : expenseCategories;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Sélectionner une catégorie',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = selectedCategory == category;
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedCategory = category;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.borderColor : AppColors.primaryPale,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.borderColor,
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        category.icon,
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          category.label,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.accentText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          if (selectedCategory != null)
            ElevatedButton(
              onPressed: () => widget.onCategorySelected(selectedCategory!),
              child: const Text('Continuer'),
            ),
        ],
      ),
    );
  }
}
