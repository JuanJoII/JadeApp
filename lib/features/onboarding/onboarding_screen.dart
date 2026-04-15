import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
      description: 'Crea tu propio santuario digital. Un espacio de calma en un mundo lleno de distracciones.',
      icon: Icons.spa_outlined,
    ),
    OnboardingData(
      title: 'Protege tu enfoque',
      description: 'Selecciona las apps que consumen tu tiempo y JADE te ayudará a limitar su uso.',
      icon: Icons.shield_moon_outlined,
    ),
    OnboardingData(
      title: 'Bienestar que premia',
      description: 'Gana puntos y sube de nivel mientras mantienes tus hábitos digitales saludables.',
      icon: Icons.auto_awesome_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () => context.go('/home'),
                child: const Text('Omitir', style: TextStyle(color: JadeColors.primary)),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(40),
                          decoration: BoxDecoration(
                            color: JadeColors.primary.withOpacity(0.05),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _pages[index].icon,
                            size: 100,
                            color: JadeColors.primary,
                          ),
                        ),
                        const SizedBox(height: 48),
                        Text(
                          _pages[index].title,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _pages[index].description,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: colorScheme.onSurface.withOpacity(0.6),
                                height: 1.5,
                              ),
                        ),
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
                          color: _currentPage == index ? JadeColors.primary : JadeColors.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  JadeButton(
                    text: _currentPage == _pages.length - 1 ? 'Comenzar' : 'Siguiente',
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

  OnboardingData({
    required this.title,
    required this.description,
    required this.icon,
  });
}
