import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../widgets/jade_button.dart';
import '../../providers/deep_work_provider.dart';

class DeepWorkScreen extends ConsumerStatefulWidget {
  const DeepWorkScreen({super.key});

  @override
  ConsumerState<DeepWorkScreen> createState() => _DeepWorkScreenState();
}

class _DeepWorkScreenState extends ConsumerState<DeepWorkScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      // User left the app during Deep Work
      ref.read(deepWorkProvider.notifier).recordInterruption();
    }
  }

  String _formatTime(int seconds) {
    final mins = (seconds / 60).floor();
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final deepWork = ref.watch(deepWorkProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (deepWork.status == DeepWorkStatus.completed) {
      return _buildCompletionReport(context, deepWork);
    }

    return Scaffold(
      backgroundColor: isDark ? JadeColors.darkSurface : JadeColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'TRABAJO PROFUNDO',
                style: theme.textTheme.labelLarge?.copyWith(
                  letterSpacing: 4,
                  color: JadeColors.primary.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                deepWork.taskTitle ?? 'Sesión de Enfoque',
                style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              
              // Timer Display
              _BreathingAnchor(
                child: Text(
                  _formatTime(deepWork.remainingSeconds),
                  style: theme.textTheme.displayLarge?.copyWith(
                    fontSize: 80,
                    fontWeight: FontWeight.w200,
                    color: JadeColors.primary,
                  ),
                ),
              ),
              
              const Spacer(),
              
              // Interruption Counter
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: JadeColors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 18,
                      color: deepWork.interruptions > 0 ? Colors.orange : JadeColors.primary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Interrupciones: ${deepWork.interruptions}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: deepWork.interruptions > 0 ? Colors.orange : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 48),
              
              JadeButton(
                text: 'Abandonar Sesión',
                onPressed: () {
                  ref.read(deepWorkProvider.notifier).cancelChallenge();
                  context.pop();
                },
                isPrimary: false,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompletionReport(BuildContext context, DeepWorkState state) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle_outline, size: 80, color: JadeColors.primary),
              const SizedBox(height: 24),
              Text(
                '¡Sesión Completada!',
                style: theme.textTheme.displaySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Has salvado ${state.durationMinutes} unidades de enfoque.',
                style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              _ReportItem(
                label: 'Calidad de Atención',
                value: state.interruptions == 0 ? 'Total' : 'Fragmentada',
                icon: Icons.psychology,
              ),
              _ReportItem(
                label: 'Interrupciones',
                value: '${state.interruptions}',
                icon: Icons.notifications_paused,
              ),
              const SizedBox(height: 60),
              JadeButton(
                text: 'Volver al Ritual',
                onPressed: () {
                  ref.read(deepWorkProvider.notifier).reset();
                  context.pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BreathingAnchor extends StatefulWidget {
  final Widget child;
  const _BreathingAnchor({required this.child});

  @override
  State<_BreathingAnchor> createState() => _BreathingAnchorState();
}

class _BreathingAnchorState extends State<_BreathingAnchor> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: widget.child,
    );
  }
}

class _ReportItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _ReportItem({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        children: [
          Icon(icon, color: JadeColors.primary.withValues(alpha: 0.4)),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.4))),
              Text(value, style: theme.textTheme.titleLarge),
            ],
          ),
        ],
      ),
    );
  }
}
