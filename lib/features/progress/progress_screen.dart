import 'package:flutter/material.dart';
import '../../core/theme.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text('Monitoreo de Uso', style: theme.textTheme.displayLarge),
              const SizedBox(height: 12),
              Text(
                'Tu tiempo es sagrado. Así lo has distribuido hoy.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 40),

              // Tarjeta de Resumen Central
              Center(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: JadeColors.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: JadeColors.primary.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 160,
                            height: 160,
                            child: CircularProgressIndicator(
                              value: 0.65,
                              strokeWidth: 12,
                              backgroundColor: JadeColors.primary.withValues(
                                alpha: 0.1,
                              ),
                              color: JadeColors.primary,
                              strokeCap: StrokeCap.round,
                            ),
                          ),
                          Column(
                            children: [
                              Text(
                                '2h 15m',
                                style: theme.textTheme.displaySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: JadeColors.primary,
                                ),
                              ),
                              Text(
                                'Tiempo Total',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _StatItem(
                            label: 'Límite Diario',
                            value: '4h 00m',
                            icon: Icons.timer_outlined,
                          ),
                          _StatItem(
                            label: 'Ahorrado',
                            value: '1h 45m',
                            icon: Icons.auto_awesome,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 48),
              Text(
                'Aplicaciones Monitoreadas',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),

              _AppUsageCard(
                appName: 'Instagram',
                usageTime: '45m',
                limitTime: '1h 00m',
                progress: 0.75,
                color: const Color(0xFFE4405F),
              ),
              const SizedBox(height: 16),
              _AppUsageCard(
                appName: 'TikTok',
                usageTime: '1h 20m',
                limitTime: '1h 30m',
                progress: 0.88,
                color: Colors.black,
              ),
              const SizedBox(height: 16),
              _AppUsageCard(
                appName: 'Twitter / X',
                usageTime: '10m',
                limitTime: '30m',
                progress: 0.33,
                color: const Color(0xFF1DA1F2),
              ),

              const SizedBox(height: 40),
              // Botón de acción sutil
              Center(
                child: TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add_circle_outline, size: 20),
                  label: const Text('Gestionar límites'),
                  style: TextButton.styleFrom(
                    foregroundColor: JadeColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, size: 20, color: JadeColors.primary.withValues(alpha: 0.6)),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}

class _AppUsageCard extends StatelessWidget {
  final String appName;
  final String usageTime;
  final String limitTime;
  final double progress;
  final Color color;

  const _AppUsageCard({
    required this.appName,
    required this.usageTime,
    required this.limitTime,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? JadeColors.darkSurfaceContainer
            : JadeColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.apps, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '$usageTime usados de $limitTime',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: progress > 0.8 ? JadeColors.error : JadeColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: JadeColors.primary.withValues(alpha: 0.05),
              valueColor: AlwaysStoppedAnimation<Color>(
                progress > 0.8 ? JadeColors.error : JadeColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
