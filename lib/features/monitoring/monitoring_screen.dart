import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../providers/app_provider.dart';

class MonitoringScreen extends ConsumerStatefulWidget {
  const MonitoringScreen({super.key});

  @override
  ConsumerState<MonitoringScreen> createState() => _MonitoringScreenState();
}

class _MonitoringScreenState extends ConsumerState<MonitoringScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initSync();
  }

  Future<void> _initSync() async {
    setState(() => _isLoading = true);
    await ref.read(appListProvider.notifier).syncApps();
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final apps = ref.watch(appListProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bienestar Digital',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _initSync,
            icon: _isLoading 
              ? const SizedBox(
                  width: 20, 
                  height: 20, 
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.refresh),
          ),
          const SizedBox(width: 8),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              'Selecciona las apps que deseas monitorear y limitar su uso.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: _isLoading && apps.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : apps.isEmpty
                      ? const Center(
                          child: Text('No se encontraron aplicaciones.'),
                        )
                      : ListView.separated(
                          itemCount: apps.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final app = apps[index];
                            final hasIcon = app.iconBytes != null && app.iconBytes!.isNotEmpty;
                            
                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: app.isBlocked
                                    ? JadeColors.primaryContainer.withValues(alpha: 0.3)
                                    : (Theme.of(context).brightness == Brightness.light
                                          ? JadeColors.surfaceContainerLow
                                          : JadeColors.darkSurfaceContainer),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: hasIcon
                                        ? Image.memory(
                                            app.iconBytes!,
                                            width: 48,
                                            height: 48,
                                            errorBuilder: (context, error, stackTrace) => 
                                              const Icon(Icons.apps, size: 48),
                                          )
                                        : const Icon(Icons.apps, size: 48),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          app.name,
                                          style: Theme.of(context).textTheme.titleMedium
                                              ?.copyWith(fontWeight: FontWeight.w500),
                                        ),
                                        Text(
                                          app.packageName,
                                          style: Theme.of(context).textTheme.bodySmall
                                              ?.copyWith(
                                                color: colorScheme.onSurface.withValues(alpha: 0.5),
                                              ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Switch(
                                    value: app.isBlocked,
                                    onChanged: (_) {
                                      ref
                                          .read(appListProvider.notifier)
                                          .toggleBlocked(app.id);
                                    },
                                    activeThumbColor: JadeColors.primary,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.push('/overlay'),
                  child: const Text('Probar Bloqueo (Overlay)'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
