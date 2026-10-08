import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/app_theme.dart';
import '../../domain/category_catalog.dart';
import '../../domain/category_schema.dart';
import '../../domain/category_schemas.dart';
import '../../domain/field_validation.dart';
import '../../models/transaction_model.dart';
import '../../models/transaction_type.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/category_form.dart';

/// Détail d'une transaction : formulaire de la catégorie, date, description
/// et validation avant enregistrement.
class TransactionDetailScreen extends StatefulWidget {
  final TransactionType type;
  final CategoryDefinition category;

  const TransactionDetailScreen({
    super.key,
    required this.type,
    required this.category,
  });

  @override
  State<TransactionDetailScreen> createState() => _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  RawValues _values = const {};
  Map<String, FieldError> _errors = const {};
  DateTime _date = DateTime.now();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  CategorySchema get _schema => categorySchemas[widget.category.key]!;
  // Le `!` est sûr : le test de cohérence (catalog_consistency_test.dart)
  // garantit qu'chaque catégorie du catalogue a un schéma.

  Future<void> _choisirDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _confirmer() async {
    final errors = validateCategoryValues(_schema, _values);
    if (errors.isNotEmpty) {
      setState(() => _errors = errors);
      return;
    }

    final transaction = TransactionModel.create(
      amountAriary: computeAmount(_schema, _values),
      type: widget.type,
      date: _date,
      categorie: widget.category.label,
      iconeCategorie: widget.category.icon,
    );

    await context.read<TransactionProvider>().addTransaction(transaction);
    if (!mounted) return;

    // Retour à l'accueil de la section Finances, sans repasser par le choix.
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final amountError = _errors[amountErrorKey];

    return Scaffold(
      appBar: AppBar(title: Text(widget.category.label)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              libelleType(widget.type),
              style: const TextStyle(color: AppColors.mutedText),
            ),
            const SizedBox(height: 16),

            CategoryForm(
              schema: _schema,
              errors: _errors,
              onChanged: (values) => setState(() {
                _values = values;
                _errors = const {};
              }),
            ),
            const SizedBox(height: 8),

            OutlinedButton.icon(
              onPressed: _choisirDate,
              icon: const Icon(Icons.calendar_today),
              label: Text('Date : ${DateFormat('dd/MM/yyyy').format(_date)}'),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (facultatif)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            if (amountError != null) ...[
              Text(
                fieldErrorMessage(amountError),
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 12),
            ],

            ElevatedButton(
              onPressed: _confirmer,
              child: const Text('Confirmer', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
