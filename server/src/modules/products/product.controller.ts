import { Request, Response, NextFunction } from 'express';
import { ProductService } from './product.service';
import { ApiResponse } from '../../utils/apiResponse';

export class ProductController {
  static async getCategories(req: Request, res: Response, next: NextFunction) {
    try {
      const categories = await ProductService.getCategories();
      return ApiResponse.success(res, 'Categories retrieved successfully', categories);
    } catch (error) {
      next(error);
    }
  }

  static async createCategory(req: Request, res: Response, next: NextFunction) {
    try {
      const category = await ProductService.createCategory(req.body);
      return ApiResponse.created(res, 'Category created successfully', category);
    } catch (error) {
      next(error);
    }
  }

  static async getProducts(req: Request, res: Response, next: NextFunction) {
    try {
      const search = req.query.search as string;
      const category = req.query.category as string;
      const products = await ProductService.getProducts({ search, category });
      return ApiResponse.success(res, 'Products retrieved successfully', products);
    } catch (error) {
      next(error);
    }
  }

  static async getProductById(req: Request, res: Response, next: NextFunction) {
    try {
      const product = await ProductService.getProductById(req.params.id);
      return ApiResponse.success(res, 'Product retrieved successfully', product);
    } catch (error) {
      next(error);
    }
  }

  static async scanProduct(req: Request, res: Response, next: NextFunction) {
    try {
      const product = await ProductService.getProductByScanCode(req.params.code);
      return ApiResponse.success(res, 'Product retrieved successfully', product);
    } catch (error) {
      next(error);
    }
  }

  static async createProduct(req: Request, res: Response, next: NextFunction) {
    try {
      const product = await ProductService.createProduct(req.body);
      return ApiResponse.created(res, 'Product created successfully', product);
    } catch (error) {
      next(error);
    }
  }

  static async updateProduct(req: Request, res: Response, next: NextFunction) {
    try {
      const product = await ProductService.updateProduct(req.params.id, req.body);
      return ApiResponse.success(res, 'Product updated successfully', product);
    } catch (error) {
      next(error);
    }
  }

  static async deleteProduct(req: Request, res: Response, next: NextFunction) {
    try {
      await ProductService.deleteProduct(req.params.id);
      return ApiResponse.success(res, 'Product deleted successfully');
    } catch (error) {
      next(error);
    }
  }
}
