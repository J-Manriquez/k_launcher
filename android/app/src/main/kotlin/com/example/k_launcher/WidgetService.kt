package com.example.k_launcher

import android.appwidget.AppWidgetHost
import android.appwidget.AppWidgetHostView
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProviderInfo
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.util.Base64
import android.util.Log
import android.view.View
import org.json.JSONArray
import org.json.JSONObject
import java.io.ByteArrayOutputStream

class WidgetService(private val context: Context) {
    
    companion object {
        private const val TAG = "WidgetService"
        private const val WIDGET_HOST_ID = 1024
    }
    
    private val appWidgetManager: AppWidgetManager = AppWidgetManager.getInstance(context)
    private val appWidgetHost: AppWidgetHost = AppWidgetHost(context, WIDGET_HOST_ID)
    
    private fun drawableToBase64(drawable: android.graphics.drawable.Drawable): String {
        return try {
            val width = if (drawable.intrinsicWidth > 0) drawable.intrinsicWidth else 48
            val height = if (drawable.intrinsicHeight > 0) drawable.intrinsicHeight else 48
            
            val bitmap = Bitmap.createBitmap(
                width,
                height,
                Bitmap.Config.ARGB_8888
            )
            val canvas = Canvas(bitmap)
            drawable.setBounds(0, 0, width, height)
            
            // Manejar diferentes tipos de drawable de forma segura
            try {
                drawable.draw(canvas)
            } catch (e: Exception) {
                Log.w(TAG, "Error drawing icon, using fallback", e)
                // Crear un icono de fallback simple
                canvas.drawColor(android.graphics.Color.GRAY)
            }
            
            bitmapToBase64(bitmap)
        } catch (e: Exception) {
            Log.e(TAG, "Error converting drawable to base64", e)
            // Retornar un string base64 vacío
            ""
        }
    }
    
    // Obtener todas las aplicaciones que tienen widgets
    fun getAppsWithWidgets(): List<Map<String, Any>> {
        val packageManager = context.packageManager
        val installedWidgets = appWidgetManager.installedProviders
        val appsWithWidgets = mutableMapOf<String, MutableMap<String, Any>>()
        
        for (widgetInfo in installedWidgets) {
            val packageName = widgetInfo.provider.packageName
            
            try {
                val appInfo = packageManager.getApplicationInfo(packageName, 0)
                val appName = packageManager.getApplicationLabel(appInfo).toString()
                
                // Obtener icono de forma segura
                val iconBase64 = try {
                    val appIcon = packageManager.getApplicationIcon(appInfo)
                    drawableToBase64(appIcon)
                } catch (e: Exception) {
                    Log.w(TAG, "Error getting icon for $packageName, using empty icon", e)
                    "" // Icono vacío en caso de error
                }
                
                if (!appsWithWidgets.containsKey(packageName)) {
                    appsWithWidgets[packageName] = mutableMapOf(
                        "appName" to appName,
                        "packageName" to packageName,
                        "icon" to iconBase64,
                        "widgets" to mutableListOf<Map<String, Any>>()
                    )
                }
                
                val widgetData = mapOf<String, Any>(
                    "widgetId" to widgetInfo.provider.className,
                    "widgetName" to (widgetInfo.loadLabel(packageManager)?.toString() ?: "Widget"),
                    "minWidth" to widgetInfo.minWidth,
                    "minHeight" to widgetInfo.minHeight,
                    "minResizeWidth" to widgetInfo.minResizeWidth,
                    "minResizeHeight" to widgetInfo.minResizeHeight,
                    "resizeMode" to widgetInfo.resizeMode,
                    "provider" to widgetInfo.provider.flattenToString()
                )
                
                @Suppress("UNCHECKED_CAST")
                (appsWithWidgets[packageName]!!["widgets"] as MutableList<Map<String, Any>>).add(widgetData)
                
            } catch (e: Exception) {
                Log.e(TAG, "Error getting app info for package: $packageName", e)
                // Continuar con el siguiente widget en lugar de fallar completamente
                continue
            }
        }
        
        return appsWithWidgets.values.toList().sortedBy { it["appName"] as String }
    }
    
    // Crear una instancia de widget
    fun createWidget(providerName: String, width: Int, height: Int): Map<String, Any>? {
        try {
            val provider = ComponentName.unflattenFromString(providerName)
            if (provider == null) {
                Log.e(TAG, "Invalid provider name: $providerName")
                return null
            }
            
            val widgetId = appWidgetHost.allocateAppWidgetId()
            val canBind = appWidgetManager.bindAppWidgetIdIfAllowed(widgetId, provider)
            
            if (!canBind) {
                Log.w(TAG, "Cannot bind widget, requesting permission")
                
                val intent = Intent(AppWidgetManager.ACTION_APPWIDGET_BIND)
                intent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, widgetId)
                intent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_PROVIDER, provider)
                
                if (context is MainActivity) {
                    context.requestWidgetBindPermission(intent, widgetId)
                }
                
                return mapOf(
                    "widgetId" to widgetId,
                    "requiresPermission" to true,
                    "provider" to providerName
                )
            }
            
            // Iniciar el host de widgets si no está iniciado
            startListening()
            
            val widgetInfo = appWidgetManager.getAppWidgetInfo(widgetId)
            
            // Calcular dimensiones en módulos del grid basado en el tamaño mínimo del widget
            val displayMetrics = context.resources.displayMetrics
            val density = displayMetrics.density
            
            // Convertir dp a píxeles
            val minWidthPx = (widgetInfo?.minWidth ?: 250).toDouble() 
            val minHeightPx = (widgetInfo?.minHeight ?: 250).toDouble()
            
            // Calcular cuántos módulos necesita (asumiendo módulos de ~100dp)
            val moduleSize = (100 * density).toDouble() // 100dp en píxeles
            val gridWidth = Math.max(1, Math.ceil(minWidthPx / moduleSize).toInt())
            val gridHeight = Math.max(1, Math.ceil(minHeightPx / moduleSize).toInt())
            
            return mapOf(
                "widgetId" to widgetId,
                "width" to (gridWidth * moduleSize).toInt(),
                "height" to (gridHeight * moduleSize).toInt(),
                "gridWidth" to gridWidth,
                "gridHeight" to gridHeight,
                "provider" to providerName,
                "requiresPermission" to false,
                "minWidth" to minWidthPx.toInt(),
                "minHeight" to minHeightPx.toInt(),
                "nativeMinWidth" to (widgetInfo?.minWidth ?: 250),
                "nativeMinHeight" to (widgetInfo?.minHeight ?: 250)
            )
            
        } catch (e: Exception) {
            Log.e(TAG, "Error creating widget: $providerName", e)
            return null
        }
    }
    
    // Actualizar widget existente
    fun updateWidget(widgetId: Int, width: Int, height: Int): String? {
        try {
            val widgetInfo = appWidgetManager.getAppWidgetInfo(widgetId)
            if (widgetInfo == null) {
                Log.e(TAG, "Widget info not found for ID: $widgetId")
                return null
            }
            
            val hostView = appWidgetHost.createView(context, widgetId, widgetInfo)
            hostView.setAppWidget(widgetId, widgetInfo)
            
            hostView.measure(
                View.MeasureSpec.makeMeasureSpec(width, View.MeasureSpec.EXACTLY),
                View.MeasureSpec.makeMeasureSpec(height, View.MeasureSpec.EXACTLY)
            )
            hostView.layout(0, 0, width, height)
            
            val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
            val canvas = Canvas(bitmap)
            hostView.draw(canvas)
            
            return bitmapToBase64(bitmap)
            
        } catch (e: Exception) {
            Log.e(TAG, "Error updating widget: $widgetId", e)
            return null
        }
    }
    
    // Eliminar widget
    fun deleteWidget(widgetId: Int): Boolean {
        return try {
            appWidgetHost.deleteAppWidgetId(widgetId)
            true
        } catch (e: Exception) {
            Log.e(TAG, "Error deleting widget: $widgetId", e)
            false
        }
    }
    
    // Iniciar el host de widgets
    fun startListening() {
        try {
            appWidgetHost.startListening()
        } catch (e: Exception) {
            Log.e(TAG, "Error starting widget host", e)
        }
    }
    
    // Detener el host de widgets
    fun stopListening() {
        try {
            appWidgetHost.stopListening()
        } catch (e: Exception) {
            Log.e(TAG, "Error stopping widget host", e)
        }
    }
    
    private fun bitmapToBase64(bitmap: Bitmap): String {
        return try {
            val byteArrayOutputStream = ByteArrayOutputStream()
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, byteArrayOutputStream)
            val byteArray = byteArrayOutputStream.toByteArray()
            // Usar NO_WRAP para evitar caracteres de nueva línea
            Base64.encodeToString(byteArray, Base64.NO_WRAP)
        } catch (e: Exception) {
            Log.e(TAG, "Error converting bitmap to base64", e)
            "" // Retornar string vacío en caso de error
        }
    }
}