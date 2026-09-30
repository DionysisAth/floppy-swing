# WorkManager (pulled in by Google Mobile Ads) creates its Room database by
# reflection at app start-up. Without these rules R8 strips the generated
# implementation's constructor and the app crashes on launch with
# "Failed to create an instance of androidx.work.impl.WorkDatabase".
-keep class * extends androidx.room.RoomDatabase { <init>(...); }
-keep class androidx.work.impl.** { *; }
-keep class androidx.room.** { *; }
