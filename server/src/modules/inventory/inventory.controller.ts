import { Request, Response, NextFunction } from 'express';
import { InventoryMovementModel } from './inventory.model';
import { ProductModel } from '../products/product.model';
import { ApiResponse } from '../../utils/apiResponse';
import { ApiError } from '../../utils/apiError';
import mongoose from 'mongoose';

export class InventoryController {
  static async adjustStock(req: Request, res: Response, next: NextFunction) {
    const session = await mongoose.startSession();
    session.startTransaction();

    try {
      const { productId, quantityChange, reason } = req.body;
      const adjustedBy = (req as any).user.userId;

      if (!productId || quantityChange === undefined || !reason) {
        throw ApiError.badRequest('Missing required fields');
      }

      const product = await ProductModel.findById(productId).session(session);
      if (!product) {
        throw ApiError.notFound('Product not found');
      }

      const type = quantityChange > 0 ? 'IN' : quantityChange < 0 ? 'OUT' : 'ADJUSTMENT';

      // Update product stock
      product.stockQuantity += quantityChange;
      if (product.stockQuantity < 0) {
        throw ApiError.badRequest('Stock quantity cannot be negative');
      }
      await product.save({ session });

      // Record movement
      const movement = new InventoryMovementModel({
        productId,
        type,
        quantityChange,
        reason,
        adjustedBy,
      });
      await movement.save({ session });

      await session.commitTransaction();
      return ApiResponse.success(res, 'Stock adjusted successfully', { product, movement });
    } catch (error) {
      await session.abortTransaction();
      next(error);
    } finally {
      session.endSession();
    }
  }

  static async getMovementHistory(req: Request, res: Response, next: NextFunction) {
    try {
      const { productId } = req.params;
      const movements = await InventoryMovementModel.find({ productId })
        .populate('adjustedBy', 'name role')
        .sort({ createdAt: -1 });
        
      return ApiResponse.success(res, 'Movement history retrieved', movements);
    } catch (error) {
      next(error);
    }
  }
}
