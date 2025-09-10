# Keep all TensorFlow Lite classes and inner classes
-keep class org.tensorflow.lite.** { *; }
-keepclassmembers class org.tensorflow.lite.** { *; }

# Keep GPU delegate and inner classes (including $Options)
-keep class org.tensorflow.lite.gpu.** { *; }
-keepclassmembers class org.tensorflow.lite.gpu.** { *; }

# Keep all enums (sometimes GPU delegate uses enums internally)
-keepclassmembers enum * { *; }

# Keep all annotations (used by TFLite)
-keepattributes *Annotation*

# Keep everything referenced by reflection
-keepnames class org.tensorflow.lite.** { *; }
-keepclassmembers class * {
    @org.tensorflow
}