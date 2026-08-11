import { Document } from 'mongoose';

export enum UserRoleEnum {
  ADMIN = 'ADMIN',
  MANAGER = 'MANAGER',
  CASHIER = 'CASHIER',
  STOCK_STAFF = 'STOCK_STAFF',
  VIEWER = 'VIEWER',
}

export interface IRole extends Document {
  name: UserRoleEnum;
  description: string;
  permissions: string[];
  isSystem: boolean;
  createdAt: Date;
  updatedAt: Date;
}
