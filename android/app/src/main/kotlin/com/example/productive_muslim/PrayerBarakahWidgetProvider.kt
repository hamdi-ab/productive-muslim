package com.example.productive_muslim

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class PrayerBarakahWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.prayer_barakah_widget).apply {
                val appTitle = widgetData.getString("widget_app_title", "Productive Muslim")
                val activeSlot = widgetData.getString("widget_active_slot", "Barakah Window")
                val hijriDate = widgetData.getString("widget_hijri_date", "")
                val fastingBadge = widgetData.getString("widget_fasting_badge", "")
                val nextPrayerLabel = widgetData.getString("widget_next_prayer_label", "Next Prayer")
                val nextPrayerName = widgetData.getString("widget_next_prayer_name", "Fajr")
                val nextPrayerTime = widgetData.getString("widget_next_prayer_time", "--:--")
                val nextPrayerCountdown = widgetData.getString("widget_next_prayer_countdown", "")
                val dhikrCount = widgetData.getString("widget_dhikr_count", "Dhikr: 0")
                val btnPrayers = widgetData.getString("widget_btn_prayers", "Prayers")
                val btnAdhkar = widgetData.getString("widget_btn_adhkar", "Adhkar")
                val btnFocus = widgetData.getString("widget_btn_focus", "Focus")
                val btnPlusOne = widgetData.getString("widget_btn_plus_one", "+1")

                setTextViewText(R.id.widget_app_title, appTitle)
                setTextViewText(R.id.widget_active_slot, activeSlot)
                setTextViewText(R.id.widget_next_prayer_label, nextPrayerLabel)
                setTextViewText(R.id.widget_next_prayer_name, nextPrayerName)
                setTextViewText(R.id.widget_next_prayer_time, nextPrayerTime)
                setTextViewText(R.id.widget_next_prayer_countdown, nextPrayerCountdown)
                setTextViewText(R.id.widget_dhikr_count, dhikrCount)
                setTextViewText(R.id.widget_action_prayer, btnPrayers)
                setTextViewText(R.id.widget_action_adhkar, btnAdhkar)
                setTextViewText(R.id.widget_action_focus, btnFocus)
                setTextViewText(R.id.widget_btn_plus_one, btnPlusOne)

                if (hijriDate.isNullOrEmpty() && fastingBadge.isNullOrEmpty()) {
                    setViewVisibility(R.id.widget_hijri_badge, View.GONE)
                } else {
                    setViewVisibility(R.id.widget_hijri_badge, View.VISIBLE)
                    val badgeText = when {
                        !hijriDate.isNullOrEmpty() && !fastingBadge.isNullOrEmpty() -> "$hijriDate • $fastingBadge"
                        !hijriDate.isNullOrEmpty() -> hijriDate
                        else -> fastingBadge
                    }
                    setTextViewText(R.id.widget_hijri_badge, badgeText)
                }

                // Root Container Deep Link
                val mainPendingIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java,
                    Uri.parse("productivemuslim://home")
                )
                setOnClickPendingIntent(R.id.widget_container, mainPendingIntent)

                // Hijri / Fasting Action Deep Link
                val fastingPendingIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java,
                    Uri.parse("productivemuslim://fasting")
                )
                setOnClickPendingIntent(R.id.widget_hijri_badge, fastingPendingIntent)

                // Prayer Times Action Deep Link
                val prayerPendingIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java,
                    Uri.parse("productivemuslim://prayer_times")
                )
                setOnClickPendingIntent(R.id.widget_action_prayer, prayerPendingIntent)

                // Adhkar Action Deep Link
                val adhkarPendingIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java,
                    Uri.parse("productivemuslim://adhkar")
                )
                setOnClickPendingIntent(R.id.widget_action_adhkar, adhkarPendingIntent)
                setOnClickPendingIntent(R.id.widget_dhikr_count, adhkarPendingIntent)

                // Interactive Direct +1 Background Broadcast Intent
                val backgroundPlusOneIntent = HomeWidgetBackgroundIntent.getBroadcast(
                    context,
                    Uri.parse("productivemuslim://increment_tasbih")
                )
                setOnClickPendingIntent(R.id.widget_btn_plus_one, backgroundPlusOneIntent)

                // Focus Action Deep Link
                val focusPendingIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java,
                    Uri.parse("productivemuslim://focus")
                )
                setOnClickPendingIntent(R.id.widget_action_focus, focusPendingIntent)
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
