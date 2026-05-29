import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:usage_stats/usage_stats.dart';
import 'package:permission_handler/permission_handler.dart';

class MonitoringService {
  static const MethodChannel _channel = MethodChannel('com.example.jade_app/monitoring');

  static Future<void> initialize() async {
    // El servicio nativo en Kotlin se encarga de su propia inicialización y canales de notificación.
  }

  // Verifica si el permiso de Mostrar sobre otras apps está concedido
  static Future<bool> isOverlayGranted() async {
    return await Permission.systemAlertWindow.isGranted;
  }

  // Solicita el permiso de Mostrar sobre otras apps
  static Future<void> requestOverlayPermission() async {
    await Permission.systemAlertWindow.request();
  }

  // Verifica si el permiso de Acceso de Uso está concedido
  static Future<bool> isAccessibilityGranted() async {
    // Mapeamos el nombre del método para evitar tener que cambiar decenas de archivos de UI
    // que esperan isAccessibilityGranted()
    return await UsageStats.checkUsagePermission() ?? false;
  }

  // Abre la pantalla de ajustes del sistema para conceder Acceso de Uso
  static Future<void> requestAccessibility() async {
    // Mapeamos el nombre del método para evitar cambiar decenas de archivos de UI
    await UsageStats.grantUsagePermission();
  }

  // Inicia el servicio persistente de monitoreo en primer plano (Kotlin)
  static Future<void> startMonitoring() async {
    try {
      final isGranted = await isAccessibilityGranted();
      if (isGranted) {
        await _channel.invokeMethod('startService');
      }
    } on PlatformException catch (e) {
      debugPrint("JADE_ERROR: Fallo al iniciar el servicio: $e");
    }
  }

  // Detiene el servicio de monitoreo
  static void stopMonitoring() async {
    try {
      await _channel.invokeMethod('stopService');
    } on PlatformException catch (e) {
      debugPrint("JADE_ERROR: Fallo al detener el servicio: $e");
    }
  }

  // Verifica si el servicio de monitoreo se está ejecutando en primer plano
  static Future<bool> isServiceRunning() async {
    try {
      return await _channel.invokeMethod<bool>('isServiceRunning') ?? false;
    } on PlatformException {
      return false;
    }
  }

  // Obtiene el paquete de la aplicación distractora pendiente de bloquear (si la hay)
  static Future<String?> getPendingOverlay() async {
    try {
      final String? pending = await _channel.invokeMethod<String>('getPendingOverlay');
      return pending;
    } on PlatformException catch (e) {
      debugPrint("JADE_ERROR: Error al obtener overlay pendiente: $e");
      return null;
    }
  }

  // Minimiza la aplicación (mueve la tarea a segundo plano) para volver a la app distractora
  static Future<void> minimizeApp() async {
    try {
      await _channel.invokeMethod('minimizeApp');
    } on PlatformException catch (e) {
      debugPrint("JADE_ERROR: Fallo al minimizar la app: $e");
    }
  }

  // Refresca la caché local de aplicaciones bloqueadas
  static Future<void> refreshBlockedAppsCache() async {
    // El servicio nativo lee las SharedPreferences directamente en tiempo real,
    // pero mantenemos esta firma por compatibilidad con app_provider.dart
  }

  // Solicita permisos de notificaciones (Android 13+)
  static Future<bool> requestNotificationPermission() async {
    // Retornamos true ya que el flujo nativo maneja las notificaciones.
    return true;
  }
}
