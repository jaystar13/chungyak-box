# Flutter embedding and plugins
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugins.** { *; }

# Play Core 관련 참조 무시
-dontwarn com.google.android.play.core.**
-dontwarn com.google.android.play.core.splitcompat.**
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**

# Firebase / Google Ads
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-keepattributes *Annotation*