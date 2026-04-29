import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart' as ia;
import '../models/app_info.dart';

final appSearchQueryProvider = StateProvider<String>((ref) => '');
final showSystemAppsProvider = StateProvider<bool>((ref) => false);

final filteredAppListProvider = Provider<List<AppInfo>>((ref) {
  final allApps = ref.watch(appListProvider);
  final searchQuery = ref.watch(appSearchQueryProvider).toLowerCase();

  if (searchQuery.isEmpty) return allApps;

  return allApps.where((app) {
    return app.name.toLowerCase().contains(searchQuery) ||
        app.packageName.toLowerCase().contains(searchQuery);
  }).toList();
});

final appListProvider = StateNotifierProvider<AppListNotifier, List<AppInfo>>((ref) {
  return AppListNotifier();
});

class AppListNotifier extends StateNotifier<List<AppInfo>> {
  AppListNotifier() : super([]);

  Future<void> syncApps({bool includeSystemApps = false}) async {
    try {
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
