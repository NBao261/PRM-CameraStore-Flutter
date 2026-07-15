import { momoService } from './src/services/momo.service';

momoService.createPaymentUrl({
  orderId: 'test_order_' + Date.now(),
  amount: 100000,
  orderInfo: 'Test'
}).then(console.log).catch(console.error);
