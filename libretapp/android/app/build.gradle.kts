import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val qaSigning = System.getenv("LIBRETAPP_QA_SIGNING") == "true"
val keystorePropertiesFile = rootProject.file("key.properties")
val hasReleaseSigning = !qaSigning && keystorePropertiesFile.exists()
if (hasReleaseSigning) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}
val isReleaseTask = gradle.startParameter.taskNames.any {
    it.contains("release", ignoreCase = true)
}
if (isReleaseTask && !hasReleaseSigning && !qaSigning) {
    throw GradleException(
        "A private android/key.properties file is required for release builds."
    )
}

android {
    namespace = "app.libret"
    compileSdk = 36
    buildToolsVersion = "36.0.0"
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // Permanent pilot identity; changing it would break Android upgrades.
        applicationId = "app.libret"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        ndk {
            abiFilters += listOf("arm64-v8a", "armeabi-v7a", "x86_64")
        }
    }

    flavorDimensions += "distribution"
    productFlavors {
        create("standard") { dimension = "distribution" }
        create("connected") {
            dimension = "distribution"
            minSdk = 28
        }
        create("offline") {
            dimension = "distribution"
            // Current Isar/libmdbx rejects the older kernels found on Android
            // 7/8 devices. The store pilot requires the tested Android 9 floor.
            minSdk = 28
        }
    }

    externalNativeBuild {
        cmake {
            path = file("src/main/cpp/CMakeLists.txt")
        }
    }

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            if (qaSigning) {
                signingConfig = signingConfigs.getByName("debug")
            }
            // Release tasks require private upload signing above.
            if (hasReleaseSigning) {
                signingConfig = signingConfigs.getByName("release")
            }
        }
    }
}

dependencies {
    implementation("androidx.core:core-splashscreen:1.2.0")
    // Used by the independent six-hour weather alert worker.
    implementation("androidx.work:work-runtime:2.11.2")
}

flutter {
    source = "../.."
}
