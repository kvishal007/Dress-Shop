import { connectDB } from '../config/db';
import { Role } from '../modules/roles/role.model';
import { User } from '../modules/users/user.model';
import { UserRoleEnum } from '../modules/roles/role.interface';
import { UserStatusEnum } from '../modules/users/user.interface';
import { hashPassword } from '../utils/password';

export const seedDatabase = async () => {
  console.log('[Seed]: Starting database initialization and seeding...');
  await connectDB();

  // 1. Roles Seed
  const rolesData = [
    {
      name: UserRoleEnum.ADMIN,
      description: 'Super Administrator with full permissions across all modules',
      permissions: ['*'],
      isSystem: true,
    },
    {
      name: UserRoleEnum.MANAGER,
      description: 'Shop Manager managing products, inventory, purchases, sales, and reports',
      permissions: [
        'products:*',
        'inventory:*',
        'purchases:*',
        'sales:*',
        'customers:*',
        'suppliers:*',
        'reports:*',
      ],
      isSystem: true,
    },
    {
      name: UserRoleEnum.CASHIER,
      description: 'Front-desk POS billing operator',
      permissions: [
        'pos:sale',
        'customers:read',
        'customers:create',
        'products:read',
        'payments:create',
        'invoices:read',
      ],
      isSystem: true,
    },
    {
      name: UserRoleEnum.STOCK_STAFF,
      description: 'Warehouse & stock room staff',
      permissions: ['inventory:*', 'purchases:read', 'purchases:create', 'products:read'],
      isSystem: true,
    },
    {
      name: UserRoleEnum.VIEWER,
      description: 'Read-only financial & analytics reporting account',
      permissions: ['reports:read', 'sales:read', 'expenses:read'],
      isSystem: true,
    },
  ];

  for (const roleDef of rolesData) {
    await Role.findOneAndUpdate({ name: roleDef.name }, roleDef, {
      upsert: true,
      new: true,
    });
  }
  console.log('[Seed]: System roles seeded successfully.');

  // 2. Users Seed
  const adminRole = await Role.findOne({ name: UserRoleEnum.ADMIN });
  const cashierRole = await Role.findOne({ name: UserRoleEnum.CASHIER });
  const managerRole = await Role.findOne({ name: UserRoleEnum.MANAGER });

  const adminPasswordHash = await hashPassword('Admin@123456');
  const cashierPasswordHash = await hashPassword('Cashier@123456');
  const managerPasswordHash = await hashPassword('Manager@123456');

  const usersData = [
    {
      name: 'Super Admin',
      email: 'admin@smartdress.com',
      phone: '+91 9876543210',
      password: adminPasswordHash,
      role: UserRoleEnum.ADMIN,
      roleId: adminRole?._id,
      status: UserStatusEnum.ACTIVE,
      shopId: 'main_shop',
    },
    {
      name: 'Main Cashier',
      email: 'cashier@smartdress.com',
      phone: '+91 9876543211',
      password: cashierPasswordHash,
      role: UserRoleEnum.CASHIER,
      roleId: cashierRole?._id,
      status: UserStatusEnum.ACTIVE,
      shopId: 'main_shop',
    },
    {
      name: 'Store Manager',
      email: 'manager@smartdress.com',
      phone: '+91 9876543212',
      password: managerPasswordHash,
      role: UserRoleEnum.MANAGER,
      roleId: managerRole?._id,
      status: UserStatusEnum.ACTIVE,
      shopId: 'main_shop',
    },
  ];

  for (const userDef of usersData) {
    const existing = await User.findOne({ email: userDef.email });
    if (!existing) {
      await User.create(userDef);
      console.log(`[Seed]: Created default user: ${userDef.email}`);
    } else {
      console.log(`[Seed]: User already exists: ${userDef.email}`);
    }
  }

  console.log('[Seed]: Database seeding completed successfully.');
};

if (process.argv[1]?.endsWith('seed.ts')) {
  seedDatabase()
    .then(() => process.exit(0))
    .catch((err) => {
      console.error('[Seed Error]:', err);
      process.exit(1);
    });
}
