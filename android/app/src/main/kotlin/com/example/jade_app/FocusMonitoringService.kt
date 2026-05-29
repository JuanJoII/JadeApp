package com.example.jade_app

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.util.Log
import androidx.core.app.NotificationCompat
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import java.util.TimeZone
import com.example.jade_app.R

class FocusMonitoringService : Service() {

    private val handler = Handler(Looper.getMainLooper())
    private var runnable: Runnable? = null
    
    private val channelId = "jade_monitoring_channel"
    private val notificationId = 1001

    private var lastApp = ""
    private var lastNotificationTime: Long = 0
    private var lastDrainTime: Long = 0
    private val defaultDrainRate = 0.5 // units per minute
    private var lastOverlayTriggerTime: Long = 0

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        if (Build.VERSION.SDK_INT >= 34) {
            startForeground(
                notificationId,
                buildNotification(),
                android.content.pm.ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE
            )
        } else {
            startForeground(notificationId, buildNotification())
        }
        lastDrainTime = System.currentTimeMillis()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        startPolling()
        return START_STICKY
    }

    override fun onDestroy() {
        stopPolling()
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val serviceChannel = NotificationChannel(
                channelId,
                "Monitoreo de JADE",
                NotificationManager.IMPORTANCE_LOW
            )
            serviceChannel.description = "Servicio en segundo plano para proteger tu enfoque"
            val manager = getSystemService(NotificationManager::class.java)
            manager?.createNotificationChannel(serviceChannel)
        }
    }

    private fun buildNotification(): Notification {
        val notificationIntent = Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            notificationIntent,
            PendingIntent.FLAG_IMMUTABLE
        )

        return NotificationCompat.Builder(this, channelId)
            .setContentTitle("JADE Activo")
            .setContentText("Protegiendo tu santuario digital...")
            .setSmallIcon(R.mipmap.launcher_icon)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .build()
    }

    private fun startPolling() {
        if (runnable != null) return

        runnable = object : Runnable {
            override fun run() {
                checkForegroundApp()
                handler.postDelayed(this, 1500) // Check every 1.5 seconds
            }
        }
        handler.post(runnable!!)
    }

    private fun stopPolling() {
        runnable?.let { handler.removeCallbacks(it) }
        runnable = null
    }

    private fun checkForegroundApp() {
        val currentApp = getForegroundAppPackage()
        Log.d("JADE_MONITOR", "checkForegroundApp: detected package '$currentApp'")
        if (currentApp == null || currentApp.isEmpty()) return

        // Evitar el procesamiento de bloqueo para JADE y SystemUI,
        // pero permitir que actualicen lastApp para registrar el cambio de foco.
        val shouldSkipLock = currentApp == "com.android.systemui" || currentApp.contains("jade_app")
        Log.d("JADE_MONITOR", "shouldSkipLock: $shouldSkipLock for package '$currentApp'")

        if (!shouldSkipLock) {
            val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            
            // Diagnóstico: Imprimir todas las claves de SharedPreferences para rastrear
            val allEntries = prefs.all
            Log.d("JADE_MONITOR", "SharedPreferences keys: ${allEntries.keys}")
            
            val blockedApps = getBlockedApps(prefs)
            Log.d("JADE_MONITOR", "Blocked Apps list: $blockedApps")

            if (blockedApps.contains(currentApp)) {
                Log.d("JADE_MONITOR", "App '$currentApp' is registered as BLOCKED!")
                drainFocus(currentApp, prefs)

                val bypassedApp = prefs.getString("flutter.bypassed_app", null)
                val bypassedTime = prefs.getLong("flutter.bypassed_time", 0L)
                val now = System.currentTimeMillis()
                val isBypassed = bypassedApp == currentApp && (now - bypassedTime < 5 * 60 * 1000) // 5 minutos de gracia
                Log.d("JADE_MONITOR", "isBypassed: $isBypassed (bypassedApp: '$bypassedApp', bypassedTime: $bypassedTime)")

                if (!isBypassed) {
                    // Disparar si el foco cambió a esta app distractora O si ya pasó el intervalo de reintento de 6s
                    if (currentApp != lastApp || now - lastOverlayTriggerTime > 6000) {
                        lastOverlayTriggerTime = now
                        Log.d("JADE_MONITOR", "Triggering overlay for '$currentApp'!")
                        
                        // 1. Intentar abrir la pantalla de bloqueo de JADE directamente
                        val overlayIntent = Intent(this, MainActivity::class.java).apply {
                            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
                            addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
                            putExtra("overlay_trigger", true)
                            putExtra("blocked_package", currentApp)
                        }
                        
                        val pendingIntent = PendingIntent.getActivity(
                            this,
                            0,
                            overlayIntent,
                            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
                        )
                        
                        try {
                            val options = android.app.ActivityOptions.makeBasic()
                            if (Build.VERSION.SDK_INT >= 34) {
                                options.setPendingIntentBackgroundActivityStartMode(
                                    android.app.ActivityOptions.MODE_BACKGROUND_ACTIVITY_START_ALLOWED
                                )
                            }
                            pendingIntent.send(this, 0, null, null, null, null, options.toBundle())
                            Log.d("JADE_MONITOR", "PendingIntent sent successfully!")
                        } catch (e: Exception) {
                            Log.e("JADE_MONITOR", "Failed to send PendingIntent: ${e.message}", e)
                            try {
                                startActivity(overlayIntent)
                                Log.d("JADE_MONITOR", "startActivity fallback succeeded!")
                            } catch (ex: Exception) {
                                Log.e("JADE_MONITOR", "startActivity fallback failed: ${ex.message}", ex)
                            }
                        }

                        // 2. Enviar notificación local como alternativa/alerta
                        if (now - lastNotificationTime > 15000) { // Cooldown de 15 segundos
                            showBlockNotification(currentApp)
                            lastNotificationTime = now
                        }
                    }
                }
            }
        }
        lastApp = currentApp
        lastDrainTime = System.currentTimeMillis()
    }

    private fun getForegroundAppPackage(): String? {
        val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as? UsageStatsManager
        if (usageStatsManager == null) {
            Log.e("JADE_MONITOR", "UsageStatsManager is null!")
            return null
        }
        val time = System.currentTimeMillis()
        
        // 1. Intentar con queryEvents (más preciso en tiempo real)
        val usageEvents = usageStatsManager.queryEvents(time - 10000, time)
        var lastResumedEventPackage: String? = null
        var lastResumedEventTime: Long = 0
        var eventCount = 0

        if (usageEvents != null) {
            val event = UsageEvents.Event()
            while (usageEvents.hasNextEvent()) {
                usageEvents.getNextEvent(event)
                eventCount++
                if (event.eventType == UsageEvents.Event.ACTIVITY_RESUMED) {
                    if (event.timeStamp > lastResumedEventTime) {
                        lastResumedEventPackage = event.packageName
                        lastResumedEventTime = event.timeStamp
                    }
                }
            }
            Log.d("JADE_MONITOR", "QueryEvents processed $eventCount events. Last package: '$lastResumedEventPackage'")
        }

        // 2. Fallback con queryUsageStats si queryEvents no arrojó resultados (algunos dispositivos retrasan eventos)
        if (lastResumedEventPackage == null) {
            val usageStats = usageStatsManager.queryUsageStats(
                UsageStatsManager.INTERVAL_DAILY,
                time - 1000 * 60, // Último minuto
                time
            )
            if (usageStats != null && usageStats.isNotEmpty()) {
                var latestStats = usageStats[0]
                for (stats in usageStats) {
                    if (stats.lastTimeUsed > latestStats.lastTimeUsed) {
                        latestStats = stats
                    }
                }
                lastResumedEventPackage = latestStats.packageName
                Log.d("JADE_MONITOR", "Fallback queryUsageStats package: '$lastResumedEventPackage'")
            }
        }
        
        return lastResumedEventPackage
    }

    private fun drainFocus(packageName: String, prefs: SharedPreferences) {
        val now = System.currentTimeMillis()
        val difference = (now - lastDrainTime) / 1000.0 // in seconds
        if (difference > 0) {
            val currentFocus = getDoublePref(prefs, "flutter.focus_level", 100.0)

            var rate = defaultDrainRate
            if (packageName.contains("facebook") ||
                packageName.contains("instagram") ||
                packageName.contains("tiktok") ||
                packageName.contains("youtube")
            ) {
                rate = 1.0
            }

            val drainAmount = (rate / 60.0) * difference
            val newFocus = (currentFocus - drainAmount).coerceIn(0.0, 100.0)

            putDoublePref(prefs, "flutter.focus_level", newFocus)
            
            // Format time as ISO 8601 string in local timezone
            val df = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS", Locale.getDefault())
            df.timeZone = TimeZone.getDefault()
            val isoDate = df.format(Date(now))
            prefs.edit().putString("flutter.focus_last_update", isoDate).apply()

            if (currentFocus >= 10.0 && newFocus < 10.0) {
                showConsciousPauseNotification()
            }
        }
    }

    private fun getDoublePref(prefs: SharedPreferences, key: String, defaultValue: Double): Double {
        try {
            if (prefs.contains(key)) {
                return prefs.getFloat(key, defaultValue.toFloat()).toDouble()
            }
        } catch (e: Exception) {}

        try {
            val str = prefs.getString(key, null)
            if (str != null) {
                return str.toDoubleOrNull() ?: defaultValue
            }
        } catch (e: Exception) {}

        try {
            if (prefs.contains(key)) {
                val longVal = prefs.getLong(key, 0L)
                if (longVal != 0L) {
                    return java.lang.Double.longBitsToDouble(longVal)
                }
            }
        } catch (e: Exception) {}

        return defaultValue
    }

    private fun putDoublePref(prefs: SharedPreferences, key: String, value: Double) {
        val editor = prefs.edit()
        val all = prefs.all
        if (all.containsKey(key)) {
            val existing = all[key]
            if (existing is Float) {
                editor.putFloat(key, value.toFloat())
            } else if (existing is String) {
                editor.putString(key, value.toString())
            } else if (existing is Long) {
                editor.putLong(key, java.lang.Double.doubleToRawLongBits(value))
            } else {
                editor.putFloat(key, value.toFloat())
            }
        } else {
            editor.putFloat(key, value.toFloat())
        }
        editor.apply()
    }

    private fun showBlockNotification(packageName: String) {
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager ?: return
        
        // Notification channel of JADE alerts
        val alertChannelId = "jade_alert_channel"
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                alertChannelId,
                "Alertas de JADE",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Notificaciones cuando abres una app bloqueada"
                enableLights(true)
                enableVibration(true)
            }
            notificationManager.createNotificationChannel(channel)
        }

        val notificationIntent = Intent(this, MainActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
            addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
            putExtra("overlay_trigger", true)
            putExtra("blocked_package", packageName)
        }
        val pendingIntent = PendingIntent.getActivity(
            this,
            System.currentTimeMillis().toInt(),
            notificationIntent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )

        val builder = NotificationCompat.Builder(this, alertChannelId)
            .setContentTitle("¡Momento de pausa!")
            .setContentText("Has abierto una app restringida. ¿Realmente la necesitas ahora?")
            .setSmallIcon(R.mipmap.launcher_icon)
            .setContentIntent(pendingIntent)
            .setAutoCancel(true)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setDefaults(NotificationCompat.DEFAULT_ALL)

        notificationManager.notify(System.currentTimeMillis().toInt(), builder.build())
    }

    private fun showConsciousPauseNotification() {
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager ?: return
        val alertChannelId = "jade_alert_channel"

        val notificationIntent = Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            this,
            999,
            notificationIntent,
            PendingIntent.FLAG_IMMUTABLE
        )

        val builder = NotificationCompat.Builder(this, alertChannelId)
            .setContentTitle("Reservorio Crítico")
            .setContentText("Tu energía de atención está agotándose. ¿Qué tal un micro-ritual de recarga?")
            .setSmallIcon(R.mipmap.launcher_icon)
            .setContentIntent(pendingIntent)
            .setAutoCancel(true)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setDefaults(NotificationCompat.DEFAULT_ALL)

        notificationManager.notify(999, builder.build())
    }

    private fun getBlockedApps(prefs: SharedPreferences): Set<String> {
        val key = "flutter.blocked_apps"
        val rawValue = prefs.all[key]
        Log.d("JADE_MONITOR", "getBlockedApps: rawValue = $rawValue (class = ${rawValue?.javaClass?.name})")

        if (rawValue == null) {
            Log.d("JADE_MONITOR", "getBlockedApps: rawValue is null, returning emptySet")
            return emptySet()
        }

        // 1. Si es un Set de Java/Kotlin (getStringSet estándar)
        if (rawValue is Set<*>) {
            val resultSet = mutableSetOf<String>()
            for (item in rawValue) {
                if (item is String) {
                    resultSet.add(item)
                }
            }
            Log.d("JADE_MONITOR", "getBlockedApps: parsed Set = $resultSet")
            return resultSet
        }

        // 2. Si es una Lista de Java/Kotlin (por si acaso)
        if (rawValue is List<*>) {
            val resultSet = mutableSetOf<String>()
            for (item in rawValue) {
                if (item is String) {
                    resultSet.add(item)
                }
            }
            Log.d("JADE_MONITOR", "getBlockedApps: parsed List = $resultSet")
            return resultSet
        }

        // 3. Si es un String (JSON array con prefijo de Flutter)
        if (rawValue is String) {
            val resultSet = mutableSetOf<String>()
            var jsonStr = rawValue.trim()
            Log.d("JADE_MONITOR", "getBlockedApps: rawString = '$jsonStr'")

            // Flutter SharedPreferences codifica listas anteponiendo el prefijo en base64 separado por "!"
            if (jsonStr.contains("!")) {
                try {
                    val index = jsonStr.indexOf("!")
                    val prefix = jsonStr.substring(0, index)
                    val content = jsonStr.substring(index + 1).trim()
                    Log.d("JADE_MONITOR", "getBlockedApps: Split done. Prefix = '$prefix', Content = '$content'")
                    jsonStr = content
                } catch (e: Exception) {
                    Log.e("JADE_MONITOR", "getBlockedApps: Failed to split on '!': ${e.message}")
                }
            }

            // Desglosar el array de JSON simple: ["app1","app2"]
            if (jsonStr.startsWith("[") && jsonStr.endsWith("]")) {
                val content = jsonStr.substring(1, jsonStr.length - 1)
                if (content.isNotEmpty()) {
                    val items = content.split(",")
                    for (item in items) {
                        var cleanItem = item.trim()
                        if (cleanItem.startsWith("\"") && cleanItem.endsWith("\"")) {
                            cleanItem = cleanItem.substring(1, cleanItem.length - 1)
                        } else if (cleanItem.startsWith("'") && cleanItem.endsWith("'")) {
                            cleanItem = cleanItem.substring(1, cleanItem.length - 1)
                        }
                        if (cleanItem.isNotEmpty()) {
                            resultSet.add(cleanItem)
                        }
                    }
                }
            } else if (jsonStr.isNotEmpty()) {
                resultSet.add(jsonStr)
            }
            
            Log.d("JADE_MONITOR", "getBlockedApps: parsed String = $resultSet")
            return resultSet
        }

        Log.d("JADE_MONITOR", "getBlockedApps: unhandled type, returning emptySet")
        return emptySet()
    }
}
