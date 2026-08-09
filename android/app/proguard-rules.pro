# Mengabaikan error missing classes pada TensorFlow Lite (digunakan oleh ML Kit)
-dontwarn org.tensorflow.lite.**
-keep class org.tensorflow.lite.** { *; }
-keepclassmembers class org.tensorflow.lite.** { *; }

# Tambahan: Mengabaikan warning Google ML Kit secara umum
-dontwarn com.google.mlkit.**
-keep class com.google.mlkit.** { *; }