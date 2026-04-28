import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/transaction_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TransactionProvider(),
      child: MaterialApp(
        title: 'Gestion Finances',
        theme: ThemeData(
  scaffoldBackgroundColor: const Color(0xFFFFF8F0),
  fontFamily: 'Roboto',
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF7C4A1E),
  ),
),
debugShowCheckedModeBanner: false,
        home: const HomeScreen(),
      ),
    );
  }
}
