package app.libret

import android.Manifest
import android.app.AlarmManager
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import org.json.JSONObject
import androidx.work.Constraints
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.NetworkType
import androidx.work.WorkManager
import androidx.work.Worker
import androidx.work.WorkerParameters
import java.net.HttpURLConnection
import java.net.URL
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import java.util.concurrent.TimeUnit

class MainActivity : FlutterActivity() {
    @Volatile private var flutterFirstFrameReady = false

    override fun onCreate(savedInstanceState: Bundle?) {
        installSplashScreen().setKeepOnScreenCondition { !flutterFirstFrameReady }
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "libretapp/splash")
            .setMethodCallHandler { call, result ->
                if (call.method == "flutterReady") {
                    flutterFirstFrameReady = true
                    result.success(null)
                } else {
                    result.notImplemented()
                }
            }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "libretapp/lite_reminders")
            .setMethodCallHandler { call, result ->
                if (call.method == "exactAvailable") {
                    val alarm = getSystemService(Context.ALARM_SERVICE) as AlarmManager
                    result.success(Build.VERSION.SDK_INT < Build.VERSION_CODES.S || alarm.canScheduleExactAlarms())
                    return@setMethodCallHandler
                }
                if (call.method == "requestExactAccess") {
                    try {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                            startActivity(Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM).apply {
                                data = android.net.Uri.parse("package:$packageName")
                            })
                        }
                        result.success(null)
                    } catch (error: Exception) {
                        result.error("EXACT_ACCESS", error.message, null)
                    }
                    return@setMethodCallHandler
                }
                if (call.method != "replace") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                try {
                    val entries = call.argument<List<Map<String, Any?>>>("entries") ?: emptyList()
                    val array = JSONArray()
                    entries.forEach { entry ->
                        array.put(JSONObject().apply {
                            put("id", entry["id"] as String)
                            put("title", entry["title"] as String)
                            put("body", entry["body"] as String)
                            put("at", (entry["at"] as Number).toLong())
                        })
                    }
                    LiteReminderAlarms.replace(this, array)
                    result.success(null)
                } catch (error: Exception) {
                    result.error("REMINDERS", error.message, null)
                }
            }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "libretapp/weather_alerts")
            .setMethodCallHandler { call, result ->
                try {
                    when (call.method) {
                        "configure" -> {
                            WeatherAlertWork.configure(
                                this,
                                enabled = call.argument<Boolean>("enabled") == true,
                                workspaceId = call.argument<String>("workspaceId") ?: "",
                                latitude = call.argument<Double>("latitude") ?: 0.0,
                                longitude = call.argument<Double>("longitude") ?: 0.0,
                                experience = call.argument<String>("experience") ?: "complete",
                            )
                            result.success(null)
                        }
                        "cancel" -> {
                            WeatherAlertWork.cancel(this)
                            result.success(null)
                        }
                        else -> result.notImplemented()
                    }
                } catch (error: Exception) {
                    result.error("WEATHER_ALERTS", error.message, null)
                }
            }
    }
}

/** Weather notifications have their own periodic worker and Android channel. */
internal object WeatherAlertWork {
    private const val uniqueName = "libretapp.weather-alerts.v1"
    private const val storage = "weather_alerts_v1"
    private const val channelId = "weather_alerts_v1"

    fun configure(
        context: Context,
        enabled: Boolean,
        workspaceId: String,
        latitude: Double,
        longitude: Double,
        experience: String,
    ) {
        val prefs = context.getSharedPreferences(storage, Context.MODE_PRIVATE)
        if (!enabled || workspaceId.isBlank() || latitude !in -90.0..90.0 || longitude !in -180.0..180.0) {
            cancel(context)
            return
        }
        if (!prefs.edit().putBoolean("enabled", true)
                .putString("workspaceId", workspaceId)
                .putString("experience", experience)
                .putString("latitude", latitude.toString())
                .putString("longitude", longitude.toString()).commit()) {
            throw IllegalStateException("No se pudo guardar la configuración de avisos")
        }
        val request = androidx.work.PeriodicWorkRequest.Builder(
            WeatherCheckWorker::class.java,
            6,
            TimeUnit.HOURS,
        )
            .setConstraints(Constraints.Builder().setRequiredNetworkType(NetworkType.CONNECTED).build())
            .setInputData(androidx.work.Data.Builder().putString("workspaceId", workspaceId).build())
            .build()
        WorkManager.getInstance(context).enqueueUniquePeriodicWork(
            uniqueName,
            ExistingPeriodicWorkPolicy.KEEP,
            request,
        )
    }

    fun cancel(context: Context) {
        context.getSharedPreferences(storage, Context.MODE_PRIVATE).edit()
            .putBoolean("enabled", false).commit()
        WorkManager.getInstance(context).cancelUniqueWork(uniqueName)
    }

    fun channelId() = channelId
    fun storageName() = storage
}

class WeatherCheckWorker(context: Context, parameters: WorkerParameters) : Worker(context, parameters) {
    override fun doWork(): Result {
        val prefs = applicationContext.getSharedPreferences(WeatherAlertWork.storageName(), Context.MODE_PRIVATE)
        val workspaceId = inputData.getString("workspaceId") ?: return Result.success()
        if (!prefs.getBoolean("enabled", false) || prefs.getString("workspaceId", null) != workspaceId) {
            return Result.success()
        }
        if (Build.VERSION.SDK_INT >= 33 && applicationContext.checkSelfPermission(
                Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED) {
            return Result.success()
        }
        val latitude = prefs.getString("latitude", null)?.toDoubleOrNull() ?: return Result.success()
        val longitude = prefs.getString("longitude", null)?.toDoubleOrNull() ?: return Result.success()
        var connection: HttpURLConnection? = null
        return try {
            val query = "latitude=$latitude&longitude=$longitude&current=temperature_2m%2Cweather_code&timezone=auto"
            connection = (URL("https://api.open-meteo.com/v1/forecast?$query").openConnection() as HttpURLConnection).apply {
                requestMethod = "GET"
                connectTimeout = 10000
                readTimeout = 10000
            }
            if (connection.responseCode != 200) return Result.retry()
            val payload = JSONObject(connection.inputStream.bufferedReader().use { it.readText() })
            val current = payload.getJSONObject("current")
            val temperature = current.getDouble("temperature_2m")
            val weatherCode = current.getInt("weather_code")
            // Check configuration again in case the user changed spaces mid-request.
            if (!prefs.getBoolean("enabled", false) || prefs.getString("workspaceId", null) != workspaceId) {
                return Result.success()
            }
            val day = SimpleDateFormat("yyyy-MM-dd", Locale.US).format(Date())
            val conditions = mutableListOf<String>()
            if (temperature <= 10.0) conditions.add("cold")
            if (temperature >= 32.0) conditions.add("heat")
            if (weatherCode in setOf(65, 67, 82, 95, 96, 99)) conditions.add("rain")
            conditions.forEach { condition ->
                val sentKey = "sent:$workspaceId:$day:$condition"
                if (prefs.getBoolean(sentKey, false)) return@forEach
                notify(condition, prefs.getString("experience", "complete") == "lite")
                prefs.edit().putBoolean(sentKey, true).apply()
            }
            Result.success()
        } catch (_: Exception) {
            Result.retry()
        } finally {
            connection?.disconnect()
        }
    }

    private fun notify(condition: String, petsOnly: Boolean) {
        val manager = applicationContext.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            manager.createNotificationChannel(NotificationChannel(
                WeatherAlertWork.channelId(), "Avisos del clima", NotificationManager.IMPORTANCE_DEFAULT,
            ))
        }
        val title: String
        val body: String
        when (condition) {
            "cold" -> {
                title = "Se acerca el frío"
                body = if (petsOnly) "Abriga a tu mascota y procura que descanse en un lugar cálido." else "Protege a tus animales y mascotas; prepara un resguardo cálido."
            }
            "heat" -> {
                title = "Día de mucho calor"
                body = if (petsOnly) "Ofrece agua fresca y un lugar con sombra a tus mascotas." else "Asegura agua y sombra para tus animales y mascotas."
            }
            else -> {
                title = "Lluvia fuerte o tormenta"
                body = if (petsOnly) "Resguarda a tus mascotas y evita paseos durante la tormenta." else "Revisa resguardos y protege a tus animales y mascotas."
            }
        }
        val launch = applicationContext.packageManager.getLaunchIntentForPackage(applicationContext.packageName)
        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
            Notification.Builder(applicationContext, WeatherAlertWork.channelId())
        else Notification.Builder(applicationContext)
        if (launch != null) {
            builder.setContentIntent(PendingIntent.getActivity(applicationContext, condition.hashCode(), launch,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE))
        }
        manager.notify(condition.hashCode(), builder
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle(title)
            .setContentText(body)
            .setAutoCancel(true)
            .build())
    }
}

internal object LiteReminderAlarms {
    private const val storage = "lite_reminder_alarms"
    private const val key = "entries"
    private const val channelId = "lite_dates_v1"

    fun replace(context: Context, entries: JSONArray) {
        val prefs = context.getSharedPreferences(storage, Context.MODE_PRIVATE)
        val previous = JSONArray(prefs.getString(key, "[]"))
        for (i in 0 until previous.length()) cancel(context, previous.getJSONObject(i))
        if (!prefs.edit().putString(key, entries.toString()).commit()) {
            throw IllegalStateException("No se pudieron guardar los avisos")
        }
        scheduleAll(context, entries)
    }

    fun restore(context: Context) {
        val entries = JSONArray(context.getSharedPreferences(storage, Context.MODE_PRIVATE)
            .getString(key, "[]"))
        scheduleAll(context, entries)
    }

    private fun scheduleAll(context: Context, entries: JSONArray) {
        for (i in 0 until entries.length()) schedule(context, entries.getJSONObject(i))
    }

    private fun pending(context: Context, entry: JSONObject): PendingIntent {
        val id = entry.getString("id")
        val intent = Intent(context, LiteReminderReceiver::class.java).apply {
            action = "app.libret.LITE_REMINDER"
            data = android.net.Uri.parse("libretapp://reminder/$id")
            putExtra("id", id)
            putExtra("title", entry.getString("title"))
            putExtra("body", entry.optString("body"))
        }
        return PendingIntent.getBroadcast(context, id.hashCode(), intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
    }

    private fun cancel(context: Context, entry: JSONObject) {
        val alarm = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        alarm.cancel(pending(context, entry))
    }

    private fun schedule(context: Context, entry: JSONObject) {
        val at = entry.getLong("at")
        if (at <= System.currentTimeMillis()) return
        val alarm = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = pending(context, entry)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S && !alarm.canScheduleExactAlarms()) {
            alarm.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, at, intent)
        } else {
            try {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    alarm.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, at, intent)
                } else {
                    alarm.setExact(AlarmManager.RTC_WAKEUP, at, intent)
                }
            } catch (_: SecurityException) {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    alarm.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, at, intent)
                } else {
                    alarm.set(AlarmManager.RTC_WAKEUP, at, intent)
                }
            }
        }
    }

    fun notify(context: Context, intent: Intent) {
        if (Build.VERSION.SDK_INT >= 33 && context.checkSelfPermission(
                Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED) return
        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            manager.createNotificationChannel(NotificationChannel(channelId, "Mascotas y fechas",
                NotificationManager.IMPORTANCE_HIGH))
        }
        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
            Notification.Builder(context, channelId) else Notification.Builder(context)
        val launch = context.packageManager.getLaunchIntentForPackage(context.packageName)
        if (launch != null) {
            builder.setContentIntent(PendingIntent.getActivity(context,
                (intent.getStringExtra("id") ?: "").hashCode(), launch,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE))
        }
        val notification = builder
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle(intent.getStringExtra("title") ?: "Recordatorio")
            .setContentText(intent.getStringExtra("body") ?: "")
            .setAutoCancel(true)
            .build()
        manager.notify((intent.getStringExtra("id") ?: "").hashCode(), notification)
    }
}

class LiteReminderReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        LiteReminderAlarms.notify(context, intent)
    }
}

class LiteReminderBootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED ||
            intent.action == "android.intent.action.MY_PACKAGE_REPLACED") {
            LiteReminderAlarms.restore(context)
        }
    }
}
