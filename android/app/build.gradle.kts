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
        minSdk = 21  // Android 5.0+
        targetSdk = flutter.targetSdkVersion
        versionCode = 1
        versionName = "1.0.0"

        // Enable multidex for apps with >64K methods
        multiDexEnabled = true
    }

    buildTypes {
        release {
            // For production, you need to generate a keystore:
            // keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
            // Then create android/key.properties with:
            // storePassword=<password>
            // keyPassword=<password>
            // keyAlias=upload
            // storeFile=<path-to-keystore>

            // Using debug keys for testing APK
            signingConfig = signingConfigs.getByName("debug")

            // Shrink and optimize release build
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }

        debug {
            isDebuggable = true
        }
    }

    // Enable view binding
    buildFeatures {
        viewBinding = true
    }
}

flutter {
    source = "../.."
}
