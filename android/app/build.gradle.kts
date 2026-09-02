plugins {
    id("com.android.application")
    id("com.google.gms.google-services")

    // Flutter Gradle Plugin
    // debe aplicarse después de Android y Kotlin
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.ticketpromobile"

    // ============================================================
    // ANDROID SDK
    // ============================================================

    compileSdk = 37

    ndkVersion = flutter.ndkVersion

    // ============================================================
    // JAVA
    // ============================================================

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    // ============================================================
    // CONFIGURACIÓN DE LA APP
    // ============================================================

    defaultConfig {
        applicationId = "com.example.ticketpromobile"

        minSdk = flutter.minSdkVersion

        targetSdk = 37

        versionCode = flutter.versionCode

        versionName = flutter.versionName
    }

    // ============================================================
    // BUILD TYPES
    // ============================================================

    buildTypes {
        release {
            // Por ahora usamos la firma de debug
            // para poder ejecutar release.
            signingConfig =
                signingConfigs.getByName("debug")
        }
    }
}

// ================================================================
// KOTLIN
// ================================================================

kotlin {
    compilerOptions {
        jvmTarget =
            org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

// ================================================================
// FLUTTER
// ================================================================

flutter {
    source = "../.."
}