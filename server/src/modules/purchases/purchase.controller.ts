import { Request, Response, NextFunction } from 'express';
import { PurchaseModel } from './purchase.model';
import { ProductModel } from '../products/product.model';
import { InventoryMovementModel } from '../inventory/inventory.model';
import { ApiResponse } from '../../utils/apiResponse';
import { ApiError } from '../../utils/apiError';
import mongoose from 'mongoose';

export class PurchaseController {
  static async createPurchase(req: Request, res: Response, next: NextFunction) {
    try {
      const { supplierId, items } = req.body;
      const orderedBy = (req as any).user.userId;

      if (!items || !items.length) {
        throw ApiError.badRequest('Purchase must contain at least one item');
      }

      let totalAmount = 0;
      for (const item of items) {
        totalAmount += item.subtotal;
      }

      const poNumber = `PO-${Date.now()}`;
      const purchase = new PurchaseModel({
        poNumber,
        supplierId,
        items,
        totalAmount,
        status: 'PENDING',
        orderedBy,
      });

      await purchase.save();
      return ApiResponse.created(res, 'Purchase Order created', purchase);
    } catch (error) {
      next(error);
    }
  }

  static async getPurchases(req: Request, res: Response, next: NextFunction) {
    try {
      const purchases = await PurchaseModel.find()
        .populate('supplierId', 'name contactPerson')
        .sort({ createdAt: -1 });
      return ApiResponse.success(res, 'Purchases retrieved', purchases);
    } catch (error) {
      next(error);
    }
  }

  static async receivePurchase(req: Request, res: Response, next: NextFunction) {
    const session = await mongoose.startSession();
    session.startTransaction();

    try {
      const { id } = req.params;
      const receivedBy = (req as any).user.userId;

      const purchase = await PurchaseModel.findById(id).session(session);
      if (!purchase) throw ApiError.notFound('Purchase order not found');
      if (purchase.status === 'RECEIVED') throw ApiError.badRequest('PO already received');

      // Increment stock for each item
      for (const item of purchase.items) {
        const product = await ProductModel.findById(item.productId).session(session);
        if (product) {
          product.stockQuantity += item.quantity;
          product.costPrice = item.costPrice; // Update cost price to latest
          await product.save({ session });

          // Record inventory movement
          const movement = new InventoryMovementModel({
            productId: item.productId,
            type: 'IN',
            quantityChange: item.quantity,
            reason: `Received PO: ${purchase.poNumber}`,
            adjustedBy: receivedBy,
          });
          await movement.save({ session });
        }
      }

      purchase.status = 'RECEIVED';
      purchase.receivedAt = new Date();
      await purchase.save({ session });

      await session.commitTransaction();
      return ApiResponse.success(res, 'Purchase received and stock updated', purchase);
    } catch (error) {
      await session.abortTransaction();
      next(error);
    } finally {
      session.endSession();
    }
  }
}
