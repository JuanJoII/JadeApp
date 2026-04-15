import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_info.dart';

final appListProvider = StateNotifierProvider<AppListNotifier, List<AppInfo>>((ref) {
  return AppListNotifier();
});

class AppListNotifier extends StateNotifier<List<AppInfo>> {
  AppListNotifier() : super([
    AppInfo(id: '1', name: 'Instagram', iconPath: 'instagram'),
    AppInfo(id: '2', name: 'TikTok', iconPath: 'tiktok'),
    AppInfo(id: '3', name: 'YouTube', iconPath: 'youtube'),
    AppInfo(id: '4', name: 'WhatsApp', iconPath: 'whatsapp'),
    AppInfo(id: '5', name: 'Facebook', iconPath: 'facebook'),
    AppInfo(id: '6', name: 'Twitter', iconPath: 'twitter'),
  ]);

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
