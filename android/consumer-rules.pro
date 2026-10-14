# Galeria reads these public APIs across React Native's old/new radius resolver signatures.
-keepclassmembers,allowoptimization class com.facebook.react.uimanager.LengthPercentage {
    public *** resolve(...);
}
-keepclassmembers,allowoptimization class com.facebook.react.uimanager.style.CornerRadii {
    public float getHorizontal();
}
