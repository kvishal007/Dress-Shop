import mongoose, { Schema, Document } from 'mongoose';

export interface IPurchaseItem {
  productId: mongoose.Types.ObjectId;
  productName: string;
  sku: string;
  quantity: number;
  costPrice: number;
  subtotal: number;
}

export interface IPurchase extends Document {
  poNumber: string;
  supplierId: mongoose.Types.ObjectId;
  items: IPurchaseItem[];
  totalAmount: number;
  status: 'PENDING' | 'PARTIAL' | 'RECEIVED' | 'CANCELLED';
  orderedBy: mongoose.Types.ObjectId;
  receivedAt?: Date;
  createdAt: Date;
  updatedAt: Date;
}

const purchaseItemSchema = new Schema(
  {
    productId: { type: Schema.Types.ObjectId, ref: 'Product', required: true },
    productName: { type: String, required: true },
    sku: { type: String, required: true },
    quantity: { type: Number, required: true, min: 1 },
    costPrice: { type: Number, required: true, min: 0 },
    subtotal: { type: Number, required: true, min: 0 },
  },
  { _id: false }
);

const purchaseSchema = new Schema<IPurchase>(
  {
    poNumber: { type: String, required: true, unique: true },
    supplierId: { type: Schema.Types.ObjectId, ref: 'Supplier', required: true },
    items: [purchaseItemSchema],
    totalAmount: { type: Number, required: true, min: 0 },
    status: {
      type: String,
      enum: ['PENDING', 'PARTIAL', 'RECEIVED', 'CANCELLED'],
      default: 'PENDING',
    },
    orderedBy: { type: Schema.Types.ObjectId, ref: 'User', required: true },
    receivedAt: { type: Date },
  },
  { timestamps: true }
);

export const PurchaseModel = mongoose.model<IPurchase>('Purchase', purchaseSchema);
