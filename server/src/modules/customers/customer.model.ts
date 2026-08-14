import mongoose, { Schema, Document } from 'mongoose';

export interface ICustomer extends Document {
  name: string;
  email?: string;
  phone: string;
  address?: string;
  loyaltyPoints: number;
  totalSpent: number;
  status: 'ACTIVE' | 'INACTIVE';
  createdAt: Date;
  updatedAt: Date;
}

const customerSchema = new Schema<ICustomer>(
  {
    name: { type: String, required: true },
    email: { type: String, lowercase: true, trim: true },
    phone: { type: String, required: true, unique: true },
    address: { type: String },
    loyaltyPoints: { type: Number, default: 0 },
    totalSpent: { type: Number, default: 0 },
    status: { type: String, enum: ['ACTIVE', 'INACTIVE'], default: 'ACTIVE' },
  },
  { timestamps: true }
);

export const CustomerModel = mongoose.model<ICustomer>('Customer', customerSchema);
