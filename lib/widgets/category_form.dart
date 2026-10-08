import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../domain/category_schema.dart';
import '../domain/field_validation.dart';

typedef ValuesChanged = void Function(RawValues values);

/// Formulaire généré à partir d'un [CategorySchema].
///
/// Le widget n'a pas de logique métier : il affiche les champs, remonte les
/// valeurs saisies via [onChanged] et affiche les erreurs fournies par le parent.
/// Pour changer de catégorie, le parent doit donner une clé différente
/// (ex. ValueKey(schema.categoryKey)) afin de réinitialiser le formulaire.
class CategoryForm extends StatefulWidget {
  final CategorySchema schema;
  final ValuesChanged onChanged;
  final Map<String, FieldError> errors;

  const CategoryForm({
    super.key,
    required this.schema,
    required this.onChanged,
    this.errors = const {},
  });

  @override
  State<CategoryForm> createState() => _CategoryFormState();
}

class _CategoryFormState extends State<CategoryForm> {
  final Map<String, TextEditingController> _controllers = {};
  final RawValues _values = {};

  @override
  void initState() {
    super.initState();
    for (final field in widget.schema.fields) {
      _controllers[field.key] = TextEditingController();
      _values[field.key] = '';
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _update(String key, String value) {
    setState(() => _values[key] = value);
    widget.onChanged(Map.unmodifiable(_values));
  }

  Future<void> _pickDate(DateFieldDef field) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 10),
    );
    if (picked == null || !mounted) return;

    // Format AAAA-MM-JJ, attendu par la validation.
    final iso = '${picked.year.toString().padLeft(4, '0')}-'
        '${picked.month.toString().padLeft(2, '0')}-'
        '${picked.day.toString().padLeft(2, '0')}';
    _controllers[field.key]!.text = iso;
    _update(field.key, iso);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final field in widget.schema.fields) ...[
          _buildField(field),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildField(FieldDef field) {
    final error = widget.errors[field.key];
    final decoration = InputDecoration(
      labelText: field.optional ? '${field.label} (facultatif)' : field.label,
      errorText: error == null ? null : fieldErrorMessage(error),
      border: const OutlineInputBorder(),
    );

    return switch (field) {
      ChoiceFieldDef(:final options) => DropdownButtonFormField<String>(
          initialValue: _values[field.key]!.isEmpty ? null : _values[field.key],
          decoration: decoration,
          items: [
            for (final option in options)
              DropdownMenuItem(value: option, child: Text(option)),
          ],
          onChanged: (value) {
            if (value != null) _update(field.key, value);
          },
        ),
      NumberFieldDef() => TextField(
          controller: _controllers[field.key],
          decoration: decoration,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (value) => _update(field.key, value),
        ),
      DateFieldDef() => TextField(
          controller: _controllers[field.key],
          decoration: decoration.copyWith(
            suffixIcon: const Icon(Icons.calendar_today),
          ),
          readOnly: true,
          onTap: () => _pickDate(field),
        ),
      TextFieldDef() => TextField(
          controller: _controllers[field.key],
          decoration: decoration,
          onChanged: (value) => _update(field.key, value),
        ),
    };
  }
}

/// Message affiché à l'utilisateur pour un code d'erreur.
/// Ces textes seront remplacés par des clés ARB à l'étape D.
String fieldErrorMessage(FieldError error) => switch (error) {
      FieldError.required => 'Ce champ est obligatoire',
      FieldError.invalidNumber => 'Entrez un nombre entier',
      FieldError.tooSmall => 'Valeur trop petite',
      FieldError.invalidChoice => 'Choix non reconnu',
      FieldError.invalidDate => 'Date invalide',
      FieldError.amountTooLarge => 'Montant trop élevé',
    };
