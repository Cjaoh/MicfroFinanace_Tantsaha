import 'package:flutter/material.dart';
import '../widgets/placeholder_module.dart';

class MarcheScreen extends StatelessWidget {
  const MarcheScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Marché')),
      body: const PlaceholderModule(
        icone: Icons.storefront_outlined,
        titre: 'Marché',
        description:
            'Le catalogue de produits et la vente des récoltes sont prévus en phase P10 (marketplace) de la roadmap.',
      ),
    );
  }
}