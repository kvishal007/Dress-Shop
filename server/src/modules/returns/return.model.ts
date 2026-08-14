import mongoose, { Schema, Document } from 'mongoose';

export interface IReturnItem {
  productId: mongoose.Types.ObjectId;
  productName: string;
  sku: string;
  quantity: number;
  refundAmount: number;
  restock: boolean;
}

export interface IReturn extends Document {
  saleId: mongoose.Types.ObjectId;
  invoiceNumber: string;
  items: IReturnItem[];
  totalRefund: number;
  reason: string;
  processedBy: mongoose.Types.ObjectId;
  createdAt: Date;
  updatedAt: Date;
}

const returnItemSchema = new Schema(
  {
    productId: { type: Schema.Types.ObjectId, ref: 'Product', required: true },
    productName: { type: String, required: true },
    sku: { type: String, required: true },
    quantity: { type: Number, required: true, min: 1 },
    refundAmount: { type: Number, required: true, min: 0 },
    restock: { type: Boolean, default: true },
  },
  { _id: false }
);

const returnSchema = new Schema<IReturn>(
  {
    saleId: { type: Schema.Types.ObjectId, ref: 'Sale', required: true },
    invoiceNumber: { type: String, required: true },
    items: [returnItemSchema],
    totalRefund: { type: Number, required: true, min: 0 },
    reason: { type: String, required: true },
    processedBy: { type: Schema.Types.ObjectId, ref: 'User', required: true },
  },
  { timestamps: true }
);

export const ReturnModel = mongoose.model<IReturn>('Return', returnSchema);
