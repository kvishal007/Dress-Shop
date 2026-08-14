import { Router } from 'express';
import { AuditController } from './audit.controller';
import { authenticate, authorize } from '../../middleware/auth';

const router = Router();

router.use(authenticate);
router.get('/', authorize(['ADMIN']), AuditController.getLogs);

export { router as auditRoutes };
