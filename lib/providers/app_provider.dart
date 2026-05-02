import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart' as ia;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_info.dart';
import '../core/monitoring_service.dart';

final appSearchQueryProvider = StateProvider<String>((ref) => '');
final showSystemAppsProvider = StateProvider<bool>((ref) => false);

final filteredAppListProvider = Provider<List<AppInfo>>((ref) {
  final allApps = ref.watch(appListProvider);
  final searchQuery = ref.watch(appSearchQueryProvider).toLowerCase();

  return allApps.where((app) {
    return app.name.toLowerCase().contains(searchQuery) ||
        app.packageName.toLowerCase().contains(searchQuery);
  }).toList();
});

final appListProvider = StateNotifierProvider<AppListNotifier, List<AppInfo>>((ref) {
  return AppListNotifier();
});

class AppListNotifier extends StateNotifier<List<AppInfo>> {
  AppListNotifier() : super([]) {
    _loadInitialApps();
  }

  Future<void> _loadInitialApps() async {
    // Primero sincronizamos apps básicas y luego aplicamos el estado de bloqueo guardado
    await syncApps();
  }

  Future<void> syncApps({bool includeSystemApps = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final blockedPackageNames = prefs.getStringList('blocked_apps') ?? [];

      List<ia.AppInfo> installedApps = await InstalledApps.getInstalledApps(
        withIcon: true,
        excludeSystemApps: !includeSystemApps,
      );

      state = installedApps.map((app) {
        return AppInfo(
          id: app.packageName,
          name: app.name,
          packageName: app.packageName,
          iconBytes: app.icon,
          isBlocked: blockedPackageNames.contains(app.packageName),
        );
      }).toList();
      
      state.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    } catch (e) {
      print('Error fetching apps: $e');
    }
  }

  Future<void> toggleBlocked(String id) async {
    state = [
      for (final app in state)
        if (app.id == id)
          app.copyWith(isBlocked: !app.isBlocked)
        else
          app,
    ];

    // Guardar lista actualizada en SharedPreferences para que el servicio la lea
    final prefs = await SharedPreferences.getInstance();
    final blockedList = state
        .where((app) => app.isBlocked)
        .map((app) => app.packageName)
        .toList();
    await prefs.setStringList('blocked_apps', blockedList);
    
    // Notificar al servicio de monitoreo que el caché debe actualizarse
    await MonitoringService.refreshBlockedAppsCache();
  }
}
