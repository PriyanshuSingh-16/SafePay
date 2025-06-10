// safepay_qr/safepay_qr_app/lib/features/qr_scan/pages/qr_scanner_page.dart
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart'; // Recommended package for QR scanning
import 'package:safepay_qr_app/data/providers/api_service.dart';
// import 'package:safepay_qr_app/data/models/qr_data.dart'; // Not directly used in UI, but good to have

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({Key? key}) : super(key: key);

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  // Controller for the mobile_scanner package.
  MobileScannerController cameraController = MobileScannerController();
  String? scannedData; // Stores the raw content of the scanned QR code
  String? classificationResult; // Stores the classification result from the backend
  bool _isProcessing = false; // Flag to prevent multiple scans/requests

  @override
  void dispose() {
    cameraController.dispose(); // Dispose the camera controller to release resources
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SafePay QR Scanner'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Stack(
              children: [
                // MobileScanner widget for live camera feed and QR detection
                MobileScanner(
                  controller: cameraController,
                  // Configure the scanner to detect only QR codes
                  scanWindow: Rect.fromCenter(
                      center: MediaQuery.of(context).size.center(Offset.zero),
                      width: 200,
                      height: 200),
                  onDetect: (capture) {
                    // Check if already processing a QR code to avoid duplicate calls
                    if (_isProcessing) return;

                    final List<Barcode> barcodes = capture.barcodes;
                    if (barcodes.isNotEmpty) {
                      final String? code = barcodes.first.rawValue;
                      if (code != null && code != scannedData) {
                        setState(() {
                          _isProcessing = true; // Set processing flag
                          scannedData = code; // Update scanned data
                          classificationResult =
                              'Scanning...'; // Show a scanning message
                        });
                        // Pause the camera while processing to prevent rapid re-scanning
                        cameraController.stop();
                        _classifyQrCode(code); // Call backend for classification
                      }
                    }
                  },
                ),
                // Overlay for the scan window area
                Center(
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(20.0),
              color: Colors.grey[100],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    scannedData == null
                        ? 'Point your camera at a QR code'
                        : 'Scanned: ${scannedData!}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: scannedData == null ? Colors.grey[600] : Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Display classification result
                  Text(
                    classificationResult ?? '',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _getColorForStatus(classificationResult),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Button to report suspicious QR code
                  if (scannedData != null && classificationResult != 'Scanning...')
                    ElevatedButton.icon(
                      onPressed: _isProcessing
                          ? null // Disable button while processing
                          : () => _showReportDialog(scannedData!),
                      icon: const Icon(Icons.report, color: Colors.white),
                      label: const Text(
                        'Report Suspicious QR',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange, // Report button color
                        padding: const EdgeInsets.symmetric(
                            horizontal: 25, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  const SizedBox(height: 10),
                  // Button to re-scan
                  if (scannedData != null && !_isProcessing)
                    OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          scannedData = null;
                          classificationResult = null;
                        });
                        cameraController
                            .start(); // Restart camera for a new scan
                      },
                      icon: const Icon(Icons.refresh, color: Colors.blueAccent),
                      label: const Text(
                        'Scan New QR',
                        style: TextStyle(fontSize: 16, color: Colors.blueAccent),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.blueAccent),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 25, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper function to determine text color based on classification status
  Color _getColorForStatus(String? status) {
    if (status == 'Safe') {
      return Colors.green;
    } else if (status == 'Suspicious') {
      return Colors.orange;
    } else if (status == 'Malicious') {
      return Colors.red;
    } else {
      return Colors.black; // Default for 'Scanning...' or null
    }
  }

  // Function to classify the scanned QR code by calling the backend API
  Future<void> _classifyQrCode(String qrContent) async {
    try {
      final result =
          await ApiService().post('/api/scan', {'qrContent': qrContent});
      setState(() {
        classificationResult = result['status']; // e.g., 'Safe', 'Suspicious', 'Malicious'
      });
    } catch (e) {
      setState(() {
        classificationResult = 'Error: ${e.toString()}';
      });
      _showErrorDialog('Classification Failed', 'Could not classify QR: ${e.toString()}');
    } finally {
      setState(() {
        _isProcessing = false; // Reset processing flag
      });
      // Optionally restart camera after a brief delay if not immediately re-scanning
      // Future.delayed(const Duration(seconds: 2), () => cameraController.start());
    }
  }

  // Function to show a dialog for reporting a suspicious QR code
  void _showReportDialog(String qrContent) {
    String reportReason = '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Report QR Code'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('You are about to report the QR code: $qrContent'),
              const SizedBox(height: 10),
              TextField(
                onChanged: (value) {
                  reportReason = value;
                },
                decoration: const InputDecoration(
                  hintText: 'Reason for reporting (e.g., phishing, scam)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (reportReason.isNotEmpty) {
                  Navigator.of(context).pop(); // Close the dialog
                  _reportQrCode(qrContent, reportReason); // Call report function
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please provide a reason.')),
                  );
                }
              },
              child: const Text('Submit Report'),
            ),
          ],
        );
      },
    );
  }

  // Function to report the QR code to the backend
  Future<void> _reportQrCode(String qrContent, String reason) async {
    setState(() {
      _isProcessing = true; // Set processing flag for reporting
    });
    try {
      // Assuming a mock userId or getting it from a simple auth state
      const String mockUserId = 'hackathon_user_flutter_123';
      await ApiService().post(
          '/api/report', {'qrContent': qrContent, 'reason': reason, 'userId': mockUserId});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('QR reported successfully! Thank you for your contribution.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to report QR: ${e.toString()}')),
      );
      _showErrorDialog('Report Failed', 'Could not report QR: ${e.toString()}');
    } finally {
      setState(() {
        _isProcessing = false; // Reset processing flag
      });
      // Optionally restart camera if needed after reporting
      cameraController.start();
    }
  }

  // Generic error dialog for user feedback
  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

