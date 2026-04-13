import 'package:flutter/material.dart';

import 'src/features/validator/presentation/validator_page.dart';

void main() {
  runApp(const ValidatorApp());
}

class ValidatorApp extends StatelessWidget {
  const ValidatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Validador API',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ValidatorPage(),
    );
  }
}
