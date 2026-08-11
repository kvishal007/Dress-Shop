import { Document, Types } from 'mongoose';
import { UserRoleEnum } from '../roles/role.interface';

export enum UserStatusEnum {
  ACTIVE = 'ACTIVE',
  INACTIVE = 'INACTIVE',
  SUSPENDED = 'SUSPENDED',
}

export interface IUser extends Document {
  name: string;
  email: string;
  phone?: string;
  password: string;
  role: UserRoleEnum;
  roleId?: Types.ObjectId;
  status: UserStatusEnum;
  shopId?: string;
  lastLogin?: Date;
  createdAt: Date;
  updatedAt: Date;
}
