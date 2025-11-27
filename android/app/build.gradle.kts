plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.carqr.parking"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.carqr.parking"
        minSdk = 21
        targetSdk = flutter.targetSdkVersion
        versionCode = 1
        versionName = "1.0.0"

        multiDexEnabled = true
    }

    buildTypes {
        release {
            // Use debug keystore temporarily
            signingConfig = signingConfigs.getByName("debug")

            // COMPLETELY disable R8 to avoid Play Core issues
            isMinifyEnabled = false
            isShrinkResources = false
        }

        debug {
            isDebuggable = true
        }
    }

    buildFeatures {
        viewBinding = true
    }
}

/**
 * Add Play Core library so SplitInstallManager and related classes exist.
 * Using core-ktx which includes all necessary classes without duplicates.
 */
dependencies {
    implementation("com.google.android.play:core-ktx:1.8.1")
}

flutter {
    source = "../.."
}
