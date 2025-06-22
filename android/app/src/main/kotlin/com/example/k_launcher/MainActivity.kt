package com.example.k_launcher

import android.app.AppOpsManager
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.content.pm.ResolveInfo
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.example.k_launcher.AppListService

class MainActivity : FlutterActivity() {
    private val PERMISSIONS_CHANNEL = "k_launcher/permissions"
    private val LAUNCHER_CHANNEL = "k_launcher/launcher"
    private val WIDGET_CHANNEL = "k_launcher/widgets" // Nuevo canal
    private val OVERLAY_PERMISSION_REQUEST = 1001
    private val USAGE_STATS_REQUEST = 1002
    private val WRITE_SETTINGS_REQUEST = 1003
    private val STORAGE_MANAGEMENT_REQUEST = 1004
    private val NOTIFICATION_REQUEST = 1005
    private val WIDGET_BIND_REQUEST = 1006
    private var pendingWidgetId: Int? = null
    private var pendingWidgetProvider: String? = null
    
    private lateinit var appListService: AppListService
    private lateinit var widgetService: WidgetService // Nuevo servicio
    
    companion object {
        var instance: MainActivity? = null
    }
    
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        instance = this
        appListService = AppListService(this)
        widgetService = WidgetService(this)
        
        // Registrar la vista de plataforma para widgets
        flutterEngine
            .platformViewsController
            .registry
            .registerViewFactory("system_widget_view", SystemWidgetViewFactory())
        
        // Canal para permisos
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, PERMISSIONS_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "hasUsageStatsPermission" -> {
                    result.success(hasUsageStatsPermission())
                }
                "canDrawOverlays" -> {
                    result.success(canDrawOverlays())
                }
                "canWriteSettings" -> {
                    result.success(canWriteSettings())
                }
                "hasStorageManagementPermission" -> {
                    result.success(hasStorageManagementPermission())
                }
                "requestUsageStatsPermission" -> {
                    requestUsageStatsPermission()
                    result.success(null)
                }
                "requestOverlayPermission" -> {
                    requestOverlayPermission()
                    result.success(null)
                }
                "requestWriteSettingsPermission" -> {
                    requestWriteSettingsPermission()
                    result.success(null)
                }
                "requestStorageManagementPermission" -> {
                    requestStorageManagementPermission()
                    result.success(null)
                }
                "requestNotificationPermission" -> {
                    requestNotificationPermission()
                    result.success(null)
                }
                "setAsDefaultLauncher" -> {
                    setAsDefaultLauncher()
                    result.success(null)
                }
                "isDefaultLauncher" -> {
                    result.success(isDefaultLauncher())
                }
                "resetDefaultLauncher" -> {
                    resetDefaultLauncher()
                    result.success(null)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
        
        // Canal para el launcher
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, LAUNCHER_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getInstalledApps" -> {
                    try {
                        val apps = appListService.getInstalledApps()
                        result.success(apps)
                    } catch (e: Exception) {
                        result.error("ERROR", "Error getting installed apps: ${e.message}", null)
                    }
                }
                "loadAppsFromSystem" -> {
                    try {
                        val apps = appListService.loadAppsFromSystem()
                        result.success(apps)
                    } catch (e: Exception) {
                        result.error("ERROR", "Error loading apps from system: ${e.message}", null)
                    }
                }
                "launchApp" -> {
                    val packageName = call.argument<String>("packageName")
                    if (packageName != null) {
                        launchApp(packageName, result)
                    } else {
                        result.error("INVALID_ARGUMENT", "Package name is required", null)
                    }
                }
                "openAppInfo" -> {
                    val packageName = call.argument<String>("packageName")
                    if (packageName != null) {
                        openAppInfo(packageName, result)
                    } else {
                        result.error("INVALID_ARGUMENT", "Package name is required", null)
                    }
                }
                "updateAppState" -> {
                    val packageName = call.argument<String>("packageName")
                    val isEnabled = call.argument<Boolean>("isEnabled")
                    if (packageName != null && isEnabled != null) {
                        appListService.updateAppState(packageName, isEnabled)
                        result.success(null)
                    } else {
                        result.error("INVALID_ARGUMENT", "Package name and enabled state are required", null)
                    }
                }
                "getLastUpdateDate" -> {
                    result.success(appListService.getLastUpdateDate())
                }
                "getEnabledPackages" -> {
                    result.success(appListService.getEnabledPackages().toList())
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
        
        // Nuevo canal para widgets
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, WIDGET_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getAppsWithWidgets" -> {
                    try {
                        val apps = widgetService.getAppsWithWidgets()
                        result.success(apps)
                    } catch (e: Exception) {
                        result.error("ERROR", "Error getting apps with widgets: ${e.message}", null)
                    }
                }
                "createWidget" -> {
                    val providerName = call.argument<String>("providerName")
                    val width = call.argument<Int>("width")
                    val height = call.argument<Int>("height")
                    if (providerName != null && width != null && height != null) {
                        try {
                            val widget = widgetService.createWidget(providerName, width, height)
                            result.success(widget)
                        } catch (e: Exception) {
                            result.error("ERROR", "Error creating widget: ${e.message}", null)
                        }
                    } else {
                        result.error("INVALID_ARGUMENT", "Provider name, width and height are required", null)
                    }
                }
                "updateWidget" -> {
                    val widgetId = call.argument<Int>("widgetId")
                    val width = call.argument<Int>("width")
                    val height = call.argument<Int>("height")
                    if (widgetId != null && width != null && height != null) {
                        try {
                            val image = widgetService.updateWidget(widgetId, width, height)
                            result.success(image)
                        } catch (e: Exception) {
                            result.error("ERROR", "Error updating widget: ${e.message}", null)
                        }
                    } else {
                        result.error("INVALID_ARGUMENT", "Widget ID, width and height are required", null)
                    }
                }
                "deleteWidget" -> {
                    val widgetId = call.argument<Int>("widgetId")
                    if (widgetId != null) {
                        try {
                            val success = widgetService.deleteWidget(widgetId)
                            result.success(success)
                        } catch (e: Exception) {
                            result.error("ERROR", "Error deleting widget: ${e.message}", null)
                        }
                    } else {
                        result.error("INVALID_ARGUMENT", "Widget ID is required", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
    
    fun notifyAppListUpdated() {
        // Método llamado desde AppListService para notificar actualizaciones
        // Aquí puedes agregar lógica adicional si es necesario
    }
    
    private fun launchApp(packageName: String, result: MethodChannel.Result) {
        try {
            val intent = packageManager.getLaunchIntentForPackage(packageName)
            if (intent != null) {
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                startActivity(intent)
                result.success(null)
            } else {
                result.error("APP_NOT_FOUND", "No launch intent found for package: $packageName", null)
            }
        } catch (e: Exception) {
            result.error("LAUNCH_ERROR", "Error launching app: ${e.message}", null)
        }
    }
    
    private fun openAppInfo(packageName: String, result: MethodChannel.Result) {
        try {
            val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
            intent.data = Uri.parse("package:$packageName")
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            startActivity(intent)
            result.success(null)
        } catch (e: Exception) {
            result.error("SETTINGS_ERROR", "Error opening app settings: ${e.message}", null)
        }
    }

    private fun hasUsageStatsPermission(): Boolean {
        val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            appOps.unsafeCheckOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                android.os.Process.myUid(),
                packageName
            )
        } else {
            appOps.checkOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                android.os.Process.myUid(),
                packageName
            )
        }
        return mode == AppOpsManager.MODE_ALLOWED
    }

    private fun canDrawOverlays(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            Settings.canDrawOverlays(this)
        } else {
            true
        }
    }

    private fun canWriteSettings(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            Settings.System.canWrite(this)
        } else {
            true
        }
    }

    private fun requestUsageStatsPermission() {
        val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
        startActivityForResult(intent, USAGE_STATS_REQUEST)
    }

    private fun requestOverlayPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val intent = Intent(
                Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                Uri.parse("package:$packageName")
            )
            startActivityForResult(intent, OVERLAY_PERMISSION_REQUEST)
        }
    }

    private fun requestWriteSettingsPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val intent = Intent(
                Settings.ACTION_MANAGE_WRITE_SETTINGS,
                Uri.parse("package:$packageName")
            )
            startActivityForResult(intent, WRITE_SETTINGS_REQUEST)
        }
    }

    private fun setAsDefaultLauncher() {
        try {
            // Crear intent para abrir configuración de launcher por defecto
            val intent = Intent(Settings.ACTION_HOME_SETTINGS)
            startActivity(intent)
        } catch (e: Exception) {
            // Si no funciona, intentar con intent alternativo
            try {
                val intent = Intent("android.settings.HOME_SETTINGS")
                startActivity(intent)
            } catch (e2: Exception) {
                // Como último recurso, abrir configuraciones de aplicaciones
                val intent = Intent(Settings.ACTION_MANAGE_DEFAULT_APPS_SETTINGS)
                startActivity(intent)
            }
        }
    }
    
    private fun isDefaultLauncher(): Boolean {
        return try {
            val intent = Intent(Intent.ACTION_MAIN)
            intent.addCategory(Intent.CATEGORY_HOME)
            val resolveInfo = packageManager.resolveActivity(intent, PackageManager.MATCH_DEFAULT_ONLY)
            val currentHomePackage = resolveInfo?.activityInfo?.packageName
            currentHomePackage == packageName
        } catch (e: Exception) {
            false
        }
    }
    
    private fun resetDefaultLauncher() {
        try {
            // Limpiar preferencias de launcher por defecto
            val intent = Intent(Settings.ACTION_HOME_SETTINGS)
            startActivity(intent)
        } catch (e: Exception) {
            // Fallback: abrir configuraciones de aplicaciones
            val intent = Intent(Settings.ACTION_MANAGE_DEFAULT_APPS_SETTINGS)
            startActivity(intent)
        }
    }
    
    private fun hasStorageManagementPermission(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            android.os.Environment.isExternalStorageManager()
        } else {
            true
        }
    }
    
    private fun requestStorageManagementPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            try {
                val intent = Intent(Settings.ACTION_MANAGE_APP_ALL_FILES_ACCESS_PERMISSION)
                intent.data = Uri.parse("package:$packageName")
                startActivityForResult(intent, STORAGE_MANAGEMENT_REQUEST)
            } catch (e: Exception) {
                val intent = Intent(Settings.ACTION_MANAGE_ALL_FILES_ACCESS_PERMISSION)
                startActivityForResult(intent, STORAGE_MANAGEMENT_REQUEST)
            }
        }
    }
    
    private fun requestNotificationPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            // Para Android 13+, el permiso POST_NOTIFICATIONS se maneja automáticamente
            // por permission_handler, pero podemos abrir configuraciones si es necesario
            val intent = Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS)
            intent.putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
            startActivityForResult(intent, NOTIFICATION_REQUEST)
        } else {
            // Para versiones anteriores, abrir configuraciones de notificación
            val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
            intent.data = Uri.parse("package:$packageName")
            startActivityForResult(intent, NOTIFICATION_REQUEST)
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        instance = null
    }

    fun requestWidgetBindPermission(intent: Intent, widgetId: Int) {
        pendingWidgetId = widgetId
        pendingWidgetProvider = intent.getParcelableExtra<ComponentName>(AppWidgetManager.EXTRA_APPWIDGET_PROVIDER)?.flattenToString()
        startActivityForResult(intent, WIDGET_BIND_REQUEST)
    }
    
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        
        when (requestCode) {
            OVERLAY_PERMISSION_REQUEST -> {
                // Handle overlay permission result
            }
            USAGE_STATS_REQUEST -> {
                // Handle usage stats permission result
            }
            WRITE_SETTINGS_REQUEST -> {
                // Handle write settings permission result
            }
            STORAGE_MANAGEMENT_REQUEST -> {
                // Handle storage management permission result
            }
            NOTIFICATION_REQUEST -> {
                // Handle notification permission result
            }
            WIDGET_BIND_REQUEST -> {
                if (resultCode == RESULT_OK && pendingWidgetId != null && pendingWidgetProvider != null) {
                    // Widget permission granted, notify Flutter
                    val result = mapOf(
                        "success" to true,
                        "widgetId" to pendingWidgetId!!
                    )
                    // You can send this result back to Flutter via MethodChannel if needed
                }
                // Clear pending data
                pendingWidgetId = null
                pendingWidgetProvider = null
            }
        }
    }
    
    override fun onResume() {
        super.onResume()
        // Iniciar el host de widgets
        widgetService.startListening()
    }
    
    override fun onPause() {
        super.onPause()
        // Detener el host de widgets
        widgetService.stopListening()
    }
}
