import mongoose, { Schema } from 'mongoose';
import { IUser, UserStatusEnum } from './user.interface';
import { UserRoleEnum } from '../roles/role.interface';

const userSchema = new Schema<IUser>(
  {
    name: {
      type: String,
      required: true,
      trim: true,
    },
    email: {
      type: String,
      required: true,
      unique: true,
      lowercase: true,
      trim: true,
      index: true,
    },
    phone: {
      type: String,
      trim: true,
    },
    password: {
      type: String,
      required: true,
      select: false, // Don't return password by default
    },
    role: {
      type: String,
      enum: Object.values(UserRoleEnum),
      default: UserRoleEnum.CASHIER,
      required: true,
    },
    roleId: {
      type: Schema.Types.ObjectId,
      ref: 'Role',
    },
    status: {
      type: String,
      enum: Object.values(UserStatusEnum),
      default: UserStatusEnum.ACTIVE,
    },
    shopId: {
      type: String,
      default: 'main_shop',
    },
    lastLogin: {
      type: Date,
    },
  },
  {
    timestamps: true,
  }
);

// Indexes
userSchema.index({ email: 1, status: 1 });

export const User = mongoose.model<IUser>('User', userSchema);
