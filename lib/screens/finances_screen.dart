import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction_model.dart';
import '../models/transaction_type.dart';
import '../core/app_theme.dart';
import '../widgets/transaction_tile.dart';
import '../widgets/category_picker.dart';

/// Libellé du formulaire -> type métier.
TransactionType _typeFrom(String libelle) {
  switch (libelle) {
    case 'Revenu':
      return TransactionType.income;
    case 'Épargne':
      return TransactionType.saving;
    default:
      return TransactionType.expense;
  }
}

class FinancesScreen extends StatefulWidget {
  const FinancesScreen({super.key});

  @override
  State<FinancesScreen> createState() => _FinancesScreenState();
}

class _FinancesScreenState extends State<FinancesScreen> {

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
          child: SingleChildScrollView(
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
                type == "Revenu"
                    ? "Nouveau revenu"
                    : type == "Épargne"
                        ? "Mettre de côté"
                        : "Nouvelle dépense",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 22),

              // Category Picker
              CategoryPicker(
                transactionType: _typeFrom(type).toDbValue(),
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
                      type: _typeFrom(type),
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
      ),
    );
  }

  /// Le bouton unique de la maquette : on choisit d'abord le type,
  /// puis on réutilise le formulaire existant.
  void _choisirTypeTransaction(TransactionProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.trending_up, color: AppColors.revAmount),
              title: const Text('Ajouter un revenu'),
              onTap: () {
                Navigator.pop(ctx);
                _ouvrirBottomSheet('Revenu', provider, context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.trending_down, color: AppColors.depAmount),
              title: const Text('Ajouter une dépense'),
              onTap: () {
                Navigator.pop(ctx);
                _ouvrirBottomSheet('Dépense', provider, context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.savings_outlined, color: AppColors.savAmount),
              title: const Text('Mettre de l\'argent de côté'),
              onTap: () {
                Navigator.pop(ctx);
                _ouvrirBottomSheet('Épargne', provider, context);
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Mes finances',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: AppColors.subtleGreen,
            tabs: [
              Tab(text: 'Synthèse'),
              Tab(text: 'Transactions'),
              Tab(text: 'Épargne'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildSynthese(provider),
            _buildTransactions(provider),
            _buildEpargne(provider),
          ],
        ),
      ),
    );
  }

  // ───────────── Onglet 1 : Synthèse ─────────────
  Widget _buildSynthese(TransactionProvider provider) {
    final revenus = provider.totalRevenus;
    final depenses = provider.totalDepenses;
    final epargne = provider.totalEpargne;
    final total = revenus + depenses + epargne;
    int pct(int v) => total == 0 ? 0 : (v * 100 / total).round();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Solde actuel',
                    style: TextStyle(fontSize: 12, color: AppColors.mutedText)),
                const SizedBox(height: 6),
                Text(_formatAriary(provider.balance),
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.accentText)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CustomPaint(
                    painter: _DonutPainter(
                      segments: [
                        _Segment(revenus.toDouble(), AppColors.revAmount),
                        _Segment(depenses.toDouble(), AppColors.depAmount),
                        _Segment(epargne.toDouble(), AppColors.savAmount),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      _LegendRow(
                        color: AppColors.revAmount,
                        label: 'Revenus',
                        valeur: _formatAriary(revenus),
                        pct: pct(revenus),
                      ),
                      const SizedBox(height: 12),
                      _LegendRow(
                        color: AppColors.depAmount,
                        label: 'Dépenses',
                        valeur: _formatAriary(depenses),
                        pct: pct(depenses),
                      ),
                      const SizedBox(height: 12),
                      _LegendRow(
                        color: AppColors.savAmount,
                        label: 'Épargne',
                        valeur: _formatAriary(epargne),
                        pct: pct(epargne),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () => _choisirTypeTransaction(provider),
            child: const Text('Ajouter une transaction',
                style: TextStyle(fontSize: 15)),
          ),
        ),
      ],
    );
  }

  // ───────────── Onglet 2 : Transactions ─────────────
  Widget _buildTransactions(TransactionProvider provider) {
    return _listeTransactions(
      provider,
      provider.transactions,
      "Aucune transaction pour l'instant",
    );
  }

  // ───────────── Onglet 3 : Épargne ─────────────
  Widget _buildEpargne(TransactionProvider provider) {
    final epargnes = provider.transactions
        .where((t) => t.type == TransactionType.saving)
        .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.savBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.savings_outlined,
                        color: AppColors.savAmount),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total épargné',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.mutedText)),
                      const SizedBox(height: 4),
                      Text(_formatAriary(provider.totalEpargne),
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.savAmount)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: _listeTransactions(
            provider,
            epargnes,
            "Aucune épargne pour l'instant",
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () => _ouvrirBottomSheet('Épargne', provider, context),
              child: const Text("Mettre de l'argent de côté",
                  style: TextStyle(fontSize: 15)),
            ),
          ),
        ),
      ],
    );
  }

  /// Liste commune aux onglets Transactions et Épargne.
  Widget _listeTransactions(
    TransactionProvider provider,
    List<TransactionModel> items,
    String messageVide,
  ) {
    if (items.isEmpty) {
      return Center(
        child: Text(messageVide,
            style: const TextStyle(color: AppColors.mutedText)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      itemBuilder: (_, index) {
        final tx = items[index];
        return Dismissible(
          key: Key(tx.id),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => provider.removeTransaction(tx.id),
          background: Container(
            alignment: Alignment.centerRight,
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: AppColors.depAmount,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          child: TransactionTile(
            transaction: tx,
            onDelete: () => provider.removeTransaction(tx.id),
          ),
        );
      },
    );
  }
}

class _LegendRow extends StatelessWidget {
  final Color color;
  final String label;
  final String valeur;
  final int pct;

  const _LegendRow({
    required this.color,
    required this.label,
    required this.valeur,
    required this.pct,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label,
              style: const TextStyle(fontSize: 12, color: AppColors.mutedText)),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(valeur,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accentText)),
            Text('($pct%)',
                style: const TextStyle(fontSize: 10, color: AppColors.mutedText)),
          ],
        ),
      ],
    );
  }
}

class _Segment {
  final double value;
  final Color color;
  const _Segment(this.value, this.color);
}

/// Donut dessiné à la main (CustomPainter) : pas de dépendance en plus.
class _DonutPainter extends CustomPainter {
  final List<_Segment> segments;
  const _DonutPainter({required this.segments});

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 22.0;
    final rect = Offset(stroke / 2, stroke / 2) &
        Size(size.width - stroke, size.height - stroke);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;

    final total = segments.fold<double>(0, (sum, s) => sum + s.value);

    // Aucune donnée : anneau gris neutre.
    if (total <= 0) {
      paint.color = AppColors.borderColor;
      canvas.drawArc(rect, 0, 2 * math.pi, false, paint);
      return;
    }

    var start = -math.pi / 2;
    for (final s in segments) {
      if (s.value <= 0) continue;
      final sweep = 2 * math.pi * (s.value / total);
      paint.color = s.color;
      canvas.drawArc(rect, start, sweep, false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) => old.segments != segments;
}