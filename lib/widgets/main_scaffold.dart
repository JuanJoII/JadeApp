import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

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
      body: child,
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
