// ============================================
// CARDANO COMMUNITY SUITE - BACKEND SERVER
// ============================================
// Express.js REST API for web application

import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { fileURLToPath } from 'url';
import { dirname } from 'path';

// Import routes
import eventRoutes from './routes/event.js';
import signatureRoutes from './routes/signature.js';
import registryRoutes from './routes/registry.js';
import walletRoutes from './routes/wallet.js';
import reportRoutes from './routes/reports.js';

dotenv.config();

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const app = express();
const PORT = process.env.PORT || 3000;

// ============ MIDDLEWARE ============
app.use(cors());
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ limit: '10mb', extended: true }));

// Request logging middleware
app.use((req, res, next) => {
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.path}`);
  next();
});

// ============ HEALTH CHECK ============
app.get('/api/health', (req, res) => {
  res.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    version: '1.0.0'
  });
});

// ============ API ROUTES ============
app.use('/api/events', eventRoutes);
app.use('/api/signatures', signatureRoutes);
app.use('/api/registry', registryRoutes);
app.use('/api/wallet', walletRoutes);
app.use('/api/reports', reportRoutes);

// ============ ERROR HANDLING ============
app.use((err, req, res, next) => {
  console.error('Error:', err);
  
  res.status(err.status || 500).json({
    error: err.message || 'Internal server error',
    timestamp: new Date().toISOString()
  });
});

// ============ 404 HANDLING ============
app.use((req, res) => {
  res.status(404).json({
    error: 'Route not found',
    path: req.path,
    method: req.method
  });
});

// ============ START SERVER ============
app.listen(PORT, () => {
  console.log(`
╔════════════════════════════════════════════════════════╗
║    Cardano Community Suite - Backend Server             ║
║    Running on: http://localhost:${PORT}                        ║
║    Environment: ${process.env.NODE_ENV || 'development'}                ║
╚════════════════════════════════════════════════════════╝
  `);
});

export default app;
