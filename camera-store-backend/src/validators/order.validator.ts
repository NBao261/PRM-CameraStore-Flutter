import { body } from 'express-validator';

export const checkoutValidator = [
  body('shippingInfo.fullName').notEmpty().withMessage('Tên người nhận là bắt buộc'),
  body('shippingInfo.phone').notEmpty().withMessage('Số điện thoại là bắt buộc'),
  body('shippingInfo.address').notEmpty().withMessage('Địa chỉ giao hàng là bắt buộc'),
  body('paymentMethod')
    .isIn(['cod', 'bank_transfer', 'e_wallet'])
    .withMessage('Phương thức thanh toán không hợp lệ'),
];
