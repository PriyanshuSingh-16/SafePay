// safepay_qr/safepay_qr_app/lib/features/qr_scan/pages/qr_scanner_page.dart
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart'; // Recommended package for QR scanning
import 'package:safepay_qr_app/data/providers/api_service.dart';
import 'dart:async'; // Import for StreamSubscription

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
  StreamSubscription<BarcodeCapture>? _barcodeSubscription; // To manage the stream subscription

  @override
  void initState() {
    super.initState();
    print('Frontend Debug: initState called.');
    // Initialize classification result for initial state
    classificationResult = 'Initializing camera...';

    // Start the camera controller and listen for errors or successful start
    _startCameraController(); // Call this to attempt camera start

    // Subscribe to the barcodes stream for detection in mobile_scanner 5.x.x
    _barcodeSubscription = cameraController.barcodes.listen((capture) {
      print('Frontend Debug: barcodes stream emitted! Capture: $capture');
      // The logic previously in onDetect now goes here
      if (_isProcessing) {
        print('Frontend Debug: Already processing, ignoring new detection from stream.');
        return;
      }

      final List<Barcode> barcodes = capture.barcodes;
      if (barcodes.isNotEmpty) {
        final String? code = barcodes.first.rawValue;
        if (code != null && code.isNotEmpty && code != scannedData) {
          print('Frontend Debug: New unique QR code detected from stream: $code');
          setState(() {
            _isProcessing = true; // Set processing flag
            scannedData = code; // Update scanned data
            classificationResult = 'Scanning...'; // Show a scanning message
          });
          // Pause the camera while processing to prevent rapid re-scanning
          cameraController.stop();
          _classifyQrCode(code); // Call backend for classification
        } else if (code == scannedData) {
          print('Frontend Debug: Same QR code scanned again via stream, ignoring duplicate.');
        } else {
          print('Frontend Debug: Barcode rawValue is null or empty after detection from stream, or already processed.');
        }
      } else {
        print('Frontend Debug: No barcodes found in the current capture frame from stream.');
      }
    });
  }

  // Helper function to explicitly start the camera controller
  Future<void> _startCameraController() async {
    print('Frontend Debug: Attempting to start camera controller...');
    try {
      await cameraController.start();
      print('Frontend Debug: Camera controller started successfully.');
      setState(() {
        classificationResult = 'Camera Ready! Point at a QR.';
      });
    } catch (e) {
      print('Frontend Debug: Failed to start camera controller in _startCameraController: $e');
      setState(() {
        classificationResult = 'Camera Init Error: ${e.toString()}';
      });
      _showErrorDialog('Camera Initialization Failed', 'There was an issue starting the camera: ${e.toString()}. Please check app permissions.');
    }
  }

  @override
  void dispose() {
    print('Frontend Debug: dispose called. Cancelling subscriptions and disposing controller.');
    _barcodeSubscription?.cancel(); // Cancel the stream subscription
    cameraController.dispose(); // Dispose the camera controller to release resources
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('Frontend Debug: build method called.');
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
                  // Make scanWindow larger to maximize detection area for testing
                  scanWindow: Rect.fromLTWH(
                      MediaQuery.of(context).size.width * 0.1, // Left
                      MediaQuery.of(context).size.height * 0.1, // Top
                      MediaQuery.of(context).size.width * 0.8, // Width (80% of screen width)
                      MediaQuery.of(context).size.height * 0.4, // Height (40% of screen height)
                  ),
                ),
                // Overlay for the scan window area (now larger)
                Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.8, // Match scanWindow width
                    height: MediaQuery.of(context).size.height * 0.4, // Match scanWindow height
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                // Add a processing indicator
                if (_isProcessing)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black54,
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: Colors.white),
                            SizedBox(height: 10),
                            Text('Processing QR...', style: TextStyle(color: Colors.white, fontSize: 18)),
                          ],
                        ),
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
                  Flexible( // Added Flexible to prevent overflow of this text
                    child: Text(
                      scannedData == null
                          ? 'Point your camera at a QR code'
                          : 'Scanned: ${scannedData!}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: scannedData == null ? Colors.grey[600] : Colors.blue,
                      ),
                      overflow: TextOverflow.ellipsis, // Add ellipsis for very long text
                      maxLines: 2, // Limit lines to prevent excessive vertical growth
                    ),
                  ),
                  const SizedBox(height: 10),
                  Flexible( // Added Flexible to prevent overflow of this text
                    child: Text(
                      classificationResult ?? '',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _getColorForStatus(classificationResult),
                      ),
                      overflow: TextOverflow.ellipsis, // Add ellipsis for very long text
                      maxLines: 2, // Limit lines
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
                        cameraController.start(); // Restart camera for a new scan
                        print('Frontend Debug: Camera restarted for new scan.');
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
    } else if (status != null && status.contains('Error')) {
      return Colors.red; // Color for errors
    } else {
      return Colors.black; // Default for 'Scanning...' or null
    }
  }

  // Function to classify the scanned QR code by calling the backend API
  Future<void> _classifyQrCode(String qrContent) async {
    print('Frontend Debug: Attempting to classify QR code: $qrContent');
    try {
      final result =
          await ApiService().post('/api/scan', {'qrContent': qrContent});
      print('Frontend Debug: Classification API response: $result');
      setState(() {
        classificationResult = result['status']; // e.g., 'Safe', 'Suspicious', 'Malicious'
      });
      print('Frontend Debug: Classification result updated: $classificationResult');
    } catch (e) {
      print('Frontend Debug: Error during classification API call: $e');
      setState(() {
        classificationResult = 'Error: ${e.toString()}';
      });
      _showErrorDialog('Classification Failed', 'Could not classify QR: ${e.toString()}');
    } finally {
      setState(() {
        _isProcessing = false; // Reset processing flag
      });
      print('Frontend Debug: Processing complete. isProcessing set to false.');
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
    print('Frontend Debug: Attempting to report QR code: $qrContent with reason: $reason');
    setState(() {
      _isProcessing = true; // Set processing flag for reporting
    });
    try {
      // Assuming a mock userId or getting it from a simple auth state
      const String mockUserId = 'hackathon_user_flutter_123';
      await ApiService().post(
          '/api/report', {'qrContent': qrContent, 'reason': reason, 'userId': mockUserId});
      print('Frontend Debug: Report API response successful.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('QR reported successfully! Thank you for your contribution.')),
      );
    } catch (e) {
      print('Frontend Debug: Error during report API call: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to report QR: ${e.toString()}')),
      );
      _showErrorDialog('Report Failed', 'Could not report QR: ${e.toString()}');
    } finally {
      setState(() {
        _isProcessing = false; // Reset processing flag
      });
      print('Frontend Debug: Reporting complete. isProcessing set to false.');
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