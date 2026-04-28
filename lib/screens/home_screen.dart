import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction_model.dart';
import '../constants/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  String _formatAriary(double montant) {
    return NumberFormat('#,###', 'fr_FR')
      .format(montant)
      .replaceAll(',', ' ') + ' Ar';
  }

  // Mini-card pour le résumé financier
  Widget _buildMiniCard(String label, String valeur, Color couleur) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.creamCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.goldBorder, width: 0.8),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: AppColors.lightBrown,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              valeur,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: couleur,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // Tuile de transaction avec swipe to delete
  Widget _buildTransactionTile(TransactionModel tx, TransactionProvider provider, BuildContext context) {
    final isRevenu = tx.type == "income";

    return Dismissible(
      key: Key(tx.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: AppColors.creamBg,
            title: Text(
              "Supprimer ?",
              style: TextStyle(color: AppColors.primaryBrown),
            ),
            content: const Text(
              "Cette transaction sera supprimée définitivement.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  "Annuler",
                  style: TextStyle(color: AppColors.lightBrown),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  "Supprimer",
                  style: TextStyle(color: AppColors.depenseRed),
                ),
              ),
            ],
          ),
        ) ?? false;
      },
      onDismissed: (_) {
        provider.removeTransaction(tx.id);
      },
      background: Container(
        alignment: Alignment.centerRight,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.only(right: 18),
        decoration: BoxDecoration(
          color: AppColors.depenseRed,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 22),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.creamCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.goldBorder, width: 0.8),
        ),
        child: Row(
          children: [
            // Barre indicateur couleur gauche
            Container(
              width: 4,
              height: 38,
              decoration: BoxDecoration(
                color: isRevenu ? AppColors.revenueGreen : AppColors.depenseRed,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            // Type + Date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isRevenu ? "Revenu" : "Dépense",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    DateFormat('dd/MM/yyyy – HH:mm').format(tx.date),
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            // Montant
            Text(
              (isRevenu ? "+ " : "- ") + _formatAriary(tx.amount),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isRevenu ? AppColors.revenueGreen : AppColors.depenseRed,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _ouvrirBottomSheet(String type, TransactionProvider provider, BuildContext context) {
    final TextEditingController ctrl = TextEditingController();
    String? errorText;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFFFFF8F0),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                  color: AppColors.goldBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 22),

              // Titre
              Text(
                type == "Revenu" ? "Nouveau revenu" : "Nouvelle dépense",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF7C4A1E),
                ),
              ),
              const SizedBox(height: 22),

              // TextField
              TextField(
                controller: ctrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "Montant en Ariary",
                  suffixText: "Ar",
                  errorText: errorText,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFF5D5A8)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFF5D5A8)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF7C4A1E),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Bouton Confirmer
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C4A1E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: const StadiumBorder(),
                    elevation: 0,
                  ),
                  onPressed: () {
                    final val = double.tryParse(ctrl.text.trim());
                    if (val == null || val <= 0) {
                      setModalState(() => errorText = "Entrez un montant valide");
                      return;
                    }
                    provider.addTransactionWithAmount(
                      amount: val,
                      type: type == "Revenu" ? "income" : "expense",
                    );
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
      backgroundColor: AppColors.creamBg,
      body: SafeArea(
        child: Column(
          children: [

            //══════════════════════════════════════
            // BLOC 1 — HEADER marron
            //══════════════════════════════════════
            Container(
              width: double.infinity,
              color: AppColors.primaryBrown,
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "MICROFINANCE MALAGASY",
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.goldText,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Tantsaha MVP",
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

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
                      color: AppColors.creamBg,
                      padding: const EdgeInsets.symmetric(vertical: 28),
                      child: Column(
                        children: [
                          Text(
                            "SOLDE TOTAL",
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.lightBrown,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primaryBrown,
                              border: Border.all(
                                color: AppColors.goldBorder,
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryBrown.withOpacity(0.25),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _formatAriary(solde),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "Ariary",
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.goldText,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    //════════════════════════════
                    // BLOC 3 — SUMMARY ROW
                    //════════════════════════════
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
                      child: Row(
                        children: [
                          _buildMiniCard(
                            "Revenus",
                            "+ ${_formatAriary(transactionProvider.totalRevenus)}",
                            AppColors.revenueGreen,
                          ),
                          const SizedBox(width: 6),
                          _buildMiniCard(
                            "Dépenses",
                            "- ${_formatAriary(transactionProvider.totalDepenses)}",
                            AppColors.depenseRed,
                          ),
                          const SizedBox(width: 6),
                          _buildMiniCard(
                            "Balance",
                            _formatAriary(solde),
                            AppColors.primaryBrown,
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
                                backgroundColor: AppColors.primaryBrown,
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
                                foregroundColor: AppColors.lightBrown,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: const StadiumBorder(),
                                side: const BorderSide(
                                  color: AppColors.goldBorder,
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
                            color: AppColors.lightBrown,
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
                              color: AppColors.lightBrown,
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
                            return _buildTransactionTile(tx, transactionProvider, context);
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
