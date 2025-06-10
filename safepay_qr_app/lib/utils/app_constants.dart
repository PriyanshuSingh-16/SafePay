// safepay_qr/safepay_qr_app/lib/utils/app_constants.dart
// This file centralizes application-wide constants, making them easy to manage
// and modify without searching through the entire codebase.

class AppConstants {
  // Base URL for the backend API.
  // IMPORTANT:
  // For Android Emulator, use '[http://10.0.2.2:3000](http://10.0.2.2:3000)' to access localhost on your machine.
  // For iOS Simulator or Web, use 'http://localhost:3000'.
  // For a deployed backend, replace with the actual deployed URL (e.g., '[https://your-backend-app.herokuapp.com](https://your-backend-app.herokuapp.com)').
  static const String API_BASE_URL = 'http://192.168.42.216:3000'; // Example for Android emulator
  // static const String API_BASE_URL = 'http://localhost:3000'; // Example for iOS simulator/Web

  // Add other constants here if needed, e.g.,
  // static const String APP_NAME = 'SafePay QR';
  // static const int SCAN_INTERVAL_MS = 500;
}

