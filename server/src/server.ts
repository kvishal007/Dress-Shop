import app from './app';
import { env } from './config/env';
import { connectDB } from './config/db';

const startServer = async () => {
  try {
    // Attempt Database Connection
    try {
      await connectDB();
    } catch (err) {
      console.warn('[Warning]: Database connection failed on startup. Server will start in detached mode.');
    }

    const PORT = parseInt(env.PORT, 10);
    app.listen(PORT, '0.0.0.0', () => {
      console.log(`
🚀 ======================================================== 🚀
   Smart Dress Shop POS & Business Management REST API
   Environment: ${env.NODE_ENV}
   Server URL:  http://localhost:${PORT}
   Health:      http://localhost:${PORT}/health
🚀 ======================================================== 🚀
      `);
    });
  } catch (error) {
    console.error('[Fatal Server Startup Error]:', error);
    process.exit(1);
  }
};

startServer();
