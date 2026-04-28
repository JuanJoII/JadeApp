import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/jade_button.dart';
import '../../widgets/jade_quiet_input.dart';

class RitualTask {
  final String title;
  final String importance;
  final int points;
  bool isCompleted;

  RitualTask({
    required this.title,
    required this.importance,
    required this.points,
    this.isCompleted = false,
  });
}

class RoutinesScreen extends StatefulWidget {
  const RoutinesScreen({super.key});

  @override
  State<RoutinesScreen> createState() => _RoutinesScreenState();
}

class _RoutinesScreenState extends State<RoutinesScreen> {
  final List<RitualTask> _myRitual = [
    RitualTask(
      title: 'Meditar 10 minutos',
      importance: 'Importante',
      points: 150,
    ),
    RitualTask(
      title: 'Planear el día sin pantallas',
      importance: 'Esencial',
      points: 300,
    ),
  ];

  void _addTask(String title, String importance, int points) {
    setState(() {
      _myRitual.add(
        RitualTask(title: title, importance: importance, points: points),
      );
    });
  }

  void _showAddTaskSheet() {
    String selectedImportance = 'Hábito';
    int selectedPoints = 50;
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
                'IMPORTANCIA',
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
                    label: 'Hábito',
                    points: 50,
                    isSelected: selectedImportance == 'Hábito',
                    onTap: () => setModalState(() {
                      selectedImportance = 'Hábito';
                      selectedPoints = 50;
                    }),
                  ),
                  _ImportanceOption(
                    label: 'Importante',
                    points: 150,
                    isSelected: selectedImportance == 'Importante',
                    onTap: () => setModalState(() {
                      selectedImportance = 'Importante';
                      selectedPoints = 150;
                    }),
                  ),
                  _ImportanceOption(
                    label: 'Esencial',
                    points: 300,
                    isSelected: selectedImportance == 'Esencial',
                    onTap: () => setModalState(() {
                      selectedImportance = 'Esencial';
                      selectedPoints = 300;
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              JadeButton(
                text: 'Añadir al Ritual',
                onPressed: () {
                  if (taskController.text.isNotEmpty) {
                    _addTask(
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalPoints = _myRitual.fold(0, (sum, item) => sum + item.points);

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
                  const SizedBox(height: 8),
                  Text(
                    'Completa tus tareas para ganar puntos de bienestar.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: JadeColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.auto_awesome,
                          color: JadeColors.primary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Valor total del ritual: ',
                          style: theme.textTheme.titleMedium,
                        ),
                        Text(
                          '$totalPoints pts',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: JadeColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ]),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final task = _myRitual[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _TaskCard(task: task),
                  );
                }, childCount: _myRitual.length),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: JadeButton(
                  text: 'Añadir Tarea',
                  onPressed: _showAddTaskSheet,
                  isPrimary: false,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final RitualTask task;

  const _TaskCard({required this.task});

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
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: JadeColors.primary.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
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
                      '• +${task.points} pts',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
              '$points pts',
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
