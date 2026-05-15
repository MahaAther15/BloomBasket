plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") 
}

android {
    namespace = "com.example.yourapp" // Apne project ka package name check kar len
    compileSdk = 34

    defaultConfig {
        applicationId = "com.example.yourapp" 
        minSdk = flutter.minSdkVersion 
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
        
        // Agar app bari ho jaye to ye error se bachata hai
        multiDexEnabled = true
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
    
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }
}

dependencies {
    // 2. Firebase BoM (Bill of Materials)
    implementation(platform("com.google.firebase:firebase-bom:33.1.0"))

    // 3. Firebase Libraries (Inka version BoM control karega)
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-auth")
    implementation("com.google.firebase:firebase-firestore")
    implementation("com.google.firebase:firebase-storage")

    // 4. Google Sign-In ke liye zaroori library
    implementation("com.google.android.gms:play-services-auth:20.7.0")
}

flutter {
    source = "../.."
}
