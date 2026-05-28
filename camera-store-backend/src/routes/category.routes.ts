import { Router } from 'express';
import { getCategories, getBrands } from '../controllers/category.controller';

const router = Router();

router.get('/categories', getCategories);
router.get('/brands', getBrands);

export default router;
