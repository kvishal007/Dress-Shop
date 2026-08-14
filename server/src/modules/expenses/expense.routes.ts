import { Router } from 'express';
import { ExpenseController } from './expense.controller';
import { authenticate, authorize } from '../../middleware/auth';

const router = Router();

router.use(authenticate);

router.post('/', authorize(['ADMIN', 'MANAGER']), ExpenseController.createExpense);
router.get('/', authorize(['ADMIN', 'MANAGER', 'VIEWER']), ExpenseController.getExpenses);
router.put('/:id', authorize(['ADMIN', 'MANAGER']), ExpenseController.updateExpense);
router.delete('/:id', authorize(['ADMIN', 'MANAGER']), ExpenseController.deleteExpense);

export { router as expenseRoutes };
