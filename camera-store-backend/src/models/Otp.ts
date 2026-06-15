import mongoose, { Schema, Document } from 'mongoose';

export interface IOtp extends Document {
  email: string;
  otp: string;
  data: any; // Store registration data temporarily
  createdAt: Date;
  expiresAt: Date;
}

const OtpSchema: Schema = new Schema(
  {
    email: { type: String, required: true, trim: true },
    otp: { type: String, required: true },
    data: { type: Schema.Types.Mixed, required: true },
    createdAt: { type: Date, default: Date.now },
    // OTP will expire and be automatically deleted from DB after 5 minutes (300 seconds)
    expiresAt: { type: Date, required: true, index: { expires: '0s' } },
  }
);

export default mongoose.model<IOtp>('Otp', OtpSchema);
