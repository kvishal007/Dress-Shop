import mongoose, { Schema, Document } from 'mongoose';

export interface ISupplier extends Document {
  name: string;
  contactPerson: string;
  phone: string;
  email?: string;
  payablesDue: number;
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
}

const supplierSchema = new Schema<ISupplier>(
  {
    name: { type: String, required: true },
    contactPerson: { type: String, required: true },
    phone: { type: String, required: true, unique: true },
    email: { type: String },
    payablesDue: { type: Number, default: 0 },
    isActive: { type: Boolean, default: true },
  },
  { timestamps: true }
);

export const SupplierModel = mongoose.model<ISupplier>('Supplier', supplierSchema);
