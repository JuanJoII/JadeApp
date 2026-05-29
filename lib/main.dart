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

class JadeApp extends ConsumerStatefulWidget {
  const JadeApp({super.key});

  @override
  ConsumerState<JadeApp> createState() => _JadeAppState();
}

class _JadeAppState extends ConsumerState<JadeApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPendingOverlay();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPendingOverlay();
    }
  }

  Future<void> _checkPendingOverlay() async {
    // Breve retraso para dar tiempo a la inicialización o reanudación
    await Future.delayed(const Duration(milliseconds: 150));
    final pending = await MonitoringService.getPendingOverlay();
    if (pending != null && pending.isNotEmpty) {
      try {
        final currentRoute = router.routerDelegate.currentConfiguration.uri.path;
        if (!currentRoute.startsWith('/overlay')) {
          router.push('/overlay', extra: pending);
        }
      } catch (e) {
        // En caso de que no esté completamente inicializado el router, forzar push directo
        router.push('/overlay', extra: pending);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
