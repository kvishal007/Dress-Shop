import { Router } from 'express';
import { ProductController } from './product.controller';
import { authenticate, authorize } from '../../middleware/auth';
import { validateRequest } from '../../middleware/validate';
import { createProductSchema, updateProductSchema, createCategorySchema } from './product.validation';

const router = Router();

// Protect all product routes with authentication
router.use(authenticate);

// Category routes
router.get('/categories', ProductController.getCategories);
router.post(
  '/categories',
  authorize(['ADMIN', 'MANAGER']),
  validateRequest(createCategorySchema),
  ProductController.createCategory
);

// Product routes
router.get('/products', ProductController.getProducts);
router.get('/products/scan/:code', ProductController.scanProduct);
router.get('/products/:id', ProductController.getProductById);
router.post(
  '/products',
  authorize(['ADMIN', 'MANAGER']),
  validateRequest(createProductSchema),
  ProductController.createProduct
);
router.put(
  '/products/:id',
  authorize(['ADMIN', 'MANAGER']),
  validateRequest(updateProductSchema),
  ProductController.updateProduct
);
router.delete(
  '/products/:id',
  authorize(['ADMIN']),
  ProductController.deleteProduct
);

export const productRoutes = router;
