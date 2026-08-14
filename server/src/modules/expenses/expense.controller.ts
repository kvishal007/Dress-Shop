import { Request, Response, NextFunction } from 'express';
import { ExpenseModel } from './expense.model';
import { ApiResponse } from '../../utils/apiResponse';
import { ApiError } from '../../utils/apiError';

export class ExpenseController {
  static async createExpense(req: Request, res: Response, next: NextFunction) {
    try {
      const { category, amount, date, note } = req.body;
      const recordedBy = (req as any).user.userId;

      const expense = new ExpenseModel({ category, amount, date, note, recordedBy });
      await expense.save();

      return ApiResponse.created(res, 'Expense created successfully', expense);
    } catch (error) {
      next(error);
    }
  }

  static async getExpenses(req: Request, res: Response, next: NextFunction) {
    try {
      const expenses = await ExpenseModel.find().populate('recordedBy', 'name').sort({ date: -1 });
      return ApiResponse.success(res, 'Expenses retrieved successfully', expenses);
    } catch (error) {
      next(error);
    }
  }

  static async updateExpense(req: Request, res: Response, next: NextFunction) {
    try {
      const { id } = req.params;
      const expense = await ExpenseModel.findByIdAndUpdate(id, req.body, { new: true });
      if (!expense) throw ApiError.notFound('Expense not found');
      
      return ApiResponse.success(res, 'Expense updated', expense);
    } catch (error) {
      next(error);
    }
  }

  static async deleteExpense(req: Request, res: Response, next: NextFunction) {
    try {
      const { id } = req.params;
      const expense = await ExpenseModel.findByIdAndDelete(id);
      if (!expense) throw ApiError.notFound('Expense not found');
      
      return ApiResponse.success(res, 'Expense deleted');
    } catch (error) {
      next(error);
    }
  }
}
