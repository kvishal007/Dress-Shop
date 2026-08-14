import express, { Express, Request, Response } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import rateLimit from 'express-rate-limit';
import { env } from './config/env';
import { authRoutes } from './modules/auth/auth.routes';
import { productRoutes } from './modules/products/product.routes';
import { saleRoutes } from './modules/sales/sale.routes';
import { errorHandler } from './middleware/errorHandler';
import { ApiResponse } from './utils/apiResponse';
import { seedDatabase } from './scripts/seed';

const app: Express = express();

// Trust Render's proxy (required for rate limiting behind load balancer)
app.set('trust proxy', 1);

// Security Middlewares
app.use(helmet());
app.use(
  cors({
    origin: env.CORS_ORIGIN === '*' ? true : env.CORS_ORIGIN,
    credentials: true,
  })
);

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 300, // Limit each IP to 300 requests per windowMs
  standardHeaders: true,
  legacyHeaders: false,
  message: {
    success: false,
    message: 'Too many requests from this IP, please try again after 15 minutes',
  },
});
app.use('/api', limiter);

// Body Parsing Middlewares
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Health Check Route
app.get('/health', (req: Request, res: Response) => {
  return ApiResponse.success(res, 'Smart Dress Shop POS API is healthy', {
    uptime: process.uptime(),
    timestamp: new Date().toISOString(),
    env: env.NODE_ENV,
  });
});

// Seed route helper for dev setup
app.post('/api/v1/seed', async (req: Request, res: Response, next) => {
  try {
    await seedDatabase();
    return ApiResponse.success(res, 'Database seeded successfully');
  } catch (error) {
    next(error);
  }
});

// API Routes (v1)
app.use('/api/v1/auth', authRoutes);
app.use('/api/v1/sales', saleRoutes);
app.use('/api/v1', productRoutes);

// 404 Route Handler
app.use((req: Request, res: Response) => {
  return ApiResponse.error(res, `Cannot ${req.method} ${req.originalUrl}`, 404);
});

// Global Error Handler
app.use(errorHandler);

export default app;
