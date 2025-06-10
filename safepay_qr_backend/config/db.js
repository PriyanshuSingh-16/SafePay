// safepay_qr/safepay_qr_backend/config/db.js
const mongoose = require('mongoose'); // Mongoose is an ODM (Object Data Modeling) library for MongoDB

// Function to connect to the MongoDB database
const connectDB = async () => {
  try {
    // Attempt to connect to MongoDB using the URI from environment variables
    // process.env.MONGO_URI should be set in your .env file
    const conn = await mongoose.connect(process.env.MONGO_URI);
    console.log(`MongoDB Connected: ${conn.connection.host}`);
  } catch (err) {
    // If connection fails, log the error and exit the process
    console.error(`Error connecting to MongoDB: ${err.message}`);
    // Exit process with failure code (1)
    process.exit(1);
  }
};

module.exports = connectDB; // Export the connectDB function for use in server.js

