import 'package:flutter/material.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Progreso')),
      body: const Center(child: Text('Próximamente: Visualiza tus logros y estadísticas.')),
    );
  }
}
