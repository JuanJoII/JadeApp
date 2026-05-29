import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme.dart';
import '../core/monitoring_service.dart';

class MainScaffold extends StatefulWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  Timer? _overlayTimer;

  @override
  void initState() {
    super.initState();
    _startOverlayCheck();
  }

  @override
  void dispose() {
    _overlayTimer?.cancel();
    super.dispose();
  }

  void _startOverlayCheck() {
    _overlayTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      final pendingOverlay = await MonitoringService.getPendingOverlay();
      if (pendingOverlay != null && pendingOverlay.isNotEmpty) {
        if (mounted) {
          context.push('/overlay', extra: pendingOverlay);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    int currentIndex = 0;
    if (location.startsWith('/monitoring')) {
      currentIndex = 1;
    } else if (location.startsWith('/routines')) {
      currentIndex = 2;
    } else if (location.startsWith('/progress')) {
      currentIndex = 3;
    } else if (location.startsWith('/settings')) {
      currentIndex = 4;
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go('/home');
              break;
            case 1:
              context.go('/monitoring');
              break;
            case 2:
              context.go('/routines');
              break;
            case 3:
              context.go('/progress');
              break;
            case 4:
              context.go('/settings');
              break;
          }
        },
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primaryContainer.withValues(alpha: 0.5),
        elevation: 0,
        destinations: [
          NavigationDestination(
            icon: Icon(
              Icons.home_outlined,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            selectedIcon: const Icon(Icons.home, color: JadeColors.primary),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.app_registration_outlined,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            selectedIcon: const Icon(
              Icons.app_registration,
              color: JadeColors.primary,
            ),
            label: 'Apps',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.self_improvement_outlined,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            selectedIcon: const Icon(
              Icons.self_improvement,
              color: JadeColors.primary,
            ),
            label: 'Rutinas',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.auto_awesome_outlined,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            selectedIcon: const Icon(
              Icons.auto_awesome,
              color: JadeColors.primary,
            ),
            label: 'Progreso',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.settings_outlined,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            selectedIcon: const Icon(Icons.settings, color: JadeColors.primary),
            label: 'Ajustes',
          ),
        ],
      ),
    );
  }
}
