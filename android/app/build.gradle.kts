plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

import java.io.FileInputStream
import java.util.Properties
import org.gradle.api.tasks.bundling.Zip

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
val hasReleaseKeystore = keystorePropertiesFile.exists()
if (hasReleaseKeystore) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.nutriz.app"
    // Keep this explicit to avoid relying on Flutter defaults.
    // Some plugins now require API 36+ for resource linking.
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.nutriz.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        // Target can be bumped separately; keep stable for now.
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseKeystore) {
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
            // For Play Store, you must sign with an upload/release key (android/key.properties).
            // Fallback to debug signing only when building locally without a keystore.
            signingConfig = signingConfigs.getByName(if (hasReleaseKeystore) "release" else "debug")
            // Generate native symbols zip for Play Console (ANR/crash symbolication).
//            ndk {
//                debugSymbolLevel = "SYMBOL_TABLE"
//            }
        }
    }

    packaging {
        jniLibs {
            // Workaround for environments where stripDebugSymbols fails on some .so files.
            keepDebugSymbols += "**/*.so"
        }
    }

    lint {
        checkReleaseBuilds = false
        abortOnError = false
    }
}

flutter {
    source = "../.."
}

// tasks.register<Zip>("bundleReleaseNativeSymbols") {
//     dependsOn("stripReleaseDebugSymbols")
//     from(layout.buildDirectory.dir("intermediates/merged_native_libs/release/mergeReleaseNativeLibs/out/lib"))
//     destinationDirectory.set(layout.buildDirectory.dir("outputs/native-debug-symbols/release"))
//     archiveFileName.set("native-debug-symbols.zip")
// }
