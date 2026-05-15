import 'dart:async';
import 'dart:io';
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
  static DateTime? _lastDrainTime;
  static const double _defaultDrainRate = 0.5; // units per minute

  static Future<void> initialize() async {
    // Configuración de Notificaciones
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
    );
    
    await _notificationsPlugin.initialize(initializationSettings);

    if (Platform.isAndroid) {
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
    }
    
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
    if (Platform.isIOS) {
      return await _notificationsPlugin
              .resolvePlatformSpecificImplementation<
                  IOSFlutterLocalNotificationsPlugin>()
              ?.requestPermissions(
                alert: true,
                badge: true,
                sound: true,
              ) ??
          false;
    }

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
    if (!Platform.isAndroid) {
      debugPrint("JADE_INFO: Monitoreo de accesibilidad no disponible en esta plataforma.");
      return;
    }

    if (_accessibilitySubscription != null) return;

    await refreshBlockedAppsCache();
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      String lastApp = "";

      _accessibilitySubscription = FlutterAccessibilityService.accessStream.listen((event) async {
        final String currentApp = event.packageName ?? "";
        
        if (currentApp.isEmpty || currentApp == "com.android.systemui") return;
        if (currentApp.contains("jade_app")) return;

        if (_cachedBlockedApps.contains(currentApp)) {
          // Drain focus
          await _drainFocus(currentApp);

          if (currentApp != lastApp) {
            final now = DateTime.now();
            if (_lastNotificationTime == null || 
                now.difference(_lastNotificationTime!) > const Duration(seconds: 15)) {
              
              _showBlockNotification(currentApp);
              _lastNotificationTime = now;
            }
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

  static Future<void> _drainFocus(String packageName) async {
    final now = DateTime.now();
    if (_lastDrainTime != null) {
      final difference = now.difference(_lastDrainTime!).inSeconds;
      if (difference > 0) {
        final prefs = await SharedPreferences.getInstance();
        double currentFocus = prefs.getDouble('focus_level') ?? 100.0;
        
        // Dynamic drain rate logic
        double rate = _defaultDrainRate;
        if (packageName.contains('facebook') || 
            packageName.contains('instagram') || 
            packageName.contains('tiktok') ||
            packageName.contains('youtube')) {
          rate = 1.0; // Social media drains faster
        }

        double drainAmount = (rate / 60.0) * difference;
        double newFocus = (currentFocus - drainAmount).clamp(0.0, 100.0);
        
        await prefs.setDouble('focus_level', newFocus);
        await prefs.setString('focus_last_update', now.toIso8601String());

        // Check for Conscious Pause
        if (currentFocus >= 10.0 && newFocus < 10.0) {
          _showConsciousPauseNotification();
        }
      }
    }
    _lastDrainTime = now;
  }

  static Future<void> _showConsciousPauseNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'jade_alert_channel',
      'Alertas de JADE',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    
    const DarwinNotificationDetails darwinPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: darwinPlatformChannelSpecifics,
    );

    try {
      await _notificationsPlugin.show(
        999,
        'Reservorio Crítico',
        'Tu energía de atención está agotándose. ¿Qué tal un micro-ritual de recarga?',
        platformChannelSpecifics,
      );
    } catch (e) {
      debugPrint("JADE_ERROR: Fallo al mostrar notificación: $e");
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
    
    const DarwinNotificationDetails darwinPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: darwinPlatformChannelSpecifics,
    );

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
    _lastDrainTime = null;
  }

  static Future<bool> isAccessibilityGranted() async {
    if (!Platform.isAndroid) return true; // No aplica en iOS
    return await FlutterAccessibilityService.isAccessibilityPermissionEnabled();
  }

  static Future<void> requestAccessibility() async {
    if (Platform.isAndroid) {
      await FlutterAccessibilityService.requestAccessibilityPermission();
    }
  }
}

