import mongoose, { Schema, Document } from 'mongoose';

export interface IStoreLocation extends Document {
  name: string;
  address: string;
  phone: string;
  openingHours: string;
  latitude: number;
  longitude: number;
  createdAt: Date;
  updatedAt: Date;
}

const StoreLocationSchema: Schema = new Schema(
  {
    name:         { type: String, required: true },
    address:      { type: String, required: true },
    phone:        { type: String, required: true },
    openingHours: { type: String, default: '8:00 – 21:00' },
    latitude:     { type: Number, required: true },
    longitude:    { type: Number, required: true },
  },
  { timestamps: true }
);

export default mongoose.model<IStoreLocation>('StoreLocation', StoreLocationSchema);
