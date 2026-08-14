import { Router } from 'express';
import { CustomerController } from './customer.controller';
import { authenticate, authorize } from '../../middleware/auth';

const router = Router();

router.use(authenticate);

router.post('/', authorize(['ADMIN', 'MANAGER', 'CASHIER']), CustomerController.createCustomer);
router.get('/', authorize(['ADMIN', 'MANAGER', 'CASHIER', 'VIEWER']), CustomerController.getCustomers);
router.put('/:id', authorize(['ADMIN', 'MANAGER']), CustomerController.updateCustomer);
router.delete('/:id', authorize(['ADMIN', 'MANAGER']), CustomerController.deleteCustomer);

export { router as customerRoutes };
