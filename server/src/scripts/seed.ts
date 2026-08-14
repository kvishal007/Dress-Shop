import { connectDB } from '../config/db';
import { Role } from '../modules/roles/role.model';
import { User } from '../modules/users/user.model';
import { UserRoleEnum } from '../modules/roles/role.interface';
import { UserStatusEnum } from '../modules/users/user.interface';
import { CategoryModel } from '../modules/products/category.model';
import { ProductModel } from '../modules/products/product.model';
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

  // 3. Categories Seed
  const categoriesData = [
    { name: 'Sarees', description: 'Silk, Cotton, Designer & Festive Sarees' },
    { name: 'Lehengas', description: 'Bridal, Party Wear & Designer Lehengas' },
    { name: 'Kurtis & Sets', description: 'Daily wear, Anarkali & Straight Kurtis' },
    { name: 'Salwar Suits', description: 'Unstitched & Stitched Designer Suits' },
    { name: 'Western Wear', description: 'Dresses, Tops, Gowns & Indo-Western' },
    { name: 'Accessories', description: 'Dupattas, Belts & Matching Jewelry' },
  ];

  for (const catDef of categoriesData) {
    const slug = catDef.name.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/(^-|-$)/g, '');
    await CategoryModel.findOneAndUpdate(
      { slug },
      { ...catDef, slug, isActive: true },
      { upsert: true, new: true }
    );
  }
  console.log('[Seed]: Categories seeded successfully.');

  // 4. Products Seed
  const count = await ProductModel.countDocuments();
  if (count === 0) {
    const sampleProducts = [
      {
        name: 'Royal Kanjeevaram Silk Saree',
        sku: 'SAR-KAN-001',
        barcode: '890123456701',
        categoryName: 'Sarees',
        description: 'Traditional Gold Zari Pure Kanjeevaram Silk Saree with Blouse Piece',
        price: 8999,
        costPrice: 5500,
        stockQuantity: 12,
        minStockLevel: 3,
        sizes: ['Free Size'],
        colors: ['Red', 'Gold', 'Royal Blue'],
        status: 'AVAILABLE',
      },
      {
        name: 'Designer Velvet Bridal Lehenga',
        sku: 'LEH-VEL-002',
        barcode: '890123456702',
        categoryName: 'Lehengas',
        description: 'Heavy Embroidered Maroon Velvet Lehenga Choli with Dupatta',
        price: 18500,
        costPrice: 12000,
        stockQuantity: 5,
        minStockLevel: 2,
        sizes: ['M', 'L', 'XL'],
        colors: ['Maroon', 'Deep Wine'],
        status: 'AVAILABLE',
      },
      {
        name: 'Anarkali Rayon Printed Kurti Set',
        sku: 'KUR-ANA-003',
        barcode: '890123456703',
        categoryName: 'Kurtis & Sets',
        description: 'Floral Print Anarkali Kurti with Pants and Dupatta',
        price: 1899,
        costPrice: 950,
        stockQuantity: 25,
        minStockLevel: 5,
        sizes: ['S', 'M', 'L', 'XL', 'XXL'],
        colors: ['Teal Green', 'Mustard Yellow', 'Pink'],
        status: 'AVAILABLE',
      },
      {
        name: 'Chanderi Silk Unstitched Suit Material',
        sku: 'SUT-CHA-004',
        barcode: '890123456704',
        categoryName: 'Salwar Suits',
        description: '3 Piece Chanderi Silk Suit with Zari Work Dupatta',
        price: 2499,
        costPrice: 1400,
        stockQuantity: 2,
        minStockLevel: 5,
        sizes: ['Unstitched'],
        colors: ['Peach', 'Mint Green'],
        status: 'LOW_STOCK',
      },
    ];

    for (const prod of sampleProducts) {
      await ProductModel.create(prod);
    }
    console.log('[Seed]: Sample Products seeded successfully.');
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
