import { Router } from 'express';
import { getStores } from '../controllers/store.controller';

const router = Router();

router.get('/', getStores);

export default router;
