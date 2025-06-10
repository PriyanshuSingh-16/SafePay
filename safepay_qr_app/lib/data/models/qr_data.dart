// safepay_qr/safepay_qr_app/lib/data/models/qr_data.dart
// This file defines the data models for the QR code and reported QR entities.
// These models help in structuring the data exchanged between the frontend and backend.

class QrData {
  final String content; // The actual data extracted from the QR code (e.g., UPI ID, URL)
  final String? type; // Optional: Type of QR content (e.g., 'UPI', 'URL', 'TEXT')
  final String? status; // Optional: Classification status (e.g., 'Safe', 'Suspicious', 'Malicious')
  final String? message; // Optional: A message from the backend about the classification

  QrData({required this.content, this.type, this.status, this.message});

  // Factory constructor to create a QrData object from a JSON map (e.g., from API response)
  factory QrData.fromJson(Map<String, dynamic> json) {
    return QrData(
      content: json['content'] as String,
      type: json['type'] as String?,
      status: json['status'] as String?,
      message: json['message'] as String?,
    );
  }

  // Method to convert a QrData object to a JSON map (e.g., for sending to API)
  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'type': type,
      'status': status,
      'message': message,
    };
  }
}

class ReportedQr {
  final String qrContent; // The content of the QR code being reported
  final String reason; // The user's reason for reporting
  final String? reportedBy; // Optional: ID of the user who reported it
  final DateTime timestamp; // When the QR was reported

  ReportedQr({
    required this.qrContent,
    required this.reason,
    this.reportedBy,
    required this.timestamp,
  });

  // Factory constructor to create a ReportedQr object from a JSON map
  factory ReportedQr.fromJson(Map<String, dynamic> json) {
    return ReportedQr(
      qrContent: json['qrContent'] as String,
      reason: json['reason'] as String,
      reportedBy: json['reportedBy'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String), // Parse ISO 8601 string to DateTime
    );
  }

  // Method to convert a ReportedQr object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'qrContent': qrContent,
      'reason': reason,
      'reportedBy': reportedBy,
      'timestamp': timestamp.toIso8601String(), // Convert DateTime to ISO 8601 string
    };
  }
}

// safepay_qr/safepay_qr_app/lib/utils/app_constants.dart
// This file centralizes application-wide constants, making them easy to manage
// and modify without searching through the entire codebase.

class AppConstants {
  // Base URL for the backend API.
  // IMPORTANT:
  // For Android Emulator, use '[http://10.0.2.2:3000](http://10.0.2.2:3000)' to access localhost on your machine.
  // For iOS Simulator or Web, use 'http://localhost:3000'.
  // For a deployed backend, replace with the actual deployed URL (e.g., '[https://your-backend-app.herokuapp.com](https://your-backend-app.herokuapp.com)').
  static const String API_BASE_URL = '[http://10.0.2.2:3000](http://10.0.2.2:3000)'; // Example for Android emulator
  // static const String API_BASE_URL = 'http://localhost:3000'; // Example for iOS simulator/Web

  // Add other constants here if needed, e.g.,
  // static const String APP_NAME = 'SafePay QR';
  // static const int SCAN_INTERVAL_MS = 500;
}
```yaml
# safepay_qr/safepay_qr_app/pubspec.yaml
name: safepay_qr_app
description: A new Flutter project for SafePay QR hackathon.
publish_to: 'none' # Remove this line if you wish to publish to pub.dev

version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0' # Adjust based on your Flutter SDK version

dependencies:
  flutter:
    sdk: flutter
  # The mobile_scanner package is highly recommended for QR scanning.
  # It leverages native MLKit for performance and reliability.
  mobile_scanner: ^5.0.0 # Check for the latest stable version on pub.dev

  # Dio is a powerful HTTP client for Dart, easy to use for API calls.
  dio: ^5.0.0 # Check for the latest stable version on pub.dev

  cupertino_icons: ^1.0.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.0

flutter:
  uses-material-design: true

  # To add assets to your application, add an assets section like this:
  # assets:
  #   - assets/images/
  #   - assets/icons/
  #   - assets/fonts/

  # For information on the generic Dart part of this file, see the
  # following page: https://dartlang.org/tools/pub/pubspec