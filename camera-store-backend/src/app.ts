import express from 'express';
import helmet from 'helmet';
import cors from 'cors';
import compression from 'compression';
import path from 'path';
import { requestLogger } from './middlewares/logger';
import { errorHandler } from './middlewares/errorHandler';

// Route imports
import authRoutes from './routes/auth.routes';
import productRoutes from './routes/product.routes';
import categoryRoutes from './routes/category.routes';
import cartRoutes from './routes/cart.routes';
import orderRoutes from './routes/order.routes';
import notificationRoutes from './routes/notification.routes';
import storeRoutes from './routes/store.routes';
import chatRoutes from './routes/chat.routes';
import paymentRoutes from './routes/payment.routes';
import adminOrderRoutes from './routes/admin.order.routes';
import adminChatRoutes from './routes/admin.chat.routes';

const app = express();

// ── Static files (product images) - before helmet ───
app.use('/public', express.static(path.join(__dirname, '..', 'public')));

// ── Security middleware ─────────────────────────────
app.use(helmet({
  crossOriginResourcePolicy: { policy: 'cross-origin' },
}));
app.use(cors({ origin: process.env.ALLOWED_ORIGINS?.split(',') || '*' }));
app.use(compression());

// ── Body parsing ────────────────────────────────────
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// ── Request logging ─────────────────────────────────
app.use(requestLogger);

// ── Health check ────────────────────────────────────
app.get('/api/health', (_req, res) => {
  res.json({
    status: 'ok',
    uptime: process.uptime(),
    timestamp: new Date().toISOString(),
  });
});

// ── Routes ──────────────────────────────────────────
app.use('/api/auth', authRoutes);
app.use('/api/products', productRoutes);
app.use('/api/categories', categoryRoutes);
app.use('/api/cart', cartRoutes);
app.use('/api/orders', orderRoutes);
app.use('/api/notifications', notificationRoutes);
app.use('/api/stores', storeRoutes);
app.use('/api/chat', chatRoutes);
app.use('/api/payment', paymentRoutes);
app.use('/api/admin/orders', adminOrderRoutes);
app.use('/api/admin/chat', adminChatRoutes);

// ── Global error handler (must be last) ─────────────
app.use(errorHandler);

export default app;
