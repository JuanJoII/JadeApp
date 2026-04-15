import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../providers/app_provider.dart';

class MonitoringScreen extends ConsumerWidget {
  const MonitoringScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apps = ref.watch(appListProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bienestar Digital',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
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
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: ListView.separated(
                itemCount: apps.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final app = apps[index];
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: app.isBlocked
                          ? JadeColors.primaryContainer.withOpacity(0.3)
                          : (Theme.of(context).brightness == Brightness.light
                              ? JadeColors.surfaceContainerLow
                              : JadeColors.darkSurfaceContainer),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: JadeColors.primary.withOpacity(0.1),
                          child: Icon(
                            _getIconForApp(app.name),
                            color: JadeColors.primary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            app.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                        Switch(
                          value: app.isBlocked,
                          onChanged: (_) {
                            ref.read(appListProvider.notifier).toggleBlocked(app.id);
                          },
                          activeColor: JadeColors.primary,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: ElevatedButton(
                onPressed: () => context.push('/overlay'),
                child: const Text('Probar Bloqueo (Overlay)'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForApp(String name) {
    switch (name.toLowerCase()) {
      case 'instagram':
        return Icons.camera_alt_outlined;
      case 'tiktok':
        return Icons.music_note_outlined;
      case 'youtube':
        return Icons.play_circle_outline;
      case 'whatsapp':
        return Icons.chat_bubble_outline;
      case 'facebook':
        return Icons.facebook_outlined;
      default:
        return Icons.apps;
    }
  }
}
