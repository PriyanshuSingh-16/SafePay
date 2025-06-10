// safepay_qr/safepay_qr_backend/src/routes/apiRoutes.js
const express = require('express');
const router = express.Router();
const qrController = require('../controllers/qrController'); // Import QR controller functions
const authMiddleware = require('../middleware/authMiddleware'); // Import authentication middleware

// Define API routes and link them to controller functions

// POST /api/scan: Endpoint for scanning a QR code and getting its classification.
// This route does not require authentication for the hackathon MVP, allowing anyone to scan.
router.post('/scan', qrController.scanQr);

// POST /api/report: Endpoint for users to report suspicious QR codes.
// This route is protected by a basic authentication middleware.
// Only "authenticated" (via mock token) users can report.
router.post('/report', authMiddleware.authenticateUser, qrController.reportQr);

// You can add other routes here as the project grows, e.g.,
// router.get('/reports', authMiddleware.authenticateUser, qrController.getAllReports); // For admin view

module.exports = router; // Export the router for use in server.js

