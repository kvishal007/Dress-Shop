import { Request, Response, NextFunction } from 'express';
import { SupplierModel } from './supplier.model';
import { ApiResponse } from '../../utils/apiResponse';
import { ApiError } from '../../utils/apiError';

export class SupplierController {
  static async createSupplier(req: Request, res: Response, next: NextFunction) {
    try {
      const { name, contactPerson, phone, email } = req.body;
      const existing = await SupplierModel.findOne({ phone });
      if (existing) {
        throw ApiError.badRequest('Supplier with this phone already exists');
      }

      const supplier = new SupplierModel({ name, contactPerson, phone, email });
      await supplier.save();

      return ApiResponse.created(res, 'Supplier created successfully', supplier);
    } catch (error) {
      next(error);
    }
  }

  static async getSuppliers(req: Request, res: Response, next: NextFunction) {
    try {
      const suppliers = await SupplierModel.find().sort({ name: 1 });
      return ApiResponse.success(res, 'Suppliers retrieved successfully', suppliers);
    } catch (error) {
      next(error);
    }
  }

  static async updateSupplier(req: Request, res: Response, next: NextFunction) {
    try {
      const { id } = req.params;
      const supplier = await SupplierModel.findByIdAndUpdate(id, req.body, { new: true });
      if (!supplier) throw ApiError.notFound('Supplier not found');
      
      return ApiResponse.success(res, 'Supplier updated', supplier);
    } catch (error) {
      next(error);
    }
  }

  static async deleteSupplier(req: Request, res: Response, next: NextFunction) {
    try {
      const { id } = req.params;
      const supplier = await SupplierModel.findByIdAndDelete(id);
      if (!supplier) throw ApiError.notFound('Supplier not found');
      
      return ApiResponse.success(res, 'Supplier deleted');
    } catch (error) {
      next(error);
    }
  }
}
