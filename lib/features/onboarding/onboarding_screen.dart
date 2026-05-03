import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/monitoring_service.dart';
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
          'JADE necesita acceso para detectar cuándo abres apps restringidas y enviarte recordatorios.',
      icon: Icons.key_outlined,
      isPermissionPage: true,
    ),
  ];

  Future<void> _requestPermissions() async {
    // 1. Pedir permiso de notificaciones (Android 13+)
    await Permission.notification.request();

    // 2. Pedir permiso de Accesibilidad
    await MonitoringService.requestAccessibility();
  }

  Future<void> _finishOnboarding() async {
    final bool isGranted = await MonitoringService.isAccessibilityGranted();

    if (isGranted) {
      // Iniciar el monitoreo reactivo
      MonitoringService.startMonitoring();
      if (mounted) context.go('/home');
    } else {
      // Si no lo ha dado, le avisamos pero le dejamos pasar (el Home le avisará de nuevo)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Recuerda activar el monitor en los ajustes para proteger tu tiempo.',
            ),
          ),
        );
        context.go('/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0, left: 16.0),
                  ),
                  if (_currentPage != _pages.length - 1)
                    TextButton(
                      onPressed: () => context.go('/home'),
                      child: const Text(
                        'Omitir',
                        style: TextStyle(color: JadeColors.primary),
                      ),
                    )
                  else
                    const SizedBox(height: 48, width: 60),
                ],
              ),
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
                        index == 0
                            ? SvgPicture.asset(
                                'lib/assets/Logo_Jade_No_Bg.svg',
                                height: 200,
                              )
                            : Container(
                                padding: const EdgeInsets.all(40),
                                decoration: BoxDecoration(
                                  color: JadeColors.primary.withValues(
                                    alpha: 0.05,
                                  ),
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
                            label: const Text('Configurar Accesibilidad'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: JadeColors.primary.withValues(
                                alpha: 0.1,
                              ),
                              foregroundColor: JadeColors.primary,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
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
                        _finishOnboarding();
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
