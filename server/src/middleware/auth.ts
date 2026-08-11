import { Request, Response, NextFunction } from 'express';
import { verifyToken, IJwtPayload } from '../utils/jwt';
import { ApiError } from '../utils/apiError';
import { User } from '../modules/users/user.model';
import { UserStatusEnum } from '../modules/users/user.interface';

export interface AuthenticatedRequest extends Request {
  user?: IJwtPayload & { status?: string };
}

export const authenticate = async (
  req: AuthenticatedRequest,
  res: Response,
  next: NextFunction
) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      throw ApiError.unauthorized('No authentication token provided');
    }

    const token = authHeader.split(' ')[1];
    if (!token) {
      throw ApiError.unauthorized('Invalid authorization header format');
    }

    const decoded = verifyToken(token);
    
    // Check if user still exists and is active
    const userDoc = await User.findById(decoded.userId).select('status role');
    if (!userDoc) {
      throw ApiError.unauthorized('User associated with this token no longer exists');
    }

    if (userDoc.status !== UserStatusEnum.ACTIVE) {
      throw ApiError.forbidden('User account is inactive or suspended');
    }

    req.user = {
      userId: decoded.userId,
      email: decoded.email,
      role: decoded.role,
      status: userDoc.status,
    };

    next();
  } catch (error) {
    next(error);
  }
};
