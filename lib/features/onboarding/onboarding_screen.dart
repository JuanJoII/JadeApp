import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/theme.dart';
import '../../widgets/jade_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: 'Bienvenido a JADE',
      description:
          'Crea tu propio santuario digital. Un espacio de calma en un mundo lleno de distracciones.',
      icon: Icons.spa_outlined,
    ),
    OnboardingData(
      title: 'Protege tu enfoque',
      description:
          'Selecciona las apps que consumen tu tiempo y JADE te ayudará a limitar su uso.',
      icon: Icons.shield_moon_outlined,
    ),
    OnboardingData(
      title: 'Bienestar que premia',
      description:
          'Gana puntos y sube de nivel mientras mantienes tus hábitos digitales saludables.',
      icon: Icons.auto_awesome_outlined,
    ),
    OnboardingData(
      title: 'Permisos necesarios',
      description:
          'JADE necesita acceso para ver qué apps usas y poder ayudarte a limitar el tiempo en ellas.',
      icon: Icons.key_outlined,
      isPermissionPage: true,
    ),
  ];

  Future<void> _requestPermissions() async {
    // Nota: El acceso a estadísticas de uso en Android usualmente requiere 
    // abrir la pantalla de ajustes de sistema específica.
    // Aquí usamos un permiso de ejemplo para demostrar la lógica.
    final status = await Permission.sensors.request(); 
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Estado del permiso: ${status.name}'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: _currentPage != _pages.length - 1 
                ? TextButton(
                    onPressed: () => context.go('/home'),
                    child: const Text(
                      'Omitir',
                      style: TextStyle(color: JadeColors.primary),
                    ),
                  )
                : const SizedBox(height: 48),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final data = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(40),
                          decoration: BoxDecoration(
                            color: JadeColors.primary.withValues(alpha: 0.05),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            data.icon,
                            size: 100,
                            color: JadeColors.primary,
                          ),
                        ),
                        const SizedBox(height: 48),
                        Text(
                          data.title,
                          textAlign: TextAlign.center,
                          style: Theme.of(
                            context,
                          ).textTheme.displayLarge?.copyWith(fontSize: 28),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          data.description,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                                height: 1.5,
                              ),
                        ),
                        if (data.isPermissionPage) ...[
                          const SizedBox(height: 32),
                          ElevatedButton.icon(
                            onPressed: _requestPermissions,
                            icon: const Icon(Icons.settings),
                            label: const Text('Conceder Permisos'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: JadeColors.primary.withValues(alpha: 0.1),
                              foregroundColor: JadeColors.primary,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? JadeColors.primary
                              : JadeColors.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  JadeButton(
                    text: _currentPage == _pages.length - 1
                        ? 'Comenzar'
                        : 'Siguiente',
                    onPressed: () {
                      if (_currentPage == _pages.length - 1) {
                        context.go('/home');
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String description;
  final IconData icon;
  final bool isPermissionPage;

  OnboardingData({
    required this.title,
    required this.description,
    required this.icon,
    this.isPermissionPage = false,
  });
}
