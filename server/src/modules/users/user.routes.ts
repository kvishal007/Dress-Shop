import { Router } from 'express';
import { UserController } from './user.controller';
import { authenticate, authorize } from '../../middleware/auth';

const router = Router();

router.use(authenticate);

router.get('/', authorize(['ADMIN']), UserController.getUsers);
router.patch('/:id/deactivate', authorize(['ADMIN']), UserController.deactivateUser);
router.patch('/:id/reset-password', authorize(['ADMIN']), UserController.resetPassword);
router.patch('/:id/role', authorize(['ADMIN']), UserController.updateRole);

export { router as userRoutes };
