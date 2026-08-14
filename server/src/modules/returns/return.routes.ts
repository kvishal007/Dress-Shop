import { Router } from 'express';
import { ReturnController } from './return.controller';
import { authenticate, authorize } from '../../middleware/auth';

const router = Router();

router.use(authenticate);

router.post('/', authorize(['ADMIN', 'MANAGER']), ReturnController.processReturn);
router.get('/', authorize(['ADMIN', 'MANAGER']), ReturnController.getReturns);

export { router as returnRoutes };
