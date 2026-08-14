import mongoose, { Schema, Document } from 'mongoose';

export interface IProduct extends Document {
  name: string;
  sku: string;
  barcode?: string;
  categoryId?: mongoose.Types.ObjectId;
  categoryName: string;
  description?: string;
  price: number;
  costPrice?: number;
  stockQuantity: number;
  minStockLevel: number;
  sizes: string[];
  colors: string[];
  imageUrl?: string;
  status: 'AVAILABLE' | 'LOW_STOCK' | 'OUT_OF_STOCK';
  createdAt: Date;
  updatedAt: Date;
}

const ProductSchema: Schema = new Schema(
  {
    name: { type: String, required: true, trim: true },
    sku: { type: String, required: true, unique: true, uppercase: true, trim: true },
    barcode: { type: String, trim: true },
    categoryId: { type: Schema.Types.ObjectId, ref: 'Category' },
    categoryName: { type: String, required: true, default: 'General' },
    description: { type: String, trim: true },
    price: { type: Number, required: true, min: 0 },
    costPrice: { type: Number, default: 0, min: 0 },
    stockQuantity: { type: Number, required: true, default: 0, min: 0 },
    minStockLevel: { type: Number, default: 5, min: 0 },
    sizes: [{ type: String, trim: true }],
    colors: [{ type: String, trim: true }],
    imageUrl: { type: String, trim: true },
    status: {
      type: String,
      enum: ['AVAILABLE', 'LOW_STOCK', 'OUT_OF_STOCK'],
      default: 'AVAILABLE',
    },
  },
  { timestamps: true }
);

// A scanner code must resolve to exactly one product; sparse so products
// without a barcode (undefined) don't collide.
ProductSchema.index({ barcode: 1 }, { unique: true, sparse: true });

// Pre-save middleware to calculate status automatically based on stock
ProductSchema.pre<IProduct>('save', function (next) {
  if (this.stockQuantity <= 0) {
    this.status = 'OUT_OF_STOCK';
  } else if (this.stockQuantity <= this.minStockLevel) {
    this.status = 'LOW_STOCK';
  } else {
    this.status = 'AVAILABLE';
  }
  next();
});

export const ProductModel = mongoose.model<IProduct>('Product', ProductSchema);
