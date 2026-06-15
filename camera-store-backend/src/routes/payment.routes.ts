import { Router } from 'express';
import { handleMoMoIPN, handleMoMoCallback } from '../controllers/payment.controller';

const router = Router();

// MoMo IPN endpoint - no auth required since MoMo will call this directly
router.post('/momo/ipn', handleMoMoIPN);

// MoMo Callback endpoint - for local testing sync via Flutter App
router.get('/momo/callback', handleMoMoCallback);

export default router;
