import { Router } from 'express';
import { ReportController } from './report.controller';
import { authenticate, authorize } from '../../middleware/auth';

const router = Router();

router.use(authenticate);

router.get('/sales', authorize(['ADMIN', 'MANAGER', 'VIEWER']), ReportController.getSales);
router.get('/profit-loss', authorize(['ADMIN', 'MANAGER', 'VIEWER']), ReportController.getProfitLoss);
router.get('/inventory-valuation', authorize(['ADMIN', 'MANAGER', 'VIEWER']), ReportController.getInventoryValuation);

export { router as reportRoutes };
