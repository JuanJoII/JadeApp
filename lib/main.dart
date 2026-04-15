import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme.dart';
import 'routes.dart';

void main() {
  // Asegurar que los widgets estén inicializados
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    const ProviderScope(
      child: JadeApp(),
    ),
  );
}

class JadeApp extends ConsumerWidget {
  const JadeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'JADE Digital Wellness',
      debugShowCheckedModeBanner: false,
      theme: JadeTheme.lightTheme,
      darkTheme: JadeTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
