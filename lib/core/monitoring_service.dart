import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_accessibility_service/flutter_accessibility_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MonitoringService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static StreamSubscription? _accessibilitySubscription;
  static List<String> _cachedBlockedApps = [];
  static DateTime? _lastNotificationTime;

  static Future<void> initialize() async {
    // Configuración de Notificaciones
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    
    await _notificationsPlugin.initialize(initializationSettings);

    const AndroidNotificationChannel alertChannel = AndroidNotificationChannel(
      'jade_alert_channel',
      'Alertas de JADE',
      description: 'Notificaciones cuando abres una app bloqueada',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(alertChannel);
    
    // Cargar apps bloqueadas inicialmente
    await refreshBlockedAppsCache();
  }

  static Future<void> refreshBlockedAppsCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _cachedBlockedApps = prefs.getStringList('blocked_apps') ?? [];
    } catch (e) {
      // Log solo en caso de error crítico
      debugPrint("JADE_ERROR: Error al cargar caché: $e");
    }
  }

  static Future<bool> requestNotificationPermission() async {
    if (await isAccessibilityGranted()) {
      final plugin = _notificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (plugin != null) {
        return await plugin.requestNotificationsPermission() ?? false;
      }
    }
    return false;
  }

  // Iniciar el monitor
  static Future<void> startMonitoring() async {
    if (_accessibilitySubscription != null) return;

    await refreshBlockedAppsCache();
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      String lastApp = "";

      _accessibilitySubscription = FlutterAccessibilityService.accessStream.listen((event) {
        final String currentApp = event.packageName ?? "";
        
        if (currentApp.isEmpty || currentApp == "com.android.systemui") return;
        if (currentApp.contains("jade_app")) return;

        if (currentApp != lastApp && _cachedBlockedApps.contains(currentApp)) {
          final now = DateTime.now();
          if (_lastNotificationTime == null || 
              now.difference(_lastNotificationTime!) > const Duration(seconds: 15)) {
            
            _showBlockNotification(currentApp);
            _lastNotificationTime = now;
          }
        }
        lastApp = currentApp;
      }, onError: (error) {
        debugPrint("JADE_ERROR: Error en el Stream: $error");
      });
    } catch (e) {
      debugPrint("JADE_ERROR: Fallo al iniciar monitoreo: $e");
    }
  }

  static Future<void> _showBlockNotification(String packageName) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'jade_alert_channel',
      'Alertas de JADE',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'Alerta de JADE',
      icon: '@mipmap/ic_launcher',
    );
    
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    try {
      await _notificationsPlugin.show(
        DateTime.now().millisecond,
        '¡Momento de pausa!',
        'Has abierto una app restringida. ¿Realmente la necesitas ahora?',
        platformChannelSpecifics,
      );
    } catch (e) {
      debugPrint("JADE_ERROR: Fallo al mostrar notificación: $e");
    }
  }

  static void stopMonitoring() {
    _accessibilitySubscription?.cancel();
    _accessibilitySubscription = null;
  }

  static Future<bool> isAccessibilityGranted() async {
    return await FlutterAccessibilityService.isAccessibilityPermissionEnabled();
  }

  static Future<void> requestAccessibility() async {
    await FlutterAccessibilityService.requestAccessibilityPermission();
  }
}
