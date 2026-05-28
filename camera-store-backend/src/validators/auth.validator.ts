import { body } from 'express-validator';

export const registerValidator = [
  body('fullName').notEmpty().withMessage('Họ và tên là bắt buộc').trim(),
  body('email').isEmail().withMessage('Email không hợp lệ').normalizeEmail(),
  body('phone').notEmpty().withMessage('Số điện thoại là bắt buộc').trim(),
  body('password').isLength({ min: 6 }).withMessage('Mật khẩu phải có ít nhất 6 ký tự'),
  body('confirmPassword').custom((value, { req }) => {
    if (value !== req.body.password) {
      throw new Error('Xác nhận mật khẩu không khớp');
    }
    return true;
  }),
];

export const loginValidator = [
  body('email').isEmail().withMessage('Email không hợp lệ').normalizeEmail(),
  body('password').notEmpty().withMessage('Mật khẩu là bắt buộc'),
];

export const updateProfileValidator = [
  body('fullName').optional().notEmpty().withMessage('Họ và tên không được để trống').trim(),
  body('phone').optional().notEmpty().withMessage('Số điện thoại không được để trống').trim(),
  body('address').optional().trim(),
];
