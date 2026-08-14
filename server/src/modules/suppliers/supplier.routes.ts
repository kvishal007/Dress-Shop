import { Router } from 'express';
import { SupplierController } from './supplier.controller';
import { authenticate, authorize } from '../../middleware/auth';

const router = Router();

router.use(authenticate);

router.post('/', authorize(['ADMIN', 'MANAGER']), SupplierController.createSupplier);
router.get('/', authorize(['ADMIN', 'MANAGER', 'STOCK_STAFF']), SupplierController.getSuppliers);
router.put('/:id', authorize(['ADMIN', 'MANAGER']), SupplierController.updateSupplier);
router.delete('/:id', authorize(['ADMIN', 'MANAGER']), SupplierController.deleteSupplier);

export { router as supplierRoutes };
