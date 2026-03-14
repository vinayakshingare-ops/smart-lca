# SmartLCA Mine

An environmental intelligence MVP focusing on:
1. Satellite Mining Monitoring (NDVI mock implementation)
2. Product Waste Scanner (ML-based classification simulation)
3. Eco-friendly Product Marketplace (Alternative suggestions and gamification)

## Setup Instructions

Since `flutter` might not be in your PATH, follow these steps to build the project on a machine where Flutter is installed.

### 1. Requirements
- Flutter SDK (`>=3.0.0`)
- Android Studio / Xcode

### 2. Getting Started
1. Clone or copy this complete project folder (`smart_lca_mine`).
2. Open terminal in the `smart_lca_mine` directory.
3. Run `flutter pub get` to install all dependencies (Provider, fl_chart, google_maps_flutter, etc.).
4. Run `flutter run` to start the app on an Android emulator or physical device.

### 3. Firebase Configuration
To replace the mock data with actual Firebase backend:
1. Create a project on the [Firebase Console](https://console.firebase.google.com/).
2. Enable **Authentication** and **Cloud Firestore**.
3. Use FlutterFire CLI to configure the app:
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
4. In `lib/main.dart`, uncomment:
   ```dart
   WidgetsFlutterBinding.ensureInitialized();
   await Firebase.initializeApp();
   ```

### 4. API Keys (Production)
- **Google Maps**: Add your Google Maps API Key in `android/app/src/main/AndroidManifest.xml` and `ios/Runner/AppDelegate.swift`.
- **Google Earth Engine**: Integrate Earth Engine REST API using a service account for live satellite imagery bounds.

## Features Developed
- [x] Splashes & Dashboards with EcoCoins Gamification
- [x] Mining Monitor with fl_chart visualization
- [x] Product Scanner matching barcodes to database and awarding points
- [x] Google Maps Recycling Center Locator
- [x] Eco Swap Store allowing simulated purchases

Enjoy building a sustainable future! 🌿
