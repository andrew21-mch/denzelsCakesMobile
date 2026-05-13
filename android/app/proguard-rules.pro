# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-keep class io.flutter.embedding.** { *; }

# Google Play Core (for dynamic delivery)
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# Stripe SDK
-keep class com.stripe.** { *; }
-keep class com.reactnativestripesdk.** { *; }
-dontwarn com.stripe.**
-dontwarn com.reactnativestripesdk.**

# HTTP and networking
-keep class okhttp3.** { *; }
-keep class retrofit2.** { *; }

# Gson serialization
-keepattributes Signature
-keepattributes *Annotation*
-keep class sun.misc.Unsafe { *; }
-keep class com.google.gson.stream.** { *; }

# Generic model classes
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# Image loading
-keep class com.bumptech.glide.** { *; }

# Connectivity
-keep class android.net.** { *; }

# Additional rules to prevent R8 issues
-dontwarn org.bouncycastle.**
-dontwarn org.conscrypt.**
-dontwarn org.openjsse.**

# Keep all native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep all enums
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}
