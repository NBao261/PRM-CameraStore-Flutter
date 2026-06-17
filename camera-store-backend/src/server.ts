import http from 'http';

import app from './app';
import connectDB from './config/db';
import config from './config/env';
import mongoose from 'mongoose';

import { initSocket } from './socket';

const server = http.createServer(app);

// ── Socket.IO ───────────────────────────────────────
const io = initSocket(server);

// ── Startup ─────────────────────────────────────────
const startServer = async () => {
  await connectDB();

  server.listen(config.port, () => {
    console.log(`🚀 Server running on port ${config.port}`);
    console.log(`📡 Environment: ${process.env.NODE_ENV || 'development'}`);
  });
};

// ── Graceful Shutdown ───────────────────────────────
const gracefulShutdown = async (signal: string) => {
  console.log(`\n⚠️  ${signal} received — shutting down gracefully...`);

  // 1. Stop accepting new connections
  server.close(() => {
    console.log('✅ HTTP server closed');
  });

  // 2. Disconnect Socket.IO
  io.close(() => {
    console.log('✅ Socket.IO closed');
  });

  // 3. Close MongoDB connection
  try {
    await mongoose.connection.close();
    console.log('✅ MongoDB connection closed');
  } catch (err) {
    console.error('❌ Error closing MongoDB:', err);
  }

  process.exit(0);
};

process.on('SIGINT', () => gracefulShutdown('SIGINT'));
process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));

// Handle unhandled rejections
process.on('unhandledRejection', (reason: any) => {
  console.error('❌ Unhandled Rejection:', reason);
  gracefulShutdown('unhandledRejection');
});

startServer();
