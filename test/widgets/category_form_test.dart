import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:microfinance_tantsaha/domain/category_schema.dart';
import 'package:microfinance_tantsaha/domain/field_validation.dart';
import 'package:microfinance_tantsaha/widgets/category_form.dart';

const _schema = CategorySchema(
  categoryKey: 'test',
  fields: [
    NumberFieldDef(key: 'quantite', label: 'Quantité'),
    ChoiceFieldDef(key: 'culture', label: 'Culture', options: ['riz', 'vanille']),
    TextFieldDef(key: 'note', label: 'Note', optional: true),
  ],
  amountFactors: ['quantite'],
);

Widget _host(ValuesChanged onChanged, {Map<String, FieldError> errors = const {}}) {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        child: CategoryForm(schema: _schema, onChanged: onChanged, errors: errors),
      ),
    ),
  );
}

void main() {
  testWidgets('affiche un champ par définition, avec « facultatif » si besoin', (tester) async {
    await tester.pumpWidget(_host((_) {}));

    expect(find.text('Quantité'), findsOneWidget);
    expect(find.text('Culture'), findsOneWidget);
    expect(find.text('Note (facultatif)'), findsOneWidget);
  });

  testWidgets('remonte la saisie d\'un nombre', (tester) async {
    RawValues? last;
    await tester.pumpWidget(_host((v) => last = v));

    await tester.enterText(find.widgetWithText(TextField, 'Quantité'), '3');
    expect(last?['quantite'], '3');
  });

  testWidgets('remonte le choix d\'une liste', (tester) async {
    RawValues? last;
    await tester.pumpWidget(_host((v) => last = v));

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('vanille').last);
    await tester.pumpAndSettle();

    expect(last?['culture'], 'vanille');
  });

  testWidgets('affiche le message d\'erreur fourni par le parent', (tester) async {
    await tester.pumpWidget(_host((_) {}, errors: {'quantite': FieldError.required}));

    expect(find.text(fieldErrorMessage(FieldError.required)), findsOneWidget);
  });
}
