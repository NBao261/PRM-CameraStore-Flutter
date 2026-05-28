import mongoose, { Schema, Document } from 'mongoose';

export type NotificationType = 'order' | 'promotion' | 'system' | 'product';

export interface INotification extends Document {
  user: mongoose.Types.ObjectId;
  title: string;
  content: string;
  type: NotificationType;
  isRead: boolean;
  relatedId?: string;   // e.g. order ID or product ID
  relatedType?: string; // e.g. 'order', 'product'
  createdAt: Date;
  updatedAt: Date;
}

const NotificationSchema: Schema = new Schema(
  {
    user:        { type: Schema.Types.ObjectId, ref: 'User', required: true },
    title:       { type: String, required: true },
    content:     { type: String, required: true },
    type:        { type: String, enum: ['order', 'promotion', 'system', 'product'], default: 'system' },
    isRead:      { type: Boolean, default: false },
    relatedId:   { type: String, default: null },
    relatedType: { type: String, default: null },
  },
  { timestamps: true }
);

export default mongoose.model<INotification>('Notification', NotificationSchema);
