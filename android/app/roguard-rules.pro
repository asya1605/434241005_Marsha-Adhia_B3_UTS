# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Kotlin
-keep class kotlin.** { *; }
-keep class kotlinx.** { *; }

# Kotlin Serialization
-keep class kotlinx.serialization.** { *; }
-dontwarn kotlinx.serialization.**

# Supabase
-keep class io.supabase.** { *; }
-dontwarn io.supabase.**

# Gson
-keep class com.google.gson.** { *; }
-dontwarn com.google.gson.**

# Keep annotations
-keepattributes *Annotation*

# Keep model classes
-keep class com.example.helpdesk_ticket.** { *; }

# Prevent warnings
-dontwarn org.jetbrains.annotations.**
-dontwarn kotlin.**