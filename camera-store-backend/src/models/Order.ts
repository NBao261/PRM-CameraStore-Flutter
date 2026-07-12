import mongoose, { Schema, Document } from 'mongoose';

export interface IOrderItem {
  product: mongoose.Types.ObjectId;
  name: string;
  price: number;
  quantity: number;
  imageUrl: string;
}

export type OrderStatus = 'pending' | 'confirmed' | 'shipping' | 'delivered' | 'cancelled';

export interface IOrder extends Document {
  user: mongoose.Types.ObjectId;
  items: IOrderItem[];
  shippingInfo: {
    fullName: string;
    phone: string;
    address: string;
    note?: string;
  };
  paymentMethod: 'cod' | 'bank_transfer' | 'e_wallet';
  paymentStatus: 'unpaid' | 'paid' | 'failed';
  couponCode?: string;
  discountAmount: number;
  subtotal: number;
  shippingFee: number;
  total: number;
  status: OrderStatus;
  statusHistory: { status: OrderStatus; changedAt: Date }[];
  createdAt: Date;
  updatedAt: Date;
}

const OrderSchema: Schema = new Schema(
  {
    user: { type: Schema.Types.ObjectId, ref: 'User', required: true },
    items: [
      {
        product:  { type: Schema.Types.ObjectId, ref: 'Product', required: true },
        name:     { type: String, required: true },
        price:    { type: Number, required: true },
        quantity: { type: Number, required: true, min: 1 },
        imageUrl: { type: String, required: true },
      },
    ],
    shippingInfo: {
      fullName: { type: String, required: true },
      phone:    { type: String, required: true },
      address:  { type: String, required: true },
      note:     { type: String, default: '' },
    },
    paymentMethod: {
      type: String,
      enum: ['cod', 'bank_transfer', 'e_wallet'],
      required: true,
    },
    paymentStatus: {
      type: String,
      enum: ['unpaid', 'paid', 'failed'],
      default: 'unpaid',
    },
    couponCode:     { type: String, default: null },
    discountAmount: { type: Number, default: 0 },
    subtotal:       { type: Number, required: true },
    shippingFee:    { type: Number, default: 0 },
    total:          { type: Number, required: true },
    status: {
      type: String,
      enum: ['pending', 'confirmed', 'shipping', 'delivered', 'cancelled'],
      default: 'pending',
    },
    statusHistory: [
      {
        status:    { type: String },
        changedAt: { type: Date, default: Date.now },
      },
    ],
  },
  { timestamps: true }
);

export default mongoose.model<IOrder>('Order', OrderSchema);
