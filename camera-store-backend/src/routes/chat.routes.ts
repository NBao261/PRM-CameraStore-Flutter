import { Router } from 'express';
import { sendMessage, getChatHistory } from '../controllers/chat.controller';
import authMiddleware from '../middlewares/auth';

const router = Router();

router.use(authMiddleware);

router.post('/', sendMessage);
router.get('/history', getChatHistory);

export default router;
