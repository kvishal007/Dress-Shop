import mongoose, { Schema, Document } from 'mongoose';

export interface IExpense extends Document {
  category: string;
  amount: number;
  date: Date;
  note: string;
  recordedBy: mongoose.Types.ObjectId;
  createdAt: Date;
  updatedAt: Date;
}

const expenseSchema = new Schema<IExpense>(
  {
    category: { type: String, required: true },
    amount: { type: Number, required: true, min: 0 },
    date: { type: Date, required: true },
    note: { type: String, required: true },
    recordedBy: { type: Schema.Types.ObjectId, ref: 'User', required: true },
  },
  { timestamps: true }
);

export const ExpenseModel = mongoose.model<IExpense>('Expense', expenseSchema);
