import mongoose, { Schema, Document } from 'mongoose';

export interface IChatMessage extends Document {
  sender: mongoose.Types.ObjectId;
  receiver?: mongoose.Types.ObjectId;
  content: string;
  senderRole: 'user' | 'support';
  conversationId: string;
  createdAt: Date;
  updatedAt: Date;
}

const ChatMessageSchema: Schema = new Schema(
  {
    sender:         { type: Schema.Types.ObjectId, ref: 'User', required: true },
    receiver:       { type: Schema.Types.ObjectId, ref: 'User', default: null },
    content:        { type: String, required: true, trim: true },
    senderRole:     { type: String, enum: ['user', 'support'], required: true },
    conversationId: { type: String, required: true, index: true },
  },
  { timestamps: true }
);

export default mongoose.model<IChatMessage>('ChatMessage', ChatMessageSchema);
