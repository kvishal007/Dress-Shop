import { Request, Response, NextFunction } from 'express';
import { AuthService } from './auth.service';
import { ApiResponse } from '../../utils/apiResponse';
import { AuthenticatedRequest } from '../../middleware/auth';
import { AuditService } from '../audit/audit.service';

export class AuthController {
  static login = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const { email, password } = req.body;
      const result = await AuthService.login(email, password, req.ip);

      await AuditService.log({
        userId: (result.user._id as any).toString(),
        userName: result.user.name,
        userRole: result.user.role,
        action: 'USER_LOGIN',
        entity: 'User',
        entityId: (result.user._id as any).toString(),
        ipAddress: req.ip,
      });

      return ApiResponse.success(res, 'Login successful', result);
    } catch (error) {
      next(error);
    }
  };

  static getMe = async (req: AuthenticatedRequest, res: Response, next: NextFunction) => {
    try {
      const user = await AuthService.getMe(req.user!.userId);
      return ApiResponse.success(res, 'User profile retrieved successfully', user);
    } catch (error) {
      next(error);
    }
  };

  static logout = async (req: AuthenticatedRequest, res: Response, next: NextFunction) => {
    try {
      if (req.user) {
        await AuditService.log({
          userId: req.user.userId,
          action: 'USER_LOGOUT',
          entity: 'User',
          entityId: req.user.userId,
          ipAddress: req.ip,
        });
      }
      return ApiResponse.success(res, 'Logout successful');
    } catch (error) {
      next(error);
    }
  };
}
