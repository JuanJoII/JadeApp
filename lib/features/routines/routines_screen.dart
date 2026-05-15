import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../widgets/jade_button.dart';
import '../../widgets/jade_quiet_input.dart';
import '../../providers/ritual_provider.dart';
import '../../providers/focus_provider.dart';
import '../../providers/deep_work_provider.dart';

class RoutinesScreen extends ConsumerStatefulWidget {
  const RoutinesScreen({super.key});

  @override
  ConsumerState<RoutinesScreen> createState() => _RoutinesScreenState();
}

class _RoutinesScreenState extends ConsumerState<RoutinesScreen> {
  void _showAddTaskSheet() {
    String selectedImportance = 'Hábito';
    int selectedPoints = 5; // Focus units
    final TextEditingController taskController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 32,
            top: 32,
            left: 24,
            right: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nueva tarea del ritual',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 24),
              JadeQuietInput(
                label: '¿QUÉ HARÁS?',
                hintText: 'Ej: Leer 15 páginas',
                controller: taskController,
              ),
              const SizedBox(height: 24),
              Text(
                'VALOR DE ENFOQUE',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _ImportanceOption(
                    label: 'Micro',
                    points: 5,
                    isSelected: selectedPoints == 5,
                    onTap: () => setModalState(() {
                      selectedImportance = 'Hábito';
                      selectedPoints = 5;
                    }),
                  ),
                  _ImportanceOption(
                    label: 'Medio',
                    points: 15,
                    isSelected: selectedPoints == 15,
                    onTap: () => setModalState(() {
                      selectedImportance = 'Importante';
                      selectedPoints = 15;
                    }),
                  ),
                  _ImportanceOption(
                    label: 'Esencial',
                    points: 30,
                    isSelected: selectedPoints == 30,
                    onTap: () => setModalState(() {
                      selectedImportance = 'Esencial';
                      selectedPoints = 30;
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              JadeButton(
                text: 'Añadir al Ritual',
                onPressed: () {
                  if (taskController.text.isNotEmpty) {
                    ref.read(ritualProvider.notifier).addTask(
                      taskController.text,
                      selectedImportance,
                      selectedPoints,
                    );
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeepWorkSheet() {
    int selectedMinutes = 25;
    final TextEditingController taskController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 32,
            top: 32,
            left: 24,
            right: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Configurar Deep Work',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 24),
              JadeQuietInput(
                label: '¿EN QUÉ TE ENFOCARÁS?',
                hintText: 'Ej: Estudiar algoritmos',
                controller: taskController,
              ),
              const SizedBox(height: 24),
              Text(
                'DURACIÓN (MINUTOS)',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [25, 45, 60, 90].map((mins) => GestureDetector(
                  onTap: () => setModalState(() => selectedMinutes = mins),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: selectedMinutes == mins
                          ? JadeColors.primary.withValues(alpha: 0.1)
                          : Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selectedMinutes == mins ? JadeColors.primary : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      '$mins',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: selectedMinutes == mins ? JadeColors.primary : null,
                        fontWeight: selectedMinutes == mins ? FontWeight.bold : null,
                      ),
                    ),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 40),
              JadeButton(
                text: 'Iniciar Micro-Desafío',
                onPressed: () {
                  ref.read(deepWorkProvider.notifier).startChallenge(
                    selectedMinutes,
                    taskController.text.isEmpty ? 'Sesión de Enfoque' : taskController.text,
                  );
                  Navigator.pop(context);
                  context.push('/deep-work');
                },
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
    final rituals = ref.watch(ritualProvider);
    final focusState = ref.watch(focusProvider);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(24.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 20),
                  Text('Mi Ritual Diario', style: theme.textTheme.displayLarge),
                  const SizedBox(height: 24),
                  
                  // Focus Reservoir Widget
                  _FocusReservoir(level: focusState.level),
                  
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tareas de hoy',
                        style: theme.textTheme.headlineSmall,
                      ),
                      Text(
                        '${rituals.where((t) => t.isCompleted).length}/${rituals.length}',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ]),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final task = rituals[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _TaskCard(task: task),
                  );
                }, childCount: rituals.length),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    JadeButton(
                      text: 'Añadir Tarea',
                      onPressed: _showAddTaskSheet,
                      isPrimary: false,
                    ),
                    const SizedBox(height: 40),
                    _DeepWorkChallengeCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FocusReservoir extends StatelessWidget {
  final double level;

  const _FocusReservoir({required this.level});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? JadeColors.darkSurfaceContainer : JadeColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Reservorio de Enfoque',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              Text(
                '${level.toInt()}%',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: JadeColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Stack(
            children: [
              Container(
                height: 12,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: JadeColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeOutCubic,
                height: 12,
                width: (MediaQuery.of(context).size.width - 96) * (level / 100),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      JadeColors.primary,
                      JadeColors.primary.withValues(alpha: 0.6),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: JadeColors.primary.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            level < 20 
              ? 'Nivel crítico. Considera un micro-ritual.' 
              : 'Tu atención es un recurso finito. Cuídala.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskCard extends ConsumerWidget {
  final RitualTask task;

  const _TaskCard({required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => ref.read(ritualProvider.notifier).toggleTask(task.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: task.isCompleted
              ? JadeColors.primary.withValues(alpha: 0.05)
              : (isDark ? JadeColors.darkSurfaceContainer : JadeColors.surfaceContainerLow),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: task.isCompleted ? JadeColors.primary.withValues(alpha: 0.2) : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: task.isCompleted ? JadeColors.primary : Colors.transparent,
                border: Border.all(
                  color: task.isCompleted ? JadeColors.primary : JadeColors.primary.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: task.isCompleted
                  ? const Icon(Icons.check, size: 18, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                      color: task.isCompleted ? theme.colorScheme.onSurface.withValues(alpha: 0.3) : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        task.importance,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: JadeColors.primary.withValues(alpha: 0.7),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '• +${task.points} enfoque',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (!task.isCompleted)
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  size: 20,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                ),
                onPressed: () => ref.read(ritualProvider.notifier).removeTask(task.id),
              ),
          ],
        ),
      ),
    );
  }
}

class _DeepWorkChallengeCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark 
            ? [JadeColors.primary.withValues(alpha: 0.15), JadeColors.darkSurfaceContainer]
            : [JadeColors.primary.withValues(alpha: 0.05), JadeColors.surfaceContainerLow],
        ),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bolt, color: JadeColors.primary),
              const SizedBox(width: 12),
              Text(
                'Deep Work',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Inicia un micro-desafío de trabajo profundo. Tu recompensa dependerá de tu atención.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24),
          JadeButton(
            text: 'Comenzar Desafío',
            onPressed: () {
              // Call the private method from the state
              final state = context.findAncestorStateOfType<_RoutinesScreenState>();
              state?._showDeepWorkSheet();
            },
          ),
        ],
      ),
    );
  }
}

class _ImportanceOption extends StatelessWidget {
  final String label;
  final int points;
  final bool isSelected;
  final VoidCallback onTap;

  const _ImportanceOption({
    required this.label,
    required this.points,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? JadeColors.primary.withValues(alpha: 0.1)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? JadeColors.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: isSelected ? JadeColors.primary : null,
                fontWeight: isSelected ? FontWeight.bold : null,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$points enf.',
              style: theme.textTheme.labelSmall?.copyWith(
                color: isSelected
                    ? JadeColors.primary.withValues(alpha: 0.7)
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
