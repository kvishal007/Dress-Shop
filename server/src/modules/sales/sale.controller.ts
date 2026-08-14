import { Request, Response, NextFunction } from 'express';
import { SaleModel } from './sale.model';
import { ProductModel } from '../products/product.model';
import { ApiResponse } from '../../utils/apiResponse';
import { ApiError } from '../../utils/apiError';
import mongoose from 'mongoose';

export class SaleController {
  static async createSale(req: Request, res: Response, next: NextFunction) {
    const session = await mongoose.startSession();
    session.startTransaction();

    try {
      const { items, paymentMethod, taxAmount = 0, discountAmount = 0, customerId } = req.body;
      const cashierId = (req as any).user.userId;

      if (!items || !items.length) {
        throw ApiError.badRequest('Sale must contain at least one item');
      }

      let subtotal = 0;
      const saleItems = [];

      for (const item of items) {
        const product = await ProductModel.findOne({ sku: item.sku }).session(session);
        
        if (!product) {
          throw ApiError.notFound(`Product with SKU ${item.sku} not found`);
        }

        if (product.stockQuantity < item.quantity) {
          throw ApiError.badRequest(`Insufficient stock for ${product.name}`);
        }

        // Deduct stock
        product.stockQuantity -= item.quantity;
        await product.save({ session });

        const itemSubtotal = product.price * item.quantity;
        subtotal += itemSubtotal;

        saleItems.push({
          productId: product._id,
          productName: product.name,
          sku: product.sku,
          quantity: item.quantity,
          unitPrice: product.price,
          subtotal: itemSubtotal,
        });
      }

      const totalAmount = subtotal + taxAmount - discountAmount;
      const invoiceNumber = `INV-${Date.now()}`;

      const sale = new SaleModel({
        invoiceNumber,
        cashierId,
        ...(customerId && { customerId }),
        items: saleItems,
        subtotal,
        taxAmount,
        discountAmount,
        totalAmount,
        paymentMethod,
      });

      await sale.save({ session });
      await session.commitTransaction();
      
      return ApiResponse.created(res, 'Sale completed successfully', sale);
    } catch (error) {
      await session.abortTransaction();
      next(error);
    } finally {
      session.endSession();
    }
  }

  static async getSales(req: Request, res: Response, next: NextFunction) {
    try {
      const query: any = {};
      const { date } = req.query;
      
      if (date) {
        const startDate = new Date(date as string);
        startDate.setHours(0, 0, 0, 0);
        const endDate = new Date(date as string);
        endDate.setHours(23, 59, 59, 999);
        query.createdAt = { $gte: startDate, $lte: endDate };
      }

      // If user is Cashier, only show their own sales
      if ((req as any).user.role === 'CASHIER') {
        query.cashierId = (req as any).user.userId;
      }

      const sales = await SaleModel.find(query).sort({ createdAt: -1 }).limit(50);
      return ApiResponse.success(res, 'Sales retrieved successfully', sales);
    } catch (error) {
      next(error);
    }
  }

  static async getSaleById(req: Request, res: Response, next: NextFunction) {
    try {
      const { id } = req.params;
      const sale = await SaleModel.findById(id).populate('cashierId', 'name').populate('customerId', 'name phone');
      if (!sale) throw ApiError.notFound('Sale not found');

      // Cashiers can only view their own sales
      if ((req as any).user.role === 'CASHIER' && sale.cashierId.toString() !== (req as any).user.userId) {
        throw ApiError.forbidden('You can only view your own sales');
      }

      return ApiResponse.success(res, 'Sale retrieved successfully', sale);
    } catch (error) {
      next(error);
    }
  }
}
