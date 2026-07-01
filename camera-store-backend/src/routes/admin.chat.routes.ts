import { Router } from 'express';
import { getConversationList, getConversationMessages, sendAdminMessage } from '../controllers/admin.chat.controller';
import authMiddleware from '../middlewares/auth';
import adminAuth from '../middlewares/adminAuth';

const router = Router();

router.use(authMiddleware, adminAuth);

router.get('/conversations', getConversationList);
router.get('/conversations/:conversationId', getConversationMessages);
router.post('/conversations/:conversationId', sendAdminMessage);

export default router;
