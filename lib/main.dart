import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme.dart';
import 'core/monitoring_service.dart';
import 'routes.dart';

void main() async {
  // Asegurar que los widgets estén inicializados
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configurar UI inmersiva (ocultar barra de navegación de forma predeterminada)
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // Inicializar servicio de monitoreo
  await MonitoringService.initialize();

  runApp(const ProviderScope(child: JadeApp()));
}

class JadeApp extends ConsumerWidget {
  const JadeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'JADE',
      debugShowCheckedModeBanner: false,
      theme: JadeTheme.lightTheme,
      darkTheme: JadeTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
