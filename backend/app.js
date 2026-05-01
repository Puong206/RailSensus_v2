const express = require('express');
const cors = require('cors');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');

const app = express();

// Global Rate Limiter
const globalLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 200, // Limit each IP to 200 requests per windowMs
  message: {
    success: false,
    message: 'Too many requests from this IP, please try again after 15 minutes'
  }
});

// Middlewares
app.use(globalLimiter);
app.use(cors());
app.use(morgan('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Routes
const path = require('path');
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

const apiRoutes = require('./src/routes');
app.use('/api', apiRoutes);

// Health check endpoint (moved here to avoid routing complexity before routes exist)
app.get('/api/health', (req, res) => {
  res.json({ success: true, message: "RailSensus API is running" });
});

// 404 Handler
app.use((req, res, next) => {
  res.status(404).json({
    success: false,
    message: 'Route not found'
  });
});

// Global Error Handler
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(err.status || 500).json({
    success: false,
    message: err.message || 'Internal Server Error',
    errors: err.errors || {}
  });
});

module.exports = app;
