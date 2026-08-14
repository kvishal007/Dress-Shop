import mongoose, { Schema } from 'mongoose';
import { ISale } from './sale.interface';

const saleItemSchema = new Schema(
  {
    productId: { type: Schema.Types.ObjectId, ref: 'Product', required: true },
    productName: { type: String, required: true },
    sku: { type: String, required: true },
    quantity: { type: Number, required: true, min: 1 },
    unitPrice: { type: Number, required: true, min: 0 },
    subtotal: { type: Number, required: true, min: 0 },
  },
  { _id: false }
);

const saleSchema = new Schema<ISale>(
  {
    invoiceNumber: { type: String, required: true, unique: true },
    cashierId: { type: Schema.Types.ObjectId, ref: 'User', required: true },
    customerId: { type: Schema.Types.ObjectId, ref: 'Customer' },
    shopId: { type: String, default: 'main_shop' },
    items: [saleItemSchema],
    subtotal: { type: Number, required: true, min: 0 },
    taxAmount: { type: Number, default: 0, min: 0 },
    discountAmount: { type: Number, default: 0, min: 0 },
    totalAmount: { type: Number, required: true, min: 0 },
    paymentMethod: {
      type: String,
      enum: ['CASH', 'CARD', 'UPI', 'OTHER'],
      default: 'CASH',
    },
    status: {
      type: String,
      enum: ['COMPLETED', 'REFUNDED', 'CANCELLED'],
      default: 'COMPLETED',
    },
  },
  { timestamps: true }
);

// Indexes for common queries
saleSchema.index({ invoiceNumber: 1 });
saleSchema.index({ cashierId: 1, createdAt: -1 });
saleSchema.index({ createdAt: -1 });

export const SaleModel = mongoose.model<ISale>('Sale', saleSchema);
