import { Router } from 'express';
import { PurchaseController } from './purchase.controller';
import { authenticate, authorize } from '../../middleware/auth';

const router = Router();

router.use(authenticate);

router.post('/', authorize(['ADMIN', 'MANAGER', 'STOCK_STAFF']), PurchaseController.createPurchase);
router.get('/', authorize(['ADMIN', 'MANAGER', 'STOCK_STAFF']), PurchaseController.getPurchases);
router.post('/:id/receive', authorize(['ADMIN', 'MANAGER']), PurchaseController.receivePurchase);

export { router as purchaseRoutes };
