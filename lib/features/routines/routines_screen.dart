import 'package:flutter/material.dart';

class RoutinesScreen extends StatelessWidget {
  const RoutinesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rutinas')),
      body: const Center(child: Text('Próximamente: Configura tus rutinas de enfoque.')),
    );
  }
}
