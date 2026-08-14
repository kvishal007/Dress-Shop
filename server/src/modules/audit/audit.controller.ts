import { Request, Response, NextFunction } from 'express';
import { AuditLog } from './audit.model';
import { ApiResponse } from '../../utils/apiResponse';

export class AuditController {
  static async getLogs(req: Request, res: Response, next: NextFunction) {
    try {
      // Fetch latest 100 logs
      const logs = await AuditLog.find().sort({ createdAt: -1 }).limit(100).populate('userId', 'name role');
      return ApiResponse.success(res, 'Audit logs fetched successfully', logs);
    } catch (error) {
      next(error);
    }
  }
}
