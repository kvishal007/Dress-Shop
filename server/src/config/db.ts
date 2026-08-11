import mongoose from 'mongoose';
import { env } from './env';

export const connectDB = async (): Promise<void> => {
  try {
    const conn = await mongoose.connect(env.MONGO_URI);
    console.log(`[MongoDB Connected]: ${conn.connection.host} (${conn.connection.name})`);
  } catch (error) {
    console.error(`[MongoDB Connection Error]: ${(error as Error).message}`);
    // Don't crash immediately in dev mode if DB is connecting async, but throw error so caller can handle
    throw error;
  }
};
