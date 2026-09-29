import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction_model.dart';
import '../models/transaction_type.dart';
import '../core/app_theme.dart';
import '../widgets/transaction_tile.dart';
import '../widgets/category_picker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  String _formatAriary(int montant) {
    return '${NumberFormat('#,###', 'fr_FR').format(montant).replaceAll(',', ' ')} Ar';
  }

  void _ouvrirBottomSheet(String type, TransactionProvider provider, BuildContext context) {
    final TextEditingController amountController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    String? selectedCategory;
    String? selectedIcon;
    String? errorText;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 28,
            left: 24,
            right: 24,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 44, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 22),

              // Titre
              Text(
                type == "Revenu" ? "Nouveau revenu" : "Nouvelle dépense",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 22),

              // Category Picker
              CategoryPicker(
                transactionType: type == "Revenu" ? "income" : "expense",
                onCategorySelected: (category) {
                  setModalState(() {
                    selectedCategory = category.label;
                    selectedIcon = category.icon;
                  });
                },
              ),
              const SizedBox(height: 16),

              // TextField montant
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "Montant en Ariary",
                  suffixText: "Ar",
                  errorText: errorText,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // TextField description (optionnel)
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  hintText: "Description (optionnel)",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Bouton Confirmer
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Ariary : montant entier, pas de décimales (RM-01, RM-03).
                    final val = int.tryParse(amountController.text.trim());
                    if (val == null || val <= 0) {
                      setModalState(() => errorText = "Entrez un montant valide");
                      return;
                    }
                    if (selectedCategory == null || selectedIcon == null) {
                      setModalState(() => errorText = "Sélectionnez une catégorie");
                      return;
                    }

                    // Créer la transaction avec les catégories
                    final transaction = TransactionModel.create(
                      amountAriary: val,
                      type: type == "Revenu" ? TransactionType.income : TransactionType.expense,
                      date: DateTime.now(),
                      categorie: selectedCategory,
                      iconeCategorie: selectedIcon,
                    );

                    provider.addTransaction(transaction);
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Confirmer",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final transactions = transactionProvider.transactions;
    final solde = transactionProvider.balance;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MICROFINANCE MALAGASY',
              style: TextStyle(
                fontSize: 10,
                color: AppColors.subtleBlue,
                letterSpacing: 1.5,
              ),
            ),
            Text(
              'Tantsaha MVP',
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        toolbarHeight: 70,
      ),
      body: SafeArea(
        child: Column(
          children: [

            //══════════════════════════════════════
            // SCROLLABLE BODY
            //══════════════════════════════════════
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [

                    //════════════════════════════
                    // BLOC 2 — BALANCE CARD
                    //════════════════════════════
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 28),
                      child: Column(
                        children: [
                          Text('SOLDE TOTAL',
                            style: TextStyle(fontSize: 10, letterSpacing: 1.5,
                              color: AppColors.mutedText)),
                          const SizedBox(height: 10),
                          Container(
                            width: 100, height: 100,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('${_formatAriary(solde)}',
                                  style: TextStyle(fontSize: 16, color: Colors.white,
                                    fontWeight: FontWeight.w500)),
                                Text('Ariary',
                                  style: TextStyle(fontSize: 10, color: AppColors.subtleBlue)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    //════════════════════════════
                    // BLOC 3 — CARTES STATISTIQUES
                    //════════════════════════════
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          // Carte Revenus
                          Expanded(
                            child: Card(
                              child: Padding(
                                padding: EdgeInsets.all(12),
                                child: Column(
                                  children: [
                                    Text('Revenus', style: TextStyle(fontSize: 11,
                                      color: AppColors.mutedText)),
                                    Text('+ ${_formatAriary(transactionProvider.totalRevenus)}', style: TextStyle(fontSize: 14,
                                      fontWeight: FontWeight.w500, color: AppColors.revAmount)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Carte Dépenses
                          Expanded(
                            child: Card(
                              child: Padding(
                                padding: EdgeInsets.all(12),
                                child: Column(
                                  children: [
                                    Text('Dépenses', style: TextStyle(fontSize: 11,
                                      color: AppColors.mutedText)),
                                    Text('- ${_formatAriary(transactionProvider.totalDepenses)}', style: TextStyle(fontSize: 14,
                                      fontWeight: FontWeight.w500, color: AppColors.depAmount)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Carte Balance
                          Expanded(
                            child: Card(
                              child: Padding(
                                padding: EdgeInsets.all(12),
                                child: Column(
                                  children: [
                                    Text('Balance', style: TextStyle(fontSize: 11,
                                      color: AppColors.mutedText)),
                                    Text(_formatAriary(solde), style: TextStyle(fontSize: 14,
                                      fontWeight: FontWeight.w500, color: AppColors.balText)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    //════════════════════════════
                    // BLOC 4 — ACTION BUTTONS
                    //════════════════════════════
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 14, 12, 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.add, size: 16),
                              label: const Text(
                                "Ajouter revenu",
                                style: TextStyle(fontSize: 13),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: const StadiumBorder(),
                                elevation: 0,
                              ),
                              onPressed: () => _ouvrirBottomSheet("Revenu", transactionProvider, context),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.remove, size: 16),
                              label: const Text(
                                "Ajouter dépense",
                                style: TextStyle(fontSize: 13),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.mutedText,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: const StadiumBorder(),
                                side: const BorderSide(
                                  color: AppColors.borderColor,
                                  width: 1.2,
                                ),
                              ),
                              onPressed: () => _ouvrirBottomSheet("Dépense", transactionProvider, context),
                            ),
                          ),
                        ],
                      ),
                    ),

                    //════════════════════════════
                    // BLOC 5 — LISTE TRANSACTIONS
                    //════════════════════════════
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "HISTORIQUE",
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.mutedText,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),

                    transactions.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Text(
                            "Aucune transaction pour l'instant",
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.mutedText,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: transactions.length,
                          itemBuilder: (_, index) {
                            final tx = transactions[index];
                            return Dismissible(
                              key: Key(tx.id),
                              direction: DismissDirection.endToStart,
                              onDismissed: (_) {
                                transactionProvider.removeTransaction(tx.id);
                              },
                              background: Container(
                                alignment: Alignment.centerRight,
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                padding: const EdgeInsets.only(right: 20),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.delete, color: Colors.white),
                              ),
                              child: TransactionTile(
                                transaction: tx,
                                onDelete: () => transactionProvider.removeTransaction(tx.id),
                              ),
                            );
                          },
                        ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}