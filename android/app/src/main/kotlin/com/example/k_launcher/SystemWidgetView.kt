package com.example.k_launcher

import android.appwidget.AppWidgetHost
import android.appwidget.AppWidgetHostView
import android.appwidget.AppWidgetManager
import android.content.Context
import android.util.Log
import android.view.View
import io.flutter.plugin.platform.PlatformView

class SystemWidgetView(
    context: Context,
    id: Int,
    creationParams: Map<String?, Any?>?
) : PlatformView {
    
    companion object {
        private const val TAG = "SystemWidgetView"
        private const val WIDGET_HOST_ID = 1024
    }
    
    private val appWidgetManager: AppWidgetManager = AppWidgetManager.getInstance(context)
    private val appWidgetHost: AppWidgetHost = AppWidgetHost(context, WIDGET_HOST_ID)
    private var hostView: AppWidgetHostView? = null
    
    init {
        try {
            val widgetId = creationParams?.get("widgetId") as? Int
            val width = creationParams?.get("width") as? Int ?: 200
            val height = creationParams?.get("height") as? Int ?: 200
            
            if (widgetId != null) {
                createWidgetView(context, widgetId, width, height)
            } else {
                Log.e(TAG, "Widget ID is null")
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error creating SystemWidgetView", e)
        }
    }
    
    private fun createWidgetView(context: Context, widgetId: Int, width: Int, height: Int) {
        try {
            val widgetInfo = appWidgetManager.getAppWidgetInfo(widgetId)
            if (widgetInfo != null) {
                hostView = appWidgetHost.createView(context, widgetId, widgetInfo)
                hostView?.setAppWidget(widgetId, widgetInfo)
                
                // Configurar el tamaño
                hostView?.measure(
                    View.MeasureSpec.makeMeasureSpec(width, View.MeasureSpec.EXACTLY),
                    View.MeasureSpec.makeMeasureSpec(height, View.MeasureSpec.EXACTLY)
                )
                hostView?.layout(0, 0, width, height)
                
                Log.d(TAG, "Widget view created successfully for ID: $widgetId")
            } else {
                Log.e(TAG, "Widget info is null for ID: $widgetId")
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error creating widget view for ID: $widgetId", e)
        }
    }
    
    override fun getView(): View? {
        return hostView
    }
    
    override fun dispose() {
        try {
            hostView = null
        } catch (e: Exception) {
            Log.e(TAG, "Error disposing SystemWidgetView", e)
        }
    }
}