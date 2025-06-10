// safepay_qr/safepay_qr_backend/server.js
const express = require('express');
const dotenv = require('dotenv');
const connectDB = require('./config/db');
const apiRoutes = require('./src/routes/apiRoutes');
// const authRoutes = require('./src/routes/authRoutes'); // Optional: For full auth, uncomment
const cors = require('cors'); // Essential for frontend-backend communication

// Load environment variables from .env file
dotenv.config();

const app = express();
// Use process.env.PORT if available (e.g., when deployed), otherwise default to 3000
const PORT = process.env.PORT || 3000;

// Connect to MongoDB database
connectDB();

// Middleware
// Enable CORS for all origins during hackathon development.
// In a production environment, you would restrict this to specific origins.
app.use(cors());
// Body parser for JSON requests. This is crucial for Express to understand JSON bodies sent from the frontend.
app.use(express.json());

// Routes
// All API routes prefixed with /api (e.g., /api/scan, /api/report)
app.use('/api', apiRoutes);
// Optional: If you implement full authentication, uncomment and use authRoutes
// app.use('/auth', authRoutes);

// Simple root route for health check or welcome message
app.get('/', (req, res) => {
  res.send('SafePay QR Backend API is running! 🚀');
});

// Start the Express server
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
  console.log(`Access the backend at: http://localhost:${PORT}`);
});

