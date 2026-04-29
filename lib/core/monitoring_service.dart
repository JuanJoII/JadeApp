import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_accessibility_service/flutter_accessibility_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MonitoringService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static StreamSubscription? _accessibilitySubscription;

  static Future<void> initialize() async {
    // Configuración de Notificaciones (Solo canales)
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
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(alertChannel);
  }

  // Iniciar el monitor (Se llama desde el Home cuando el permiso está dado)
  static Future<void> startMonitoring() async {
    if (_accessibilitySubscription != null) return;

    // Esperar un momento a que el sistema registre el cambio de permiso
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      String lastApp = "";

      _accessibilitySubscription = FlutterAccessibilityService.accessStream.listen((event) async {
        final String currentApp = event.packageName ?? "";
        
        if (currentApp.isEmpty || 
            currentApp == "com.example.jade_app" || 
            currentApp == "com.android.systemui") return;

        final prefs = await SharedPreferences.getInstance();
        final blockedApps = prefs.getStringList('blocked_apps') ?? [];

        if (currentApp != lastApp && blockedApps.contains(currentApp)) {
          const AndroidNotificationDetails androidPlatformChannelSpecifics =
              AndroidNotificationDetails(
            'jade_alert_channel',
            'Alertas de JADE',
            importance: Importance.max,
            priority: Priority.high,
            fullScreenIntent: true,
          );
          const NotificationDetails platformChannelSpecifics =
              NotificationDetails(android: androidPlatformChannelSpecifics);

          await _notificationsPlugin.show(
            DateTime.now().millisecond,
            '¡Momento de consciencia!',
            'Has abierto una app restringida. ¿Es necesario?',
            platformChannelSpecifics,
          );
        }
        lastApp = currentApp;
      }, onError: (error) {
        debugPrint("Error en el flujo de accesibilidad: $error");
      });
    } catch (e) {
      debugPrint("No se pudo iniciar el monitoreo: $e");
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
