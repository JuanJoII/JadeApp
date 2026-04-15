import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hola, Jade', style: textTheme.displayLarge),
              const SizedBox(height: 8),
              Text(
                'Tu santuario digital está listo.',
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 40),
              // Tarjeta de Racha
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(
                          Icons.local_fire_department_outlined,
                          color: JadeColors.primary,
                          size: 32,
                        ),
                        Text(
                          'Nivel 4',
                          style: textTheme.titleMedium?.copyWith(
                            color: JadeColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '5 días de racha',
                      style: textTheme.headlineMedium?.copyWith(
                        color: JadeColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: 0.7,
                      backgroundColor: colorScheme.onPrimary.withValues(
                        alpha: 0.2,
                      ),
                      color: JadeColors.primary,
                      minHeight: 8,
                      borderRadius: const BorderRadius.all(Radius.circular(4)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Tarjetas de Resumen
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      context,
                      '120',
                      'Puntos Jade',
                      Icons.stars_outlined,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSummaryCard(
                      context,
                      '2h 15m',
                      'Tiempo Libre',
                      Icons.timer_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),
              Text('Accesos rápidos', style: textTheme.headlineSmall),
              const SizedBox(height: 20),
              _buildActionTile(
                context,
                'Monitoreo de Apps',
                'Configura tus límites de uso',
                Icons.app_registration_outlined,
                () => context.push('/monitoring'),
              ),
              const SizedBox(height: 12),
              _buildActionTile(
                context,
                'Rutinas de Enfoque',
                'Crea espacios de silencio',
                Icons.self_improvement_outlined,
                () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String value,
    String label,
    IconData icon,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light
            ? JadeColors.surfaceContainerLow
            : JadeColors.darkSurfaceContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: JadeColors.primary, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: JadeColors.primary.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: JadeColors.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: JadeColors.outlineVariant),
          ],
        ),
      ),
    );
  }
}
