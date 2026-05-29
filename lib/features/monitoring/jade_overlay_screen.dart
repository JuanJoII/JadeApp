import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme.dart';
import '../../core/monitoring_service.dart';
import '../../providers/focus_provider.dart';
import '../../providers/app_provider.dart';
import '../../models/app_info.dart';

class JadeOverlayScreen extends ConsumerStatefulWidget {
  final String packageName;

  const JadeOverlayScreen({super.key, required this.packageName});

  @override
  ConsumerState<JadeOverlayScreen> createState() => _JadeOverlayScreenState();
}

class _JadeOverlayScreenState extends ConsumerState<JadeOverlayScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getFallbackName(String package) {
    if (package.isEmpty) return 'Aplicación';
    if (package.contains('facebook')) return 'Facebook';
    if (package.contains('instagram')) return 'Instagram';
    if (package.contains('tiktok')) return 'TikTok';
    if (package.contains('youtube')) return 'YouTube';
    if (package.contains('twitter') || package.contains('x.android')) return 'X';
    
    final parts = package.split('.');
    if (parts.isNotEmpty) {
      final last = parts.last;
      return last[0].toUpperCase() + last.substring(1);
    }
    return package;
  }

  void _showReservoirSettings(BuildContext context, WidgetRef ref, double currentMax) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    double tempMinutes = currentMax;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: EdgeInsets.only(
            top: 32,
            left: 32,
            right: 32,
            bottom: 32 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.tune_outlined, color: JadeColors.primary),
                  const SizedBox(width: 12),
                  Text(
                    'Ajustar Reservorio',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Define cuántos minutos de atención representa tu reservorio al 100%. Las aplicaciones distractoras drenarán este reservorio de forma proporcional.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 32),
              Center(
                child: Column(
                  children: [
                    Text(
                      '${tempMinutes.toInt()} minutos',
                      style: theme.textTheme.displayMedium?.copyWith(
                        color: JadeColors.primary,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tempMinutes >= 60
                          ? '(${ (tempMinutes / 60).floor() } h ${ (tempMinutes % 60).toInt() > 0 ? '${(tempMinutes % 60).toInt()} min' : '' })'
                          : '(${tempMinutes.toInt()} minutos)',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Slider(
                value: tempMinutes,
                min: 30.0,
                max: 240.0,
                divisions: 14, // Pasos de 15 minutos (30, 45, 60, ..., 240)
                activeColor: JadeColors.primary,
                inactiveColor: JadeColors.primary.withValues(alpha: 0.15),
                onChanged: (value) {
                  setState(() {
                    tempMinutes = value;
                  });
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(focusProvider.notifier).setMaxMinutes(tempMinutes);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: JadeColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Guardar Ajuste',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  child: const Text('Cancelar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Obtener la información de la app distractora
    final allApps = ref.watch(appListProvider);
    final appInfo = allApps.firstWhere(
      (a) => a.packageName == widget.packageName,
      orElse: () => AppInfo(
        id: '',
        name: _getFallbackName(widget.packageName),
        packageName: widget.packageName,
      ),
    );

    // Obtener el nivel de enfoque actual
    final focusState = ref.watch(focusProvider);
    final focusLevel = focusState.level;
    final maxMinutes = focusState.maxMinutes;
    final estimatedMinutes = (focusLevel * (maxMinutes / 100.0)).toInt();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            children: [
              const Spacer(),
              
              // Animación central de respiración zen
              ScaleTransition(
                scale: _animation,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: JadeColors.primary.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: JadeColors.primary.withValues(alpha: 0.04),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: JadeColors.primary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.spa_outlined,
                        color: JadeColors.primary,
                        size: 44,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 48),
              
              // Título y Mensaje Editorial Zen
              Text(
                'Momento de pausa',
                style: theme.textTheme.displayLarge?.copyWith(
                  fontSize: 30,
                  letterSpacing: -0.02,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  '${appInfo.name} está bloqueada para proteger tu paz mental. Respira profundamente.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.65),
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              
              // Visualización del Reservorio de Enfoque (Glassmorphic & Minimal)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? JadeColors.darkSurfaceContainer : JadeColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: JadeColors.primary.withValues(alpha: 0.08),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Reservorio de Enfoque',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onSurface.withValues(alpha: 0.8),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  constraints: const BoxConstraints(),
                                  padding: EdgeInsets.zero,
                                  icon: Icon(
                                    Icons.tune_outlined,
                                    size: 16,
                                    color: JadeColors.primary.withValues(alpha: 0.6),
                                  ),
                                  onPressed: () => _showReservoirSettings(context, ref, maxMinutes),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '~$estimatedMinutes min de atención libre',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: JadeColors.primary.withValues(alpha: 0.6),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${focusLevel.toInt()}%',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: JadeColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Barra de progreso del reservorio
                    Stack(
                      children: [
                        Container(
                          height: 10,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: JadeColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 1000),
                              curve: Curves.easeOutCubic,
                              height: 10,
                              width: constraints.maxWidth * (focusLevel / 100),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    JadeColors.primary,
                                    JadeColors.primary.withValues(alpha: 0.7),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(5),
                                boxShadow: [
                                  BoxShadow(
                                    color: JadeColors.primary.withValues(alpha: 0.15),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: JadeColors.error,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Si continúas, tu Reservorio de Enfoque comenzará a drenarse.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: JadeColors.error.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const Spacer(),
              
              // Botón de Volver al Presente - FOCO PRINCIPAL (Confiable, lleno)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // Retorna al presente, cerrando la app distractora
                    context.pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: JadeColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Volver al presente',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Botón de Continuar - SIN ENFOCAR (Texto plano, bajo contraste, sutil)
              TextButton(
                onPressed: () async {
                  // Guardar el bypass en SharedPreferences para la app actual (5 mins grace period)
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('bypassed_app', widget.packageName);
                  await prefs.setInt('bypassed_time', DateTime.now().millisecondsSinceEpoch);
                  
                  if (context.mounted) {
                    // Minimizar JADE para que el usuario retorne directamente a la app distractora
                    await MonitoringService.minimizeApp();
                    if (context.mounted) {
                      context.pop();
                    }
                  }
                },
                style: TextButton.styleFrom(
                  foregroundColor: colorScheme.onSurface.withValues(alpha: 0.4),
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                ),
                child: Text(
                  'Continuar a ${appInfo.name}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
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
