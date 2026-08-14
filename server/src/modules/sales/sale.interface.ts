import { Document, Types } from 'mongoose';

export interface ISaleItem {
  productId: Types.ObjectId | string;
  productName: string;
  sku: string;
  quantity: number;
  unitPrice: number;
  subtotal: number;
}

export interface ISale extends Document {
  invoiceNumber: string;
  cashierId: Types.ObjectId | string;
  shopId: string;
  items: ISaleItem[];
  subtotal: number;
  taxAmount: number;
  discountAmount: number;
  totalAmount: number;
  paymentMethod: 'CASH' | 'CARD' | 'UPI' | 'OTHER';
  status: 'COMPLETED' | 'REFUNDED' | 'CANCELLED';
  createdAt: Date;
  updatedAt: Date;
}
