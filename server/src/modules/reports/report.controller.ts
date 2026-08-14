import { Request, Response, NextFunction } from 'express';
import { SaleModel } from '../sales/sale.model';
import { ExpenseModel } from '../expenses/expense.model';
import { ProductModel } from '../products/product.model';
import { ApiResponse } from '../../utils/apiResponse';

export class ReportController {
  static async getSales(req: Request, res: Response, next: NextFunction) {
    try {
      const { period } = req.query; // e.g. 'today', 'week', 'month'
      // Aggregate sales data based on period
      // For simplicity, we just return total sum
      const sales = await SaleModel.aggregate([
        { $match: { status: 'COMPLETED' } },
        { $group: { _id: null, totalSales: { $sum: '$totalAmount' }, count: { $sum: 1 } } }
      ]);
      
      return ApiResponse.success(res, 'Sales report', sales[0] || { totalSales: 0, count: 0 });
    } catch (error) {
      next(error);
    }
  }

  static async getProfitLoss(req: Request, res: Response, next: NextFunction) {
    try {
      // Calculate total sales
      const salesData = await SaleModel.aggregate([
        { $match: { status: 'COMPLETED' } },
        { $group: { _id: null, totalRevenue: { $sum: '$totalAmount' } } }
      ]);
      const totalRevenue = salesData[0]?.totalRevenue || 0;

      // Calculate COGS (Cost of Goods Sold) based on items sold
      // This is a simplified COGS
      const cogsData = await SaleModel.aggregate([
        { $match: { status: 'COMPLETED' } },
        { $unwind: '$items' },
        // Normally we'd look up the exact cost at time of sale, but here we simplify
        { $lookup: { from: 'products', localField: 'items.productId', foreignField: '_id', as: 'product' } },
        { $unwind: '$product' },
        { $group: { _id: null, totalCogs: { $sum: { $multiply: ['$items.quantity', '$product.costPrice'] } } } }
      ]);
      const totalCogs = cogsData[0]?.totalCogs || 0;

      // Calculate total expenses
      const expenseData = await ExpenseModel.aggregate([
        { $group: { _id: null, totalExpenses: { $sum: '$amount' } } }
      ]);
      const totalExpenses = expenseData[0]?.totalExpenses || 0;

      const grossProfit = totalRevenue - totalCogs;
      const netProfit = grossProfit - totalExpenses;

      return ApiResponse.success(res, 'Profit and Loss report', {
        totalRevenue,
        totalCogs,
        grossProfit,
        totalExpenses,
        netProfit
      });
    } catch (error) {
      next(error);
    }
  }

  static async getInventoryValuation(req: Request, res: Response, next: NextFunction) {
    try {
      const valuationData = await ProductModel.aggregate([
        { $match: { stockQuantity: { $gt: 0 } } },
        { $group: { 
            _id: null, 
            totalItems: { $sum: '$stockQuantity' },
            totalValue: { $sum: { $multiply: ['$stockQuantity', '$costPrice'] } },
            retailValue: { $sum: { $multiply: ['$stockQuantity', '$price'] } }
        }}
      ]);

      return ApiResponse.success(res, 'Inventory Valuation', valuationData[0] || { totalItems: 0, totalValue: 0, retailValue: 0 });
    } catch (error) {
      next(error);
    }
  }
}
