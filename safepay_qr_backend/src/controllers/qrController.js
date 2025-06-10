// safepay_qr/safepay_qr_backend/src/controllers/qrController.js
const ReportedQr = require('../models/reportedQrModel'); // Import the ReportedQr Mongoose model

// --- AI/ML Model Simulation for Hackathon MVP ---
// This function simulates the output of an AI/ML model for QR classification and steganography detection.
// In a full implementation, this would involve loading and running actual models (e.g., TensorFlow Lite, MobileNet, ResNet).
const simulateMlClassification = (qrContent) => {
  // For hackathon, we simulate different outcomes based on specific content.
  // This represents the *result* that an AI/ML model would provide.

  // Scenario 1: Highly malicious content (e.g., phishing links, known scam indicators)
  if (qrContent.includes('malicious.com') || qrContent.includes('phishing.xyz') || qrContent.includes('scam.net')) {
    return { status: 'Malicious', message: 'AI/ML Model Result: Detected as a known malicious domain. AVOID!' };
  }
  // Scenario 2: Content with suspicious patterns (e.g., very long URLs, unusual character sequences)
  // This could represent an ML model detecting anomalies or potential hidden data indicators.
  if (qrContent.length > 150 || qrContent.includes('verify-account') || qrContent.includes('urgent-update')) {
    return { status: 'Suspicious', message: 'AI/ML Model Result: Contains suspicious elements or unusual length. Proceed with caution.' };
  }
  // Scenario 3: Simulating steganography detection based on LSB modification criteria
  // In a real application, an ML model trained on image analysis (e.g., using OpenCV or specialized steganography techniques)
  // would detect hidden data by analyzing image pixel data for anomalies indicative of LSB modification.
  // For the hackathon, we simulate this by checking for a specific string marker that represents
  // the detection of an LSB-modified payload within the QR's data.
  if (qrContent.includes('LSB_MODIFIED_DATA_HIDDEN_SECRET_CODE')) {
    return { status: 'Malicious', message: 'AI/ML Model Result: Steganography detected (LSB modification). This QR contains hidden malicious data. AVOID!' };
  }
  // Scenario 4: Valid UPI format check (a rule-based check that could be part of an ML feature set)
  if (qrContent.startsWith('upi://') && qrContent.includes('@')) {
    return { status: 'Safe', message: 'AI/ML Model Result: Appears to be a valid UPI QR code.' };
  }
  // Default scenario: If no suspicious patterns are detected by the simulated ML.
  return { status: 'Safe', message: 'AI/ML Model Result: QR code appears safe. Always verify receiver details before payment.' };
};

// Controller function for handling QR code scanning requests
exports.scanQr = async (req, res) => {
  const { qrContent } = req.body; // Extract qrContent from the request body

  // Input validation: Ensure qrContent is provided
  if (!qrContent) {
    return res.status(400).json({ message: 'QR content is required for scanning.' });
  }

  try {
    // First, check if the QR content is present in our reported/blacklisted database
    const foundBlacklisted = await ReportedQr.findOne({ qrContent, isBlacklisted: true });

    if (foundBlacklisted) {
      // If found and blacklisted, immediately classify as Malicious
      return res.json({ status: 'Malicious', message: 'This QR has been blacklisted by the community for suspicious activity.' });
    }

    // If not blacklisted, proceed with AI/ML-based classification simulation
    const classification = simulateMlClassification(qrContent);

    // Send the classification result back to the frontend
    res.json(classification);
  } catch (err) {
    console.error('Error during QR scan classification:', err);
    res.status(500).json({ message: 'Server error during QR scan classification. Please try again.' });
  }
};

// Controller function for handling QR code reporting requests
exports.reportQr = async (req, res) => {
  const { qrContent, reason, userId } = req.body; // Extract data from request body (userId would come from auth middleware normally)

  // Input validation: Ensure qrContent and reason are provided
  if (!qrContent || !reason) {
    return res.status(400).json({ message: 'QR content and reason are required for reporting.' });
  }

  try {
    // Create a new ReportedQr document
    const newReport = new ReportedQr({
      qrContent,
      reason,
      // If authentication middleware is used, req.userId would be available
      reportedBy: req.userId || userId || 'anonymous', // Use userId from auth, or provided, or 'anonymous'
    });

    // Save the new report to the database
    await newReport.save();
    console.log(`QR reported successfully: ${qrContent} by ${newReport.reportedBy}`);
    res.status(201).json({ success: true, message: 'QR reported successfully! Thank you for your contribution.' });
  } catch (err) {
    console.error('Error reporting QR:', err);
    res.status(500).json({ success: false, message: 'Failed to report QR. Please try again.' });
  }
};

