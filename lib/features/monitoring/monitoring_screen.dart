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
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initSync();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initSync() async {
    setState(() => _isLoading = true);
    final showSystem = ref.read(showSystemAppsProvider);
    await ref.read(appListProvider.notifier).syncApps(includeSystemApps: showSystem);
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final apps = ref.watch(filteredAppListProvider);
    final showSystemApps = ref.watch(showSystemAppsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Monitoreo',
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
            // Buscador
            TextField(
              controller: _searchController,
              onChanged: (value) => ref.read(appSearchQueryProvider.notifier).state = value,
              decoration: InputDecoration(
                hintText: 'Buscar aplicación...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
            const SizedBox(height: 16),
            // Filtro de Apps de Sistema
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Mostrar apps de sistema',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                Transform.scale(
                  scale: 0.8,
                  child: Switch(
                    value: showSystemApps,
                    onChanged: (value) {
                      ref.read(showSystemAppsProvider.notifier).state = value;
                      _initSync(); // Re-sincronizar con el nuevo filtro
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading && apps.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : apps.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off, size: 64, color: colorScheme.onSurface.withValues(alpha: 0.2)),
                              const SizedBox(height: 16),
                              const Text('No se encontraron aplicaciones.'),
                            ],
                          ),
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
