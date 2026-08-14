import { Request, Response, NextFunction } from 'express';
import { ShopSettings } from './settings.model';
import { ApiResponse } from '../../utils/apiResponse';

export class SettingsController {
  static async getSettings(req: Request, res: Response, next: NextFunction) {
    try {
      let settings = await ShopSettings.findOne();
      if (!settings) {
        settings = await ShopSettings.create({});
      }
      return ApiResponse.success(res, 'Settings fetched successfully', settings);
    } catch (error) {
      next(error);
    }
  }

  static async updateSettings(req: Request, res: Response, next: NextFunction) {
    try {
      let settings = await ShopSettings.findOne();
      if (!settings) {
        settings = await ShopSettings.create(req.body);
      } else {
        settings = await ShopSettings.findOneAndUpdate({}, req.body, { new: true });
      }
      return ApiResponse.success(res, 'Settings updated successfully', settings);
    } catch (error) {
      next(error);
    }
  }
}
