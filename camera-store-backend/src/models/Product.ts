import mongoose, { Schema, Document } from 'mongoose';

export interface IProductSpecs {
  megapixel?: string;
  sensor?: string;       // Full-frame, APS-C, Micro Four Thirds
  isoRange?: string;
  lensType?: string;     // Kit lens info
  video?: string;        // 4K, Full HD
  connectivity?: string; // Wi-Fi, Bluetooth, NFC
  battery?: string;
  weight?: string;
}

export interface IProduct extends Document {
  name: string;
  brand: mongoose.Types.ObjectId;
  category: mongoose.Types.ObjectId;
  images: string[];
  price: number;
  salePrice?: number;
  description: string;
  specs: IProductSpecs;
  stock: number;
  isActive: boolean;
  warranty?: string;
  averageRating: number;
  reviewCount: number;
  createdAt: Date;
  updatedAt: Date;
}

const ProductSchema: Schema = new Schema(
  {
    name:        { type: String, required: true, trim: true },
    brand:       { type: Schema.Types.ObjectId, ref: 'Brand', required: true },
    category:    { type: Schema.Types.ObjectId, ref: 'Category', required: true },
    images:      [{ type: String }],
    price:       { type: Number, required: true, min: 0 },
    salePrice:   { type: Number, default: null },
    description: { type: String, default: '' },
    specs: {
      megapixel:    { type: String, default: '' },
      sensor:       { type: String, default: '' },
      isoRange:     { type: String, default: '' },
      lensType:     { type: String, default: '' },
      video:        { type: String, default: '' },
      connectivity: { type: String, default: '' },
      battery:      { type: String, default: '' },
      weight:       { type: String, default: '' },
    },
    stock:         { type: Number, required: true, default: 0, min: 0 },
    isActive:      { type: Boolean, default: true },
    warranty:      { type: String, default: '' },
    averageRating: { type: Number, default: 0 },
    reviewCount:   { type: Number, default: 0 },
  },
  { timestamps: true }
);

// Virtual field for inStock status
ProductSchema.virtual('inStock').get(function (this: IProduct) {
  return this.stock > 0;
});

ProductSchema.set('toJSON', { virtuals: true });

export default mongoose.model<IProduct>('Product', ProductSchema);
