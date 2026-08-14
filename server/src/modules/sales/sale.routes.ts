import { Router } from 'express';
import { SaleController } from './sale.controller';
import { authenticate, authorize } from '../../middleware/auth';

const router = Router();

// Protect all sales routes
router.use(authenticate);

router.post('/', authorize(['ADMIN', 'MANAGER', 'CASHIER']), SaleController.createSale);
router.get('/', authorize(['ADMIN', 'MANAGER', 'CASHIER', 'VIEWER']), SaleController.getSales);
router.get('/:id', authorize(['ADMIN', 'MANAGER', 'CASHIER', 'VIEWER']), SaleController.getSaleById);
router.patch('/:id/void', authorize(['ADMIN']), SaleController.voidSale);

export { router as saleRoutes };
