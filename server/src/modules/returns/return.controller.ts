import { Request, Response, NextFunction } from 'express';
import { ReturnModel } from './return.model';
import { SaleModel } from '../sales/sale.model';
import { ProductModel } from '../products/product.model';
import { InventoryMovementModel } from '../inventory/inventory.model';
import { ApiResponse } from '../../utils/apiResponse';
import { ApiError } from '../../utils/apiError';
import mongoose from 'mongoose';

export class ReturnController {
  static async processReturn(req: Request, res: Response, next: NextFunction) {
    const session = await mongoose.startSession();
    session.startTransaction();

    try {
      const { invoiceNumber, items, reason } = req.body;
      const processedBy = (req as any).user.userId;

      const sale = await SaleModel.findOne({ invoiceNumber }).session(session);
      if (!sale) throw ApiError.notFound('Sale not found for this invoice number');
      
      let totalRefund = 0;

      for (const item of items) {
        // Validate against sale items if needed (omitted for brevity)
        totalRefund += item.refundAmount;

        if (item.restock) {
          const product = await ProductModel.findById(item.productId).session(session);
          if (product) {
            product.stockQuantity += item.quantity;
            await product.save({ session });

            const movement = new InventoryMovementModel({
              productId: item.productId,
              type: 'IN',
              quantityChange: item.quantity,
              reason: `Return/Restock against invoice: ${invoiceNumber}. Reason: ${reason}`,
              adjustedBy: processedBy,
            });
            await movement.save({ session });
          }
        }
      }

      const returnDoc = new ReturnModel({
        saleId: sale._id,
        invoiceNumber,
        items,
        totalRefund,
        reason,
        processedBy,
      });

      await returnDoc.save({ session });
      
      // Optionally update sale status to REFUNDED if fully refunded
      // sale.status = 'REFUNDED';
      // await sale.save({ session });

      await session.commitTransaction();
      return ApiResponse.created(res, 'Return processed successfully', returnDoc);
    } catch (error) {
      await session.abortTransaction();
      next(error);
    } finally {
      session.endSession();
    }
  }

  static async getReturns(req: Request, res: Response, next: NextFunction) {
    try {
      const returns = await ReturnModel.find().populate('processedBy', 'name').sort({ createdAt: -1 });
      return ApiResponse.success(res, 'Returns retrieved successfully', returns);
    } catch (error) {
      next(error);
    }
  }
}
