import { Request, Response, NextFunction } from 'express';
import { User } from './user.model';
import { ApiResponse } from '../../utils/apiResponse';
import { UserStatusEnum } from './user.interface';
import bcrypt from 'bcryptjs';

export class UserController {
  static async getUsers(req: Request, res: Response, next: NextFunction) {
    try {
      const users = await User.find().select('-password').sort({ createdAt: -1 });
      return ApiResponse.success(res, 'Users fetched successfully', users);
    } catch (error) {
      next(error);
    }
  }

  static async deactivateUser(req: Request, res: Response, next: NextFunction) {
    try {
      const { id } = req.params;
      const user = await User.findByIdAndUpdate(id, { status: UserStatusEnum.INACTIVE }, { new: true }).select('-password');
      if (!user) {
        return res.status(404).json({ success: false, message: 'User not found' });
      }
      return ApiResponse.success(res, 'User deactivated successfully', user);
    } catch (error) {
      next(error);
    }
  }

  static async resetPassword(req: Request, res: Response, next: NextFunction) {
    try {
      const { id } = req.params;
      const { newPassword } = req.body;
      if (!newPassword) {
        return res.status(400).json({ success: false, message: 'newPassword is required' });
      }

      const salt = await bcrypt.genSalt(10);
      const hashedPassword = await bcrypt.hash(newPassword, salt);

      const user = await User.findByIdAndUpdate(id, { password: hashedPassword }).select('-password');
      if (!user) {
        return res.status(404).json({ success: false, message: 'User not found' });
      }

      return ApiResponse.success(res, 'User password reset successfully', null);
    } catch (error) {
      next(error);
    }
  }

  static async updateRole(req: Request, res: Response, next: NextFunction) {
    try {
      const { id } = req.params;
      const { role } = req.body;
      if (!role) {
        return res.status(400).json({ success: false, message: 'Role is required' });
      }

      const user = await User.findByIdAndUpdate(id, { role }, { new: true }).select('-password');
      if (!user) {
        return res.status(404).json({ success: false, message: 'User not found' });
      }

      return ApiResponse.success(res, 'User role updated successfully', user);
    } catch (error) {
      next(error);
    }
  }
}
