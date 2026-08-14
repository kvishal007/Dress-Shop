import { Request, Response, NextFunction } from 'express';
import { CustomerModel } from './customer.model';
import { ApiResponse } from '../../utils/apiResponse';
import { ApiError } from '../../utils/apiError';

export class CustomerController {
  static async createCustomer(req: Request, res: Response, next: NextFunction) {
    try {
      const { name, email, phone, address } = req.body;
      const existing = await CustomerModel.findOne({ phone });
      if (existing) {
        throw ApiError.badRequest('Customer with this phone already exists');
      }

      const customer = new CustomerModel({ name, email, phone, address });
      await customer.save();

      return ApiResponse.created(res, 'Customer created successfully', customer);
    } catch (error) {
      next(error);
    }
  }

  static async getCustomers(req: Request, res: Response, next: NextFunction) {
    try {
      const { search } = req.query;
      const query: any = {};
      
      if (search && typeof search === 'string') {
        query.$or = [
          { name: { $regex: search, $options: 'i' } },
          { phone: { $regex: search, $options: 'i' } },
        ];
      }

      const customers = await CustomerModel.find(query).sort({ createdAt: -1 });
      return ApiResponse.success(res, 'Customers retrieved successfully', customers);
    } catch (error) {
      next(error);
    }
  }

  static async updateCustomer(req: Request, res: Response, next: NextFunction) {
    try {
      const { id } = req.params;
      const customer = await CustomerModel.findByIdAndUpdate(id, req.body, { new: true });
      if (!customer) throw ApiError.notFound('Customer not found');
      
      return ApiResponse.success(res, 'Customer updated', customer);
    } catch (error) {
      next(error);
    }
  }

  static async deleteCustomer(req: Request, res: Response, next: NextFunction) {
    try {
      const { id } = req.params;
      const customer = await CustomerModel.findByIdAndDelete(id);
      if (!customer) throw ApiError.notFound('Customer not found');
      
      return ApiResponse.success(res, 'Customer deleted');
    } catch (error) {
      next(error);
    }
  }
}
