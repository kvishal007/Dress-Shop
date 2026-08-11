import jwt, { SignOptions } from 'jsonwebtoken';
import { env } from '../config/env';

export interface IJwtPayload {
  userId: string;
  role: string;
  email: string;
}

export const generateToken = (payload: IJwtPayload): string => {
  const options: SignOptions = {
    expiresIn: env.JWT_EXPIRES_IN as jwt.Secret | number | string | undefined as any,
  };
  return jwt.sign(payload, env.JWT_SECRET, { expiresIn: '7d' });
};

export const verifyToken = (token: string): IJwtPayload => {
  return jwt.verify(token, env.JWT_SECRET) as IJwtPayload;
};
