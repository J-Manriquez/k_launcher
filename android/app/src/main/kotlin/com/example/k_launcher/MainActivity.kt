package com.example.k_launcher

import android.app.AppOpsManager
import android.content.Context
import android.content.Intent
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
    private val OVERLAY_PERMISSION_REQUEST = 1001
    private val USAGE_STATS_REQUEST = 1002
    private val WRITE_SETTINGS_REQUEST = 1003
    private val STORAGE_MANAGEMENT_REQUEST = 1004
    private val NOTIFICATION_REQUEST = 1005
    
    private lateinit var appListService: AppListService
    
    companion object {
        var instance: MainActivity? = null
    }
    
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        instance = this
        appListService = AppListService(this)
        
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
        val intent = Intent(Settings.ACTION_HOME_SETTINGS)
        startActivity(intent)
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
}
