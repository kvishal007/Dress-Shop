import mongoose, { Schema, Document } from 'mongoose';

export interface IInventoryMovement extends Document {
  productId: mongoose.Types.ObjectId;
  type: 'IN' | 'OUT' | 'ADJUSTMENT';
  quantityChange: number;
  reason: string;
  adjustedBy: mongoose.Types.ObjectId;
  createdAt: Date;
  updatedAt: Date;
}

const inventoryMovementSchema = new Schema(
  {
    productId: { type: Schema.Types.ObjectId, ref: 'Product', required: true },
    type: { type: String, enum: ['IN', 'OUT', 'ADJUSTMENT'], required: true },
    quantityChange: { type: Number, required: true }, // can be positive or negative
    reason: { type: String, required: true },
    adjustedBy: { type: Schema.Types.ObjectId, ref: 'User', required: true },
  },
  { timestamps: true }
);

inventoryMovementSchema.index({ productId: 1, createdAt: -1 });

export const InventoryMovementModel = mongoose.model<IInventoryMovement>('InventoryMovement', inventoryMovementSchema);
