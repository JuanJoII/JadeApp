import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usage_stats/usage_stats.dart';

class MonitoringService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    final service = FlutterBackgroundService();

    // Configuración de Notificaciones Locales
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await _notificationsPlugin.initialize(initializationSettings);

    // Canal de notificación para el servicio en primer plano
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'jade_monitoring_service',
      'JADE Monitoring Service',
      description: 'Este servicio monitorea el uso de aplicaciones.',
      importance: Importance.low,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: false, // El usuario lo activará manualmente o al terminar onboarding
        isForegroundMode: true,
        notificationChannelId: 'jade_monitoring_service',
        initialNotificationTitle: 'JADE está activo',
        initialNotificationContent: 'Monitoreando tu bienestar digital...',
        foregroundServiceTypes: [AndroidForegroundType.specialUse],
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
  }

  @pragma('vm:entry-point')
  static Future<bool> onIosBackground(ServiceInstance service) async {
    return true;
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    DartPluginRegistrant.ensureInitialized();

    final FlutterLocalNotificationsPlugin notificationsPlugin =
        FlutterLocalNotificationsPlugin();

    String lastApp = "";

    Timer.periodic(const Duration(seconds: 2), (timer) async {
      final prefs = await SharedPreferences.getInstance();
      final blockedApps = prefs.getStringList('blocked_apps') ?? [];
      
      if (blockedApps.isEmpty) return;

      DateTime endDate = DateTime.now();
      DateTime startDate = endDate.subtract(const Duration(minutes: 1));

      try {
        List<EventUsageInfo> events = await UsageStats.queryEvents(startDate, endDate);
        
        if (events.isNotEmpty) {
          // Buscamos el último evento de tipo MOVE_TO_FOREGROUND (1)
          final foregroundEvents = events.where((e) => e.eventType == "1").toList();
          if (foregroundEvents.isEmpty) return;

          String currentApp = foregroundEvents.last.packageName ?? "";
          
          if (currentApp != lastApp && blockedApps.contains(currentApp)) {
            // Mostrar notificación de alerta
            const AndroidNotificationDetails androidPlatformChannelSpecifics =
                AndroidNotificationDetails(
              'jade_alert_channel',
              'Alertas de JADE',
              channelDescription: 'Notificaciones cuando abres una app bloqueada',
              importance: Importance.max,
              priority: Priority.high,
              ticker: 'ticker',
            );
            const NotificationDetails platformChannelSpecifics =
                NotificationDetails(android: androidPlatformChannelSpecifics);

            await notificationsPlugin.show(
              1,
              '¡Momento de consciencia!',
              'Has abierto una aplicación que querías limitar. ¿Seguro que quieres continuar?',
              platformChannelSpecifics,
            );
          }
          lastApp = currentApp;
        }
      } catch (e) {
        debugPrint("Error monitoreando apps: $e");
      }
    });
  }
}
