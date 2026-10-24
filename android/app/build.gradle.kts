plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // Firebase plugin yahan add kar diya
}

android {
    namespace = "com.example.bfcables_app"
    
    // Yahan explicit compileSdk set kiya hai taake jmod error na aaye
    compileSdk = 34 
    
    // Error mein jo NDK version maanga gaya tha, woh set kar diya hai
    ndkVersion = "28.2.13676358" 

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        // Kotlin DSL mein isay String "1.8" likhna hota hai
        jvmTarget = "1.8" 
    }

    defaultConfig {
        applicationId = "com.example.bfcables_app"
        minSdk = flutter.minSdkVersion // Firebase ke liye 21 zaroori hai
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
