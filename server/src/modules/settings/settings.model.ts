import mongoose, { Schema, Document } from 'mongoose';

export interface IShopSettings extends Document {
  shopName: string;
  currency: string;
  taxRate: number;
  receiptFormat: 'STANDARD' | 'THERMAL' | 'A4';
  address: string;
  phone: string;
}

const shopSettingsSchema = new Schema<IShopSettings>(
  {
    shopName: { type: String, required: true, default: 'Smart Dress Shop' },
    currency: { type: String, required: true, default: 'INR' },
    taxRate: { type: Number, required: true, default: 0 },
    receiptFormat: { type: String, enum: ['STANDARD', 'THERMAL', 'A4'], default: 'THERMAL' },
    address: { type: String, default: '' },
    phone: { type: String, default: '' },
  },
  { timestamps: true }
);

export const ShopSettings = mongoose.model<IShopSettings>('ShopSettings', shopSettingsSchema);
