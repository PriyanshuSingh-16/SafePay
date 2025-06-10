// safepay_qr/safepay_qr_backend/src/middleware/authMiddleware.js
// This middleware provides a very basic, mock authentication for hackathon purposes.
// In a real application, this would involve JWT verification, session management, etc.

exports.authenticateUser = (req, res, next) => {
  // For hackathon, we'll use a simple mock token or allow anonymous access.
  // In a real app, this would check for a valid JWT token in the Authorization header.
  const token = req.headers['authorization']; // Get the Authorization header

  // A very basic check: if a token exists and matches a hardcoded "secret" token.
  // This is NOT secure for production!
  if (token && token === 'Bearer hackathon_super_secret_token_123') {
    // If the token is "valid", attach a mock userId to the request object
    // This userId can then be used in controllers (e.g., for 'reportedBy' field)
    req.userId = 'hackathon_user_backend_456';
    next(); // Proceed to the next middleware or route handler
  } else {
    // If no token or invalid token, return an unauthorized status
    // For hackathon, we might even let it pass or use a simpler check for demo.
    // Given the report mentions "Simple login / Mock OAuth", this is a basic implementation.
    console.warn('Unauthorized access attempt: Invalid or missing token.');
    return res.status(401).json({ message: 'Unauthorized: Access token is missing or invalid.' });
  }

  // --- Alternative for Hackathon: Allow anonymous access if no token for simplicity ---
  // If you want to make reporting accessible without strict token for hackathon demo:
  // if (token) {
  //   if (token === 'Bearer hackathon_super_secret_token_123') {
  //     req.userId = 'hackathon_user_backend_456';
  //   } else {
  //     console.warn('Invalid token provided, proceeding as anonymous.');
  //     req.userId = 'anonymous'; // Assign anonymous for reporting
  //   }
  // } else {
  //   req.userId = 'anonymous'; // Assign anonymous for reporting if no token
  // }
  // next();
};

