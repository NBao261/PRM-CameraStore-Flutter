import { Request, Response } from 'express';
import { momoService } from '../services/momo.service';
import Order from '../models/Order';

export const handleMoMoIPN = async (req: Request, res: Response): Promise<void> => {
  try {
    const data = req.body;
    
    // 1. Verify signature
    const isValid = momoService.verifySignature(data);
    if (!isValid) {
      console.error('MoMo IPN Signature invalid');
      res.status(400).json({ message: 'Invalid signature' });
      return;
    }

    // 2. Check result code
    const orderId = data.orderId;
    const resultCode = data.resultCode;

    const order = await Order.findById(orderId);
    if (!order) {
      res.status(404).json({ message: 'Order not found' });
      return;
    }

    if (resultCode === 0) {
      // Payment success
      if (order.paymentStatus !== 'paid') {
        order.paymentStatus = 'paid';
        // Optionally update the overall order status to confirmed
        order.status = 'confirmed';
        order.statusHistory.push({ status: 'confirmed', changedAt: new Date() });
        await order.save();
      }
    } else {
      // Payment failed
      if (order.paymentStatus !== 'failed') {
        order.paymentStatus = 'failed';
        await order.save();
      }
    }

    // MoMo requires 204 No Content for IPN success
    res.status(204).send();
  } catch (error) {
    console.error('IPN Error:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

export const handleMoMoCallback = async (req: Request, res: Response): Promise<void> => {
  try {
    const data = req.query;
    
    // 1. Verify signature
    const isValid = momoService.verifySignature(data);
    if (!isValid) {
      console.error('MoMo Callback Signature invalid');
      res.status(400).json({ message: 'Invalid signature' });
      return;
    }

    // 2. Check result code
    const orderId = data.orderId as string;
    const resultCode = parseInt(data.resultCode as string, 10);

    const order = await Order.findById(orderId);
    if (!order) {
      res.status(404).json({ message: 'Order not found' });
      return;
    }

    if (resultCode === 0) {
      // Payment success
      if (order.paymentStatus !== 'paid') {
        order.paymentStatus = 'paid';
        order.status = 'confirmed';
        order.statusHistory.push({ status: 'confirmed', changedAt: new Date() });
        await order.save();
      }
    } else {
      // Payment failed
      if (order.paymentStatus !== 'failed') {
        order.paymentStatus = 'failed';
        await order.save();
      }
    }

    res.status(200).json({ message: 'Payment status updated successfully', orderId, paymentStatus: order.paymentStatus });
  } catch (error) {
    console.error('Callback Error:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};
