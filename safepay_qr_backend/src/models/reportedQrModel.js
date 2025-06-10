// safepay_qr/safepay_qr_backend/src/models/reportedQrModel.js
const mongoose = require('mongoose'); // Import Mongoose

// Define the schema for a reported QR code
const reportedQrSchema = new mongoose.Schema({
  // The actual content of the QR code that was reported
  qrContent: {
    type: String,
    required: true, // This field is mandatory
    index: true, // Add an index for faster lookups (e.g., when checking blacklisted QRs)
  },
  // The reason provided by the user for reporting the QR code
  reason: {
    type: String,
    default: 'User reported as suspicious', // Default reason if not provided
  },
  // The ID of the user who reported the QR (optional, could be anonymous)
  reportedBy: {
    type: String,
    default: 'anonymous',
  },
  // Timestamp when the QR code was reported
  timestamp: {
    type: Date,
    default: Date.now, // Automatically set to the current date/time upon creation
  },
  // A flag to indicate if this QR code has been marked as blacklisted
  // This can be manually updated by an admin or automatically based on multiple reports
  isBlacklisted: {
    type: Boolean,
    default: false, // Default to false
  },
  // You might add more fields in the future, e.g.,
  // reviewStatus: { type: String, enum: ['Pending', 'Reviewed', 'Dismissed'], default: 'Pending' },
  // reviewerNotes: { type: String },
});

// Create and export the Mongoose model based on the schema
// 'ReportedQr' will be the name of the collection in MongoDB (automatically pluralized to 'reportedqrs')
module.exports = mongoose.model('ReportedQr', reportedQrSchema);

