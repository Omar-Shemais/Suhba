# ✅ Flutter Local Notifications
-keep class com.dexterous.** { *; }
-keep class androidx.core.app.NotificationCompat** { *; }
-dontwarn com.dexterous.**

# ✅ Keep notification sounds and raw resources
-keepclassmembers class **.R$* {
    public static <fields>;
}

-keep class **.R$raw { *; }
-keep class **.R$drawable { *; }

# ✅ Timezone
-keep class net.iakovlev.timeshape.** { *; }
-dontwarn net.iakovlev.timeshape.**

# ✅ Just Audio
-keep class com.ryanheise.just_audio.** { *; }
-dontwarn com.ryanheise.just_audio.**

# ✅ Geolocator
-keep class com.baseflow.geolocator.** { *; }
-dontwarn com.baseflow.geolocator.**

# ✅ SharedPreferences
-keep class androidx.preference.** { *; }
-dontwarn androidx.preference.**

# ✅ Kotlin
-keep class kotlin.** { *; }
-keep class kotlin.Metadata { *; }
-dontwarn kotlin.**

# ✅ Kotlinx Coroutines
-keepnames class kotlinx.coroutines.internal.MainDispatcherFactory {}
-keepnames class kotlinx.coroutines.CoroutineExceptionHandler {}
-keepclassmembernames class kotlinx.** {
    volatile <fields>;
}

# ✅ General Android
-keep public class * extends android.app.Activity
-keep public class * extends android.app.Application
-keep public class * extends android.app.Service
-keep public class * extends android.content.BroadcastReceiver
-keep public class * extends android.content.ContentProvider

# ✅ Prevent obfuscation of notification classes
-keep class * extends androidx.core.app.NotificationCompat$Builder