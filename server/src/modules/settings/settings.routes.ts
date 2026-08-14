import { Router } from 'express';
import { SettingsController } from './settings.controller';
import { authenticate, authorize } from '../../middleware/auth';

const router = Router();

router.use(authenticate);

// Everyone can read settings to know tax rates, currency, etc.
router.get('/', SettingsController.getSettings);

// Only ADMIN can update settings
router.patch('/', authorize(['ADMIN']), SettingsController.updateSettings);

export { router as settingsRoutes };
