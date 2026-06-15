import crypto from 'crypto';
import config from '../config/env';

interface MoMoPaymentRequest {
  orderId: string;
  amount: number;
  orderInfo: string;
}

export class MoMoService {
  // Test credentials for MoMo Sandbox (can be overridden by .env)
  private partnerCode = config.momo.partnerCode; 
  private accessKey = config.momo.accessKey;
  private secretKey = config.momo.secretKey;
  private apiUrl = config.momo.apiUrl + '/v2/gateway/api/create';
  
  // URL to redirect back to App after payment. Note: we will use a custom scheme or just a dummy URL for webview interception.
  private redirectUrl = config.momo.returnUrl;
  private ipnUrl = config.momo.ipnUrl;

  async createPaymentUrl(data: MoMoPaymentRequest): Promise<string> {
    const requestId = data.orderId + "_" + new Date().getTime(); // Prevent duplicate requestId
    const orderId = data.orderId;
    const amount = data.amount;
    const orderInfo = data.orderInfo;
    const requestType = 'payWithMethod';
    const extraData = '';
    
    const rawSignature = `accessKey=${this.accessKey}&amount=${amount}&extraData=${extraData}&ipnUrl=${this.ipnUrl}&orderId=${orderId}&orderInfo=${orderInfo}&partnerCode=${this.partnerCode}&redirectUrl=${this.redirectUrl}&requestId=${requestId}&requestType=${requestType}`;
    
    const signature = crypto
      .createHmac('sha256', this.secretKey)
      .update(rawSignature)
      .digest('hex');

    const requestBody = {
      partnerCode: this.partnerCode,
      partnerName: "Camera Store",
      storeId: "CameraStore1",
      requestId: requestId,
      amount: amount,
      orderId: orderId,
      orderInfo: orderInfo,
      redirectUrl: this.redirectUrl,
      ipnUrl: this.ipnUrl,
      lang: "vi",
      requestType: requestType,
      autoCapture: true,
      extraData: extraData,
      signature: signature
    };

    const response = await fetch(this.apiUrl, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(requestBody)
    });

    const responseData = await response.json() as any;
    if (responseData.resultCode === 0) {
      return responseData.payUrl;
    } else {
      console.error('MoMo payment creation error:', responseData);
      throw new Error(`Lỗi khởi tạo thanh toán MoMo: ${responseData.message}`);
    }
  }

  verifySignature(data: any): boolean {
    const { partnerCode, orderId, requestId, amount, orderInfo, orderType, transId, resultCode, message, payType, responseTime, extraData, signature } = data;
    const rawSignature = `accessKey=${this.accessKey}&amount=${amount}&extraData=${extraData}&message=${message}&orderId=${orderId}&orderInfo=${orderInfo}&orderType=${orderType}&partnerCode=${partnerCode}&payType=${payType}&requestId=${requestId}&responseTime=${responseTime}&resultCode=${resultCode}&transId=${transId}`;
    
    const expectedSignature = crypto
      .createHmac('sha256', this.secretKey)
      .update(rawSignature)
      .digest('hex');

    return signature === expectedSignature;
  }
}

export const momoService = new MoMoService();
