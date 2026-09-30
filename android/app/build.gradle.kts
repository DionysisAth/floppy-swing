import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing: put your upload key's details in android/key.properties
// (never commit it). Without that file, release builds use the debug key,
// which is fine for testing but not for the Play Store. CI writes the file
// from repository secrets (see .github/workflows/build.yml).
val keyProperties = Properties().apply {
    val file = rootProject.file("key.properties")
    if (file.exists()) file.inputStream().use { load(it) }
}

// AdMob app id from assets/config/admob.json (Google's test id while it's
// empty). The ad unit ids in the same file are read by the Dart code.
val admobAppId: String = run {
    val json = rootProject.file("../assets/config/admob.json").readText()
    val android = Regex("\"android\"\\s*:\\s*\\{([^}]*)\\}").find(json)?.groupValues?.get(1).orEmpty()
    Regex("\"appId\"\\s*:\\s*\"([^\"]*)\"").find(android)?.groupValues?.get(1)?.trim().orEmpty()
        .ifEmpty { "ca-app-pub-3940256099942544~3347511713" }
}

android {
    namespace = "com.floppyswing.floppy_swing"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // flutter_local_notifications needs java.time on old Androids.
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        applicationId = "com.floppyswing.floppy_swing"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        manifestPlaceholders["admobAppId"] = admobAppId
    }

    signingConfigs {
        if (keyProperties.containsKey("storeFile")) {
            create("release") {
                storeFile = file(keyProperties.getProperty("storeFile"))
                storePassword = keyProperties.getProperty("storePassword")
                keyAlias = keyProperties.getProperty("keyAlias")
                keyPassword = keyProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.findByName("release") ?: signingConfigs.getByName("debug")
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Same version as the games_services plugin uses; needed here because
    // MainActivity starts the Play Games SDK itself (see AndroidManifest.xml).
    implementation("com.google.android.gms:play-services-games-v2:21.0.0")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
