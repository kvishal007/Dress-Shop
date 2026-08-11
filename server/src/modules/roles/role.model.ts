import mongoose, { Schema } from 'mongoose';
import { IRole, UserRoleEnum } from './role.interface';

const roleSchema = new Schema<IRole>(
  {
    name: {
      type: String,
      enum: Object.values(UserRoleEnum),
      required: true,
      unique: true,
    },
    description: {
      type: String,
      required: true,
    },
    permissions: [
      {
        type: String,
        required: true,
      },
    ],
    isSystem: {
      type: Boolean,
      default: true,
    },
  },
  {
    timestamps: true,
  }
);

export const Role = mongoose.model<IRole>('Role', roleSchema);
