import { momoService } from './src/services/momo.service';

const id = '6a53ebb8161d80d0a7dc8d0c';
const total = 55990000;

momoService.createPaymentUrl({
  orderId: id,
  amount: total,
  orderInfo: `Thanh toán đơn hàng #${id} tại Camera Store`,
}).then(url => {
  console.log('PAY URL:', url);
  process.exit(0);
}).catch(err => {
  console.error('ERROR:', err);
  process.exit(1);
});
