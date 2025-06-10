// safepay_qr/safepay_qr_app/lib/main.dart
import 'package:flutter/material.dart';
import 'package:safepay_qr_app/features/authentication/pages/login_page.dart'; // Placeholder for login, can be replaced
import 'package:safepay_qr_app/features/qr_scan/pages/qr_scanner_page.dart';

void main() {
  runApp(const SafePayQRApp());
}

class SafePayQRApp extends StatelessWidget {
  const SafePayQRApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafePay QR',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // For hackathon, you can directly go to QrScannerPage,
      // or implement a simple LoginPage as a placeholder.
      home: const QrScannerPage(), // Start directly with the QR scanner for quick demo
      // You can define routes here if you have multiple pages.
      // routes: {
      //   '/login': (context) => const LoginPage(),
      //   '/scanner': (context) => const QrScannerPage(),
      // },
      debugShowCheckedModeBanner: false, // Hide the debug banner
    );
  }
}