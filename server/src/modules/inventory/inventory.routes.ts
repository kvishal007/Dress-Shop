import { Router } from 'express';
import { InventoryController } from './inventory.controller';
import { authenticate, authorize } from '../../middleware/auth';

const router = Router();

router.use(authenticate);

router.post('/adjust', authorize(['ADMIN', 'MANAGER']), InventoryController.adjustStock);
router.get('/product/:productId', authorize(['ADMIN', 'MANAGER', 'STOCK_STAFF']), InventoryController.getMovementHistory);

export { router as inventoryRoutes };
