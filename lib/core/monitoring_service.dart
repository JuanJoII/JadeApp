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
      debugPrint("JADE_DEBUG: Caché cargado. Apps bloqueadas (${_cachedBlockedApps.length}): ${_cachedBlockedApps.join(', ')}");
    } catch (e) {
      debugPrint("JADE_DEBUG_ERROR: Error al cargar caché: $e");
    }
  }

  static Future<bool> requestNotificationPermission() async {
    debugPrint("JADE_DEBUG: Solicitando permiso de notificaciones...");
    if (await isAccessibilityGranted()) {
      final plugin = _notificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (plugin != null) {
        final result = await plugin.requestNotificationsPermission() ?? false;
        debugPrint("JADE_DEBUG: Resultado permiso notificaciones: $result");
        return result;
      }
    }
    return false;
  }

  // Iniciar el monitor
  static Future<void> startMonitoring() async {
    debugPrint("JADE_DEBUG: Intentando iniciar MonitoringService...");
    
    if (_accessibilitySubscription != null) {
      debugPrint("JADE_DEBUG: Monitoreo omitido: ya existe una suscripción activa.");
      return;
    }

    await refreshBlockedAppsCache();
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      String lastApp = "";

      _accessibilitySubscription = FlutterAccessibilityService.accessStream.listen((event) {
        final String currentApp = event.packageName ?? "";
        
        // LOG VITAL: Ver qué llega del sistema
        debugPrint("JADE_DEBUG: EVENTO SISTEMA -> $currentApp (Tipo: ${event.eventType})");

        if (currentApp.isEmpty || currentApp == "com.android.systemui") return;

        // Ignorar nuestra propia app para evitar bucles
        if (currentApp.contains("jade_app")) return;

        if (currentApp != lastApp && _cachedBlockedApps.contains(currentApp)) {
          debugPrint("JADE_DEBUG: ¡DETECCIÓN POSITIVA! Bloqueando $currentApp");
          
          final now = DateTime.now();
          if (_lastNotificationTime == null || 
              now.difference(_lastNotificationTime!) > const Duration(seconds: 10)) {
            
            _showBlockNotification(currentApp);
            _lastNotificationTime = now;
          }
        }
        lastApp = currentApp;
      }, onError: (error) {
        debugPrint("JADE_DEBUG_ERROR: Error en el Stream de Accesibilidad: $error");
      });
      
      debugPrint("JADE_DEBUG: Suscripción al stream completada.");
    } catch (e) {
      debugPrint("JADE_DEBUG_ERROR: Fallo al iniciar monitoreo: $e");
    }
  }

  static Future<void> _showBlockNotification(String packageName) async {
    debugPrint("JADE_DEBUG: Intentando mostrar notificación para $packageName");
    
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'jade_alert_channel',
      'Alertas de JADE',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'Alerta de JADE',
      icon: '@mipmap/ic_launcher', // Asegurar que el icono sea el correcto
    );
    
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    try {
      await _notificationsPlugin.show(
        DateTime.now().millisecond, // ID único para cada notificación
        '¡Momento de pausa!',
        'Has abierto una app restringida. ¿Realmente la necesitas ahora?',
        platformChannelSpecifics,
      );
      debugPrint("JADE_DEBUG: Notificación enviada al sistema.");
    } catch (e) {
      debugPrint("JADE_DEBUG_ERROR: Fallo al mostrar notificación: $e");
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
