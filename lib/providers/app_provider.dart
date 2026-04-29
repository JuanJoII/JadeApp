import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart' as ia;
import '../models/app_info.dart';

final appListProvider = StateNotifierProvider<AppListNotifier, List<AppInfo>>((ref) {
  return AppListNotifier();
});

class AppListNotifier extends StateNotifier<List<AppInfo>> {
  AppListNotifier() : super([]);

  Future<void> syncApps() async {
    try {
      // Parámetros confirmados para installed_apps 2.1.1:
      // withIcon: bool (incluye los bytes del icono)
      // excludeSystemApps: bool (por defecto true, ocultamos apps de sistema para UX)
      List<ia.AppInfo> installedApps = await InstalledApps.getInstalledApps(
        withIcon: true,
        excludeSystemApps: true,
      );

      state = installedApps.map((app) {
        return AppInfo(
          id: app.packageName,
          name: app.name,
          packageName: app.packageName,
          iconBytes: app.icon,
          isBlocked: false,
        );
      }).toList();
      
      // Ordenar alfabéticamente
      state.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    } catch (e) {
      print('Error fetching apps: $e');
    }
  }

  void toggleBlocked(String id) {
    state = [
      for (final app in state)
        if (app.id == id)
          app.copyWith(isBlocked: !app.isBlocked)
        else
          app,
    ];
  }
}
